#!/bin/bash

# Stop Local Deployment
# This script stops and removes the locally running container

set -e

CONTAINER_NAME="retell-ai-app"

echo "Stopping container: ${CONTAINER_NAME}"
docker stop "${CONTAINER_NAME}" 2>/dev/null || echo "Container not running"

echo "Removing container: ${CONTAINER_NAME}"
docker rm "${CONTAINER_NAME}" 2>/dev/null || echo "Container already removed"

echo "✓ Service stopped and removed"
