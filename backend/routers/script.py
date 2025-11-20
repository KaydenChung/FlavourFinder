# Imports
from fastapi import APIRouter, HTTPException, Depends
from models.recipe import Recipe, RecipeGenerateRequest, RecipeModifyRequest
from services.recipeService import recipeService
from services.imageService import imageService
from services.supabaseClient import get_supabase
from middleware.auth import verify_token
import uuid
import json

router = APIRouter(prefix="/recipes", tags=["recipes"])
recipe_service = recipeService()
image_service = imageService()

# Generate Recipe Endpoint
@router.post("/generate", response_model=Recipe)
async def generate_recipe(
    request: RecipeGenerateRequest,
    user_id: str = Depends(verify_token)
):
    try:
        supabase = get_supabase()
        
        # Get Previous 10 User Recipes to Avoid Duplicates
        history_response = supabase.table('recipe_history') \
            .select('recipe_title') \
            .eq('user_id', user_id) \
            .order('created_at', desc=True) \
            .limit(10) \
            .execute()
        
        existing_recipes = [item['recipe_title'] for item in history_response.data]

        # Generate Recipe with Groq
        recipe_data = recipe_service.generate_recipe(
            preferences=request.preferences,
            existing_recipes=existing_recipes
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
        
        # Store in Recipe History
        supabase.table('recipe_history').insert({
            'user_id': user_id,
            'recipe_title': recipe.title,
            'recipe_data': json.loads(recipe.model_dump_json())
        }).execute()
        
        # Return Recipe
        return recipe
    
    # Handle Errors
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Modify Recipe Endpoint
@router.post("/modify", response_model=Recipe)
async def modify_recipe(
    request: RecipeModifyRequest,
    user_id: str = Depends(verify_token)
):
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
    
    # Handle Errors
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Get Recipe History Endpoint
@router.get("/history")
async def get_recipe_history(
    limit: int = 50,
    user_id: str = Depends(verify_token)
):
    try:
        supabase = get_supabase()
        
        # Get Recipe History
        response = supabase.table('recipe_history') \
            .select('*') \
            .eq('user_id', user_id) \
            .order('created_at', desc=True) \
            .limit(limit) \
            .execute()
        
        # Return Recipes
        return {"recipes": response.data}
    
    # Handle Errors
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Save Recipe Endpoint
@router.post("/save")
async def save_recipe(
    recipe: Recipe,
    user_id: str = Depends(verify_token)
):
    try:
        supabase = get_supabase()
        
        # Check if Recipe is Saved
        existing = supabase.table('saved_recipes') \
            .select('id') \
            .eq('user_id', user_id) \
            .eq('recipe_id', recipe.id) \
            .execute()
        
        if existing.data:
            raise HTTPException(status_code=400, detail="Recipe already saved")
        
        # Save Recipe
        supabase.table('saved_recipes').insert({
            'user_id': user_id,
            'recipe_id': recipe.id,
            'recipe_data': json.loads(recipe.model_dump_json())
        }).execute()
        
        return {"message": "Recipe saved successfully"}
    
    # Handle Errors
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Unsave Recipe Endpoint
@router.delete("/save/{recipe_id}")
async def unsave_recipe(
    recipe_id: str,
    user_id: str = Depends(verify_token)
):
    try:
        supabase = get_supabase()
        
        # Unsave Recipe
        supabase.table('saved_recipes') \
            .delete() \
            .eq('user_id', user_id) \
            .eq('recipe_id', recipe_id) \
            .execute()
        
        return {"message": "Recipe removed from saved"}
    
    # Handle Errors
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Get Saved Recipes Endpoint
@router.get("/saved")
async def get_saved_recipes(
    user_id: str = Depends(verify_token)
):
    try:
        supabase = get_supabase()
        
        # Get Saved Recipes
        response = supabase.table('saved_recipes') \
            .select('*') \
            .eq('user_id', user_id) \
            .order('created_at', desc=True) \
            .execute()
        
        return {"recipes": response.data}
    
    # Handle Errors
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Test Endpoint
@router.get("/test")
async def test_generation():
    try:

        from models.recipe import UserPreferences
        
        recipe_data = recipe_service.generate_recipe(preferences=UserPreferences())
        image_url = image_service.get_recipe_image(recipe_data["title"], recipe_data["ingredients"])
        
        return {
            "status": "success",
            "recipe": recipe_data,
            "image": image_url
        }
    
    except Exception as e:
        return {"status": "error", "message": str(e)}
