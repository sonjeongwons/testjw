# pip install jsonata-python
# https://github.com/rayokota/jsonata-python

import jsonata
import json

class JSONataParser:
    def __init__(self):
        pass

    @staticmethod
    def parse(jsonata_str: str) -> bool:
        try:
            return jsonata.Jsonata(jsonata_str)
        except:
            return False  # 파싱 실패 시 유효하지 않음

    @staticmethod
    # Jsonata 평가규칙으로 평가한 값을 Return함.
    def get_value_with_jsonata_from_json_data(json_data, jsonata_str):
        import logging
        logger = logging.getLogger('airflow.task')

        try:
            jsonata.Jsonata(jsonata_str)
            expr = jsonata.Jsonata(jsonata_str)
            value = expr.evaluate(json_data)
            logger.info(f"jsonata_str {jsonata_str} -> value {value}")

            if type(value) is set:  # Key-value가 아닐때,
                value = list(value)
                if len(value) == 1:  # 값으로 반환
                    return value[0]
                else:  # List로 반환
                    return value
            else:
                return value

        except Exception as e:
            logging.exception(f"JSONata expression : {str(e)}")
