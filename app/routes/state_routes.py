from flask import request, jsonify, Blueprint
import traceback
import json

from Util.FileManager import export_file
from Util.StringBuilder import get_hashed_snake_case
from app.routes.CodeBlocks.dags_blocks import dags_states_command
from app.routes.CodeBlocks.import_blocks import basic_import_block
from app.routes.Mapper.VariableObjectMapper import get_only_vaild_dict
from app.routes.dags_factory import extract_from_states, assemble_dags
from app.routes.parser import parse_state

state_bp = Blueprint('state', __name__)
# Blueprint 생성: 'user'는 이름, __name__은 현재 모듈의 이름

@state_bp.route('/parse_and_generate', methods=['POST'])
def parse_and_generate():
    try:
        data = request.get_json()
        data = parse_json_impl(data)
        return dags_generate_impl(data)
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@state_bp.route('/parse', methods=['POST'])
def parse_json():
    data = request.get_json()
    return parse_json_impl(data)

def parse_json_impl(data):
    try:
        # 필수 키 확인
        required_keys = ['StartAt', 'States']
        for key in required_keys:
            if key not in data:
                return jsonify({"error": f"Missing required key: {key}"}), 400


        workflow = get_only_vaild_dict({
            "query_language": data.get('QueryLanguage', 'JSONPath'),
            "start_at" : get_hashed_snake_case(data.get('StartAt')),
            "comment" : data.get('Comment', None),
            "timeout_seconds": data.get('TimeoutSeconds', None),
            "version" : data.get('Version', None),
        })

        # States 파싱
        workflow["states"] = {}
        states = data.get('States', {})

        for state_name, state_details in states.items():
            parsed = parse_state(workflow["query_language"], state_name, state_details)
            print(json.dumps(parsed, indent=4))
            if parsed is not None:
                #추후 Task로서 사용을 위하여, key를 snake_case로 변환함
                state_name = get_hashed_snake_case(state_name)
                workflow["states"][state_name] = parsed
        return workflow

    except Exception as e:
        print(traceback.format_exc())
        return jsonify({
            "error": {
                "type": type(e).__name__,
                "message": str(e),
                "stack_trace": traceback.format_exc()
            }
        }), 500


@state_bp.route('/generate', methods=['POST'])
def dags_generate():
    data = request.get_json()
    return dags_generate_impl(data)

def dags_generate_impl(data):
    try:
        # 필수 키 확인
        required_keys = ['start_at', 'states']
        for key in required_keys:
            if key not in data:
                return jsonify({"error": f"Missing required key: {key}"}), 400


        workflow_info = get_only_vaild_dict({
            "query_language": data.get('query_language', 'JSONPath'),
            "start_at" : data.get('startd_at'),
            "comment" : data.get('comment', None),
            "timeout_seconds": data.get('timeoutseconds', None),
            "version" : data.get('version', None),
        })



        dags = {'imports_type' : {},
                'imports' : [basic_import_block()],
                'dags_info' : [dags_states_command(workflow_info)],
                'states' : [],
                'work_orders' : []
                }



        for state_name, state_details in data["states"].items():
            type = state_details["meta"]["type"]

            # import Type 분류 후 추가
            if dags["imports_type"].get(type) is None:
                dags["imports_type"][type] = True

            # work_order구하기
            next_state = state_details["meta"].get("next")
            if next_state is not None:
                dags["work_orders"].append(f"{state_name} >> {next_state}")

            states = extract_from_states(state_name, state_details)
            if len(states) > 0:
                dags["states"] += states

        # state가 단일 state이며, next가 없을 경우
        if len(workflow_info) == 0:
            dags["work_orders"].append(workflow_info["start_at"])

        print(json.dumps(dags, indent=4))

        dags_text = assemble_dags(dags)

        export_file('../.tmp/hello.py', dags_text)

        return dags_text

    except Exception as e:
        print(traceback.format_exc())
        return jsonify({
            "error": {
                "type": type(e).__name__,
                "message": str(e),
                "stack_trace": traceback.format_exc()
            }
        }), 500




#Test를 위해 assemble만 수행함.
@state_bp.route('/assemble', methods=['POST'])
def dags_assemble():
    try:
        # data = {'imports' : [], 'dags_info' : [], 'states' : [], 'work_orders' : []}
        data = request.get_json()
        print(json.dumps(data, indent=4))
        dags_text = assemble_dags(data)
        return dags_text

    except Exception as e:
        print(traceback.format_exc())
        return jsonify({
            "error": {
                "type": type(e).__name__,
                "message": str(e),
                "stack_trace": traceback.format_exc()
            }
        }), 500
