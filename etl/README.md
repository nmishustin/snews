# Airflow ETL Infrastructure

Инфраструктура для ETL процессов на базе Apache Airflow 3.1.0 с MySQL и Redis.

## 🚀 Быстрый старт

### Запуск окружения

```bash
make start
# или
scripts/start.sh
```

Это запустит все сервисы:
- Airflow Standalone (scheduler, api-server, triggerer)
- MySQL (база данных)
- Redis (message broker)
- Celery Worker
- Flower (мониторинг Celery)

### Остановка окружения

```bash
make stop
# или
scripts/stop.sh
```

### Перезапуск сервисов

```bash
# Перезапустить все сервисы
make restart

# Перезапустить конкретный сервис
make restart SERVICE=airflow-standalone
# или
scripts/restart.sh airflow-standalone
```

## 📊 Доступ к сервисам

| Сервис | URL | Описание |
|--------|-----|----------|
| Airflow UI | http://localhost:8080 | Веб-интерфейс Airflow |
| Flower | http://localhost:5555 | Мониторинг Celery (не работает в standalone режиме) |
| MySQL | localhost:3306 | База данных |
| Redis | localhost:6379 | Message broker |

### Учетные данные

**Airflow UI:**
- Username: `admin`
- Password: Генерируется автоматически при первом запуске, смотри в логах:
  ```bash
  make logs SERVICE=airflow-standalone | grep "Password for user"
  # или
  scripts/logs.sh airflow-standalone | grep "Password for user"
  ```
  
  Пример вывода:
  ```
  Simple auth manager | Password for user 'admin': abc123XYZ
  ```

**MySQL:**
- User: `airflow`
- Password: `airflow`
- Database: `airflow` (метаданные Airflow), `snews` (для DAG'ов)

## 📝 Управляющие команды

### Использование Makefile (рекомендуется)

```bash
make help  # Показать все доступные команды
```

### Основные команды

| Команда | Описание | Пример |
|---------|----------|--------|
| `make start` | Запустить все сервисы | `make start` |
| `make stop` | Остановить все сервисы | `make stop` |
| `make restart` | Перезапустить сервис(ы) | `make restart SERVICE=airflow-standalone` |
| `make status` | Показать статус сервисов | `make status` |
| `make logs` | Показать логи сервиса | `make logs SERVICE=airflow-standalone` |

### Дополнительные команды

| Команда | Описание | Пример |
|---------|----------|--------|
| `make rebuild` | Пересобрать Docker образ | `make rebuild` |
| `make exec` | Выполнить команду в контейнере | `make exec SERVICE=airflow-standalone CMD='bash'` |
| `make clean` | Очистить всё (включая БД!) | `make clean` |

### Альтернатива: прямые скрипты

Все скрипты находятся в папке `scripts/`:

```bash
scripts/start.sh
scripts/stop.sh
scripts/restart.sh [service]
scripts/status.sh
scripts/logs.sh <service> [lines]
scripts/rebuild.sh
scripts/exec.sh [service] [cmd]
scripts/clean.sh
```

## 📂 Структура проекта

```
etl/
├── docker/           # Docker конфигурация
│   ├── docker-compose.yml  # Конфигурация сервисов
│   ├── Dockerfile          # Образ Airflow
│   └── create_user.py      # Скрипт создания пользователя
├── scripts/          # Управляющие скрипты
│   ├── start.sh      # Запуск окружения
│   ├── stop.sh       # Остановка окружения
│   ├── restart.sh    # Перезапуск сервисов
│   ├── status.sh     # Статус сервисов
│   ├── logs.sh       # Просмотр логов
│   ├── rebuild.sh    # Пересборка образа
│   ├── exec.sh       # Выполнение команд в контейнере
│   └── clean.sh      # Очистка окружения
├── dags/             # DAG файлы
│   └── test.py       # Пример DAG
├── logs/             # Логи Airflow (в .gitignore)
├── plugins/          # Airflow plugins (создается автоматически)
├── .gitignore        # Git ignore для Airflow
├── requirements.txt  # Python зависимости
├── Makefile          # Удобные команды make
├── README.md         # Документация
└── ARCHITECTURE.md   # Архитектурная документация
```

## 🛠️ Разработка DAG'ов

### Создание нового DAG

1. Создайте файл в директории `dags/`:

```python
from airflow.sdk import dag, task
from datetime import datetime


@task
def my_task():
    print("Hello from my task!")


@dag(
    dag_id="my_dag",
    schedule="0 0 * * *",  # Ежедневно в полночь
    start_date=datetime(2025, 1, 1),
    catchup=False,
)
def my_dag():
    my_task()


dag_instance = my_dag()
```

2. DAG появится в UI через 10 секунд (настройка `DAG_DIR_LIST_INTERVAL`)

### Структура DAG (best practices)

Рекомендуемая структура для сложных DAG'ов:

```
dags/
├── my_dag/
│   ├── dag.py              # Основной DAG файл
│   ├── tasks.py            # Task функции (@task)
│   ├── const.py            # Константы
│   ├── settings.py         # Настройки, Airflow Variables
│   ├── callables.py        # Бизнес-логика (без зависимостей от Airflow)
│   ├── sql_templates.py    # SQL запросы
│   ├── db_interactions.py  # Работа с БД
│   ├── types.py            # Типы и dataclasses
│   ├── utils.py            # Утилиты
│   └── processing.py       # Обработка данных (pandas, duckdb)
```

### Важные изменения в Airflow 3.x

⚠️ **Обязательно используйте новые импорты:**

```python
# ❌ Старый способ (не работает в Airflow 3)
from airflow.decorators import dag, task

# ✅ Новый способ (Airflow 3.x)
from airflow.sdk import dag, task
```

⚠️ **Изменения параметров:**
- `schedule_interval` → `schedule`
- `airflow webserver` → `airflow api-server`
- `airflow users create` → изменен синтаксис

## 🔧 Настройки

### Частота сканирования DAG'ов

В `docker/docker-compose.yml`:

```yaml
AIRFLOW__SCHEDULER__DAG_DIR_LIST_INTERVAL: 10  # Сканировать папку каждые 10 сек
AIRFLOW__SCHEDULER__MIN_FILE_PROCESS_INTERVAL: 10  # Обрабатывать файл каждые 10 сек
```

Для продакшена рекомендуется увеличить до 60-300 секунд.

### Добавление Python зависимостей

1. Добавьте пакет в `requirements.txt`
2. Пересоберите образ:
   ```bash
   ./rebuild.sh
   ```

## 🐛 Troubleshooting

### DAG не появляется в UI

1. Проверьте логи:
   ```bash
   make logs SERVICE=airflow-standalone | grep -i error
   ```

2. Проверьте синтаксис DAG:
   ```bash
   make exec SERVICE=airflow-standalone CMD='python3 /opt/airflow/dags/your_dag.py'
   ```

3. Проверьте что файл виден в контейнере:
   ```bash
   make exec SERVICE=airflow-standalone CMD='ls -la /opt/airflow/dags/'
   ```

### Сервисы не запускаются

1. Проверьте статус:
   ```bash
   make status
   ```

2. Проверьте логи конкретного сервиса:
   ```bash
   make logs SERVICE=mysql
   make logs SERVICE=airflow-standalone
   ```

3. Пересоздайте окружение:
   ```bash
   make stop
   make start
   ```

### Ошибка "port is already allocated"

Порты 8080, 5555, 3306 или 6379 уже заняты. Остановите конфликтующие сервисы:

```bash
# Проверить что использует порт
lsof -i :8080

# Остановить Docker контейнеры
docker ps
docker stop <container_id>
```

### Полная очистка и перезапуск

```bash
make clean  # Удалит ВСЕ данные!
make start
```

## 📚 Полезные команды

### Airflow CLI

```bash
# Список DAG'ов
make exec SERVICE=airflow-standalone CMD='airflow dags list'

# Запустить DAG вручную
make exec SERVICE=airflow-standalone CMD='airflow dags trigger my_dag'

# Протестировать task
make exec SERVICE=airflow-standalone CMD='airflow tasks test my_dag my_task 2025-01-01'
```

### MySQL

```bash
# Подключиться к MySQL
make exec SERVICE=mysql CMD='mysql -uairflow -pairflow airflow'

# Экспорт данных
docker-compose exec mysql mysqldump -uairflow -pairflow airflow > backup.sql
```

### Redis

```bash
# Подключиться к Redis
make exec SERVICE=redis CMD='redis-cli'

# Проверить ключи
docker-compose exec redis redis-cli KEYS "*"
```

## 📖 Документация

- [Apache Airflow 3 Documentation](https://airflow.apache.org/docs/apache-airflow/stable/)
- [Airflow SDK (Task Flow API)](https://airflow.apache.org/docs/apache-airflow/stable/tutorial/taskflow.html)
- [Celery Executor](https://airflow.apache.org/docs/apache-airflow-providers-celery/stable/celery_executor.html)

## ⚙️ Конфигурация сервисов

### Standalone Mode (текущий)

- **Executor**: LocalExecutor (принудительно в standalone)
- **Компоненты**: Scheduler, API Server, Triggerer в одном контейнере
- **Использование**: Разработка, тестирование
- **Масштабирование**: Нет

### CeleryExecutor Mode (для продакшена)

Для переключения на распределенное выполнение задач:

1. Измените `docker/docker-compose.yml` - раскомментируйте отдельные сервисы (scheduler, api-server, worker)
2. Удалите `airflow-standalone` сервис
3. Пересоберите: `make rebuild`

## 🔐 Безопасность

⚠️ **Для продакшена обязательно измените:**

1. **Fernet Key**: 
   ```bash
   python3 -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"
   ```
   
2. **Secret Key**: Любая случайная строка

3. **Пароли MySQL**: В `docker-compose.yml` и connection strings

4. **Admin пароль**: Создайте пользователя с безопасным паролем

## 📝 TODO

- [ ] Настроить email уведомления
- [ ] Добавить мониторинг (Prometheus, Grafana)
- [ ] Настроить логирование в S3/GCS
- [ ] Добавить CI/CD для деплоя DAG'ов
- [ ] Настроить backup базы данных
