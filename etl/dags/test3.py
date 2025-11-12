from airflow.decorators import dag, task
from datetime import datetime


@task
def test_task():
    print("Hello, World!")


@dag(
    dag_id="test3",
    schedule="0 0 * * *",
    start_date=datetime(2025, 1, 1),
    catchup=False,
)
def test():
    test_task()


dag = test()