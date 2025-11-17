# Imports
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routers import script
from dotenv import load_dotenv

# Load Environment Variables
load_dotenv()

# Initialize FastAPI App
app = FastAPI(title="FlavourFinder Backend API")

# Enable CORS for iOS app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include Routers
app.include_router(script.router)

# Root Endpoint
@app.get("/")
async def root():
    return {"message": "FlavourFinder Backend API"}

# Health Check Endpoint
@app.get("/health")
async def health():
    return {"status": "healthy"}
