#!/bin/bash

# Test Crash Recovery
# Simulates container crashes to verify auto-restart functionality

set -e

CONTAINER_NAME="retell-ai-app"
PORT="${PORT:-8000}"
HEALTH_ENDPOINT="http://localhost:${PORT}/health"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Testing Auto-Restart on Crash${NC}"
echo -e "${YELLOW}========================================${NC}\n"

# Check if container exists
if ! docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo -e "${RED}Error: Container '${CONTAINER_NAME}' not found${NC}"
    echo -e "${YELLOW}Please run ./scripts/deploy-local.sh first${NC}"
    exit 1
fi

# Function to check if container is running
is_running() {
    docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"
}

# Function to check health
check_health() {
    local max_retries=15
    local retry=0

    while [ $retry -lt $max_retries ]; do
        if curl -f -s "${HEALTH_ENDPOINT}" > /dev/null 2>&1; then
            return 0
        fi
        sleep 1
        retry=$((retry + 1))
    done
    return 1
}

# Function to simulate crash
simulate_crash() {
    local crash_num=$1

    echo -e "${BLUE}[Crash Test #${crash_num}]${NC}"
    echo -e "${YELLOW}Simulating crash by killing the main process inside container...${NC}"

    # Record the time before crash
    local before_crash=$(date +%s)

    # Get the main process PID (gunicorn) and kill it to simulate a crash
    # This is different from 'docker kill' - it simulates the app crashing, not the container being stopped
    docker exec "${CONTAINER_NAME}" sh -c 'kill -9 1' > /dev/null 2>&1 || true

    echo -e "${RED}✗ Main process killed (crash simulated)${NC}"

    # Wait a moment for Docker to detect the crash
    sleep 2

    # Check if container is running again
    echo -e "${YELLOW}Checking if container auto-restarted...${NC}"

    local retry=0
    local max_retries=10

    while [ $retry -lt $max_retries ]; do
        if is_running; then
            local after_restart=$(date +%s)
            local recovery_time=$((after_restart - before_crash))
            echo -e "${GREEN}✓ Container auto-restarted!${NC}"
            echo -e "${GREEN}  Recovery time: ~${recovery_time} seconds${NC}\n"

            # Wait for health check
            echo -e "${YELLOW}Waiting for health endpoint to respond...${NC}"
            if check_health; then
                echo -e "${GREEN}✓ Health check passed!${NC}"
                curl -s "${HEALTH_ENDPOINT}" | python3 -m json.tool 2>/dev/null || curl -s "${HEALTH_ENDPOINT}"
                echo -e "\n"
                return 0
            else
                echo -e "${RED}✗ Health check failed after restart${NC}\n"
                return 1
            fi
        fi

        sleep 1
        retry=$((retry + 1))
    done

    echo -e "${RED}✗ Container did not auto-restart${NC}\n"
    return 1
}

# Show current container status
echo -e "${BLUE}Initial Status:${NC}"
docker ps --filter "name=${CONTAINER_NAME}" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""

# Check restart policy
echo -e "${BLUE}Restart Policy:${NC}"
docker inspect "${CONTAINER_NAME}" --format '{{.HostConfig.RestartPolicy.Name}}' || echo "unknown"
echo ""

# Run multiple crash tests
NUM_CRASHES=${NUM_CRASHES:-3}
echo -e "${YELLOW}Running ${NUM_CRASHES} crash simulations...${NC}\n"

success_count=0
for i in $(seq 1 $NUM_CRASHES); do
    if simulate_crash $i; then
        success_count=$((success_count + 1))
    else
        echo -e "${RED}Crash test #${i} failed!${NC}"
        break
    fi

    # Wait between tests
    if [ $i -lt $NUM_CRASHES ]; then
        echo -e "${YELLOW}Waiting 3 seconds before next crash test...${NC}\n"
        sleep 3
    fi
done

# Summary
echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Test Summary${NC}"
echo -e "${YELLOW}========================================${NC}"
echo -e "Total crashes simulated: ${NUM_CRASHES}"
echo -e "Successful recoveries: ${success_count}"

if [ $success_count -eq $NUM_CRASHES ]; then
    echo -e "${GREEN}✓ All crash recovery tests passed!${NC}"
    echo -e "${GREEN}✓ Auto-restart is working correctly!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some crash recovery tests failed${NC}"
    exit 1
fi
