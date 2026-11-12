from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import select, or_, func
from sqlalchemy.ext.asyncio import AsyncSession
from ..core.database import get_db
from ..models.product import Product

router = APIRouter(prefix="/products", tags=["products"])

@router.get("/barcode/{barcode}")
async def get_by_barcode(barcode: str, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Product).where(Product.barcode == barcode))
    product = result.scalar_one_or_none()
    if not product:
        raise HTTPException(status_code=404, detail="Produit introuvable")
    return _serialize(product)

@router.get("/search")
async def search_products(
    q: str = Query(..., min_length=2, description="Terme de recherche"),
    limit: int = Query(20, le=50),
    db: AsyncSession = Depends(get_db),
):
    """Recherche par nom ou marque (insensible à la casse)."""
    pattern = f"%{q}%"
    stmt = (
        select(Product)
        .where(or_(Product.name.ilike(pattern), Product.brand.ilike(pattern)))
        .limit(limit)
    )
    result = await db.execute(stmt)
    products = result.scalars().all()
    return [_serialize(p) for p in products]

@router.get("/{product_id}")
async def get_by_id(product_id: UUID, db: AsyncSession = Depends(get_db)):
    product = await db.get(Product, product_id)
    if not product:
        raise HTTPException(status_code=404, detail="Produit introuvable")
    return _serialize(product)

def _serialize(p: Product) -> dict:
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
    }