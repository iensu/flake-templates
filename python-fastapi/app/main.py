from fastapi import FastAPI, HTTPException, Response
from fastapi.responses import StreamingResponse
from fastapi.requests import Request
import os
import io
import logging

API_KEY = os.getenv("API_KEY")

app = FastAPI()
logger = logging.getLogger("uvicorn")

@app.middleware("http")
async def check_api_key(request: Request, call_next):
    """Check if request has the correct X-Api-Key header if API_KEY is set."""
    if API_KEY is not None and request.headers.get("X-Api-Key") != API_KEY:
        return Response(status_code=401)

    response = await call_next(request)
    return response


@app.get("/")
async def alive(request: Request):
    """Stay alive"""
    try:
        return "alive"

    except BaseException as ex:
        logger.error("ERROR type={} message={}".format(type(ex), ex))

        raise HTTPException(status_code=500, detail="Something went wrong")
