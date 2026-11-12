"""Moteur de scoring simplifié pour la Phase M2.
Le calcul complet sera affiné en Phase M3.
"""
from dataclasses import dataclass

DEFAULT_WEIGHTS = {"nutrition": 0.40, "additives": 0.35, "processing": 0.25}


@dataclass
class ScoreResult:
    total: float
    nutrition: float
    additives: float
    processing: float


def compute_score(
    nutrition_facts: dict,
    ingredients: list,
    processing_level: int | None,
) -> ScoreResult:
    nutrition = _score_nutrition(nutrition_facts)
    additives = _score_additives(ingredients)
    processing = _score_processing(processing_level)

    total = (
        nutrition * DEFAULT_WEIGHTS["nutrition"]
        + additives * DEFAULT_WEIGHTS["additives"]
        + processing * DEFAULT_WEIGHTS["processing"]
    )
    return ScoreResult(
        total=round(total, 2),
        nutrition=round(nutrition, 2),
        additives=round(additives, 2),
        processing=round(processing, 2),
    )


def _score_nutrition(facts: dict) -> float:
    """Score basé sur les nutriments. Plus le sucre/sel/graisse est élevé, plus le score baisse."""
    if not facts:
        return 50.0
    sugar = facts.get("sugar", 0) or 0
    fat = facts.get("fat", 0) or 0
    salt = facts.get("salt", 0) or 0
    # Pénalités simples (échelle 0-100)
    penalty = min(sugar * 1.2, 40) + min(fat * 0.8, 20) + min(salt * 200, 20)
    return max(0.0, 100.0 - penalty)


def _score_additives(ingredients: list) -> float:
    """Score basé sur les additifs. V1 : pénalité forfaitaire par additif détecté."""
    if not ingredients:
        return 100.0
    risky = sum(1 for i in ingredients if isinstance(i, dict) and i.get("risk") == "high")
    return max(0.0, 100.0 - risky * 20)


def _score_processing(level: int | None) -> float:
    """Classification NOVA : 1 = non transformé (100), 4 = ultra-transformé (25)."""
    if level is None:
        return 50.0
    return {1: 100.0, 2: 75.0, 3: 50.0, 4: 25.0}.get(level, 50.0)