from __future__ import annotations

import datetime, json
from airflow.models.dag import DAG
from airflow.operators.python import PythonOperator

from Operator.PassOperator import PassOperator
import logging

logger = logging.getLogger(__name__)

with (DAG(
        dag_id="test_my_pass_operator",
        schedule=datetime.timedelta(hours=4),
        start_date=datetime.datetime(2021, 1, 1),
        catchup=False,
        tags=["cloud.park", "passOperator"],
) as dag):

    file_path = r'TestTemplate/ParsedJSON/Pass_with_two_type.json'
    with open(f"/opt/airflow/plugins/{file_path}", 'r') as json_file:
        input_json = json.load(json_file)

    sample_state_variable = input_json["states"]["JSONPath_state___6b3cc434"]

    global_io_variable = {}
    global_io_variable["input_value"] = json.loads("""
    {
        "transaction" : {
            "total" : "100"
         }
    }
    """)


    task1 = PythonOperator(
        task_id="task1",
        python_callable=lambda: print(datetime.datetime.now())
    )

    sample_state_variable["io_variable"]['input_value'] = global_io_variable["input_value"]
    task2 = PassOperator(
        task_id="task2",
        meta=sample_state_variable["meta"],
        io_variable=sample_state_variable["io_variable"],
    )



    task3 = PythonOperator(
        task_id="task3",
        python_callable=lambda: print(datetime.datetime.now())
    )

    task1 >> task2 >> task3

if __name__ == "__main__":
    dag.test()
