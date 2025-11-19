# Imports
from pydantic import BaseModel
from typing import List, Optional

# User Preferences Model
class UserPreferences(BaseModel):

    # Preference Levels (1-3)
    effort_level: int = 2
    skill_level: int = 2
    calorie_consciousness: int = 2
    protein_preference: int = 2
    spice_level: int = 2
    
    # Convert Preferences to Prompt String
    def to_prompt_string(self) -> str:
        effort_map = {1: "quick & easy", 2: "moderate effort", 3: "intricate dish"}
        skill_map = {1: "beginner-friendly", 2: "intermediate", 3: "advanced"}
        calorie_map = {1: "low-calorie", 2: "moderate calories", 3: "high-calorie"}
        protein_map = {1: "low-protein", 2: "moderate protein", 3: "high-protein"}
        spice_map = {1: "not spicy", 2: "mildly spicy", 3: "very spicy"}
        
        return f"""
        Effort: {effort_map.get(self.effort_level, "moderate effort")}
        Skill: {skill_map.get(self.skill_level, "intermediate")}
        Calories: {calorie_map.get(self.calorie_consciousness, "moderate calories")}
        Protein: {protein_map.get(self.protein_preference, "moderate protein")}
        Spice: {spice_map.get(self.spice_level, "mildly spicy")}
        """

# Nutritional Information
class Macros(BaseModel):
    calories: int
    protein: int
    carbs: int
    fat: int

# Cooking Step
class RecipeStep(BaseModel):
    step_number: int
    instruction: str

# Recipe Model
class Recipe(BaseModel):
    id: str
    image_url: str
    title: str
    description: str
    cook_time: int
    tags: List[str]
    ingredients: List[str]
    steps: List[RecipeStep]
    macros: Macros

# Recipe Generation Request
class RecipeGenerateRequest(BaseModel):
    preferences: UserPreferences
    existing_recipes: List[str] = []
    
# Recipe Modification Request
class RecipeModifyRequest(BaseModel):
    original_recipe: dict
    modification: str
