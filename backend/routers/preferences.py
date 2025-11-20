# Imports
from fastapi import APIRouter, HTTPException, Depends
from models.recipe import UserPreferences
from services.supabaseClient import get_supabase
from middleware.auth import verify_token

router = APIRouter(prefix="/preferences", tags=["preferences"])

# Get User Preferences
@router.get("", response_model=UserPreferences)
async def get_preferences(user_id: str = Depends(verify_token)):
    try:
        supabase = get_supabase()
        
        # Get User Preferences
        response = supabase.table('user_preferences') \
            .select('*') \
            .eq('user_id', user_id) \
            .single() \
            .execute()
        
        # Return Preferences or Default
        if response.data:
            return UserPreferences(**response.data)
        else:
            return UserPreferences()
    
    except Exception as e:
        if "PGRST116" in str(e):
            return UserPreferences()
        raise HTTPException(status_code=500, detail=str(e))

# Update User Preferences
@router.put("", response_model=UserPreferences)
async def update_preferences(
    preferences: UserPreferences,
    user_id: str = Depends(verify_token)
):
    try:
        supabase = get_supabase()
        
        # Check for Preferences
        existing = supabase.table('user_preferences') \
            .select('id') \
            .eq('user_id', user_id) \
            .execute()
        
        pref_dict = preferences.model_dump()
        pref_dict['user_id'] = user_id
        
        # Update or Insert Preferences
        if existing.data:
            response = supabase.table('user_preferences') \
                .update(pref_dict) \
                .eq('user_id', user_id) \
                .execute()
        else:
            response = supabase.table('user_preferences') \
                .insert(pref_dict) \
                .execute()
        return UserPreferences(**response.data[0])
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    