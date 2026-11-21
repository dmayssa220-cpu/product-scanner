from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select, delete
from sqlalchemy.ext.asyncio import AsyncSession
from ..core.database import get_db
from ..core.dependencies import get_current_user
from ..models.favorite import Favorite
from ..models.product import Product
from ..models.user import User
from .products import _serialize

router = APIRouter(prefix="/favorites", tags=["favorites"])


@router.get("")
async def list_favorites(
    db: AsyncSession = Depends(get_db),
    current: User = Depends(get_current_user),
):
    stmt = (
        select(Product)
        .join(Favorite, Favorite.product_id == Product.id)
        .where(Favorite.user_id == current.id)
        .order_by(Favorite.created_at.desc())
    )
    products = (await db.execute(stmt)).scalars().all()
    return [await _serialize(p, db) for p in products]


@router.post("/{product_id}", status_code=201)
async def add_favorite(
    product_id: UUID,
    db: AsyncSession = Depends(get_db),
    current: User = Depends(get_current_user),
):
    product = await db.get(Product, product_id)
    if not product:
        raise HTTPException(status_code=404, detail="Produit introuvable")
    existing = await db.execute(
        select(Favorite).where(Favorite.user_id == current.id, Favorite.product_id == product_id)
    )
    if existing.scalar_one_or_none():
        return {"status": "already_favorite"}
    db.add(Favorite(user_id=current.id, product_id=product_id))
    await db.commit()
    return {"status": "added"}


@router.delete("/{product_id}", status_code=204)
async def remove_favorite(
    product_id: UUID,
    db: AsyncSession = Depends(get_db),
    current: User = Depends(get_current_user),
):
    await db.execute(
        delete(Favorite).where(Favorite.user_id == current.id, Favorite.product_id == product_id)
    )
    await db.commit()


@router.get("/{product_id}/status")
async def favorite_status(
    product_id: UUID,
    db: AsyncSession = Depends(get_db),
    current: User = Depends(get_current_user),
):
    result = await db.execute(
        select(Favorite).where(Favorite.user_id == current.id, Favorite.product_id == product_id)
    )
    return {"is_favorite": result.scalar_one_or_none() is not None}