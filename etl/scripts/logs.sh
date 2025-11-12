#!/bin/bash

SERVICE=$1
TAIL=${2:-100}

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

if [ -z "$SERVICE" ]; then
    echo "📋 Available services:"
    docker-compose -f docker/docker-compose.yml ps --services
    echo ""
    echo "Usage: scripts/logs.sh <service> [lines]"
    echo "Example: scripts/logs.sh airflow-standalone 50"
    echo ""
    echo "To follow logs: docker-compose -f docker/docker-compose.yml logs -f <service>"
    exit 0
fi

echo "📋 Showing last $TAIL lines for $SERVICE..."
echo ""
docker-compose -f docker/docker-compose.yml logs --tail "$TAIL" "$SERVICE"

