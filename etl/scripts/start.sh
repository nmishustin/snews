#!/bin/bash

set -e

echo "🚀 Starting Airflow ETL Infrastructure..."

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    echo "❌ docker-compose not found. Please install Docker Compose."
    exit 1
fi

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Start services
cd "$PROJECT_ROOT" && docker-compose -f docker/docker-compose.yml up -d

echo ""
echo "⏳ Waiting for services to become healthy..."
sleep 10

# Show status
cd "$PROJECT_ROOT" && docker-compose -f docker/docker-compose.yml ps

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
echo "   Username: admin"
echo "   Password: check logs with: ./logs.sh airflow-standalone | grep 'Password for user'"
echo ""
echo "📝 Useful commands:"
echo "   ./logs.sh [service]  - View logs"
echo "   ./stop.sh            - Stop all services"
echo "   ./restart.sh         - Restart services"
echo "   ./status.sh          - Check status"

