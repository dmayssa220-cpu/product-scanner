from uuid import UUID
from fastapi import APIRouter, Depends, Query
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from ..core.database import get_db
from ..core.dependencies import get_current_user
from ..models.user import User
from ..models.scan_history import ScanHistory
from ..models.product import Product

router = APIRouter(prefix="/history", tags=["history"])


@router.get("")
async def list_history(
    limit: int = Query(50, le=200),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    stmt = (
        select(ScanHistory, Product)
        .join(Product, Product.id == ScanHistory.product_id, isouter=True)
        .where(ScanHistory.user_id == current_user.id)
        .order_by(ScanHistory.scanned_at.desc())
        .limit(limit)
    )
    result = await db.execute(stmt)
    items = []
    for entry, product in result.all():
        items.append({
            "id": str(entry.id),
            "scan_type": entry.scan_type,
            "scanned_at": entry.scanned_at.isoformat(),
            "product": {
                "id": str(product.id),
                "name": product.name,
                "brand": product.brand,
            } if product else None,
        })
    return items


@router.delete("/{entry_id}", status_code=204)
async def delete_entry(
    entry_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    entry = await db.get(ScanHistory, entry_id)
    if entry and entry.user_id == current_user.id:
        await db.delete(entry)
        await db.commit()