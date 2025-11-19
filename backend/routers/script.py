# Imports
from fastapi import APIRouter, HTTPException
from models.recipe import Recipe, RecipeGenerateRequest, RecipeModifyRequest
from services.recipeService import recipeService
from services.imageService import imageService
import uuid
router = APIRouter(prefix="/recipes", tags=["recipes"])
recipe_service = recipeService()
image_service = imageService()

# Generate Recipe Endpoint
@router.post("/generate", response_model=Recipe)
async def generate_recipe(request: RecipeGenerateRequest):
    try:

        # Generate Recipe with Groq
        recipe_data = recipe_service.generate_recipe(
            preferences=request.preferences,
            existing_recipes=request.existing_recipes
        )
        
        # Get Image from Unsplash
        image_url = image_service.get_recipe_image(
            recipe_data["title"],
            recipe_data["ingredients"]
        )
        
        # Create Complete Recipe
        recipe = Recipe(
            id=str(uuid.uuid4()),
            image_url=image_url,
            **recipe_data
        )
        
        # Return Recipe
        return recipe
    
    # Handle Errors
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Modify Recipe Endpoint
@router.post("/modify", response_model=Recipe)
async def modify_recipe(request: RecipeModifyRequest):
    try:
        
        # Modify Recipe with Groq
        modified_data = recipe_service.modify_recipe(
            request.original_recipe,
            request.modification
        )
        
        # Create Complete Recipe
        recipe = Recipe(**modified_data)

        # Return Recipe
        return recipe
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Test Endpoint
@router.get("/test")
async def test_generation():
    try:
        recipe_data = recipe_service.generate_recipe(preferences="healthy")
        image_url = image_service.get_recipe_image(recipe_data["title"], recipe_data["ingredients"])
        return {
            "status": "success",
            "recipe": recipe_data,
            "image": image_url
        }
    except Exception as e:
        return {"status": "error", "message": str(e)}
