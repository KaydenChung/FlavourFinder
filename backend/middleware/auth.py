# Imports
from fastapi import HTTPException, Header
import jwt
import os
from typing import Optional

JWT_SECRET = os.getenv("SUPABASE_JWT_SECRET")

# Verify JWT Token and Extract User ID
def verify_token(authorization: Optional[str] = Header(None)) -> str:

    if not authorization:
        raise HTTPException(status_code=401, detail="Missing authorization header")
    
    try:
        
        if not authorization.startswith("Bearer "):
            raise HTTPException(status_code=401, detail="Invalid authorization format")
        
        token = authorization.split("Bearer ")[1]
        
        # Decode and Verify Token
        payload = jwt.decode(
            token,
            JWT_SECRET,
            algorithms=["HS256"],
            audience="authenticated"
        )
        
        # Extract User ID from Payload
        user_id = payload.get("sub")
        if not user_id:
            raise HTTPException(status_code=401, detail="Invalid token payload")
        
        return user_id
    
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token has expired")
    
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")
    
    except Exception as e:
        raise HTTPException(status_code=401, detail=f"Authentication failed: {str(e)}")
    