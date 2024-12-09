from typing import Optional, Any

from airflow.exceptions import AirflowException
from airflow.models import BaseOperator

from Classes.Common import IOVariable, StateMeta
from Util.JSONPathParser import JSONPathParser

class FailOperator(BaseOperator, AirflowException):
    def __init__(self,
                 meta: dict,
                 io_variable: dict,
                 object_variable: Optional[dict] = None,
                 **kwargs
                 ):
        super().__init__(**kwargs)

        self.meta = StateMeta(meta)
        if meta.get('query_language') == "JSONata":
            self.io_variable = IOVariable(io_variable).JSONataObj(io_variable)
        elif meta.get('query_language') in ["JSONPath", None]:
            self.io_variable = IOVariable(io_variable).JSONPathObj(io_variable)

        self.error = object_variable.get('error')
        self.error_path = object_variable.get('error_path')
        self.cause = object_variable.get('cause')
        self.cause_path = object_variable.get('cause_path')

        self.json_parser = JSONPathParser()

    def execute(self) -> IOVariable:
        self.pre_process()
        self.process()
        self.post_process()

        return self.io_variable.output_value

    def pre_execute(self, context: Any):
        self.input_value_process()

    def execute(self, context):
        self.process()
        self.output_value_process()

        return self.io_variable.output_value

    def input_value_process(self):
        if self.io_variable.input_path is not None:
            self.io_variable.input_filter_by_input_path()

        if self.io_variable.parameter is not None:
            self.io_variable.input_by_parameter()

    def process(self):
        pass

    def output_value_process(self):
        #에러 처리
        if self.error_path is not None:
            self.error = self.json_parser.get_value_with_jsonpath_from_json_data(self.io_variable.input_value, self.error_path)

        #오류 원인 처리
        if self.cause_path is not None:
            self.error = self.json_parser.get_value_with_jsonpath_from_json_data(self.io_variable.input_value, self.cause_path)
