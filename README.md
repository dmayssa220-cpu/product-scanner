# Product Scanner

Application mobile de reconnaissance et d'évaluation des produits.

## Démarrage rapide

```bash
cp .env.example .env
docker compose up --build -d
```

Le démarrage lance PostgreSQL et l'API. Le stockage objet MinIO est désactivé pour l'instant, car l'image Community n'est plus publiée sur Docker Hub.