from app.routes.Mapper.ChoiceObjectMapper import choice_object_variable_mapping, choice_parse_choices
from app.routes.Mapper.VariableObjectMapper import *


def parse_state(workflow_query_language, state_name, state_details):
    parsed_state = {}

    state_details["Name"] = state_name

    meta = meta_mapper(state_details, workflow_query_language)

    parsed_state["meta"] = meta
    parsed_state["io_variable"] = io_variable_mapper(state_details)
    # I/O 변수 매핑


    # 타입별 처리

    match meta["type"]:
        case "Choice":
            parsed_state["object_variable"] = {}
            object_variable = choice_object_variable_mapping(state_details)
            parsed_state["object_variable"]["choice_values"] = choice_parse_choices(object_variable["choices"], state_details["QueryLanguage"])
            # choice는 재귀적으로 추가되지 않음. Choice 하위에 추가되더라도 해당 Object들은 별개의 Object로 취급되어 상관없음.

        # case "Parallel":
        #     # Parallel의 Branches를 재귀적으로 처리가 필요함.
        #     # 사실상 다시 DAG를 만드는 것과 동일함. Comment를 제외한 DAG..
        #     # TriggerDagRunOperator 사용하여 다른 DAG를 트리거?
        #     branches = [
        #         parse_states(branch["States"])
        #         for branch in state_details.get("Branches", [])
        #     ]
        #     parsed_states[state_name] = Parallel(meta=meta, io_variable=io_variable, branches=branches)
        #
        # case "Map":
        #     # Map의 Iterator 처리
        #     # iterator = parse_states(state_details["Iterator"]["States"])
        #     # parsed_states[state_name] = Map(meta=meta, io_variable=io_variable, iterator=iterator)

        case "Pass":
            pass

        case "Wait":
            object_variable = wait_object_variable_mapping(state_details)
            parsed_state["object_variable"] = object_variable

        case "Succeed":
            pass

        case "Fail":
            object_variable = fail_object_variable_mapping(state_details)
            parsed_state["object_variable"] = object_variable

        case _:
            print(f"알 수 없는 타입입니다: {meta["type"]}")

    return parsed_state

