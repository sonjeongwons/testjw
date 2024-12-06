j1.son@j1-son002 MINGW64 /c/project/ssf-manager-pilot (develop-OtherOperators)
$ git diff develop..develop-OtherOperators|cat
diff --git a/Classes/Common/JSONPathObj.py b/Classes/Common/JSONPathObj.py
index 14c1a59..0261bed 100644
--- a/Classes/Common/JSONPathObj.pyk
+++ b/Classes/Common/JSONPathObj.py
@@ -1,8 +1,10 @@
+from copy import deepcopy
 from typing import Optional

 from Classes.Common.IOVariable import IOVariable
 from Util.JSONPathParser import JSONPathParser
-
+import logging
+logger = logging.getLogger('airflow.task')

 class JSONPathObj(IOVariable):
     def __init__(self,
@@ -29,7 +31,8 @@ class JSONPathObj(IOVariable):

     ### inputs
     # jsondata에서 jsonpath로 뽑아옴
-    def filter(self, jsondata: dict, jsonpath: str) -> Optional[dict]:
+
+    def apply_json_path(self, jsondata: dict, jsonpath: str) -> Optional[dict]:
         if not self.json_parser.parse(jsonpath):
             raise ValueError(f"Invalid JSONPath: {jsonpath}")

@@ -37,15 +40,18 @@ class JSONPathObj(IOVariable):

     #Input으로 입력 필터링 - InputPath 필터를 사용하여 사용할 상태 입력의 일부를 선택합니다
     def input_filter_by_input_path(self) -> Optional[dict]:
-        self.input_value = self.filter(self.input_value, self.input_path)
+        logger.debug(f"input_by_parameters : {self.input_path}")
+        self.input_value = self.apply_json_path(self.input_value, self.input_path)
         return self.input_value

-    def input_by_parameter(self) -> Optional[dict]:
+    def input_by_parameters(self) -> Optional[dict]:
+        logger.debug(f"input_by_parameters : {self.parameters}")
         self.input_value = self.extract_jsonpath_value_from_processing_json(self.parameters, self.input_value)
-        return self.input_value
+

    ### Outputs
     def output_set_by_result(self):
+        logger.debug(f"output_set_by_result : {self.result}")
         self.output_value = self.result

     # ResultSelector로 결과 변환 - ResultSelector 필터를 사용하여 태스크 결과의 일부 (Output)을 활용해 새 JSON 객체를 생성합니다
@@ -58,26 +64,33 @@ class JSONPathObj(IOVariable):
         if self.result_path is None: #Discard reuslt and keep origianl Input
             self.output_value = self.input_value
         else: #Combine Original input with result
-            self.output_value += self.filter(self.input_value, self.result_path)
+            self.output_value += self.apply_json_path(self.input_value, self.result_path)
         return self.output_value

     # jsonpath를 포함하고 있는 json(processing_json)에서 jsonpath값을 치환환 json 추출하여 결과 반환
+    # 기존의 입력값을 살리기 위해 별도의 output_json객체를 deepcopy하여 .$값이 끝나는 값을 .$을 제거한 (JSONpath를 평가한) 값으로 치환하여 return
     def extract_jsonpath_value_from_processing_json(self, processing_json: dict, target_json: dict) -> Optional[dict]:
+        output_json = deepcopy(processing_json)
         for key in list(processing_json.keys()):  # 원본 딕셔너리를 수정하므로 list()로 복사
             if key.endswith(".$"): # key가 .$로 끝나면
                 jsonpath = processing_json[key]  # ".$" 제거하여 JsonPath 추출
-                value = self.filter(target_json, jsonpath)  # JsonPath로 값 필터링
-                processing_json[key] = value  # 해당 키의 값을 치환
-        return processing_json
+                value = self.apply_json_path(target_json, jsonpath)  # JsonPath로 값 필터링 or 함수일경우 함수 실행
+                output_json[key.rsplit('.$', 1)[0]] = value  # 해당 키의 값을 치환
+                del output_json[key] #기존 키 삭제
+        logger.debug(f"Output extracted : {output_json}")
+        return output_json

     #Output 입력 필터링 - Output 필터를 사용하여 사용할 상태 입력의 일부를 선택합니다
     def output_filter_by_output_path(self) -> Optional[dict]:
-        self.output_value = self.filter(self.output_value, self.output_path)
+        logger.debug(f"output_filter_by_output_path : {self.output_path}")
+        self.output_value = self.apply_json_path(self.output_value, self.output_path)
         return self.output_value



     def filterling_input_by_types(self, types):
+        logger.debug(
+            f"Filtering input by types : {types}, input_path : {self.input_path}, params: {self.parameters}, input_value:{self.input_value}")
         match types:
             case "Choice":
                 pass
@@ -85,19 +98,29 @@ class JSONPathObj(IOVariable):
                 pass
             case "Map":
                 pass
+
             case "Pass":
-                pass
+                if self.input_path is not None:
+                    self.input_filter_by_input_path()
+                if self.parameters is not None:
+                    self.input_by_parameters()
+
             case "Wait":
                 if self.input_path is not None:
                     self.input_filter_by_input_path()
+
             case "Succeed":
-                pass
+                if self.input_path is not None:
+                    self.input_filter_by_input_path()
+
             case "Fail":
                 pass
             case _:
                 raise ValueError(f"Invalid type: {types}")
+        logger.debug(f"Filtered Input : {self.input_value}")

     def filterling_output_by_types(self, types):
+        logger.debug(f"Filtering output by types : {types}, {self.result_path}, {self.result}, {self.output_path}, {self.output_value}")
         match types:
             case "Choice":
                 pass
@@ -106,8 +129,18 @@ class JSONPathObj(IOVariable):
             case "Map":
                 pass
             case "Pass":
-                pass
+
+                if self.result is not None:
+                    self.output_set_by_result()
+
+                if self.result_path is not None:
+                    self.output_add_original_input_with_result_path()
+
+                if self.output_path is not None:
+                    self.output_filter_by_output_path()
+
             case "Wait":
+                logger.info("Wait에 도착하였습니다!!!!!!!")
                 if self.output_path is not None:
                     self.output_filter_by_output_path()
             case "Succeed":
@@ -116,3 +149,4 @@ class JSONPathObj(IOVariable):
                 pass
             case _:
                 raise ValueError(f"Invalid type: {types}")
+        logger.debug(f"Filtered Output : {self.output_value}")
\ No newline at end of file
diff --git a/Classes/Common/JSONataObj.py b/Classes/Common/JSONataObj.py
index 71e5971..ca5ccb1 100644
--- a/Classes/Common/JSONataObj.py
+++ b/Classes/Common/JSONataObj.py
@@ -1,7 +1,8 @@
 from typing import Optional

 from Classes.Common.IOVariable import IOVariable
-
+import logging
+logger = logging.getLogger('airflow.task')

 class JSONataObj(IOVariable):
     def __init__(self,
@@ -17,7 +18,9 @@ class JSONataObj(IOVariable):
         self.assign = assign
         self.output = output

+
     def filterling_input_by_types(self, types):
+        logger.debug(f"Filitering JSONataObj / input: {self.input_value}, assign: {self.assign}, output: {self.output}")
         match types:
             case "Choice":
                 pass
@@ -35,8 +38,11 @@ class JSONataObj(IOVariable):
                 pass
             case _:
                 raise ValueError(f"Invalid type: {types}")
+        logger.debug(f"Filtered input: {self.input_value}")

     def filterling_output_by_types(self, types):
+        logger.debug(f"Filitering JSONataObj / Output: {self.output_value}, assign: {self.assign}, output: {self.output}")
+
         match types:
             case "Choice":
                 pass
@@ -54,3 +60,4 @@ class JSONataObj(IOVariable):
                 pass
             case _:
                 raise ValueError(f"Invalid type: {types}")
+        logger.debug(f"Filtered output: {self.output_value}")
\ No newline at end of file
diff --git a/Classes/Common/StateMeta.py b/Classes/Common/StateMeta.py
index 8298f93..d5bc4f1 100644
--- a/Classes/Common/StateMeta.py
+++ b/Classes/Common/StateMeta.py
@@ -3,8 +3,8 @@ from typing import Optional
 class StateMeta():
     def __init__(self,
                  name: str,
-                 comment: str,
                  type: str,
+                 comment: Optional[str] = "",
                  query_language: str = "JSONPath",
                  next: Optional[str] = None,
                  end: Optional[bool] = None,
diff --git a/Classes/Validators/__init__.py b/Classes/Validators/__init__.py
deleted file mode 100644
index e69de29..0000000
diff --git a/Operator/PassOperator.py b/Operator/PassOperator.py
index 37ba56f..f2722db 100644
--- a/Operator/PassOperator.py
+++ b/Operator/PassOperator.py
@@ -2,53 +2,46 @@ from typing import Optional, Any

 from airflow.models import BaseOperator

-from Classes.Common import IOVariable, StateMeta
+import Classes.Common.JSONPathObj
+from Classes.Common.StateMeta import StateMeta
+from Classes.Common.JSONataObj import JSONataObj
+from Classes.Common.JSONPathObj import JSONPathObj


 class PassOperator(BaseOperator):
     def __init__(self,
                  meta: dict,
                  io_variable: dict,
-                 object_variable: Optional[dict] = None,
+                 *args,
                  **kwargs
                  ):
-        super().__init__(**kwargs)

-        self.meta = StateMeta(meta)
+        self.meta = StateMeta(**meta)
+
+        super().__init__(*args, **kwargs)
+
         if meta.get('query_language') == "JSONata":
-            self.io_variable = IOVariable(io_variable).JSONataObj(io_variable)
+            self.io_variable = JSONataObj(**io_variable)
         elif meta.get('query_language') in ["JSONPath", None]:
-            self.io_variable = IOVariable(io_variable).JSONPathObj(io_variable)
-
-        self.object_variable = None
+            self.io_variable = JSONPathObj(**io_variable,)

     def pre_execute(self, context: Any):
         self.input_value_process()

-    def execute(self, context):
-        self.process()
+    def execute(self, context: Any):
+        # The Pass State (identified by "Type":"Pass") by default passes its input to its output, performing no work.
+        pass
+
+    def post_execute(self, context: Any, result: Any = None):
         self.output_value_process()

-        return self.io_variable.output_value
+        context['task_instance'].xcom_push(key="output_value", value=self.io_variable.output_value)
+        super().post_execute(context, result)

     def input_value_process(self):
-        if self.io_variable.input_path is not None:
-            self.io_variable.input_filter_by_input_path()
-
-        if self.io_variable.parameter is not None:
-            self.io_variable.input_by_parameter()
-
-    def process(self):
-        pass
+        self.io_variable.filterling_input_by_types(self.meta.type)

     def output_value_process(self):
-        if self.io_variable.result is not None:
-            self.io_variable.output_set_by_result()
-
-        if self.io_variable.result_path is not None:
-            self.io_variable.output_add_original_input_with_result_path()
-
-        if self.io_variable.output_path is not None:
-            self.io_variable.output_filter_by_output_path()
+        self.io_variable.filterling_output_by_types(self.meta.type)


diff --git a/Operator/SucceedOperator.py b/Operator/SucceedOperator.py
index 2c72a4b..a07bc3a 100644
--- a/Operator/SucceedOperator.py
+++ b/Operator/SucceedOperator.py
@@ -1,46 +1,48 @@
-from typing import Optional, Any
+from typing import Any

 from airflow.models import BaseOperator
-from Classes.Common import IOVariable, StateMeta

+from Classes.Common.StateMeta import StateMeta
+from Classes.Common.JSONataObj import JSONataObj
+from Classes.Common.JSONPathObj import JSONPathObj

-class SuccessOperator(BaseOperator):
+
+class SucceedOperator(BaseOperator):
     def __init__(self,
                  meta: dict,
                  io_variable: dict,
-                 object_variable: Optional[dict] = None,
+                 *args,
                  **kwargs
                  ):
         super().__init__(**kwargs)

-        self.meta = StateMeta(meta)
+        self.meta = StateMeta(**meta)

         if meta.get('query_language') == "JSONata":
-            self.io_variable = IOVariable(io_variable).JSONataObj(io_variable)
+            self.io_variable = JSONataObj(**io_variable)
         elif meta.get('query_language') in ["JSONPath", None]:
-            self.io_variable = IOVariable(io_variable).JSONPathObj(io_variable)
-
-        self.io_variable = IOVariable(io_variable)
-        self.object_variable = None
-
-
-    def input_value_process(self):
-        pass
+            self.io_variable = JSONPathObj(**io_variable)

-    def process(self):
-        pass
-
-    def output_value_process(self):
-        pass

     def pre_execute(self, context: Any):
         self.input_value_process()

-    def execute(self, context):
-        self.process()
+    def execute(self, context: Any):
+        pass
+
+    def post_execute(self, context, result):
         self.output_value_process()
+        context['task_instance'].xcom_push(key="output_value", value=self.io_variable.output_value)
+        super().post_execute(context, result)

-        return self.io_variable.output_value
+    def input_value_process(self):
+        self.io_variable.filterling_input_by_types(self.meta.type)
+
+    def output_value_process(self):
+        # If "Output" is not provided, the Succeed State copies its input through to its output.
+        # A JSONata Succeed State MAY have an "Output" field whose value, if present, will become the state output.
+        self.io_variable.output_value = self.io_variable.input_value
+        self.io_variable.filterling_output_by_types(self.meta.type)



diff --git a/Operator/WaitOperator.py b/Operator/WaitOperator.py
index 852832a..2aaafec 100644
--- a/Operator/WaitOperator.py
+++ b/Operator/WaitOperator.py
@@ -39,19 +39,13 @@ class WaitOperator(BaseOperator):
     def pre_execute(self, context: Any):
         self.input_value_process()

-    def input_value_process(self):
-        # input을 IO_Variables에 맞게 처리함
-        self.io_variable.filterling_input_by_types(self.meta.type)
-
-        # io_vairable의 input_value를 이용해서 평가된 wait_time timestamp를 확인
-        self.evaluated_wait_timestamp = WaitObjectVariables(self.object_variable).evaluate(self.io_variable.input_value)

     def execute(self, context: Any):
         self.log.info(f"현재: {datetime.now().isoformat()}, 평가후 Evaluated Wait Time Stamp:  {self.evaluated_wait_timestamp}")
         self.log.info(f"execute 시작, {datetime.now().isoformat()}")
         self.log.info(f"context: {context}")

-
+
     def post_execute(self, context, result):
         self.log.info(f"execute 종료, {datetime.now().isoformat()}")
         self.output_value_process()
@@ -64,6 +58,13 @@ class WaitOperator(BaseOperator):
         # CustomOperator에서는 위와같이 Result를 Push해줘야함.
         # return self.io_variable.output_value

+    def input_value_process(self):
+        # input을 IO_Variables에 맞게 처리함
+        self.io_variable.filterling_input_by_types(self.meta.type)
+
+        # io_vairable의 input_value를 이용해서 평가된 wait_time timestamp를 확인
+        self.evaluated_wait_timestamp = WaitObjectVariables(self.object_variable).evaluate(self.io_variable.input_value)
+
     def output_value_process(self):
         self.io_variable.filterling_output_by_types(self.meta.type)

diff --git a/TestTemplate/ParsedJSON/Pass_with_two_type.json b/TestTemplate/ParsedJSON/Pass_with_two_type.json
new file mode 100644
index 0000000..f1c67c2
--- /dev/null
+++ b/TestTemplate/ParsedJSON/Pass_with_two_type.json
@@ -0,0 +1,35 @@
+{
+    "query_language": "JSONPath",
+    "start_at": "JSONPath state",
+    "states": {
+        "JSONPath state": {
+            "io_variable": {
+                "parameters": {
+                    "total.$": "$.transaction.total"
+                },
+                "query_language": "JSONPath"
+            },
+            "meta": {
+                "end": false,
+                "name": "JSONPath state",
+                "next": "JSONata state",
+                "query_language": "JSONPath",
+                "type": "Pass"
+            }
+        },
+        "JSONata state": {
+            "io_variable": {
+                "output": {
+                    "total": "{% $states.input.transaction.total %}"
+                },
+                "query_language": "JSONata"
+            },
+            "meta": {
+                "end": true,
+                "name": "JSONata state",
+                "query_language": "JSONata",
+                "type": "Pass"
+            }
+        }
+    }
+}
\ No newline at end of file
diff --git a/TestTemplate/RawJSONTemplate/Pass_with_two_type.json b/TestTemplate/RawJSONTemplate/Pass_with_two_type.json
new file mode 100644
index 0000000..e5b1e78
--- /dev/null
+++ b/TestTemplate/RawJSONTemplate/Pass_with_two_type.json
@@ -0,0 +1,21 @@
+{
+  "QueryLanguage": "JSONPath",
+  "StartAt": "JSONPath state",
+  "States": {
+    "JSONPath state": {
+      "Type": "Pass",
+      "Parameters": {
+        "total.$": "$.transaction.total"
+      },
+      "Next": "JSONata state"
+    },
+    "JSONata state": {
+      "Type": "Pass",
+      "QueryLanguage": "JSONata",
+      "Output": {
+        "total": "{% $states.input.transaction.total %}"
+      },
+      "End": true
+    }
+  }
+}
\ No newline at end of file
diff --git a/Util/JSONPathParser.py b/Util/JSONPathParser.py
index 7b7ae98..aebbb2d 100644
--- a/Util/JSONPathParser.py
+++ b/Util/JSONPathParser.py
@@ -1,6 +1,8 @@
 import json
 from jsonpath_ng import parse
 from jsonpath_ng.exceptions import JsonPathParserError
+import logging
+logger = logging.getLogger('airflow.task')

 class JSONPathParser:
     def __init__(self):
@@ -15,14 +17,18 @@ class JSONPathParser:

     @staticmethod
     def get_value_with_jsonpath_from_json_data(json_data, json_path):
-        expression = parse(json_path)
-        value = {match.value for match in expression.find(json_data)}
+        try:
+            expression = parse(json_path)
+            logger.info(f"Parsing JSON path '{json_path}' from JSON data")
+            value = {match.value for match in expression.find(json_data)}

-        if type(value) is set: # Key-value가 아닐때,
-            value = list(value)
-            if len(value) == 1: # 값으로 반환
-                return value[0]
-            else: # List로 반환
+            if type(value) is set: # Key-value가 아닐때,
+                value = list(value)
+                if len(value) == 1: # 값으로 반환
+                    return value[0]
+                else: # List로 반환
+                    return value
+            else:
                 return value
-        else:
-            return value
\ No newline at end of file
+        except JsonPathParserError:
+            logger.exception('JsonPathParserError')
\ No newline at end of file
diff --git a/Util/JSONataParser.py b/Util/JSONataParser.py
index ef07f15..1b4b499 100644
--- a/Util/JSONataParser.py
+++ b/Util/JSONataParser.py
@@ -1,6 +1,5 @@
 # pip install jsonata-python
 # https://github.com/rayokota/jsonata-python
-import logging

 import jsonata
 import json
@@ -19,10 +18,14 @@ class JSONataParser:
     @staticmethod
     # Jsonata 평가규칙으로 평가한 값을 Return함.
     def get_value_with_jsonata_from_json_data(json_data, jsonata_str):
+        import logging
+        logger = logging.getLogger('airflow.task')
+
         try:
             jsonata.Jsonata(jsonata_str)
             expr = jsonata.Jsonata(jsonata_str)
             value = expr.evaluate(json_data)
+            logger.debug(f"jsonata_str {jsonata_str} -> value {value}")

             if type(value) is set:  # Key-value가 아닐때,
                 value = list(value)
@@ -34,5 +37,5 @@ class JSONataParser:
                 return value

         except Exception as e:
-            logging.error(f"JSONata expression : {str(e)}")
+            logging.exception(f"JSONata expression : {str(e)}")

diff --git a/app/routes/Mapper/VariableObjectMapper.py b/app/routes/Mapper/VariableObjectMapper.py
index d3b60fe..739e4e9 100644
--- a/app/routes/Mapper/VariableObjectMapper.py
+++ b/app/routes/Mapper/VariableObjectMapper.py
@@ -44,7 +44,11 @@ def meta_mapper(object_detail: dict, workflow_query_language: str) -> dict:
     if object_detail.get("QueryLanguage") == None:
         object_detail["QueryLanguage"] = workflow_query_language

-    return obj if meta_validate_variables_mapping(obj) else vaild
+
+    if meta_validate_variables_mapping(obj):
+        return obj
+    else:
+        raise ValueError(f"meta mapper 오류 : {obj}")



diff --git a/dags/test_my_Pass_Operator.py b/dags/test_my_Pass_Operator.py
new file mode 100644
index 0000000..a6a220c
--- /dev/null
+++ b/dags/test_my_Pass_Operator.py
@@ -0,0 +1,58 @@
+from __future__ import annotations
+
+import datetime, json
+from airflow.models.dag import DAG
+from airflow.operators.python import PythonOperator
+
+from Operator.PassOperator import PassOperator
+import logging
+
+logger = logging.getLogger(__name__)
+
+with (DAG(
+        dag_id="test_my_pass_operator",
+        schedule=datetime.timedelta(hours=4),
+        start_date=datetime.datetime(2021, 1, 1),
+        catchup=False,
+        tags=["cloud.park", "passOperator"],
+) as dag):
+
+    file_path = r'TestTemplate/ParsedJSON/Pass_with_two_type.json'
+    with open(f"/opt/airflow/plugins/{file_path}", 'r') as json_file:
+        input_json = json.load(json_file)
+
+    sample_state_variable = input_json["states"]["JSONPath state"]
+
+    global_io_variable = {}
+    global_io_variable["input_value"] = json.loads("""
+    {
+        "transaction" : {
+            "total" : "100"
+         }
+    }
+    """)
+
+
+    task1 = PythonOperator(
+        task_id="task1",
+        python_callable=lambda: print(datetime.datetime.now())
+    )
+
+    sample_state_variable["io_variable"]['input_value'] = global_io_variable["input_value"]
+    task2 = PassOperator(
+        task_id="task2",
+        meta=sample_state_variable["meta"],
+        io_variable=sample_state_variable["io_variable"],
+    )
+
+
+
+    task3 = PythonOperator(
+        task_id="task3",
+        python_callable=lambda: print(datetime.datetime.now())
+    )
+
+    task1 >> task2 >> task3
+
+if __name__ == "__main__":
+    dag.test()
\ No newline at end of file
diff --git a/dags/test_my_Suceed_Operator.py b/dags/test_my_Suceed_Operator.py
new file mode 100644
index 0000000..9ba3663
--- /dev/null
+++ b/dags/test_my_Suceed_Operator.py
@@ -0,0 +1,56 @@
+from __future__ import annotations
+
+import datetime, json
+from airflow.models.dag import DAG
+from airflow.operators.python import PythonOperator
+
+from Operator.SucceedOperator import SucceedOperator
+
+
+with (DAG(
+        dag_id="test_my_Succeed_operator",
+        schedule=datetime.timedelta(hours=4),
+        start_date=datetime.datetime(2021, 1, 1),
+        catchup=False,
+        tags=["cloud.park", "SucceedOperator"],
+) as dag):
+
+    with open("/opt/airflow/plugins/TestTemplate/ParsedJSON/parsed_jsonata1.json", 'r') as json_file:
+        input_json = json.load(json_file)
+
+    sample_state_variable = input_json["states"]["Summarize the Execution"]
+
+    global_io_variable = {}
+    global_io_variable["input_value"] = json.loads("""
+    {
+        "Hello" : 10
+    }
+    """)
+
+
+    task1 = PythonOperator(
+        task_id="task1",
+        python_callable=lambda: print(datetime.datetime.now())
+    )
+
+
+    task2 = SucceedOperator(
+        task_id="task2",
+        meta=sample_state_variable["meta"],
+        io_variable=global_io_variable,
+    )
+
+
+    def value_from_task(**context):
+        res = context['task_instance'].xcom_pull(key='output_value')
+        print(res)
+
+    task3 = PythonOperator(
+        task_id="task3",
+        python_callable=value_from_task
+    )
+
+    task1 >> task2 >> task3
+
+if __name__ == "__main__":
+    dag.test()
\ No newline at end of file
diff --git a/docker-compose.yaml b/docker-compose.yaml
index d8137b6..dc49d4c 100644
--- a/docker-compose.yaml
+++ b/docker-compose.yaml
@@ -58,6 +58,7 @@ x-airflow-common:
     AIRFLOW__CELERY__RESULT_BACKEND: db+postgresql://airflow:airflow@postgres/airflow
     AIRFLOW__CELERY__BROKER_URL: redis://:@redis:6379/0
     AIRFLOW__CORE__FERNET_KEY: ''
+    AIRFLOW__LOGGING__LOGGING_LEVEL: 'DEBUG'
     AIRFLOW__CORE__DAGS_ARE_PAUSED_AT_CREATION: 'true'
     AIRFLOW__CORE__LOAD_EXAMPLES: 'false'
     AIRFLOW__API__AUTH_BACKENDS: 'airflow.api.auth.backend.basic_auth,airflow.api.auth.backend.session'
