# Serbian News Scraper - Architecture Documentation

## Project Overview

**Project Name:** Serbian News Scraper (snews)  
**Purpose:** Scrape news from Serbian news sites, translate and review using AI, publish to Telegram channel  
**Tech Stack:** Airflow 3, MySQL, Redis, Celery, Docker

## Infrastructure Components

### Services Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Docker Compose Stack                    │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Redis      │  │    MySQL     │  │   Airflow    │      │
│  │   (Broker)   │  │  (Metadata)  │  │  Webserver   │      │
│  │   Port 6379  │  │   Port 3306  │  │   Port 8080  │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Airflow    │  │   Airflow    │  │    Flower    │      │
│  │  Scheduler   │  │   Worker     │  │  (Monitor)   │      │
│  │              │  │  (Celery)    │  │   Port 5555  │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

### Service Details

#### 1. **Redis** (redis:7.2-alpine)
- **Purpose:** Celery message broker
- **Port:** 6379
- **Role:** Task queue management for distributed execution

#### 2. **MySQL** (mysql:8.0)
- **Purpose:** Dual database
  - Airflow metadata database (`airflow`)
  - Application database (`snews`)
- **Port:** 3306
- **Credentials:**
  - User: `airflow`
  - Password: `airflow`
  - Root Password: `rootpass`

#### 3. **Airflow Webserver**
- **Purpose:** Web UI for DAG management
- **Port:** 8080
- **Access:** http://localhost:8080
- **Credentials:**
  - Username: `admin`
  - Password: `SNk2G8y9bvCvsEKM`

#### 4. **Airflow Scheduler**
- **Purpose:** Schedule and trigger DAG runs
- **Executor:** CeleryExecutor

#### 5. **Airflow Worker** (Celery)
- **Purpose:** Execute tasks distributed by scheduler
- **Scaling:** Can be scaled horizontally

#### 6. **Flower**
- **Purpose:** Celery monitoring dashboard
- **Port:** 5555
- **Access:** http://localhost:5555

## Executor Choice: CeleryExecutor

**Why CeleryExecutor over LocalExecutor:**

1. **Scalability:** Can add multiple workers across machines
2. **Parallelism:** Execute multiple tasks simultaneously
3. **Resilience:** Workers can fail independently without affecting scheduler
4. **Production-Ready:** Standard choice for production deployments
5. **Resource Isolation:** Tasks run in separate worker processes

## Database Schema (snews database)

### Tables to be Created:

1. **news_sources**
   - Serbian news websites configuration
   - Fields: name, url, country, language, active status

2. **articles**
   - Scraped articles
   - Fields: url, title, content, author, published_at, content_hash, raw_html

3. **article_translations**
   - AI translations (multiple languages)
   - Fields: article_id, language, title, content, translation_model

4. **article_reviews**
   - AI-generated reviews and analysis
   - Fields: article_id, review_text, sentiment, categories, key_points

5. **publications**
   - Telegram publication tracking
   - Fields: article_id, channel_id, message_id, status, published_at

6. **scraping_logs**
   - Scraping job audit logs
   - Fields: source_id, dag_run_id, status, articles_found, articles_new

## DAG Structure Convention

**Following user's specified structure:**

```
dags/
└── <dag_name>/
    ├── dag.py              # DAG generation code (@dag decorator)
    ├── tasks.py            # Task functions (@task decorators)
    ├── const.py            # Constants (URLs, limits, etc.)
    ├── settings.py         # DAG settings, Airflow Variables
    ├── callables.py        # Pure business logic (no Airflow imports)
    ├── sql_templates.py    # SQL query templates
    ├── db_interactions.py  # Database CRUD operations
    ├── types.py            # Custom types and dataclasses
    ├── utils.py            # Pure utility functions
    └── processing.py       # Data processing (pandas, duckdb)
```

### Rules:
- Use TaskFlow API (@dag and @task decorators)
- PEP8 compliance
- Type hints required
- Separation of concerns (business logic in callables.py)

## Python Dependencies

### Core:
- apache-airflow==3.0.0
- apache-airflow-providers-mysql==5.6.3
- apache-airflow-providers-celery==3.8.3

### Celery & Redis:
- celery[redis]==5.4.0
- redis==5.2.0

### Database:
- mysql-connector-python==9.1.0
- SQLAlchemy (managed by Airflow, <2.0)

### Web Scraping:
- beautifulsoup4==4.12.3
- requests==2.32.3
- lxml==5.3.0
- fake-useragent==1.5.1

### Data Processing:
- pandas==2.2.3
- python-dateutil==2.9.0

### External Services:
- python-telegram-bot==21.7 (Telegram publishing)
- openai==1.55.3 (AI translation/review)

### Utilities:
- pydantic>=2.11.0 (validation)
- python-dotenv==1.0.1 (configuration)

## Configuration Management

### Environment Variables:

```bash
# Airflow Core
AIRFLOW__CORE__EXECUTOR=CeleryExecutor
AIRFLOW__CORE__FERNET_KEY=<generated_key>
AIRFLOW__WEBSERVER__SECRET_KEY=<generated_key>

# Database
AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=mysql+mysqlconnector://airflow:airflow@mysql:3306/airflow

# Celery
AIRFLOW__CELERY__BROKER_URL=redis://redis:6379/0
AIRFLOW__CELERY__RESULT_BACKEND=db+mysql+mysqlconnector://airflow:airflow@mysql:3306/airflow

# Application Database
MYSQL_HOST=mysql
MYSQL_PORT=3306
MYSQL_DATABASE=snews
MYSQL_USER=airflow
MYSQL_PASSWORD=airflow

# External Services (to be configured)
TELEGRAM_BOT_TOKEN=<your_token>
TELEGRAM_CHANNEL_ID=@<your_channel>
OPENAI_API_KEY=<your_key>
```

## Workflow Pipeline (To Be Implemented)

```
1. Scraping DAG (scheduled)
   ├── Fetch articles from Serbian news sites
   ├── Extract content, metadata
   ├── Calculate content hash (deduplication)
   └── Store in articles table

2. Translation DAG (triggered)
   ├── Select untranslated articles
   ├── Call OpenAI API for translation
   └── Store in article_translations

3. Review DAG (triggered)
   ├── Select unreviewed articles
   ├── Generate AI review/summary
   ├── Extract sentiment, categories
   └── Store in article_reviews

4. Publication DAG (triggered)
   ├── Select articles ready for publishing
   ├── Format message (title, summary, link)
   ├── Post to Telegram channel
   └── Update publication status
```

## Target News Sources

Serbian news websites to scrape:

1. **Blic** (blic.rs)
2. **B92** (b92.net)
3. **RTS** (rts.rs)
4. **N1** (n1info.rs)

## Development Commands

### Start Infrastructure:
```bash
cd etl
docker-compose up -d
```

### Stop Infrastructure:
```bash
docker-compose down
```

### View Logs:
```bash
docker-compose logs -f [service_name]
```

### Restart Service:
```bash
docker-compose restart [service_name]
```

### Rebuild After Changes:
```bash
docker-compose up -d --build
```

### Access MySQL:
```bash
docker exec -it etl-mysql-1 mysql -u airflow -p
# Password: airflow
```

## Next Steps

1. **Database Schema Creation**
   - Create SQL migration scripts
   - Initialize `snews` database tables
   - Seed news_sources with Serbian sites

2. **Scraping DAG**
   - Implement scraper for each news source
   - Handle different HTML structures
   - Implement rate limiting and error handling
   - Store articles with deduplication

3. **Translation DAG**
   - OpenAI API integration
   - Batch processing for efficiency
   - Cost monitoring

4. **Review DAG**
   - Sentiment analysis
   - Category extraction
   - Key points summarization

5. **Publication DAG**
   - Telegram bot setup
   - Message formatting
   - Publishing schedule

## Technical Decisions

### Why Airflow 3?
- Latest stable version
- Improved TaskFlow API
- Better performance
- Native async support

### Why MySQL?
- ACID compliance for article tracking
- Strong community support
- Easy integration with Airflow

### Why not LocalExecutor?
- Limited to single machine
- No horizontal scaling
- Less fault tolerant
- Not suitable for production workload

### Why separate business logic (callables.py)?
- Testability without Airflow dependencies
- Reusability across different contexts
- Cleaner code organization
- Faster unit tests

## Monitoring & Observability

### Airflow UI (port 8080):
- DAG runs status
- Task success/failure rates
- Execution times
- Logs

### Flower UI (port 5555):
- Worker status
- Task queue length
- Task execution stats
- Worker resource usage

### MySQL:
- Article counts
- Scraping success rates
- Translation/review progress
- Publication status

## Version Information

- **Airflow:** 3.0.0
- **Python:** 3.11
- **MySQL:** 8.0
- **Redis:** 7.2
- **Docker Compose:** 3.8

## Contact & Maintenance

This infrastructure is designed for:
- 24/7 operation
- Automated scraping (scheduled)
- AI processing (triggered)
- Telegram publishing (triggered)

Last Updated: 2025-11-12

