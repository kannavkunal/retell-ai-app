"""Tests for status endpoint."""
from datetime import datetime

import pytest


def test_status_endpoint_returns_200(client):
    """Test that status endpoint returns 200 status code."""
    response = client.get("/status")
    assert response.status_code == 200


def test_status_endpoint_returns_json(client):
    """Test that status endpoint returns JSON response."""
    response = client.get("/status")
    assert response.content_type == "application/json"


def test_status_endpoint_contains_required_fields(client):
    """Test that status endpoint returns all required fields."""
    response = client.get("/status")
    data = response.get_json()

    assert "status" in data
    assert "timestamp" in data
    assert "version" in data
    assert "service" in data


def test_status_endpoint_values(client):
    """Test that status endpoint returns correct values."""
    response = client.get("/status")
    data = response.get_json()

    assert data["status"] == "operational"
    assert data["version"] == "1.0.0"
    assert data["service"] == "retell-ai-app"


def test_status_timestamp_format(client):
    """Test that timestamp is in valid ISO 8601 format."""
    response = client.get("/status")
    data = response.get_json()

    try:
        datetime.fromisoformat(data["timestamp"])
    except ValueError:
        pytest.fail("Timestamp is not in valid ISO 8601 format")
