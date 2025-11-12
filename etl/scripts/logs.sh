#!/bin/bash

SERVICE=$1
TAIL=${2:-100}

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

if [ -z "$SERVICE" ]; then
    echo "📋 Available services:"
    docker-compose -f docker/docker-compose.yml --env-file .env ps --services
    echo ""
    echo "Usage: scripts/logs.sh <service> [lines]"
    echo "Example: scripts/logs.sh airflow-webserver 50"
    echo ""
    echo "To follow logs: docker-compose -f docker/docker-compose.yml --env-file .env logs -f <service>"
    exit 0
fi

echo "📋 Showing last $TAIL lines for $SERVICE..."
echo ""
docker-compose -f docker/docker-compose.yml --env-file .env logs --tail "$TAIL" "$SERVICE"

