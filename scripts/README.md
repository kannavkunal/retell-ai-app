# Deployment Scripts

Collection of scripts for deploying and managing the Retell AI App.

## Scripts

### `deploy-local.sh`

Deploy the Docker image locally from GitHub Container Registry.

**Features:**
- Pulls latest image from GHCR
- Runs container on port 8000
- Auto-restart on crashes (`--restart unless-stopped`)
- Health check verification with retry logic
- Cleans up existing containers

**Prerequisites:**

The Docker image needs to be accessible. You have two options:

**Option 1: Make the package public (Recommended for testing)**
1. Go to: https://github.com/kannavkunal/retell-ai-app/pkgs/container/retell-ai-app
2. Click "Package settings"
3. Scroll to "Danger Zone"
4. Click "Change visibility" → Select "Public"

**Option 2: Use authentication (For private packages)**
```bash
# Create a GitHub Personal Access Token with read:packages scope
# Then authenticate:
export GITHUB_TOKEN=your_github_token
./scripts/deploy-local.sh
```

**Usage:**

```bash
# Deploy with latest tag
./scripts/deploy-local.sh

# Deploy specific tag
IMAGE_TAG=main-c036c8a ./scripts/deploy-local.sh

# Deploy on custom port
PORT=9000 ./scripts/deploy-local.sh

# Deploy specific tag on custom port
IMAGE_TAG=main-c036c8a PORT=9000 ./scripts/deploy-local.sh
```

**Environment Variables:**
- `IMAGE_TAG` - Docker image tag (default: `latest`)
- `PORT` - Local port to expose (default: `8000`)

**What it does:**
1. Pulls image from `ghcr.io/kannavkunal/retell-ai-app`
2. Stops and removes existing container (if any)
3. Starts new container with restart policy
4. Waits up to 60 seconds for health check to pass
5. Displays container info and useful commands

**Example Output:**
```
========================================
Deploying Retell AI App Locally
========================================

[1/4] Pulling Docker image from GHCR...
Image: ghcr.io/kannavkunal/retell-ai-app:latest
✓ Image pulled successfully

[2/4] Cleaning up existing container...
✓ Ready to start

[3/4] Starting container...
Container name: retell-ai-app
Port mapping: 8000:8000
Restart policy: unless-stopped
✓ Container started successfully

[4/4] Verifying health endpoint...
Health endpoint: http://localhost:8000/health
✓ Health check passed!

========================================
Deployment Successful! 🚀
========================================
```

**Container Restart Policy:**

The container uses `--restart unless-stopped`, which means:
- ✅ Restarts automatically on crashes
- ✅ Restarts after Docker daemon restarts
- ✅ Restarts after system reboots
- ❌ Does NOT restart if manually stopped with `docker stop`

**Troubleshooting:**

If deployment fails, check:
```bash
# View container logs
docker logs retell-ai-app

# Check container status
docker ps -a | grep retell-ai-app

# Inspect container
docker inspect retell-ai-app

# Test health endpoint manually
curl http://localhost:8000/health
```

**Managing the Service:**

```bash
# View logs
docker logs retell-ai-app

# Follow logs in real-time
docker logs -f retell-ai-app

# Stop the service
docker stop retell-ai-app

# Start the service
docker start retell-ai-app

# Restart the service
docker restart retell-ai-app

# Remove the service
docker rm -f retell-ai-app

# Test crash recovery (force kill)
docker kill retell-ai-app
# Wait a few seconds - container should auto-restart
docker ps | grep retell-ai-app
```
