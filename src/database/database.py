import sqlite3
from pathlib import Path
from typing import Optional, Dict, Any, List
import logging

class Database:
    def __init__(self, db_path: Optional[str] = None):
        if db_path is None:
            db_path = str(Path(__file__).parent.parent.parent / "app_database.db")
        self.db_path = db_path
        self._init_database()

    def _init_database(self) -> None:
        """Initialize the database and create tables if they don't exist."""
        try:
            with self._get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute("""
                    CREATE TABLE IF NOT EXISTS users (
                        id INTEGER PRIMARY KEY AUTOINCREMENT,
                        username TEXT UNIQUE NOT NULL,
                        email TEXT UNIQUE NOT NULL,
                        password_hash TEXT NOT NULL
                    )
                """)
                conn.commit()
        except sqlite3.Error as e:
            logging.error(f"Database initialization error: {e}")
            raise

    def _get_connection(self) -> sqlite3.Connection:
        """Get a database connection with row factory set to dict."""
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = lambda c, r: dict([(col[0], r[idx]) for idx, col in enumerate(c.description)])
        return conn

    def create_user(self, username: str, email: str, password_hash: str) -> Optional[int]:
        """Create a new user in the database."""
        try:
            with self._get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(
                    "INSERT INTO users (username, email, password_hash) VALUES (?, ?, ?)",
                    (username, email, password_hash)
                )
                conn.commit()
                return cursor.lastrowid
        except sqlite3.IntegrityError:
            logging.error("User already exists")
            return None
        except sqlite3.Error as e:
            logging.error(f"Error creating user: {e}")
            return None

    def get_user_by_username(self, username: str) -> Optional[Dict[str, Any]]:
        """Retrieve a user by username."""
        try:
            with self._get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute("SELECT * FROM users WHERE username = ?", (username,))
                return cursor.fetchone()
        except sqlite3.Error as e:
            logging.error(f"Error retrieving user: {e}")
            return None

    def get_user_by_email(self, email: str) -> Optional[Dict[str, Any]]:
        """Retrieve a user by email."""
        try:
            with self._get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute("SELECT * FROM users WHERE email = ?", (email,))
                return cursor.fetchone()
        except sqlite3.Error as e:
            logging.error(f"Error retrieving user: {e}")
            return None

    def update_user(self, user_id: int, data: Dict[str, Any]) -> bool:
        """Update user data."""
        allowed_fields = {'email', 'password_hash'}
        update_fields = {k: v for k, v in data.items() if k in allowed_fields}
        
        if not update_fields:
            return False

        set_clause = ", ".join(f"{k} = ?" for k in update_fields.keys())
        values = list(update_fields.values())
        values.append(user_id)

        try:
            with self._get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(
                    f"UPDATE users SET {set_clause} WHERE id = ?",
                    values
                )
                conn.commit()
                return cursor.rowcount > 0
        except sqlite3.Error as e:
            logging.error(f"Error updating user: {e}")
            return False

    def delete_user(self, user_id: int) -> bool:
        """Delete a user from the database."""
        try:
            with self._get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute("DELETE FROM users WHERE id = ?", (user_id,))
                conn.commit()
                return cursor.rowcount > 0
        except sqlite3.Error as e:
            logging.error(f"Error deleting user: {e}")
            return False