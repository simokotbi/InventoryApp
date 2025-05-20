import sqlite3
from pathlib import Path
from typing import Optional, Dict, Any, List
import logging
from utils.logger import get_logger

logger = get_logger()

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
                # Create user activity table
                cursor.execute("""
                CREATE TABLE IF NOT EXISTS user_activity (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    user_id INTEGER NOT NULL,
                    action_type TEXT NOT NULL,
                    datetime DATETIME DEFAULT CURRENT_TIMESTAMP,
                    details TEXT,
                    FOREIGN KEY (user_id) REFERENCES users (id)
                )
                """)

                # Create performance metrics table
                cursor.execute("""
                CREATE TABLE IF NOT EXISTS performance_metrics (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    metric_type TEXT NOT NULL,
                    value REAL NOT NULL,
                    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
                    response_time INTEGER,
                    details TEXT
                )
                """)

                # Create request log table
                cursor.execute("""
                CREATE TABLE IF NOT EXISTS request_log (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    user_id INTEGER,
                    endpoint TEXT NOT NULL,
                    method TEXT NOT NULL,
                    status TEXT NOT NULL,
                    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
                    response_time INTEGER,
                    error_details TEXT,
                    FOREIGN KEY (user_id) REFERENCES users (id)
                )
                """)

                conn.commit()
                logger.info("Database initialized successfully")

        except Exception as e:
            logger.error(f"Error initializing database: {str(e)}", exc_info=True)
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
        except sqlite3.IntegrityError as e:
            logger.error(f"User creation failed - integrity error: {e}")
            return None
        except sqlite3.Error as e:
            logger.error(f"Error creating user: {e}")
            return None

    def get_user_by_username(self, username: str) -> Optional[Dict[str, Any]]:
        """Retrieve a user by username."""
        try:
            with self._get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute("SELECT * FROM users WHERE username = ?", (username,))
                return cursor.fetchone()
        except sqlite3.Error as e:
            logger.error(f"Error retrieving user by username: {e}")
            return None

    def get_user_by_email(self, email: str) -> Optional[Dict[str, Any]]:
        """Retrieve a user by email."""
        try:
            with self._get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute("SELECT * FROM users WHERE email = ?", (email,))
                return cursor.fetchone()
        except sqlite3.Error as e:
            logger.error(f"Error retrieving user by email: {e}")
            return None

    def update_user_password(self, user_id: int, password_hash: str) -> bool:
        """Update a user's password hash."""
        try:
            with self._get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(
                    "UPDATE users SET password_hash = ? WHERE id = ?",
                    (password_hash, user_id)
                )
                conn.commit()
                return cursor.rowcount > 0
        except sqlite3.Error as e:
            logger.error(f"Error updating user password: {e}")
            return False

    def update_user_email(self, user_id: int, email: str) -> bool:
        """Update a user's email address."""
        try:
            with self._get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(
                    "UPDATE users SET email = ? WHERE id = ?",
                    (email, user_id)
                )
                conn.commit()
                return cursor.rowcount > 0
        except sqlite3.IntegrityError:
            logger.error("Email already exists")
            return False
        except sqlite3.Error as e:
            logger.error(f"Error updating user email: {e}")
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
            logger.error(f"Error deleting user: {e}")
            return False

    def log_user_activity(self, user_id: int, action_type: str, details: Optional[str] = None):
        """Log user activity for analytics."""
        try:
            with self._get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute("""
                INSERT INTO user_activity (user_id, action_type, details)
                VALUES (?, ?, ?)
                """, (user_id, action_type, details))
                conn.commit()
        except Exception as e:
            logger.error(f"Error logging user activity: {str(e)}", exc_info=True)

    def log_performance_metric(self, metric_type: str, value: float, response_time: Optional[int] = None, details: Optional[str] = None):
        """Log performance metrics."""
        try:
            with self._get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute("""
                INSERT INTO performance_metrics (metric_type, value, response_time, details)
                VALUES (?, ?, ?, ?)
                """, (metric_type, value, response_time, details))
                conn.commit()
        except Exception as e:
            logger.error(f"Error logging performance metric: {str(e)}", exc_info=True)

    def log_request(self, endpoint: str, method: str, status: str, user_id: Optional[int] = None,
                   response_time: Optional[int] = None, error_details: Optional[str] = None):
        """Log API request details."""
        try:
            with self._get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute("""
                INSERT INTO request_log (user_id, endpoint, method, status, response_time, error_details)
                VALUES (?, ?, ?, ?, ?, ?)
                """, (user_id, endpoint, method, status, response_time, error_details))
                conn.commit()
        except Exception as e:
            logger.error(f"Error logging request: {str(e)}", exc_info=True)

    def get_user_activity_stats(self, user_id: Optional[int] = None, 
                              start_date: Optional[str] = None,
                              end_date: Optional[str] = None) -> List[Dict[str, Any]]:
        """Get user activity statistics for analytics."""
        try:
            with self._get_connection() as conn:
                cursor = conn.cursor()
                query = """
                SELECT 
                    action_type,
                    COUNT(*) as count,
                    MIN(datetime) as first_occurrence,
                    MAX(datetime) as last_occurrence
                FROM user_activity
                WHERE 1=1
                """
                params = []

                if user_id:
                    query += " AND user_id = ?"
                    params.append(user_id)

                if start_date:
                    query += " AND datetime >= ?"
                    params.append(start_date)

                if end_date:
                    query += " AND datetime <= ?"
                    params.append(end_date)

                query += " GROUP BY action_type ORDER BY count DESC"
                cursor.execute(query, params)
                
                return [dict(row) for row in cursor.fetchall()]

        except Exception as e:
            logger.error(f"Error getting user activity stats: {str(e)}", exc_info=True)
            return []

    def get_performance_stats(self, metric_type: Optional[str] = None,
                            start_date: Optional[str] = None,
                            end_date: Optional[str] = None) -> List[Dict[str, Any]]:
        """Get performance statistics for analytics."""
        try:
            with self._get_connection() as conn:
                cursor = conn.cursor()
                query = """
                SELECT 
                    metric_type,
                    AVG(value) as avg_value,
                    MIN(value) as min_value,
                    MAX(value) as max_value,
                    COUNT(*) as sample_count,
                    AVG(response_time) as avg_response_time
                FROM performance_metrics
                WHERE 1=1
                """
                params = []

                if metric_type:
                    query += " AND metric_type = ?"
                    params.append(metric_type)

                if start_date:
                    query += " AND timestamp >= ?"
                    params.append(start_date)

                if end_date:
                    query += " AND timestamp <= ?"
                    params.append(end_date)

                query += " GROUP BY metric_type"
                cursor.execute(query, params)
                
                return [dict(row) for row in cursor.fetchall()]

        except Exception as e:
            logger.error(f"Error getting performance stats: {str(e)}", exc_info=True)
            return []