import json
from datetime import datetime
from typing import Optional, Any

from airflow.models import BaseOperator
from airflow.sensors.date_time import DateTimeSensorAsync

from Classes.Common.JSONPathObj import JSONPathObj
from Classes.Common.JSONataObj import JSONataObj
from Classes.Common.StateMeta import StateMeta
from Classes.ObjectVariables.WaitObjectVariables import WaitObjectVariables


class WaitOperator(BaseOperator):
    def __init__(self,
                 meta: dict,
                 io_variable: dict,
                 object_variable: Optional[dict] = None,
                 *args,
                 **kwargs
                 ):


        self.meta = StateMeta(**meta)

        if meta.get('query_language') == "JSONata":
            self.io_variable = JSONataObj(**io_variable)
        elif meta.get('query_language') in ["JSONPath", None]:
            self.io_variable = JSONPathObj(**io_variable)

        self.object_variable = object_variable
        self.evaluated_wait_timestamp = None

        # 이유는 모르곘지만, init과정에서는 logging이 되지 않음..
        # print(f"evaluated_wait_timestamp: {self.evaluated_wait_timestamp}")
        super().__init__(*args,**kwargs)


    def pre_execute(self, context: Any):
        self.input_value_process()


    def execute(self, context: Any):
        self.log.info(f"현재: {datetime.now().isoformat()}, 평가후 Evaluated Wait Time Stamp:  {self.evaluated_wait_timestamp}")
        self.log.info(f"execute 시작, {datetime.now().isoformat()}")
        self.log.info(f"context: {context}")


    def post_execute(self, context, result):
        self.log.info(f"execute 종료, {datetime.now().isoformat()}")
        self.output_value_process()

        self.io_variable.output_value = f'"OutputResults":{str(self.evaluated_wait_timestamp)}'
        context['task_instance'].xcom_push(key="output_value", value=self.io_variable.output_value)
        super().post_execute(context, result)

        # 해당 방식은 PythonOperator에서만 자동으로 push됨.
        # CustomOperator에서는 위와같이 Result를 Push해줘야함.
        # return self.io_variable.output_value

    def input_value_process(self):
        # input을 IO_Variables에 맞게 처리함
        self.io_variable.filterling_by_types('input', self.meta.type)

        # io_vairable의 input_value를 이용해서 평가된 wait_time timestamp를 확인
        self.evaluated_wait_timestamp = WaitObjectVariables(self.object_variable).evaluate(self.io_variable.input_value)

    def output_value_process(self):
        self.io_variable.filterling_by_types('output', self.meta.type)

