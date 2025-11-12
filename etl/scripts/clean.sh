#!/bin/bash

set -e

echo "🧹 Cleaning Airflow ETL Infrastructure..."
echo ""
echo "⚠️  WARNING: This will:"
echo "   - Stop all services"
echo "   - Remove all containers"
echo "   - Remove all volumes (DATABASE DATA WILL BE LOST)"
echo "   - Remove logs"
echo ""
read -p "Are you sure? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "❌ Cleanup cancelled"
    exit 0
fi

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

echo ""
echo "🛑 Stopping services..."
docker compose -f docker/docker-compose.yml --env-file .env down -v

echo "🗑️  Removing logs..."
rm -rf logs/*
mkdir -p logs

echo "✅ Cleanup complete!"
echo ""
echo "💡 To start fresh, run: make start (or scripts/start.sh)"

