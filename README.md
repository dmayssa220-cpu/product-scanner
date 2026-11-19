# Product Scanner

Application mobile de reconnaissance et d'évaluation des produits (Flutter + FastAPI + PostgreSQL).

## Architecture
┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│ Flutter │─────▶│ FastAPI │─────▶│ PostgreSQL │
│ (iOS/Android│ │ (Docker) │ │ (Docker) │
└──────────────┘ └──────┬───────┘ └──────────────┘
│
▼
┌──────────────┐
│ API Vision │
│ (Gemini) │
└──────────────┘

## Démarrage

```bash
cp .env.example .env       # configurer VISION_API_KEY et JWT_SECRET
docker compose up --build -d

API + Swagger : http://localhost:8000/docs

Health check : curl http://localhost:8000/api/v1/health

