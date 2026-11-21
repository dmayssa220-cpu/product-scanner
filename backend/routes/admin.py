from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field
from sqlalchemy.ext.asyncio import AsyncSession
from ..core.database import get_db
from ..core.dependencies import get_current_user
from ..models.product import Product
from ..models.user import User


router = APIRouter(prefix="/admin", tags=["admin"])


class ProductIn(BaseModel):
    barcode: str | None = None
    name: str = Field(min_length=2, max_length=255)
    brand: str | None = None
    category: str | None = None
    ingredients: list = []
    nutrition_facts: dict = {}
    processing_level: int | None = Field(default=None, ge=1, le=4)


def _require_admin(user: User) -> None:
    if not user.is_admin:
        raise HTTPException(status_code=403, detail="Accès administrateur requis")


@router.post("/products", status_code=201)
async def create_product(
    payload: ProductIn,
    db: AsyncSession = Depends(get_db),
    current: User = Depends(get_current_user),
):
    _require_admin(current)
    product = Product(**payload.model_dump())
    db.add(product)
    await db.commit()
    await db.refresh(product)
    return {"id": str(product.id), "name": product.name}


@router.delete("/products/{product_id}", status_code=204)
async def delete_product(
    product_id: UUID,
    db: AsyncSession = Depends(get_db),
    current: User = Depends(get_current_user),
):
    _require_admin(current)
    product = await db.get(Product, product_id)
    if product:
        await db.delete(product)
        await db.commit()