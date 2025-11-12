from airflow.sdk import dag, task
from datetime import datetime


@task
def test_task():
    print("Hello, World!")


@dag(
    dag_id="test",
    schedule="0 0 * * *",
    start_date=datetime(2025, 1, 1),
    catchup=False,
)
def test_dag():
    test_task()


dag_instance = test_dag()