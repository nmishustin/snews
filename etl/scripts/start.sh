#!/bin/bash

set -e

echo "🚀 Starting Airflow ETL Infrastructure..."

# Check if docker compose is available
if ! docker compose version &> /dev/null; then
    echo "❌ docker compose not found. Please install Docker Compose."
    exit 1
fi

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Check .env file exists
if [ ! -f "$PROJECT_ROOT/.env" ]; then
    echo "❌ .env file not found!"
    echo "Please copy .env.example to .env and configure it:"
    echo "  cp .env.example .env"
    exit 1
fi

# Start services
cd "$PROJECT_ROOT" && docker compose -f docker/docker-compose.yml --env-file .env up -d

echo ""
echo "⏳ Waiting for services to become healthy..."
sleep 10

# Show status
cd "$PROJECT_ROOT" && docker compose -f docker/docker-compose.yml --env-file .env ps

echo ""
echo "✅ Airflow infrastructure started!"
echo ""
echo "📊 Access points:"
echo "   - Airflow UI: http://localhost:8080"
echo "   - Flower (Celery): http://localhost:5555"
echo "   - MySQL: localhost:3306"
echo "   - Redis: localhost:6379"
echo ""
echo "🔑 Default credentials:"
echo "   Username: Check .env file (AIRFLOW_ADMIN_USERNAME)"
echo "   Password: Check .env file (AIRFLOW_ADMIN_PASSWORD)"
echo ""
echo "📝 Useful commands:"
echo "   ./logs.sh [service]  - View logs"
echo "   ./stop.sh            - Stop all services"
echo "   ./restart.sh         - Restart services"
echo "   ./status.sh          - Check status"

