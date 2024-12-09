from jinja2 import Environment, FileSystemLoader
jinjaenv = Environment(loader=FileSystemLoader('./app/Templates'))


def succeed_operator_block(state_name, state_details, *args, **kwargs):
    template = jinjaenv.get_template('/OPERATORS/SUCCEED_OPERATOR.j2')
    return template.render(name=state_name, data=state_details)

def pass_operator_block(state_name, state_details, *args, **kwargs):
    template = jinjaenv.get_template('/OPERATORS/PASS_OPERATOR.j2')
    return template.render(name=state_name, data=state_details)

def wait_operator_block(state_name, state_details, *args, **kwargs):
    template = jinjaenv.get_template('/OPERATORS/WAIT_OPERATOR.j2')
    return template.render(name=state_name, data=state_details)

def fail_operator_block(state_name, state_details, *args, **kwargs):
    template = jinjaenv.get_template('/OPERATORS/FAIL_OPERATOR.j2')
    return template.render(name=state_name, data=state_details)

def choice_operator_block(state_name, state_details, *args, **kwargs):
    template = jinjaenv.get_template('/OPERATORS/CHOICE_OPERATOR.j2')
    return template.render(name=state_name, data=state_details)

def parallel_operator_block(state_name, state_details, *args, **kwargs):
    template = jinjaenv.get_template('/OPERATORS/PARALLEL_OPERATOR.j2')
    return template.render(name=state_name, data=state_details)

def map_operator_block(state_name, state_details, *args, **kwargs):
    template = jinjaenv.get_template('/OPERATORS/MAP_OPERATOR.j2')
    return template.render(name=state_name, data=state_details)
