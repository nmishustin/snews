#!/bin/bash

set -e

SERVICE=$1

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

if [ -z "$SERVICE" ]; then
    echo "🔄 Restarting all services..."
    docker-compose -f docker/docker-compose.yml restart
    echo "✅ All services restarted!"
else
    echo "🔄 Restarting $SERVICE..."
    docker-compose -f docker/docker-compose.yml restart "$SERVICE"
    echo "✅ Service $SERVICE restarted!"
fi

echo ""
docker-compose -f docker/docker-compose.yml ps

