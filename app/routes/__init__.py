"""Routes package."""
from app.routes.health import health_bp
from app.routes.status import status_bp

__all__ = ["health_bp", "status_bp"]
