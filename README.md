# Qt Quick Authentication App

A modern Qt Quick application built with Python and PySide6, featuring user authentication, SQLite database integration, and a well-structured QML interface.

## Features

- User authentication (login/signup) with bcrypt password hashing
- SQLite database integration
- Modern QML interface with custom components
- Dashboard with data table
- Analytics view with simple charts
- User form with various input types
- Settings dialog
- Responsive layout with sidebar navigation

## Prerequisites

- Python 3.8 or higher
- uv package manager
- Qt 6.x (included with PySide6)

## Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd <project-directory>
```

2. Install dependencies using uv:
```bash
uv pip install PySide6 bcrypt
```

## Project Structure

```
src/
├── main.py                 # Application entry point
├── authentication/
│   └── auth_service.py     # Authentication logic
├── database/
│   └── database.py        # SQLite database operations
└── qml/
    ├── components/        # Reusable QML components
    ├── pages/            # Main application pages
    ├── styles/           # Global styling
    └── views/            # Content views
```

## Running the Application

```bash
uv run python src/main.py
```

## Development

### Adding New Components

1. Create your QML component in `src/qml/components/`
2. Register it in `src/qml/components/qmldir`
3. Import it in your QML files using:
```qml
import "../components"
// or
import Components 1.0
```

### Database Schema

The application uses SQLite with the following schema:

```sql
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL
);
```

### Authentication Flow

1. User enters credentials
2. Credentials are validated client-side
3. Authentication request is sent to AuthService
4. Password is hashed and verified against database
5. On success, user is redirected to main application

## License

[Add your license here]