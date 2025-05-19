import re
from typing import Optional

def validate_email(email: str) -> tuple[bool, Optional[str]]:
    """
    Validate an email address.
    
    Args:
        email: The email address to validate
        
    Returns:
        Tuple of (is_valid: bool, error_message: Optional[str])
    """
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    if not email:
        return False, "Email is required"
    if not re.match(pattern, email):
        return False, "Invalid email format"
    return True, None

def validate_password(password: str, min_length: int = 8) -> tuple[bool, Optional[str]]:
    """
    Validate a password.
    
    Args:
        password: The password to validate
        min_length: Minimum required length
        
    Returns:
        Tuple of (is_valid: bool, error_message: Optional[str])
    """
    if not password:
        return False, "Password is required"
    if len(password) < min_length:
        return False, f"Password must be at least {min_length} characters"
    if not re.search(r'[A-Z]', password):
        return False, "Password must contain at least one uppercase letter"
    if not re.search(r'[a-z]', password):
        return False, "Password must contain at least one lowercase letter"
    if not re.search(r'\d', password):
        return False, "Password must contain at least one number"
    return True, None

def validate_username(username: str, min_length: int = 3) -> tuple[bool, Optional[str]]:
    """
    Validate a username.
    
    Args:
        username: The username to validate
        min_length: Minimum required length
        
    Returns:
        Tuple of (is_valid: bool, error_message: Optional[str])
    """
    if not username:
        return False, "Username is required"
    if len(username) < min_length:
        return False, f"Username must be at least {min_length} characters"
    if not re.match(r'^[a-zA-Z0-9_-]+$', username):
        return False, "Username can only contain letters, numbers, underscores, and hyphens"
    return True, None