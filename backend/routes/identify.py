from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
from sqlalchemy import select, or_
from sqlalchemy.ext.asyncio import AsyncSession
from ..core.database import get_db
from ..core.dependencies import get_optional_user
from ..models.product import Product
from ..models.user import User
from ..models.scan_history import ScanHistory
from ..app.services.vision import identify_product, VisionError

router = APIRouter(prefix="/identify", tags=["identify"])

MAX_IMAGE_BYTES = 5 * 1024 * 1024  # 5 Mo


@router.post("")
async def identify(
    file: UploadFile = File(...),
    db: AsyncSession = Depends(get_db),
    current_user: User | None = Depends(get_optional_user),
):
    if file.content_type not in {"image/jpeg", "image/png", "image/webp"}:
        raise HTTPException(status_code=415, detail="Format d'image non supporté")
    image_bytes = await file.read()
    if len(image_bytes) > MAX_IMAGE_BYTES:
        raise HTTPException(status_code=413, detail="Image trop volumineuse (max 5 Mo)")

    try:
        result = await identify_product(image_bytes)
    except VisionError as e:
        raise HTTPException(status_code=502, detail=str(e))

    if not result.get("name") or result.get("confidence", 0) < 0.5:
        return {"matched": False, "vision": result, "product": None}

    # Recherche par similarité de nom ou marque
    pattern = f"%{result['name']}%"
    brand_pattern = f"%{result.get('brand') or ''}%"
    stmt = (
        select(Product)
        .where(or_(Product.name.ilike(pattern), Product.brand.ilike(brand_pattern)))
        .limit(1)
    )
    product = (await db.execute(stmt)).scalar_one_or_none()

    if product and current_user:
        db.add(ScanHistory(user_id=current_user.id, product_id=product.id, scan_type="photo"))
        await db.commit()

    return {
        "matched": product is not None,
        "vision": result,
        "product_id": str(product.id) if product else None,
    }