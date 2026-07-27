"""Pytest configuration and fixtures."""
import pytest
from app import create_app


@pytest.fixture
def app():
    """Create and configure a test application instance."""
    app = create_app("testing")
    yield app


@pytest.fixture
def client(app):
    """Create a test client for the app."""
    return app.test_client()


@pytest.fixture
def runner(app):
    """Create a test CLI runner for the app."""
    return app.test_cli_runner()
