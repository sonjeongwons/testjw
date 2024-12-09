from typing import Optional

from Classes.Common.IOVariable import IOVariable
import logging
logger = logging.getLogger('airflow.task')

class JSONataObj(IOVariable):
    def __init__(self,
                 query_language: str = "JSONata",
                 input_value: Optional[dict] = {},
                 output_value: Optional[dict] = {},
                 assign: Optional[dict] = None,
                 output: Optional[dict] = None,
                 *args,
                 **kwargs
                 ):
        super().__init__(query_language=query_language, input_value=input_value, output_value=output_value)
        self.assign = assign
        self.output = output


    def filterling_input_by_types(self, types):
        logger.info(f"Filitering JSONataObj / input: {self.input_value}, assign: {self.assign}, output: {self.output}")
        match types:
            case "Choice":
                pass
            case "Parallel":
                pass
            case "Map":
                pass
            case "Pass":
                pass
            case "Wait":
                pass
            case "Succeed":
                pass
            case "Fail":
                pass
            case _:
                raise ValueError(f"Invalid type: {types}")
        logger.info(f"Filtered input: {self.input_value}")

    def filterling_output_by_types(self, types):
        logger.info(f"Filitering JSONataObj / Output: {self.output_value}, assign: {self.assign}, output: {self.output}")

        match types:
            case "Choice":
                pass
            case "Parallel":
                pass
            case "Map":
                pass
            case "Pass":
                pass
            case "Wait":
                pass
            case "Succeed":
                pass
            case "Fail":
                pass
            case _:
                raise ValueError(f"Invalid type: {types}")
        logger.info(f"Filtered output: {self.output_value}")
