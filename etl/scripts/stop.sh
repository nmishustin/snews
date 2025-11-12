#!/bin/bash

set -e

echo "🛑 Stopping Airflow ETL Infrastructure..."

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT" && docker compose -f docker/docker-compose.yml --env-file .env down

echo "✅ All services stopped!"
echo ""
echo "💡 To remove volumes (database data), run: cd $PROJECT_ROOT && docker compose -f docker/docker-compose.yml down -v"

