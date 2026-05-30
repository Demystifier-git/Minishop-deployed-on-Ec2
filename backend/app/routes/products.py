from fastapi import APIRouter
from app.database import get_connection
from app.models import Product

router = APIRouter()

@router.get("/")
def get_products():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("SELECT * FROM products")
    rows = cursor.fetchall()

    conn.close()
    return rows


@router.post("/")
def create_product(product: Product):
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute(
        "INSERT INTO products (name, price, description) VALUES (%s, %s, %s)",
        (product.name, product.price, product.description)
    )

    conn.commit()
    conn.close()

    return {"message": "Product added"}