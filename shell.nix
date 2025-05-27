{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    git
    neovim
    python3
    python3Packages.pip
    python3Packages.uv # For uv environment management
    python3Packages.pyside6
    python3Packages.sqlalchemy
    python3Packages.pydantic
    python3Packages.bcrypt
    python3Packages.loguru
    # Using qt6.full should pull in all necessary Qt components including qml and base
    qt6.full
    sqlite-interactive
  ];

  # Set environment variables for PySide6 to find QML modules and plugins
  # The paths are now directly referencing the output of qt6.full
  shellHook = ''
    export QT_QPA_PLATFORM_PLUGIN_PATH=${pkgs.qt6.full}/lib/qt-6/plugins
    export QML_IMPORT_PATH=${pkgs.qt6.full}/lib/qt-6/qml
    export QML2_IMPORT_PATH=${pkgs.qt6.full}/lib/qt-6/qml
    echo "Nix-shell environment for PySide6 is active."
    echo "Run 'uv venv && uv pip install -e . && uv run python src/local_db/init_local_db.py' to set up Python environment and database."
    echo "Then run 'uv run python src/main.py' to start the application."
  '';
}
