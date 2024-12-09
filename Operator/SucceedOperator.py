from typing import Any

from airflow.models import BaseOperator

from Classes.Common.StateMeta import StateMeta
from Classes.Common.JSONataObj import JSONataObj
from Classes.Common.JSONPathObj import JSONPathObj


class SucceedOperator(BaseOperator):
    def __init__(self,
                 meta: dict,
                 io_variable: dict,
                 *args,
                 **kwargs
                 ):
        super().__init__(**kwargs)

        self.meta = StateMeta(**meta)

        if meta.get('query_language') == "JSONata":
            self.io_variable = JSONataObj(**io_variable)
        elif meta.get('query_language') in ["JSONPath", None]:
            self.io_variable = JSONPathObj(**io_variable)


    def pre_execute(self, context: Any):
        self.input_value_process()

    def execute(self, context: Any):
        pass

    def post_execute(self, context, result):
        self.output_value_process()
        context['task_instance'].xcom_push(key="output_value", value=self.io_variable.output_value)
        super().post_execute(context, result)

    def input_value_process(self):
        self.io_variable.filterling_by_types('input', self.meta.type)

    def output_value_process(self):
        # If "Output" is not provided, the Succeed State copies its input through to its output.
        # A JSONata Succeed State MAY have an "Output" field whose value, if present, will become the state output.
        self.io_variable.output_value = self.io_variable.input_value
        self.io_variable.filterling_by_types('output', self.meta.type)





