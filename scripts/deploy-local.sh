#!/bin/bash

# Deploy Service Locally
# This script pulls the Docker image from GHCR and runs it locally with auto-restart

set -e  # Exit on error

# Configuration
IMAGE_NAME="ghcr.io/kannavkunal/retell-ai-app"
IMAGE_TAG="${IMAGE_TAG:-latest}"
CONTAINER_NAME="retell-ai-app"
PORT="${PORT:-8000}"
HEALTH_ENDPOINT="http://localhost:${PORT}/health"
MAX_RETRIES=30
RETRY_DELAY=2

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Deploying Retell AI App Locally${NC}"
echo -e "${YELLOW}========================================${NC}"
echo ""

# Check if GitHub token is needed for private packages
if [ -n "${GITHUB_TOKEN}" ]; then
    echo -e "${YELLOW}[1/5] Authenticating with GitHub Container Registry...${NC}"
    echo "${GITHUB_TOKEN}" | docker login ghcr.io -u "${GITHUB_USER:-$(whoami)}" --password-stdin
    echo -e "${GREEN}✓ Authenticated successfully${NC}\n"
    STEP_OFFSET=1
else
    echo -e "${YELLOW}Note: If the image is private, set GITHUB_TOKEN environment variable${NC}"
    echo -e "${YELLOW}Example: export GITHUB_TOKEN=your_token${NC}\n"
    STEP_OFFSET=0
fi

# Step 1: Pull the latest Docker image
echo -e "${YELLOW}[$((1 + STEP_OFFSET))/4] Pulling Docker image from GHCR...${NC}"
echo "Image: ${IMAGE_NAME}:${IMAGE_TAG}"

# Detect platform
PLATFORM=$(uname -m)
if [ "$PLATFORM" = "arm64" ] || [ "$PLATFORM" = "aarch64" ]; then
    echo "Detected ARM64 architecture - pulling ARM64 image"
    docker pull --platform linux/arm64 "${IMAGE_NAME}:${IMAGE_TAG}" 2>/dev/null || \
        docker pull --platform linux/amd64 "${IMAGE_NAME}:${IMAGE_TAG}"
else
    docker pull "${IMAGE_NAME}:${IMAGE_TAG}"
fi

echo -e "${GREEN}✓ Image pulled successfully${NC}\n"

# Step 2: Stop and remove existing container if it exists
echo -e "${YELLOW}[$((2 + STEP_OFFSET))/4] Cleaning up existing container...${NC}"
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Stopping existing container: ${CONTAINER_NAME}"
    docker stop "${CONTAINER_NAME}" 2>/dev/null || true
    echo "Removing existing container: ${CONTAINER_NAME}"
    docker rm "${CONTAINER_NAME}" 2>/dev/null || true
    echo -e "${GREEN}✓ Existing container removed${NC}\n"
else
    echo "No existing container found"
    echo -e "${GREEN}✓ Ready to start${NC}\n"
fi

# Step 3: Run the container with restart policy
echo -e "${YELLOW}[$((3 + STEP_OFFSET))/4] Starting container...${NC}"
echo "Container name: ${CONTAINER_NAME}"
echo "Port mapping: ${PORT}:8000"
echo "Restart policy: unless-stopped"

docker run -d \
    --name "${CONTAINER_NAME}" \
    --restart unless-stopped \
    -p "${PORT}:8000" \
    "${IMAGE_NAME}:${IMAGE_TAG}"

echo -e "${GREEN}✓ Container started successfully${NC}\n"

# Step 4: Wait for container to be healthy
echo -e "${YELLOW}[$((4 + STEP_OFFSET))/4] Verifying health endpoint...${NC}"
echo "Health endpoint: ${HEALTH_ENDPOINT}"
echo "Max retries: ${MAX_RETRIES}"

retry_count=0
while [ $retry_count -lt $MAX_RETRIES ]; do
    if curl -f -s "${HEALTH_ENDPOINT}" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Health check passed!${NC}\n"

        # Display health response
        echo -e "${GREEN}Health endpoint response:${NC}"
        curl -s "${HEALTH_ENDPOINT}" | python3 -m json.tool 2>/dev/null || curl -s "${HEALTH_ENDPOINT}"
        echo ""

        # Success summary
        echo -e "${GREEN}========================================${NC}"
        echo -e "${GREEN}Deployment Successful! 🚀${NC}"
        echo -e "${GREEN}========================================${NC}"
        echo -e "Container: ${CONTAINER_NAME}"
        echo -e "Image: ${IMAGE_NAME}:${IMAGE_TAG}"
        echo -e "Port: ${PORT}"
        echo -e "Health: ${HEALTH_ENDPOINT}"
        echo -e "Status endpoint: http://localhost:${PORT}/status"
        echo ""
        echo -e "Useful commands:"
        echo -e "  View logs:    docker logs ${CONTAINER_NAME}"
        echo -e "  Follow logs:  docker logs -f ${CONTAINER_NAME}"
        echo -e "  Stop:         docker stop ${CONTAINER_NAME}"
        echo -e "  Restart:      docker restart ${CONTAINER_NAME}"
        echo -e "  Remove:       docker rm -f ${CONTAINER_NAME}"
        echo ""

        exit 0
    fi

    retry_count=$((retry_count + 1))
    echo "Attempt $retry_count/$MAX_RETRIES - Waiting for service to be ready..."
    sleep $RETRY_DELAY
done

# Health check failed
echo -e "${RED}✗ Health check failed after ${MAX_RETRIES} attempts${NC}"
echo -e "${RED}Container logs:${NC}"
docker logs "${CONTAINER_NAME}" --tail 50
echo ""
echo -e "${RED}Deployment failed!${NC}"
exit 1
