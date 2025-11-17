# Imports
import os
import json
from groq import Groq
from dotenv import load_dotenv
from typing import List
from models.recipe import UserPreferences

# Load Environment Variables
load_dotenv()

# Recipe Service Class
class recipeService:

    # Constructor
    def __init__(self):
        self.client = Groq(api_key=os.getenv("GROQ_API_KEY"))
    
    # Function to Generate Recipe
    def generate_recipe(self, preferences: UserPreferences, existing_recipes: List[str] = None) -> dict:

        # Convert Existing Recipes to String
        existing_recipes_text = ""
        if existing_recipes and len(existing_recipes) > 0:
            existing_recipes_text = f"""
            IMPORTANT: The user has already generated these recipes:
            {', '.join(existing_recipes)}

            You MUST generate something completely different from these recipes.
            Do NOT create variations or similar dishes to the ones listed above.
            Choose a different cuisine, cooking method, or main ingredient.
            """
        
        # Convert Preferences to String
        preferences_text = preferences.to_prompt_string()
        
        # Create Prompt
        prompt = f"""
        Generate a unique recipe based on these preferences:
        Return ONLY valid JSON with this exact structure (no markdown, no extra text):
        {{
            "title": "Recipe Name/Name of Dish",
            "description": "A one sentence description",
            "cook_time": (int) total cook time in minutes,
            "tags": ["relevant tags (max 3)", ...],
            "ingredients": ["ingredient with quantity", ...],
            "steps": [
                {{"step_number": 1, "instruction": "First step..."}},
                {{"step_number": 2, "instruction": "Second step..."}}
            ],
            "macros": {{
                "calories": (int) total calories,
                "protein": (int) grams of protein,
                "carbs": (int) grams of carbs,
                "fat": (int) grams of fat
            }}
        }}
        {preferences_text}
        {existing_recipes_text}
        Make the recipe realistic, achievable, and align it with the user's preferences above.
        Ensure the recipe is completely unique from any previously generated recipes.
        Return ONLY the JSON object."""

        # Make Request to Groq
        response = self.client.chat.completions.create(
            model="llama-3.3-70b-versatile",
            messages=[{"role": "user", "content": prompt}],
            temperature=0.9,
            max_tokens=2000,
        )
        
        # Parse the JSON Response
        content = response.choices[0].message.content.strip()
        if content.startswith("```"):
            content = content.split("```")[1]
            if content.startswith("json"):
                content = content[4:]
        recipe_data = json.loads(content)
        
        return recipe_data
    
    # Function to Modify Recipe
    def modify_recipe(self, original_recipe: dict, modification: str) -> dict:
        
        # Create Prompt
        prompt = f"""
        Here's a recipe:
        {json.dumps(original_recipe, indent=2)}
        User wants to modify it: "{modification}"
        Return ONLY the updated JSON with the same structure, incorporating their changes.
        No markdown, just the JSON object."""

        # Make Request to Groq
        response = self.client.chat.completions.create(
            model="llama-3.3-70b-versatile",
            messages=[{"role": "user", "content": prompt}],
            temperature=0.7,
            max_tokens=2000,
        )
        
        # Parse the JSON Response
        content = response.choices[0].message.content.strip()
        if content.startswith("```"):
            content = content.split("```")[1]
            if content.startswith("json"):
                content = content[4:]
        modified_data = json.loads(content)

        return modified_data
