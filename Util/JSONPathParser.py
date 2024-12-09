import json
from jsonpath_ng import parse
from jsonpath_ng.exceptions import JsonPathParserError
import logging
logger = logging.getLogger('airflow.task')

class JSONPathParser:
    def __init__(self):
        pass

    @staticmethod
    def parse(jsonpath: str) -> bool:
        try:
            return parse(jsonpath)  # JSONPath를 파싱
        except JsonPathParserError:
            return False  # 파싱 실패 시 유효하지 않음

    @staticmethod
    def get_value_with_jsonpath_from_json_data(json_data, json_path):
        try:
            expression = parse(json_path)
            logger.info(f"Parsing JSON path '{json_path}' from JSON data")
            value = {match.value for match in expression.find(json_data)}

            if type(value) is set: # Key-value가 아닐때,
                value = list(value)
                if len(value) == 1: # 값으로 반환
                    return value[0]
                else: # List로 반환
                    return value
            else:
                return value
        except JsonPathParserError:
            logger.exception('JsonPathParserError')
