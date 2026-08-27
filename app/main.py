import os
from fastapi import FastAPI

APP_ENV = os.getenv("APP_ENV", "development")

app = FastAPI(title="Cloud Native Test Platform")

@app.get("/")
def root():
    return {
        "message": "Cloud Native Test Platform v2 is running",
        "environment": APP_ENV
    }

@app.get("/health")
def health():
    return {
        "status": "healthy"
    }