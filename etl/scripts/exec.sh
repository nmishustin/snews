#!/bin/bash

SERVICE=${1:-airflow-standalone}
shift

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

if [ $# -eq 0 ]; then
    echo "🔧 Opening shell in $SERVICE..."
    docker-compose -f docker/docker-compose.yml --env-file .env exec "$SERVICE" /bin/bash
else
    echo "🔧 Executing command in $SERVICE..."
    docker-compose -f docker/docker-compose.yml --env-file .env exec "$SERVICE" "$@"
fi

