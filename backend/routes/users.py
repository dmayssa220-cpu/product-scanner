from fastapi import APIRouter, Depends
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession
from ..core.database import get_db
from ..core.dependencies import get_current_user
from ..models.user import User

router = APIRouter(prefix="/users", tags=["users"])


class PreferencesIn(BaseModel):
    allergens: list[str] = []
    diets: list[str] = []


@router.get("/me/preferences")
async def get_prefs(current: User = Depends(get_current_user)):
    return current.preferences or {"allergens": [], "diets": []}


@router.put("/me/preferences")
async def set_prefs(
    payload: PreferencesIn,
    db: AsyncSession = Depends(get_db),
    current: User = Depends(get_current_user),
):
    current.preferences = payload.model_dump()
    await db.commit()
    return current.preferences