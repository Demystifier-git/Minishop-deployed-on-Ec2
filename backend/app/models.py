from pydantic import BaseModel, Field

class Product(BaseModel):
    name: str = Field(..., min_length=1)
    price: float = Field(..., gt=0)
    description: str | None = None


class User(BaseModel):
    username: str = Field(..., min_length=3)
    password: str = Field(..., min_length=6)