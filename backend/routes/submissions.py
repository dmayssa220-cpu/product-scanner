from uuid import UUID
from datetime import datetime, timezone
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from ..core.database import get_db
from ..core.dependencies import get_current_user
from ..models.submission import ProductSubmission
from ..models.product import Product
from ..models.user import User

router = APIRouter(prefix="/submissions", tags=["submissions"])


class SubmissionIn(BaseModel):
    barcode: str | None = None
    name: str = Field(min_length=2, max_length=255)
    brand: str | None = None
    category: str | None = None
    ingredients: list = []
    nutrition_facts: dict = {}
    processing_level: int | None = Field(default=None, ge=1, le=4)


@router.post("", status_code=201)
async def submit(
    payload: SubmissionIn,
    db: AsyncSession = Depends(get_db),
    current: User = Depends(get_current_user),
):
  
    if payload.barcode:
        exists = await db.execute(select(Product).where(Product.barcode == payload.barcode))
        if exists.scalar_one_or_none():
            raise HTTPException(status_code=409, detail="Ce code-barres existe déjà en base")

    submission = ProductSubmission(
        user_id=current.id,
        barcode=payload.barcode,
        payload=payload.model_dump(exclude={"barcode"}),
        status="pending",
    )
    db.add(submission)
    await db.commit()
    await db.refresh(submission)
    return {"id": str(submission.id), "status": submission.status}


@router.get("/mine")
async def my_submissions(
    db: AsyncSession = Depends(get_db),
    current: User = Depends(get_current_user),
):
    stmt = (
        select(ProductSubmission)
        .where(ProductSubmission.user_id == current.id)
        .order_by(ProductSubmission.created_at.desc())
    )
    subs = (await db.execute(stmt)).scalars().all()
    return [
        {
            "id": str(s.id),
            "barcode": s.barcode,
            "name": s.payload.get("name"),
            "status": s.status,
            "rejection_reason": s.rejection_reason,
            "created_at": s.created_at.isoformat(),
        }
        for s in subs
    ]


def _require_admin(user: User) -> None:
    if not user.is_admin:
        raise HTTPException(status_code=403, detail="Accès administrateur requis")


@router.get("/admin/pending")
async def list_pending(
    db: AsyncSession = Depends(get_db),
    current: User = Depends(get_current_user),
):
    _require_admin(current)
    stmt = (
        select(ProductSubmission)
        .where(ProductSubmission.status == "pending")
        .order_by(ProductSubmission.created_at.asc())
    )
    subs = (await db.execute(stmt)).scalars().all()
    return [
        {
            "id": str(s.id),
            "user_id": str(s.user_id),
            "barcode": s.barcode,
            "payload": s.payload,
            "created_at": s.created_at.isoformat(),
        }
        for s in subs
    ]


@router.post("/admin/{submission_id}/approve", status_code=201)
async def approve(
    submission_id: UUID,
    db: AsyncSession = Depends(get_db),
    current: User = Depends(get_current_user),
):
    _require_admin(current)
    sub = await db.get(ProductSubmission, submission_id)
    if not sub or sub.status != "pending":
        raise HTTPException(status_code=404, detail="Soumission introuvable ou déjà traitée")

    product = Product(
        barcode=sub.barcode,
        name=sub.payload["name"],
        brand=sub.payload.get("brand"),
        category=sub.payload.get("category"),
        ingredients=sub.payload.get("ingredients", []),
        nutrition_facts=sub.payload.get("nutrition_facts", {}),
        processing_level=sub.payload.get("processing_level"),
    )
    db.add(product)
    sub.status = "approved"
    sub.reviewed_at = datetime.now(timezone.utc)
    sub.reviewed_by = current.id
    await db.commit()
    await db.refresh(product)
    return {"product_id": str(product.id), "name": product.name}


@router.post("/admin/{submission_id}/reject", status_code=204)
async def reject(
    submission_id: UUID,
    reason: str = "",
    db: AsyncSession = Depends(get_db),
    current: User = Depends(get_current_user),
):
    _require_admin(current)
    sub = await db.get(ProductSubmission, submission_id)
    if not sub or sub.status != "pending":
        raise HTTPException(status_code=404, detail="Soumission introuvable ou déjà traitée")
    sub.status = "rejected"
    sub.rejection_reason = reason
    sub.reviewed_at = datetime.now(timezone.utc)
    sub.reviewed_by = current.id
    await db.commit()