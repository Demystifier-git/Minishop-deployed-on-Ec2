from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import Response

from prometheus_client import Counter, Histogram, Gauge, generate_latest, CONTENT_TYPE_LATEST
import time

from app.routes import products, users

app = FastAPI(title="MiniShop API")


# =========================
# CORS FIX (IMPORTANT)
# =========================
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "https://app.delightdavid.online"
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# =========================
# PROMETHEUS METRICS
# =========================
REQUEST_COUNT = Counter(
    "http_requests_total",
    "Total HTTP Requests",
    ["method", "endpoint", "http_status"]
)

REQUEST_LATENCY = Histogram(
    "http_request_duration_seconds",
    "HTTP request latency",
    ["endpoint"]
)

IN_PROGRESS = Gauge(
    "in_progress_requests",
    "Number of in-progress requests"
)


# =========================
# MIDDLEWARE
# =========================
@app.middleware("http")
async def metrics_middleware(request: Request, call_next):
    IN_PROGRESS.inc()
    start_time = time.time()

    try:
        response = await call_next(request)
    finally:
        IN_PROGRESS.dec()

    latency = time.time() - start_time

    REQUEST_COUNT.labels(
        method=request.method,
        endpoint=request.url.path,
        http_status=response.status_code
    ).inc()

    REQUEST_LATENCY.labels(
        endpoint=request.url.path
    ).observe(latency)

    return response


# =========================
# ROUTES
# =========================
@app.get("/health")
def health_check():
    return {"status": "ok"}


@app.get("/metrics")
def metrics():
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)


app.include_router(products.router, prefix="/products", tags=["Products"])
app.include_router(users.router, prefix="/users", tags=["Users"])


# =========================
# CI TESTS
# =========================
def run_basic_tests():
    from fastapi.testclient import TestClient

    client = TestClient(app)

    response = client.get("/health")
    assert response.status_code == 200

    response = client.get("/metrics")
    assert response.status_code == 200
    assert "http_requests_total" in response.text

    print("All basic tests passed!")


if __name__ == "__main__":
    run_basic_tests()