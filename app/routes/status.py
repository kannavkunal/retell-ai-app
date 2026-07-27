"""Status information route."""
from datetime import datetime, timezone

from flask import Blueprint, jsonify

status_bp = Blueprint("status", __name__)


@status_bp.route("/status", methods=["GET"])
def get_status():
    """
    Get application status information.

    Returns:
        JSON response with application status details
    """
    return (
        jsonify(
            {
                "status": "operational",
                "timestamp": datetime.now(timezone.utc).isoformat(),
                "version": "1.0.0",
                "service": "retell-ai-app",
            }
        ),
        200,
    )
