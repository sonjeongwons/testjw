import importlib
import_blocks_module = importlib.import_module('app.routes.CodeBlocks.import_blocks')
operator_blocks_module = importlib.import_module('app.routes.CodeBlocks.operator_blocks')

def get_method_by_type(state_type, method_type):
    if method_type == "import":
        module = import_blocks_module
    elif method_type == "operator":
        module = operator_blocks_module

    method_name = f"{state_type}_{method_type}_block"
    if hasattr(module, method_name):
        return getattr(module, method_name)
    else:
        raise NotImplementedError(f"No such method: {method_name}")
