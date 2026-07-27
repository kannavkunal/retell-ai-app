"""Tests for health check endpoint."""
import json


def test_health_endpoint_returns_200(client):
    """Test that health endpoint returns 200 status code."""
    response = client.get("/health")
    assert response.status_code == 200


def test_health_endpoint_returns_json(client):
    """Test that health endpoint returns JSON response."""
    response = client.get("/health")
    assert response.content_type == "application/json"


def test_health_endpoint_response_structure(client):
    """Test that health endpoint returns correct response structure."""
    response = client.get("/health")
    data = json.loads(response.data)

    assert "status" in data
    assert "message" in data
    assert data["status"] == "healthy"
    assert data["message"] == "Service is running"
