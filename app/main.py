from fastapi import FastAPI

app = FastAPI(title="Cloud Native Test Platform")

@app.get("/")
def root():
    return {
        "message": "Cloud Native Test Platform is running"
    }

@app.get("/health")
def health():
    return {
        "status": "healthy"
    }