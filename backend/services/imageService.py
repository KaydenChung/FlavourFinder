# Imports
import os
import requests

# Image Service Class
class imageService:

    # Constructor
    def __init__(self):
        self.unsplash_key = os.getenv("UNSPLASH_ACCESS_KEY")
        self.base_url = "https://api.unsplash.com"
    
    # Function to Get Recipe Image
    def get_recipe_image(self, recipe_title: str, ingredients: list) -> str:
        
        # Create Search Query
        search_terms = recipe_title.lower().split()[:3]
        search_query = " ".join(search_terms) + " food"
        url = f"{self.base_url}/search/photos"
        params = {
            "query": search_query,
            "per_page": 1,
            "orientation": "landscape",
            "content_filter": "high"
        }
        headers = {
            "Authorization": f"Client-ID {self.unsplash_key}",
            "Accept-Version": "v1"
        }
        
        # Make Request to Unsplash
        try:
            response = requests.get(url, params=params, headers=headers, timeout=10)
            
            # Debug Response
            print(f"Unsplash API Status: {response.status_code}")
            
            # Handle Authorization Error
            if response.status_code == 401:
                print(f"Authorization failed. Check your Unsplash Access Key.")
                print(f"Response: {response.text}")
                return self._get_fallback_image()
            
            # Handle Other Errors
            response.raise_for_status()
            data = response.json()
            
            # Check for Results
            if data.get("results") and len(data["results"]) > 0:
                image_url = data["results"][0]["urls"]["regular"]
                print(f"Found image: {image_url}")
                return image_url
            else:
                print("No results found, using fallback")
                return self._get_fallback_image()
            
        # Handle Request Exceptions        
        except requests.exceptions.RequestException as e:
            print(f"Error fetching Unsplash image: {e}")
            return self._get_fallback_image()
    
    # Function to Get Fallback Image
    def _get_fallback_image(self) -> str:
        
        # Create Search Query
        url = f"{self.base_url}/photos/random"
        params = {
            "query": "delicious food",
            "orientation": "landscape",
            "content_filter": "high"
        }
        headers = {
            "Authorization": f"Client-ID {self.unsplash_key}",
            "Accept-Version": "v1"
        }
        
        # Make Request to Unsplash
        try:
            response = requests.get(url, params=params, headers=headers, timeout=10)
            if response.status_code == 200:
                data = response.json()
                return data["urls"]["regular"]
        except:
            return "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800"
