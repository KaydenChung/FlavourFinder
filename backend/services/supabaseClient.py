# Imports
import os
from supabase import create_client, Client
from dotenv import load_dotenv

# Load Environment Variables
load_dotenv()

# Supabase Client Singleton
class SupabaseClient:

    _instance: Client = None
    
    @classmethod
    def get_client(cls) -> Client:

        if cls._instance is None:

            supabase_url = os.getenv("SUPABASE_URL")
            supabase_key = os.getenv("SUPABASE_SERVICE_KEY")
            
            if not supabase_url or not supabase_key:
                raise ValueError("Missing Supabase credentials in environment variables")
            
            cls._instance = create_client(supabase_url, supabase_key)
        
        return cls._instance

# Export Function to Get Supabase Client
def get_supabase() -> Client:
    
    return SupabaseClient.get_client()
