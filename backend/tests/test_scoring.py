import pytest
from backend.app.services.scoring import compute_score, _score_nutrition, _score_processing


def test_score_total_dans_intervalle():
    result = compute_score(
        nutrition_facts={"sugar": 10, "fat": 5, "salt": 0.1},
        ingredients=[],
        processing_level=2,
    )
    assert 0 <= result.total <= 100


def test_nutrition_penalise_sucre_eleve():
    faible = _score_nutrition({"sugar": 2, "fat": 1, "salt": 0.01})
    eleve = _score_nutrition({"sugar": 50, "fat": 30, "salt": 2})
    assert faible > eleve


def test_nutrition_facts_vides_retourne_neutre():
    assert _score_nutrition({}) == 50.0


def test_processing_nova():
    assert _score_processing(1) == 100.0
    assert _score_processing(4) == 25.0
    assert _score_processing(None) == 50.0


def test_additifs_risque_eleve_penalise():
    result = compute_score(
        nutrition_facts={},
        ingredients=[{"risk": "high"}, {"risk": "high"}],
        processing_level=3,
    )
    assert result.additives < 100


@pytest.mark.parametrize("weights", [
    {"nutrition": 1.0, "additives": 0.0, "processing": 0.0},
    {"nutrition": 0.0, "additives": 1.0, "processing": 0.0},
    {"nutrition": 0.0, "additives": 0.0, "processing": 1.0},
])
def test_poids_personnalises(weights):
    result = compute_score({}, [], 2, weights=weights)
    assert 0 <= result.total <= 100