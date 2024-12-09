from typing import Optional
from abc import ABC, abstractmethod

# JSONPathObj, JSONataObj를 위한 추상클래스
class IOVariable(ABC):
    def __init__(self,
                 query_language: str = "JSONPath",
                 input_value: Optional[dict] = {},
                 output_value: Optional[dict] = {},
                 ):

        if query_language not in ["JSONPath", "JSONata"]:
            raise ValueError("query_language must be 'JSONPath' or 'JSONata'")

        self.query_language = query_language
        self.input_value = input_value  # 초기 input에서 변환되어 최종저긍로 사용되는 input값
        self.output_value = output_value  # 최종적으로 사용되는 결과값

    @abstractmethod
    def filterling_input_by_types(self, types):
        pass

    @abstractmethod
    def filterling_output_by_types(self, types):
        pass

    def filterling_by_types(self, action: str, types: str):
        method_name = f"filterling_{action}_by_types"
        method = getattr(self, method_name, None)
        if callable(method):
            method(types)
        else:
            raise NotImplementedError(f"Method {method_name} not implemented")
