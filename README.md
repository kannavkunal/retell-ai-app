# Retell AI App

A Flask-based REST API server for Retell AI integration with health check endpoint.

## Features

- ✅ Flask REST API running on port 8000
- ✅ Health check endpoint (`GET /health`)
- ✅ Comprehensive test suite with pytest
- ✅ Code linting with Flake8 and Pylint
- ✅ Code formatting with Black
- ✅ Docker support with multi-stage builds
- ✅ Production-ready with Gunicorn

## Project Structure

```
retell-ai-app/
├── app/
│   ├── __init__.py          # Flask app factory
│   ├── config.py            # Configuration
│   └── routes/
│       ├── __init__.py
│       └── health.py        # Health endpoint
├── tests/
│   ├── __init__.py
│   ├── conftest.py          # Pytest fixtures
│   └── test_health.py       # Health endpoint tests
├── .flake8                  # Flake8 configuration
├── .pylintrc                # Pylint configuration
├── Dockerfile               # Docker configuration
├── requirements.txt         # Production dependencies
├── requirements-dev.txt     # Development dependencies
├── pyproject.toml          # Black & pytest configuration
└── run.py                  # Application entry point
```

## Prerequisites

- Python 3.11+
- Docker (optional, for containerized deployment)

## Local Setup

### 1. Clone the repository

```bash
git clone git@github.com:kannavkunal/retell-ai-app.git
cd retell-ai-app
```

### 2. Create virtual environment

```bash
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

### 3. Install dependencies

```bash
# Production dependencies
pip install -r requirements.txt

# Development dependencies (includes testing and linting tools)
pip install -r requirements-dev.txt
```

### 4. Run the server

```bash
python run.py
```

The server will start on `http://localhost:8000`

### 5. Test the health endpoint

```bash
curl http://localhost:8000/health
```

Expected response:
```json
{
  "status": "healthy",
  "message": "Service is running"
}
```

## Running Tests

### Run all tests

```bash
pytest
```

### Run with coverage

```bash
pytest --cov=app --cov-report=term-missing
```

### Run specific test file

```bash
pytest tests/test_health.py
```

## Code Quality

### Linting

```bash
# Flake8
flake8 app/ tests/

# Pylint
pylint app/ tests/
```

### Formatting

```bash
# Check formatting
black --check app/ tests/

# Auto-format
black app/ tests/
```

## Docker

### Build the Docker image

```bash
docker build -t retell-ai-app .
```

### Run the container

```bash
docker run -p 8000:8000 retell-ai-app
```

### Test the containerized app

```bash
curl http://localhost:8000/health
```

### Advanced Docker usage

```bash
# Run with environment variables
docker run -p 8000:8000 -e FLASK_ENV=development retell-ai-app

# Run in detached mode
docker run -d -p 8000:8000 --name retell-api retell-ai-app

# View logs
docker logs retell-api

# Stop container
docker stop retell-api
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `FLASK_ENV` | Environment (development/production) | `production` |
| `FLASK_DEBUG` | Enable debug mode | `False` |
| `HOST` | Server host | `0.0.0.0` |
| `PORT` | Server port | `8000` |

## API Endpoints

### Health Check

**Endpoint:** `GET /health`

**Response:**
```json
{
  "status": "healthy",
  "message": "Service is running"
}
```

**Status Code:** `200 OK`

## Development

### Project conventions

- Code formatted with Black (100 char line length)
- Linted with Flake8 and Pylint
- Tests written with pytest
- Type hints encouraged for public APIs
- Docstrings for all functions and classes

### Adding new routes

1. Create a new blueprint in `app/routes/`
2. Register it in `app/__init__.py`
3. Add tests in `tests/`

Example:
```python
# app/routes/example.py
from flask import Blueprint, jsonify

example_bp = Blueprint('example', __name__)

@example_bp.route('/example', methods=['GET'])
def example():
    return jsonify({'message': 'Hello'}), 200
```

## Deployment

### Using Gunicorn (recommended for production)

```bash
gunicorn --bind 0.0.0.0:8000 --workers 4 run:app
```

### Using Docker Compose (coming soon)

A `docker-compose.yml` can be added for orchestrating multiple services.

## Contributing

1. Create a feature branch
2. Make your changes
3. Run tests and linting
4. Submit a pull request

## License

MIT License

## Author

Kunal Kannav
