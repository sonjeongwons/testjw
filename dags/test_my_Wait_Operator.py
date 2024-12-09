from __future__ import annotations

import datetime, json
from airflow.models.dag import DAG
from airflow.operators.python import PythonOperator

from Operator.WaitOperator import WaitOperator
import logging

logger = logging.getLogger(__name__)

with (DAG(
        dag_id="test_my_wait_operator",
        schedule=datetime.timedelta(hours=4),
        start_date=datetime.datetime(2021, 1, 1),
        catchup=False,
        tags=["cloud.park", "waitOperator"],
) as dag):

    with open("/opt/airflow/plugins/TestTemplate/ParsedJSON/parsed_jsonpath1.json", 'r') as json_file:
        input_json = json.load(json_file)

    sample_state_variable = input_json["states"]["Wait_3_sec___bd8ecbd8"]

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


    task2 = WaitOperator(
        task_id="task2",
        meta=sample_state_variable["meta"],
        io_variable=global_io_variable,
        object_variable=sample_state_variable["object_variable"],
    )



    task3 = PythonOperator(
        task_id="task3",
        python_callable=lambda: print(datetime.datetime.now())
    )

    task1 >> task2 >> task3

if __name__ == "__main__":
    dag.test()
