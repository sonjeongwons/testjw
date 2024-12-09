from Operator.SucceedOperator import SucceedOperator
from jinja2 import Environment, FileSystemLoader
jinjaenv = Environment(loader=FileSystemLoader('./app/Templates'))

SUCCEED_OPERATOR_IMPORT = "from Operator.SucceedOperator import SucceedOperator"
PASS_OPERATOR_IMPORT = "from Operator.PassOperator import PassOperator"
WAIT_OPERATOR_IMPORT = "from Operator.WaitOperator import WaitOperator"
FAIL_OPERATOR_IMPORT = "from Operator.FailOperator import FailOperator"
CHOICE_OPERATOR_IMPORT = "from Operator.ChoiceOperator import ChoiceOperator"
PARALLEL_OPERATOR_IMPORT = "from Operator.ParallelOperator import ParallelOperator"
MAP_OPERATOR_IMPORT = "from Operator.MapOperator import MapOperator"


def basic_import_block(*args, **kwargs):
    template = jinjaenv.get_template('/Imports/basic_import_sentences.j2')
    return template.render()

def succeed_import_block(*args, **kwargs):
    return SUCCEED_OPERATOR_IMPORT

def pass_import_block(*args, **kwargs):
    return PASS_OPERATOR_IMPORT

def wait_import_block(*args, **kwargs):
    return WAIT_OPERATOR_IMPORT

def fail_import_block(*args, **kwargs):
    return FAIL_OPERATOR_IMPORT

def choice_import_block(*args, **kwargs):
    return "# Choice_WILL_IMPORT"
    # return CHOICE_OPERATOR_IMPORT

def parallel_import_block(*args, **kwargs):
    return "# Parallel_WILL_IMPORT"
    # return PARALLEL_OPERATOR_IMPORT

def map_import_block(*args, **kwargs):
    return "# MAP_WILL_IMPORT"
    # return MAP_OPERATOR_IMPORT
