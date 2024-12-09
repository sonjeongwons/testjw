from copy import deepcopy
from typing import Optional

from Classes.Common.IOVariable import IOVariable
from Util.JSONPathParser import JSONPathParser
import logging
logger = logging.getLogger('airflow.task')

class JSONPathObj(IOVariable):
    def __init__(self,
                 query_language: str = "JSONPath",
                 input_value: Optional[dict] = {},
                 output_value: Optional[dict] = {},
                 input_path: Optional[str] = None,
                 result_selector: Optional[dict] = None,
                 result_path: Optional[str] = None,
                 output_path: Optional[str] = None,
                 parameters: Optional[dict] = None,
                 result: Optional[dict] = None,
                 *args,
                 **kwargs
                 ):
        super().__init__(query_language=query_language, input_value=input_value, output_value=output_value)
        self.input_path = input_path
        self.json_parser = JSONPathParser()
        self.result_selector = result_selector
        self.result_path = result_path
        self.output_path = output_path
        self.parameters = parameters
        self.result = result

    ### inputs
    # jsondata에서 jsonpath로 뽑아옴

    def apply_json_path(self, jsondata: dict, jsonpath: str) -> Optional[dict]:
        if not self.json_parser.parse(jsonpath):
            raise ValueError(f"Invalid JSONPath: {jsonpath}")

        return self.json_parser.get_value_with_jsonpath_from_json_data(jsondata, jsonpath)

    #Input으로 입력 필터링 - InputPath 필터를 사용하여 사용할 상태 입력의 일부를 선택합니다
    def input_filter_by_input_path(self) -> Optional[dict]:
        logger.info(f"input_by_parameters : {self.input_path}")
        self.input_value = self.apply_json_path(self.input_value, self.input_path)
        return self.input_value

    def input_by_parameters(self) -> Optional[dict]:
        logger.info(f"input_by_parameters : {self.parameters}")
        self.input_value = self.extract_jsonpath_value_from_processing_json(self.parameters, self.input_value)


   ### Outputs
    def output_set_by_result(self):
        logger.info(f"output_set_by_result : {self.result}")
        self.output_value = self.result

    # ResultSelector로 결과 변환 - ResultSelector 필터를 사용하여 태스크 결과의 일부 (Output)을 활용해 새 JSON 객체를 생성합니다
    def output_convert_result_with_result_selector(self) -> Optional[dict]:
        self.output_value = self.extract_jsonpath_value_from_processing_json(self.result_selector, self.output_value)
        return self.output_value

    # ResultPath를 사용하여 출력에 원래 입력 추가
    def output_add_original_input_with_result_path(self) -> Optional[dict]:
        if self.result_path is None: #Discard reuslt and keep origianl Input
            self.output_value = self.input_value
        else: #Combine Original input with result
            self.output_value += self.apply_json_path(self.input_value, self.result_path)
        return self.output_value

    # jsonpath를 포함하고 있는 json(processing_json)에서 jsonpath값을 치환환 json 추출하여 결과 반환
    # 기존의 입력값을 살리기 위해 별도의 output_json객체를 deepcopy하여 .$값이 끝나는 값을 .$을 제거한 (JSONpath를 평가한) 값으로 치환하여 return
    def extract_jsonpath_value_from_processing_json(self, processing_json: dict, target_json: dict) -> Optional[dict]:
        output_json = deepcopy(processing_json)
        for key in list(processing_json.keys()):  # 원본 딕셔너리를 수정하므로 list()로 복사
            if key.endswith(".$"): # key가 .$로 끝나면
                jsonpath = processing_json[key]  # ".$" 제거하여 JsonPath 추출
                value = self.apply_json_path(target_json, jsonpath)  # JsonPath로 값 필터링 or 함수일경우 함수 실행
                output_json[key.rsplit('.$', 1)[0]] = value  # 해당 키의 값을 치환
                del output_json[key] #기존 키 삭제
        logger.info(f"Output extracted : {output_json}")
        return output_json

    #Output 입력 필터링 - Output 필터를 사용하여 사용할 상태 입력의 일부를 선택합니다
    def output_filter_by_output_path(self) -> Optional[dict]:
        logger.info(f"output_filter_by_output_path : {self.output_path}")
        self.output_value = self.apply_json_path(self.output_value, self.output_path)
        return self.output_value



    def filterling_input_by_types(self, types):
        logger.info(
            f"Filtering input by types : {types}, input_path : {self.input_path}, params: {self.parameters}, input_value:{self.input_value}")
        match types:
            case "Choice":
                pass
            case "Parallel":
                pass
            case "Map":
                pass

            case "Pass":
                if self.input_path is not None:
                    self.input_filter_by_input_path()
                if self.parameters is not None:
                    self.input_by_parameters()

            case "Wait":
                if self.input_path is not None:
                    self.input_filter_by_input_path()

            case "Succeed":
                if self.input_path is not None:
                    self.input_filter_by_input_path()

            case "Fail":
                pass
            case _:
                raise ValueError(f"Invalid type: {types}")
        logger.info(f"Filtered Input : {self.input_value}")

    def filterling_output_by_types(self, types):
        logger.info(f"Filtering output by types : {types}, {self.result_path}, {self.result}, {self.output_path}, {self.output_value}")
        match types:
            case "Choice":
                pass
            case "Parallel":
                pass
            case "Map":
                pass
            case "Pass":

                if self.result is not None:
                    self.output_set_by_result()

                if self.result_path is not None:
                    self.output_add_original_input_with_result_path()

                if self.output_path is not None:
                    self.output_filter_by_output_path()

            case "Wait":
                logger.info("Wait에 도착하였습니다!!!!!!!")
                if self.output_path is not None:
                    self.output_filter_by_output_path()
            case "Succeed":
                pass
            case "Fail":
                pass
            case _:
                raise ValueError(f"Invalid type: {types}")
        logger.info(f"Filtered Output : {self.output_value}")
