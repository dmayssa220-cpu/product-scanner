"""Moteur de scoring basé sur une configuration persistée en base."""
from dataclasses import dataclass
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from ...models.scoring_config import ScoringConfig

DEFAULT_WEIGHTS = {"nutrition": 0.40, "additives": 0.35, "processing": 0.25}


@dataclass
class ScoreResult:
    total: float
    nutrition: float
    additives: float
    processing: float

    def to_dict(self) -> dict:
        return {
            "total": self.total,
            "nutrition": self.nutrition,
            "additives": self.additives,
            "processing": self.processing,
        }


async def load_active_weights(db: AsyncSession) -> dict[str, float]:
    """Charge la configuration active. Retourne les poids par défaut si absente."""
    result = await db.execute(
        select(ScoringConfig).where(ScoringConfig.is_active.is_(True)).limit(1)
    )
    config = result.scalar_one_or_none()
    return config.weights if config else DEFAULT_WEIGHTS


def compute_score(
    nutrition_facts: dict,
    ingredients: list,
    processing_level: int | None,
    weights: dict[str, float] | None = None,
) -> ScoreResult:
    w = weights or DEFAULT_WEIGHTS
    nutrition = _score_nutrition(nutrition_facts)
    additives = _score_additives(ingredients)
    processing = _score_processing(processing_level)

    total = (
        nutrition * w.get("nutrition", 0.40)
        + additives * w.get("additives", 0.35)
        + processing * w.get("processing", 0.25)
    )
    return ScoreResult(
        total=round(total, 2),
        nutrition=round(nutrition, 2),
        additives=round(additives, 2),
        processing=round(processing, 2),
    )


def _score_nutrition(facts: dict) -> float:
    if not facts:
        return 50.0
    sugar = facts.get("sugar", 0) or 0
    fat = facts.get("fat", 0) or 0
    salt = facts.get("salt", 0) or 0
    penalty = min(sugar * 1.2, 40) + min(fat * 0.8, 20) + min(salt * 200, 20)
    return max(0.0, 100.0 - penalty)


def _score_additives(ingredients: list) -> float:
    if not ingredients:
        return 100.0
    risky = sum(1 for i in ingredients if isinstance(i, dict) and i.get("risk") == "high")
    return max(0.0, 100.0 - risky * 20)


def _score_processing(level: int | None) -> float:
    if level is None:
        return 50.0
    return {1: 100.0, 2: 75.0, 3: 50.0, 4: 25.0}.get(level, 50.0)