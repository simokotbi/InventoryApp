# ChaOffice Core - Hybrid Business Management System

![ChaOffice Logo](https://img.shields.io/badge/ChaOffice-v0.1.0-blue.svg)
![Python](https://img.shields.io/badge/Python-3.9%2B-green.svg)
![PySide6](https://img.shields.io/badge/PySide6-6.4%2B-orange.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

A modern, hybrid business management system built with **PySide6** and **QML** that seamlessly operates in both online and offline modes. ChaOffice Core provides essential business management features with automatic data synchronization between local SQLite storage and cloud-based Supabase backend.

## ✨ Features

### 🌐 Hybrid Architecture
- **Online Mode**: Full cloud synchronization with Supabase backend
- **Offline Mode**: Local SQLite database for uninterrupted operations
- **Automatic Sync**: Seamless data synchronization when connectivity is restored
- **Mode Switching**: Runtime switching between online and offline modes

### 🎨 Modern UI/UX
- **Qt Quick/QML Interface**: Responsive and fluid user interface
- **Dark/Light Themes**: System-aware theme switching
- **Material Design**: Clean, modern design principles
- **Cross-Platform**: Runs on Windows, macOS, and Linux

### 🔐 Authentication & Security
- **JWT-based Authentication**: Secure token-based authentication
- **Password Hashing**: bcrypt-secured password storage
- **Session Management**: Automatic session handling and renewal
- **Offline Authentication**: Local credential verification when offline

### 📊 Business Management
- **Product Management**: Complete CRUD operations for inventory
- **Dashboard Analytics**: Real-time business metrics and insights
- **Data Tables**: Advanced filtering, sorting, and search capabilities
- **Settings Management**: Comprehensive application configuration

## 🚀 Quick Start

### Prerequisites

- Python 3.9 or higher
- [uv](https://github.com/astral-sh/uv) package manager

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/chaoffice.git
   cd chaoffice
   ```

2. **Install dependencies**
   ```bash
   uv install
   ```

3. **Configure settings** (optional)
   ```bash
   # Copy and modify the configuration file
   cp instance_settings.json.example instance_settings.json
   # Edit instance_settings.json with your Supabase credentials
   ```

4. **Initialize local database**
   ```bash
   uv run python -m src.local_db.init_local_db
   ```

5. **Run the application**
   ```bash
   uv run python run.py
   ```

## 📁 Project Structure

```
chaoffice/
├── pyproject.toml              # Project dependencies and metadata
├── instance_settings.json     # Application configuration
├── run.py                     # Application launcher
├── src/
│   ├── main.py               # Application entry point
│   ├── app_logger/           # Logging system
│   ├── core/                 # Core utilities and configuration
│   ├── local_db/             # SQLite database layer
│   ├── api_client/           # Supabase API integration
│   ├── business_logic/       # Business service layer
│   ├── qml_handlers/         # Python-QML bridge
│   ├── qml/                  # QML user interface
│   │   ├── main.qml         # Main application window
│   │   ├── styles/          # Theme and styling
│   │   ├── components/      # Reusable UI components
│   │   ├── screens/         # Application screens
│   │   └── views/           # Business logic views
│   └── assets/              # Static assets (icons, images)
└── README.md
```

## 🏗️ Architecture

### Layered Architecture

```
┌─────────────────────────┐
│     QML Frontend        │  ← User Interface Layer
├─────────────────────────┤
│     QML Bridge          │  ← Python-QML Communication
├─────────────────────────┤
│   Business Logic        │  ← Service Layer
├─────────────────────────┤
│   Data Access Layer     │  ← Repository Pattern
├─────────────────────────┤
│  Local DB | API Client  │  ← Storage Abstraction
└─────────────────────────┘
```

### Key Components

#### 🔗 QML Bridge (`src/qml_handlers/`)
- **QmlBridge**: Central communication hub between Python and QML
- **AuthHandler**: Authentication state and operations
- **ProductHandler**: Product management operations
- **ConfigHandler**: Application settings and theme management

#### 💾 Data Layer (`src/local_db/`, `src/api_client/`)
- **Local Database**: SQLite with SQLAlchemy ORM
- **API Client**: Supabase REST API integration
- **Sync Manager**: Bidirectional data synchronization

#### 🔧 Business Logic (`src/business_logic/`)
- **AuthService**: Authentication and authorization
- **ProductService**: Product management business rules
- **Automatic Fallback**: Online/offline mode switching

#### 🎨 Frontend (`src/qml/`)
- **Screens**: Loading, Login, Main Application
- **Views**: Dashboard, Products, Settings
- **Components**: Reusable UI elements
- **Theme System**: Dynamic theming support

## ⚙️ Configuration

### Environment Settings (`instance_settings.json`)

```json
{
  "app": {
    "name": "ChaOffice Core",
    "version": "0.1.0",
    "theme": "light",
    "auto_sync_interval": 900
  },
  "database": {
    "local_db_path": "./data/chaoffice.db",
    "auto_backup": true
  },
  "supabase": {
    "url": "https://your-project.supabase.co",
    "key": "your-anon-key",
    "service_role_key": "your-service-role-key"
  },
  "logging": {
    "level": "INFO",
    "file_path": "./logs/chaoffice.log",
    "max_file_size": "10MB",
    "backup_count": 5
  }
}
```

### Database Schema

The application uses the following core models:

- **User**: Authentication and user management
- **Product**: Inventory and product catalog
- **SyncRecord**: Data synchronization tracking

## 🔧 Development

### Setting up Development Environment

1. **Install development dependencies**
   ```bash
   uv install --group dev
   ```

2. **Run tests**
   ```bash
   uv run pytest
   ```

3. **Code formatting**
   ```bash
   uv run black src/
   uv run flake8 src/
   ```

### Adding New Features

1. **Backend Logic**: Add to `src/business_logic/`
2. **QML Interface**: Extend `src/qml_handlers/qml_bridge.py`
3. **UI Components**: Create in `src/qml/components/`
4. **Views**: Add to `src/qml/views/`

### Custom Themes

Extend the theme system by modifying `src/qml/styles/Theme.qml`:

```qml
// Add custom color schemes
readonly property var customColors: ({
    primary: "#your-color",
    // ... other colors
})
```

## 📱 Usage

### Login
- **Online Mode**: Use your Supabase credentials
- **Offline Mode**: Click "Continue Offline" for local access

### Product Management
- **Add Products**: Use the "Add Product" button
- **Search & Filter**: Real-time search and category filtering
- **Bulk Operations**: Select multiple products for batch actions

### Settings
- **Theme**: Switch between light and dark modes
- **Sync**: Configure automatic synchronization intervals
- **Database**: Backup and restore local data

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **PySide6**: Qt for Python framework
- **Supabase**: Backend-as-a-Service platform
- **SQLAlchemy**: Python SQL toolkit
- **Loguru**: Modern logging library
- **uv**: Fast Python package manager

## 📞 Support

- **Documentation**: [Wiki](https://github.com/yourusername/chaoffice/wiki)
- **Issues**: [GitHub Issues](https://github.com/yourusername/chaoffice/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/chaoffice/discussions)

---

**Built with ❤️ using PySide6 and QML**
