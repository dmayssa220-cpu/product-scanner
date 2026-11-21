"""Détection d'alertes selon les préférences utilisateur."""
ALLERGEN_KEYWORDS = {
    "gluten": ["gluten", "blé", "froment", "orge", "seigle", "avoine"],
    "lactose": ["lait", "lactose", "crème", "beurre", "fromage", "yaourt"],
    "arachides": ["arachide", "cacahuète"],
    "fruits_a_coque": ["noisette", "amande", "noix", "pistache", "noix de cajou"],
    "soja": ["soja", "lécithine de soja"],
    "oeufs": ["œuf", "oeuf", "blanc d'œuf", "jaune d'œuf"],
}

DIET_KEYWORDS = {
    "halal": {"forbidden": ["porc", "jambon", "lard", "gélatine de porc", "alcool"]},
    "vegetarien": {"forbidden": ["viande", "poisson", "poulet", "bœuf", "porc", "gélatine"]},
    "vegan": {"forbidden": ["viande", "poisson", "lait", "œuf", "miel", "gélatine", "fromage"]},
}


def compute_warnings(ingredients: list, preferences: dict) -> list[dict]:
    """Retourne une liste d'alertes : [{'type': 'allergen', 'key': 'gluten', 'message': '...'}]"""
    if not preferences or not ingredients:
        return []

    # Normaliser les ingrédients en texte minuscule
    text = " ".join(
        i.get("name", "") if isinstance(i, dict) else str(i)
        for i in ingredients
    ).lower()

    warnings = []
    for allergen in preferences.get("allergens", []):
        keywords = ALLERGEN_KEYWORDS.get(allergen, [])
        if any(kw in text for kw in keywords):
            warnings.append({
                "type": "allergen",
                "key": allergen,
                "message": f"Contient un allergène : {allergen}",
            })

    for diet in preferences.get("diets", []):
        forbidden = DIET_KEYWORDS.get(diet, {}).get("forbidden", [])
        if any(kw in text for kw in forbidden):
            warnings.append({
                "type": "diet",
                "key": diet,
                "message": f"Non compatible avec le régime : {diet}",
            })
    return warnings