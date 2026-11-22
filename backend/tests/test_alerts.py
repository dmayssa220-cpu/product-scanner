from backend.services.alerts import compute_warnings


def test_alerte_gluten_detectee():
    ingredients = [{"name": "farine de blé"}, {"name": "sucre"}]
    warnings = compute_warnings(ingredients, {"allergens": ["gluten"]})
    assert any(w["key"] == "gluten" for w in warnings)


def test_alerte_absente_si_ingredient_absent():
    ingredients = [{"name": "riz"}, {"name": "eau"}]
    warnings = compute_warnings(ingredients, {"allergens": ["gluten"]})
    assert warnings == []


def test_regime_vegetarien_bloque_viande():
    ingredients = [{"name": "poulet"}, {"name": "épices"}]
    warnings = compute_warnings(ingredients, {"diets": ["vegetarien"]})
    assert any(w["key"] == "vegetarien" for w in warnings)