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

    return await _serialize(product, db)


@router.get("/search")
async def search_products(
    q: str = Query(..., min_length=2),
    limit: int = Query(20, le=50),
    db: AsyncSession = Depends(get_db),
):
    pattern = f"%{q}%"
    stmt = (
        select(Product)
        .where(or_(Product.name.ilike(pattern), Product.brand.ilike(pattern)))
        .limit(limit)
    )
    result = await db.execute(stmt)
    return [await _serialize(p, db) for p in result.scalars().all()]


@router.get("/{product_id}")
async def get_by_id(product_id: UUID, db: AsyncSession = Depends(get_db)):
    product = await db.get(Product, product_id)
    if not product:
        raise HTTPException(status_code=404, detail="Produit introuvable")
    return await _serialize(product, db)


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


async def _serialize(p: Product, db: AsyncSession) -> dict:
    weights = await load_active_weights(db)
    score = compute_score(
        nutrition_facts=p.nutrition_facts or {},
        ingredients=p.ingredients or [],
        processing_level=p.processing_level,
        weights=weights,
    )
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
    }