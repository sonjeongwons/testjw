from Classes.ObjectVariables.WaitObjectVariables import WaitObjectVariables
from Util.JSONPathParser import JSONPathParser
from Util.StringBuilder import get_hashed_snake_case


def get_only_vaild_dict(object_detail : dict) -> dict:
    obj = {
        key: value
        for key, value in object_detail.items()
        if value not in (None, "", {})  # None, 빈 문자열, 빈 딕셔너리는 제외
    }

    for key, value in obj.items():
        if key.endswith('_path') and type(value) is not str:
            raise TypeError(f"{key}의 값은 반드시 문자열이어야 합니다.")

        if key.endswith('_path') and JSONPathParser.parse(value) is False:
            raise TypeError(f"{key}가 유효한 JSONPath가 아닙니다.")

    return obj


def meta_mapper(object_detail: dict, workflow_query_language: str) -> dict:
    def meta_validate_variables_mapping(obj):
        if obj.get("name") is None:
            raise ValueError("이름이 공란일 수 없습니다.")

        if obj.get("type") is None:
            raise ValueError("Type가 공란일 수 없습니다. ")

        if obj.get("query_language") not in ["JSONPath", "JSONata"]:
            raise ValueError("QueryLanguage는 JSONPath 혹은 JSONata여야합니다")
        return True

    # 해당 State에 명시된 QueryLanguage가 있으면, 해당 QueryLanguage
    obj = get_only_vaild_dict({
        "name": object_detail.get("Name", None),
        "type": object_detail.get("Type", None),
        "query_language": object_detail.get("QueryLanguage", workflow_query_language),
        "comment": object_detail.get("Comment", ""),
        "next": object_detail.get("Next", None),
        "end": object_detail.get("End", False)
    })
    # 명시된 QueryLanguage가 없으면 Workflow의 QueryLanguage로 갈음함,
    if object_detail.get("QueryLanguage") == None:
        object_detail["QueryLanguage"] = workflow_query_language

    # 추후 task_mapping을 위하여 "next"의 값이 있을경우, snake_case로 변환함.
    if obj.get("next") is not None:
        obj["next"] = get_hashed_snake_case(obj["next"])

    if meta_validate_variables_mapping(obj):
        return obj
    else:
        raise ValueError(f"meta mapper 오류 : {obj}")




#ASL의 형식을 내부에서 사용하는 형식으로 변환
def fail_object_variable_mapping(object_detail : dict) -> dict:
    obj = get_only_vaild_dict({
        "error": object_detail.get('Error'),
        "error_path": object_detail.get('ErrorPath'),
        "cause": object_detail.get('Cause'),
        "cause_path": object_detail.get('CausePath')
    })
    if fail_validate_variables_mapping(obj):
        return obj

def fail_validate_variables_mapping(obj: dict) -> bool:
    # FAIL에서는 errorpath와 error가 동시에 들어올수 없음. 해당 제어 추가 필요
    if "error" and "error_path" in obj.keys():
        raise ValueError("error와 errorpath는 함께 사용할 수 없습니다.")
    # FAIL에서는 causerpath와 cause가 동시에 들어올수 없음. 해당 제어 추가 필요
    if "cuase" and "cause_path" in obj.keys():
        raise ValueError("cause와 causepath는 함께 사용할 수 없습니다.")

    return True



def wait_object_variable_mapping(object_detail : dict) -> dict:
    obj = get_only_vaild_dict({
        "seconds": object_detail.get('Seconds'),  # int
        "seconds_path": object_detail.get('SecondsPath'),
        "timestamp": object_detail.get('Timestamp'),  # str
        "timestamp_path": object_detail.get('TimestampPath')
    })
    if WaitObjectVariables(obj, object_detail.get("QueryLanguage")).validate():
        return obj


def io_variable_mapper(object_detail: dict):
    return get_only_vaild_dict({
            "query_language" : object_detail.get('QueryLanguage'),
            "output": object_detail.get('Output'),
            "assign" : object_detail.get('Assign'),
            "input_path": object_detail.get('InputPath'),
            "result_selector": object_detail.get('ResultSelector'),
            "result_path": object_detail.get('ResultPath'),
            "output_path": object_detail.get('OutputPath'),
            "parameters": object_detail.get('Parameters'),
            "result": object_detail.get('Result')
        })
