from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import select, or_
from sqlalchemy.ext.asyncio import AsyncSession
from ..core.database import get_db
from ..core.dependencies import get_optional_user
from ..models.product import Product
from ..models.user import User
from ..models.scan_history import ScanHistory
from ..app.services.scoring import compute_score, load_active_weights
from ..app.services.alerts import compute_warnings

router = APIRouter(prefix="/products", tags=["products"])


@router.get("/barcode/{barcode}")
async def get_by_barcode(
    barcode: str,
    db: AsyncSession = Depends(get_db),
    current_user: User | None = Depends(get_optional_user),
):
    result = await db.execute(select(Product).where(Product.barcode == barcode))
    product = result.scalar_one_or_none()
    if not product:
        raise HTTPException(status_code=404, detail="Produit introuvable")

    if current_user:
        db.add(ScanHistory(user_id=current_user.id, product_id=product.id, scan_type="barcode"))
        await db.commit()

    return await _serialize(product, db, current_user)


@router.get("/search")
async def search_products(
    q: str = Query(..., min_length=2),
    limit: int = Query(20, le=50),
    db: AsyncSession = Depends(get_db),
    current: User | None = Depends(get_optional_user),
):
    pattern = f"%{q}%"
    stmt = (
        select(Product)
        .where(or_(Product.name.ilike(pattern), Product.brand.ilike(pattern)))
        .limit(limit)
    )
    result = await db.execute(stmt)
    return [await _serialize(p, db, current) for p in result.scalars().all()]


@router.get("/{product_id}")
async def get_by_id(
    product_id: UUID,
    db: AsyncSession = Depends(get_db),
    current: User | None = Depends(get_optional_user),
):
    product = await db.get(Product, product_id)
    if not product:
        raise HTTPException(status_code=404, detail="Produit introuvable")
    return await _serialize(product, db, current)

@router.get("/{product_id}/alternatives")
async def alternatives(
    product_id: UUID,
    limit: int = 3,
    db: AsyncSession = Depends(get_db),
):
    product = await db.get(Product, product_id)
    if not product:
        raise HTTPException(status_code=404, detail="Produit introuvable")

    weights = await load_active_weights(db)
    stmt = select(Product).where(Product.id != product_id)
    if product.category:
        stmt = stmt.where(Product.category == product.category)
    candidates = (await db.execute(stmt.limit(50))).scalars().all()
    current_score = compute_score(
        product.nutrition_facts or [],
        product.ingredients or [],
        product.processing_level,
        weights=weights,
    ).total
    scored = []
    for c in candidates:
        s = compute_score(c.nutrition_facts or [], c.ingredients or [], c.processing_level, weights=weights)
        if s.total > current_score:
            scored.append((c, s.total))

    scored.sort(key=lambda x: x[1], reverse=True)
    top = scored[:limit]

    return [await _serialize(c, db) for c, _ in top]

@router.get("/{product_id}/score")
async def get_score(product_id: UUID, db: AsyncSession = Depends(get_db)):
    product = await db.get(Product, product_id)
    if not product:
        raise HTTPException(status_code=404, detail="Produit introuvable")
    weights = await load_active_weights(db)
    score = compute_score(
        nutrition_facts=product.nutrition_facts or {},
        ingredients=product.ingredients or [],
        processing_level=product.processing_level,
        weights=weights,
    )
    return {**score.to_dict(), "weights_used": weights}

@router.get("/compare")
async def compare(
    ids: str,
    db: AsyncSession = Depends(get_db),
):
    """Retourne les produits correspondant aux IDs (séparés par virgule)."""
    id_list = [i.strip() for i in ids.split(",") if i.strip()]
    if len(id_list) > 2:
        raise HTTPException(status_code=400, detail="Maximum 2 produits")
    products = []
    for pid in id_list:
        try:
            p = await db.get(Product, UUID(pid))
        except ValueError:
            continue
        if p:
            products.append(await _serialize(p, db))
    return products

async def _serialize(p: Product, db: AsyncSession, user: User | None = None) -> dict:
    weights = await load_active_weights(db)
    score = compute_score(
        nutrition_facts=p.nutrition_facts or {},
        ingredients=p.ingredients or [],
        processing_level=p.processing_level,
        weights=weights,
    )
    warnings = compute_warnings(p.ingredients or [], user.preferences if user else {})
    return {
        "id": str(p.id),
        "barcode": p.barcode,
        "name": p.name,
        "brand": p.brand,
        "category": p.category,
        "image_url": p.image_url,
        "ingredients": p.ingredients,
        "nutrition_facts": p.nutrition_facts,
        "processing_level": p.processing_level,
        "score": score.to_dict(),
        "score": score.to_dict(),
        "warnings": warnings,
    }