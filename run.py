"""Application entry point."""
import os
from app import create_app

# Get configuration from environment
config_name = os.getenv("FLASK_ENV", "production")
app = create_app(config_name)

if __name__ == "__main__":
    # Get port from config
    port = app.config.get("PORT", 8000)
    host = app.config.get("HOST", "0.0.0.0")

    print(f"Starting server on {host}:{port}")
    app.run(host=host, port=port)
