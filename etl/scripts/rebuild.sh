#!/bin/bash

set -e

echo "🔨 Rebuilding Airflow Docker image..."

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

# Stop services
echo "🛑 Stopping services..."
docker compose -f docker/docker-compose.yml --env-file .env down

# Rebuild
echo "🏗️  Building new image..."
docker compose -f docker/docker-compose.yml --env-file .env build --no-cache

# Start services
echo "🚀 Starting services with new image..."
docker compose -f docker/docker-compose.yml --env-file .env up -d

echo ""
echo "⏳ Waiting for services to start..."
sleep 15

docker compose -f docker/docker-compose.yml --env-file .env ps

echo ""
echo "✅ Rebuild complete!"

