import importlib

from Util.MethodManager import get_method_by_type
from app.routes.CodeBlocks.operator_blocks import *

from jinja2 import Environment, FileSystemLoader
jinjaenv = Environment(loader=FileSystemLoader('./app/Templates'))



def extract_from_states(state_name, state_details):
    state_type = state_details['meta']['type']
    states = []

    if state_type in ['Pass', 'Choice', 'Parallel', "Map", "Pass", "Wait", "Succeed", "Fail"]:
        method = get_method_by_type(state_type=state_type.lower(), method_type="operator")
        states.append(method(state_name, state_details))
    else:
        raise ValueError(f"Unsupported state type: {state_type}")
    return states


def assemble_dags(dags_data):
    # dags_data = {'imports_type': {},
    #         'imports': [basic_import_block()],
    #         'dags_info': [dags_states_command(workflow_info)],
    #         'states': [],
    #         'work_orders': []
    #         }


    for import_type in dags_data["imports_type"].keys():
        import_type_method = get_method_by_type(state_type=import_type.lower(), method_type="import")
        dags_data["imports"].append(import_type_method())

    template = jinjaenv.get_template('/Dags/dags_template.j2')

    # 템플릿 렌더링
    return template.render(data=dags_data)

