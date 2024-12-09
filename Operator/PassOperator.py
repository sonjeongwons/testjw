from typing import Optional, Any

from airflow.models import BaseOperator

import Classes.Common.JSONPathObj
from Classes.Common.StateMeta import StateMeta
from Classes.Common.JSONataObj import JSONataObj
from Classes.Common.JSONPathObj import JSONPathObj


class PassOperator(BaseOperator):
    def __init__(self,
                 meta: dict,
                 io_variable: dict,
                 *args,
                 **kwargs
                 ):

        self.meta = StateMeta(**meta)

        super().__init__(*args, **kwargs)

        if meta.get('query_language') == "JSONata":
            self.io_variable = JSONataObj(**io_variable)
        elif meta.get('query_language') in ["JSONPath", None]:
            self.io_variable = JSONPathObj(**io_variable,)

    def pre_execute(self, context: Any):
        self.input_value_process()

    def execute(self, context: Any):
        # The Pass State (identified by "Type":"Pass") by default passes its input to its output, performing no work.
        pass

    def post_execute(self, context: Any, result: Any = None):
        self.output_value_process()

        context['task_instance'].xcom_push(key="output_value", value=self.io_variable.output_value)
        super().post_execute(context, result)

    def input_value_process(self):
        self.io_variable.filterling_by_types('input', self.meta.type)

    def output_value_process(self):
        self.io_variable.filterling_by_types('output', self.meta.type)

