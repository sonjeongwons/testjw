from __future__ import annotations

import datetime, json
from airflow.models.dag import DAG
from airflow.operators.python import PythonOperator

from Operator.SucceedOperator import SucceedOperator


with (DAG(
        dag_id="test_my_Succeed_operator",
        schedule=datetime.timedelta(hours=4),
        start_date=datetime.datetime(2021, 1, 1),
        catchup=False,
        tags=["cloud.park", "SucceedOperator"],
) as dag):

    with open("/opt/airflow/plugins/TestTemplate/ParsedJSON/parsed_jsonata1.json", 'r') as json_file:
        input_json = json.load(json_file)

    sample_state_variable = input_json["states"]["Summarize_the_Execution😒___35b34b13"]

    global_io_variable = {}
    global_io_variable["input_value"] = json.loads("""
    {
        "Hello" : 10
    }
    """)


    task1 = PythonOperator(
        task_id="task1",
        python_callable=lambda: print(datetime.datetime.now())
    )


    task2 = SucceedOperator(
        task_id="task2",
        meta=sample_state_variable["meta"],
        io_variable=global_io_variable,
    )


    def value_from_task(**context):
        res = context['task_instance'].xcom_pull(key='output_value')
        print(res)

    task3 = PythonOperator(
        task_id="task3",
        python_callable=value_from_task
    )

    task1 >> task2 >> task3

if __name__ == "__main__":
    dag.test()
