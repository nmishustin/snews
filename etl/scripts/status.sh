#!/bin/bash

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

echo "📊 Airflow ETL Infrastructure Status"
echo "===================================="
echo ""

docker compose -f docker/docker-compose.yml --env-file .env ps

echo ""
echo "💾 Docker Resources:"
docker compose -f docker/docker-compose.yml --env-file .env exec mysql mysql -u$(grep MYSQL_USER .env | cut -d '=' -f2) -p$(grep MYSQL_PASSWORD .env | cut -d '=' -f2) -e "SELECT COUNT(*) as 'Total DAGs' FROM airflow.dag;" 2>/dev/null || echo "   MySQL not accessible"

echo ""
echo "📊 Quick Health Check:"
curl -s http://localhost:8080/health 2>/dev/null && echo "   ✅ Airflow UI is up" || echo "   ❌ Airflow UI is down"
curl -s http://localhost:5555 > /dev/null 2>&1 && echo "   ✅ Flower is up" || echo "   ⚠️  Flower is not accessible (expected with standalone mode)"

