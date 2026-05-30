from fastapi import APIRouter
from app.database import get_connection
from app.models import User

router = APIRouter()

@router.post("/signup")
def signup(user: User):
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute(
        "INSERT INTO users (username, password) VALUES (%s, %s)",
        (user.username, user.password)
    )

    conn.commit()
    conn.close()

    return {"message": "User created"}