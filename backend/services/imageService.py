# Imports
import os
import requests
import random

# Image Service Class
class imageService:

    def __init__(self):
        self.unsplash_key = os.getenv("UNSPLASH_ACCESS_KEY")
        self.base_url = "https://api.unsplash.com"
    
    def get_recipe_image(self, recipe_title: str, tags: list, ingredients: list = None) -> str:
        
        visual_tags = [tag for tag in tags if tag.lower()]
        
        # Build Search Query
        if visual_tags:

            # Using Tags
            search_query = " ".join(visual_tags[:3]) + " meal"

        else:

            # Title Fallback
            search_terms = recipe_title.lower().split()[:3]
            search_query = " ".join(search_terms) + " meal"
        
        # Search
        image_url = self._search_unsplash(search_query)
        if image_url:
            return image_url
        
        # Fallback Image
        return self._get_fallback_image()
    
    def _search_unsplash(self, query: str, per_page: int = 15) -> str:
        
        # Unsplash Query
        url = f"{self.base_url}/search/photos"
        params = {
            "query": query,
            "per_page": per_page,
            "orientation": "landscape",
            "content_filter": "high"
        }
        headers = {
            "Authorization": f"Client-ID {self.unsplash_key}",
            "Accept-Version": "v1"
        }
        
        # Make Request
        try:

            # API Call
            response = requests.get(url, params=params, headers=headers, timeout=10)
            
            # Debug Logging
            print(f"Unsplash search: '{query}' - Status: {response.status_code}")
            
            # Handle Errors
            if response.status_code == 401:
                print("Authorization failed. Check your Unsplash Access Key.")
                return None
            response.raise_for_status()
            data = response.json()
            
            # Select Random Image from Results
            if data.get("results") and len(data["results"]) > 0:
                random_index = random.randint(0, min(10, len(data["results"]) - 1))
                image_url = data["results"][random_index]["urls"]["regular"]
                print(f"Found image (index {random_index}): {image_url}")
                return image_url
            else:
                print(f"No results found for '{query}'")
                return None

        # Handle Request Exceptions       
        except requests.exceptions.RequestException as e:
            print(f"Error fetching Unsplash image: {e}")
            return None
    
    # Fallback Image Method
    def _get_fallback_image(self) -> str:
        
        # Random Image Query
        url = f"{self.base_url}/photos/random"
        params = {
            "query": "delicious food meal",
            "orientation": "landscape",
            "content_filter": "high"
        }
        headers = {
            "Authorization": f"Client-ID {self.unsplash_key}",
            "Accept-Version": "v1"
        }
        
        # Make Request
        try:

            # API Call
            response = requests.get(url, params=params, headers=headers, timeout=10)

            # Handle Success
            if response.status_code == 200:
                data = response.json()
                print(f"Using random fallback image")
                return data["urls"]["regular"]
        except:
            pass
        
        # Hard-Coded Fallback
        print("Using hard-coded fallback image")
        return "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800"
    