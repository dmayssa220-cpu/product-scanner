from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    database_url: str = "postgresql+asyncpg://scanner:scanner_dev@db:5432/product_scanner"
    jwt_secret: str = "dev-secret"
    jwt_algorithm: str = "HS256"
    jwt_expire_minutes: int = 60
    vision_api_key: str = ""
    api_v1_prefix: str = "/api/v1"

    class Config:
        env_file = ".env"

settings = Settings()