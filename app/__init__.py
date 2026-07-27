"""Flask application factory."""
from flask import Flask
from app.config import config
from app.routes import health_bp


def create_app(config_name="default"):
    """
    Create and configure the Flask application.

    Args:
        config_name: Configuration name (development, testing, production, default)

    Returns:
        Configured Flask application instance
    """
    app = Flask(__name__)
    app.config.from_object(config[config_name])

    # Register blueprints
    app.register_blueprint(health_bp)

    return app
