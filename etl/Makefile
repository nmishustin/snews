.PHONY: start stop restart status logs rebuild clean exec help

help:
	@echo "🚀 Airflow ETL Infrastructure Commands"
	@echo ""
	@echo "Main commands:"
	@echo "  make start          - Start all services"
	@echo "  make stop           - Stop all services"
	@echo "  make restart        - Restart all services"
	@echo "  make status         - Show services status"
	@echo "  make logs           - Show logs (use SERVICE=name for specific service)"
	@echo ""
	@echo "Additional commands:"
	@echo "  make rebuild        - Rebuild Docker image"
	@echo "  make clean          - Clean everything (removes data!)"
	@echo "  make exec           - Execute command in container (use SERVICE=name CMD='command')"
	@echo ""
	@echo "Examples:"
	@echo "  make logs SERVICE=airflow-standalone"
	@echo "  make restart SERVICE=airflow-standalone"
	@echo "  make exec SERVICE=airflow-standalone CMD='airflow dags list'"

start:
	@scripts/start.sh

stop:
	@scripts/stop.sh

restart:
ifdef SERVICE
	@scripts/restart.sh $(SERVICE)
else
	@scripts/restart.sh
endif

status:
	@scripts/status.sh

logs:
ifdef SERVICE
	@scripts/logs.sh $(SERVICE) $(LINES)
else
	@scripts/logs.sh
endif

rebuild:
	@scripts/rebuild.sh

clean:
	@scripts/clean.sh

exec:
ifdef SERVICE
	@scripts/exec.sh $(SERVICE) $(CMD)
else
	@scripts/exec.sh
endif

