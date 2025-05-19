import bcrypt
from typing import Tuple, Dict, Any, Optional
from database.database import Database
from utils.validators import validate_email, validate_password, validate_username
from utils.logger import get_logger
from utils.config_manager import ConfigManager

logger = get_logger()
config = ConfigManager()

class AuthService:
    def __init__(self):
        self.database = Database()

    def register(self, username: str, email: str, password: str) -> Tuple[bool, str]:
        """
        Register a new user with validation.
        
        Args:
            username: The desired username
            email: User's email address
            password: User's password (plain text)
            
        Returns:
            Tuple of (success: bool, message: str)
        """
        try:
            # Validate inputs
            username_valid, username_error = validate_username(username)
            if not username_valid:
                logger.warning(f"Invalid username attempt: {username_error}")
                return False, username_error

            email_valid, email_error = validate_email(email)
            if not email_valid:
                logger.warning(f"Invalid email attempt: {email_error}")
                return False, email_error

            min_password_length = config.get('auth.min_password_length', 8)
            password_valid, password_error = validate_password(password, min_password_length)
            if not password_valid:
                logger.warning("Invalid password attempt")
                return False, password_error

            # Check if username or email already exists
            if self.database.get_user_by_username(username):
                logger.warning(f"Registration attempt with existing username: {username}")
                return False, "Username already exists"
            if self.database.get_user_by_email(email):
                logger.warning(f"Registration attempt with existing email: {email}")
                return False, "Email already exists"

            # Hash the password
            password_hash = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())
            
            # Create the user
            user_id = self.database.create_user(
                username=username,
                email=email,
                password_hash=password_hash.decode('utf-8')
            )
            
            if user_id:
                logger.info(f"Successfully registered new user: {username}")
                return True, "Registration successful"
            
            logger.error("Failed to create user in database")
            return False, "Failed to create user"
            
        except Exception as e:
            logger.error(f"Registration error: {str(e)}", exc_info=True)
            return False, f"Registration failed: {str(e)}"

    def login(self, username: str, password: str) -> Tuple[bool, str, Optional[Dict[str, Any]]]:
        """
        Authenticate a user with logging.
        
        Args:
            username: Username or email
            password: User's password (plain text)
            
        Returns:
            Tuple of (success: bool, message: str, user_data: Optional[Dict])
        """
        try:
            # Try to find user by username first, then by email if not found
            user = self.database.get_user_by_username(username)
            if not user:
                user = self.database.get_user_by_email(username)
            
            if not user:
                logger.warning(f"Login attempt with non-existent username/email: {username}")
                return False, "Invalid username or email", None

            # Verify password
            if bcrypt.checkpw(
                password.encode('utf-8'),
                user['password_hash'].encode('utf-8')
            ):
                # Don't include password_hash in returned user data
                user_data = {
                    'id': user['id'],
                    'username': user['username'],
                    'email': user['email']
                }
                logger.info(f"Successful login for user: {username}")
                return True, "Login successful", user_data
            
            logger.warning(f"Failed login attempt for user: {username}")
            return False, "Invalid password", None
            
        except Exception as e:
            logger.error(f"Login error: {str(e)}", exc_info=True)
            return False, f"Login failed: {str(e)}", None