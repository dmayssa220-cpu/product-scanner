"""Service de reconnaissance d'image.
En V1, on utilise une API Vision tierce (Gemini ou Claude) via HTTP.
Si la clé n'est pas configurée, on retourne une erreur explicite.
"""
import base64
import httpx
from ...core.config import settings

VISION_PROMPT = (
    "Tu es un assistant qui identifie des produits de consommation à partir d'une photo. "
    "Réponds UNIQUEMENT en JSON avec les clés suivantes : "
    '{"name": "nom du produit", "brand": "marque", "category": "catégorie", '
    '"confidence": 0.0-1.0}. '
    "Si tu ne reconnais pas le produit, retourne {\"name\": null, \"confidence\": 0}."
)


async def identify_product(image_bytes: bytes) -> dict:
    """Retourne {'name', 'brand', 'category', 'confidence'} ou lève une exception."""
    if not settings.vision_api_key:
        raise VisionError("VISION_API_KEY non configurée")

    b64 = base64.b64encode(image_bytes).decode()
    payload = {
        "contents": [{
            "parts": [
                {"text": VISION_PROMPT},
                {"inline_data": {"mime_type": "image/jpeg", "data": b64}},
            ]
        }]
    }
    url = (
        "https://generativelanguage.googleapis.com/v1beta/models/"
        f"gemini-3.5-flash-lite:generateContent?key={settings.vision_api_key}"
    )
    async with httpx.AsyncClient(timeout=30.0) as client:
        resp = await client.post(url, json=payload)
    if resp.status_code != 200:
        raise VisionError(f"API Vision a retourné {resp.status_code}")

    try:
        data = resp.json()
        text = data["candidates"][0]["content"]["parts"][0]["text"]
        # Nettoyage des éventuels backticks markdown
        text = text.strip().strip("```json").strip("```").strip()
        import json
        return json.loads(text)
    except (KeyError, IndexError, ValueError) as e:
        raise VisionError(f"Réponse Vision invalide : {e}")


class VisionError(Exception):
    pass