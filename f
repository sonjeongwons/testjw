j1.son@SDS-DIS-15776 MINGW64 /c/project/ssf (cloudpark-WaitSensordevel)
$ git diff origin/cloudpark-WaitSensordevel..main|cat
diff --git a/Classes/Common/IOVariable.py b/Classes/Common/IOVariable.py
index 1553ee5..133d005 100644
--- a/Classes/Common/IOVariable.py
+++ b/Classes/Common/IOVariable.py
@@ -1,8 +1,7 @@
 from typing import Optional
-from abc import ABC, abstractmethod

-# JSONPathObj, JSONataObj를 위한 추상클래스
-class IOVariable(ABC):
+
+class IOVariable():
     def __init__(self,
                  query_language: str = "JSONPath",
                  input_value: Optional[dict] = {},
@@ -16,12 +15,4 @@ class IOVariable(ABC):
         self.input_value = input_value  # 초기 input에서 변환되어 최종저긍로 사용되는 input값
         self.output_value = output_value  # 최종적으로 사용되는 결과값

-    @abstractmethod
-    def filterling_input_by_types(self, types):
-        pass
-
-    @abstractmethod
-    def filterling_output_by_types(self, types):
-        pass
-

diff --git a/Classes/Common/JSONataObj.py b/Classes/Common/JSONataObj.py
index 71e5971..7b074e6 100644
--- a/Classes/Common/JSONataObj.py
+++ b/Classes/Common/JSONataObj.py
@@ -16,41 +16,3 @@ class JSONataObj(IOVariable):
         super().__init__(query_language=query_language, input_value=input_value, output_value=output_value)
         self.assign = assign
         self.output = output
-
-    def filterling_input_by_types(self, types):
-        match types:
-            case "Choice":
-                pass
-            case "Parallel":
-                pass
-            case "Map":
-                pass
-            case "Pass":
-                pass
-            case "Wait":
-                pass
-            case "Succeed":
-                pass
-            case "Fail":
-                pass
-            case _:
-                raise ValueError(f"Invalid type: {types}")
-
-    def filterling_output_by_types(self, types):
-        match types:
-            case "Choice":
-                pass
-            case "Parallel":
-                pass
-            case "Map":
-                pass
-            case "Pass":
-                pass
-            case "Wait":
-                pass
-            case "Succeed":
-                pass
-            case "Fail":
-                pass
-            case _:
-                raise ValueError(f"Invalid type: {types}")
diff --git a/Classes/Common/JSONPathObj.py b/Classes/Common/JSONpathObj.py
similarity index 77%
rename from Classes/Common/JSONPathObj.py
rename to Classes/Common/JSONpathObj.py
index 14c1a59..9113200 100644
--- a/Classes/Common/JSONPathObj.py
+++ b/Classes/Common/JSONpathObj.py
@@ -44,6 +44,7 @@ class JSONPathObj(IOVariable):
         self.input_value = self.extract_jsonpath_value_from_processing_json(self.parameters, self.input_value)
         return self.input_value

+
    ### Outputs
     def output_set_by_result(self):
         self.output_value = self.result
@@ -74,45 +75,3 @@ class JSONPathObj(IOVariable):
     def output_filter_by_output_path(self) -> Optional[dict]:
         self.output_value = self.filter(self.output_value, self.output_path)
         return self.output_value
-
-
-
-    def filterling_input_by_types(self, types):
-        match types:
-            case "Choice":
-                pass
-            case "Parallel":
-                pass
-            case "Map":
-                pass
-            case "Pass":
-                pass
-            case "Wait":
-                if self.input_path is not None:
-                    self.input_filter_by_input_path()
-            case "Succeed":
-                pass
-            case "Fail":
-                pass
-            case _:
-                raise ValueError(f"Invalid type: {types}")
-
-    def filterling_output_by_types(self, types):
-        match types:
-            case "Choice":
-                pass
-            case "Parallel":
-                pass
-            case "Map":
-                pass
-            case "Pass":
-                pass
-            case "Wait":
-                if self.output_path is not None:
-                    self.output_filter_by_output_path()
-            case "Succeed":
-                pass
-            case "Fail":
-                pass
-            case _:
-                raise ValueError(f"Invalid type: {types}")
diff --git a/Classes/ObjectVariables/WaitObjectVariables.py b/Classes/Validators/WaitObjectValidator.py
similarity index 63%
rename from Classes/ObjectVariables/WaitObjectVariables.py
rename to Classes/Validators/WaitObjectValidator.py
index 8958e96..a8afce4 100644
--- a/Classes/ObjectVariables/WaitObjectVariables.py
+++ b/Classes/Validators/WaitObjectValidator.py
@@ -1,23 +1,16 @@
 from datetime import datetime, timezone, timedelta
 from typing import Optional
-
 from Util.JSONPathParser import JSONPathParser
 from Util.JSONataParser import JSONataParser


-class WaitObjectVariables:
+
+class WaitObjectValidator:
     def __init__(self,
                  obj : dict,
                  query_language : Optional[str] = "JSONPath"):

         self.obj = obj
-        self.validate_variables_mapping()
-
-        self.seconds = obj.get("seconds")
-        self.seconds_path = obj.get("seconds_path")
-        self.timestamp = obj.get("timestamp")
-        self.timestamp_path = obj.get("timestamp_path")
-
         self.query_language = query_language
         self.evaluated_timestamp = None

@@ -27,52 +20,49 @@ class WaitObjectVariables:
         if len(self.obj.items()) > 1:
             raise ValueError("Second, secondsPath, timestamp, timestampPath 중 1개만 입력 가능합니다.")

-    # 값에 대한 유효성 검증을 수행한 후, 실제 wait해야하는 값에 대한 timestamp를 반환
-    # Wait 값이 있을경우 Timestamp를 출력, 없을경우 현재시간의 datetime.now()를 출력함.
     def evaluate(self, input_value : dict) -> str:
         self.validate()
         self.inject(input_value)
-        return self.evaluated_timestamp if self.post_validate() is True else datetime.now().isoformat()
+        self.post_validate()
+        return self.evaluated_timestamp
+

     def inject(self, input_value : dict) -> bool:
         # seconds, secondspath, timestamp, timestampPath를 이용해서 해당 값을 timestamp 방식으로 변환하여 `self.evauated_timestamp`로 리턴함

-        if self.seconds is not None:
+        if self.obj.get('seconds') is not None:
             if self.query_language == "JSONPath":
-                seconds = self.seconds
+                seconds = self.obj.get('seconds')
             elif self.query_language == "JSONata":
-                if isinstance(self.seconds, int):
-                    seconds = self.seconds
-                elif isinstance(self.seconds, str):
-                    seconds = JSONataParser.get_value_with_jsonata_from_json_data(json_data = input_value, jsonata_str=self.seconds)
+                if isinstance(self.obj.get('seconds'), int):
+                    seconds = self.obj.get('seconds')
+                elif isinstance(self.obj.get('seconds'), str):
+                    seconds = JSONataParser.get_value_with_jsonata_from_json_data(json_data = input_value, jsonata_str=self.obj.get('seconds'))

-        elif self.seconds_path is not None:
+        elif self.obj.get('secondsPath') is not None:
             try:
-                seconds=int(JSONPathParser.get_value_with_jsonpath_from_json_data(json_data=input_value, json_path=self.seconds_path))
+                seconds=int(JSONPathParser.get_value_with_jsonpath_from_json_data(json_data=input_value, json_path=self.obj.get('secondsPath')))
             except:
                 raise ValueError("유효하지 않은 secondsPath입니다.")

-        elif self.timestamp is not None:
+        elif self.obj.get('timestamp') is not None:
             try:
-                self.evaluated_timestamp = datetime.fromisoformat(self.timestamp.replace('Z', '+00:00'))
+                self.evaluated_timestamp = datetime.fromisoformat(self.obj.get('timestamp').replace('Z', '+00:00'))
                 return True
             except:
                 raise ValueError("유효하지 않은 timestamp입니다.")


-        elif self.timestamp_path is not None:
+        elif self.obj.get('timestampPath') is not None:
             try:
-                timestamp = JSONPathParser.get_value_with_jsonpath_from_json_data(json_data= input_value, json_path=self.timestamp_path)
+                timestamp = JSONPathParser.get_value_with_jsonpath_from_json_data(json_data= input_value, json_path=self.obj.get('timestampPath'))
                 self.evaluated_timestamp = datetime.fromisoformat(timestamp.replace('Z', '+00:00'))
                 return True
             except:
                 raise ValueError("유효하지 않은 timestampPath입니다.")

-        if self.seconds is not None or self.seconds_path is not None:
+        if self.obj.get('seconds') is not None or self.obj.get('secondsPath') is not None:
             try:
-                import logging
-                logger = logging.getLogger(__name__)
-                logger.info(f"self.seconds: {self.seconds}")
                 now = datetime.now()
                 future_time = now + timedelta(seconds=seconds)
                 self.evaluated_timestamp = future_time.isoformat()
@@ -95,19 +85,20 @@ class WaitObjectVariables:
             return True if validation is True else False

     def validate_seconds(self) -> bool:
-        if self.seconds == None:
+        seconds = self.obj.get('seconds')
+        if seconds == None:
             return True

-        if isinstance(self.seconds, (int)):
-            if not (0 <= self.seconds <= 99999999):
+        if isinstance(seconds, (int)):
+            if not (0 <= seconds <= 99999999):
                 raise ValueError("0에서 99999999까지의 양의 정수만 지원합니다.")

-            if self.seconds > 31536000:
+            if seconds > 31536000:
                 raise ValueError("1년 이상의 Seconds는 지원하지 않습니다")

-        elif isinstance(self.seconds, (str)):
+        elif isinstance(seconds, (str)):
             if self.query_language == "JSONata":
-                JSONataParser.parse(jsonata_str = self.seconds)
+                JSONataParser.parse(jsonata_str = seconds)

             elif self.query_language == "JSONPath":
                 raise ValueError("JSONPath 의 Wait Obejct seconds는 int여야합니다.")
@@ -119,15 +110,16 @@ class WaitObjectVariables:


     def validate_seconds_path(self) -> bool:
-        if self.seconds_path is None:
+        seconds_path = self.obj.get('seconds_path')
+        if seconds_path == None:
             return True

-        if isinstance(self.seconds_path, (str)):
+        if isinstance(seconds_path, (str)):
             if self.query_language == "JSONata":
                 raise ValueError("JSONata는 seconds_path를 지원하지 않습니다")

             elif self.query_language == "JSONPath":
-                return False if JSONPathParser.parse(self.seconds_path) is False else True
+                return False if JSONPathParser.parse(seconds_path) is False else True

         else:
             raise TypeError("지원하지 않는 Type의 seconds_path입니다. ")
@@ -137,20 +129,21 @@ class WaitObjectVariables:


     def validate_timestamp(self):
-        if self.timestamp is None:
+        timestamp = self.obj.get('timestamp')
+        if timestamp is None:
             return True

-        if isinstance(self.timestamp, (str)):
+        if isinstance(timestamp, (str)):
             current_time = datetime.now(timezone.utc)

             if self.query_language == "JSONata":
                 # JSONATA Type의 Value인지 확인
-                JSONataParser.get_value_with_jsonata_from_json_data(self.timestamp)
+                JSONataParser.get_value_with_jsonata_from_json_data(timestamp)


             elif self.query_language == "JSONPath":
                 try:
-                    timestamp_datetime = datetime.fromisoformat(self.timestamp.replace('Z', '+00:00'))
+                    timestamp_datetime = datetime.fromisoformat(timestamp.replace('Z', '+00:00'))
                     one_year_later = current_time + timedelta(days=365)
                     if not (current_time <= timestamp_datetime <= one_year_later):
                         raise ValueError(
@@ -161,42 +154,27 @@ class WaitObjectVariables:
         return True

     def validate_timestamp_path(self):
-        if self.timestamp_path is None:
+        timestamp_path = self.obj.get('timestamp_path')
+        if timestamp_path is None:
             return True

-        if isinstance(self.timestamp_path, (str)):
+        if isinstance(timestamp_path, (str)):
             if self.query_language == "JSONata":
                 raise ValueError("JSONata는 timestamp_path를 지원하지 않습니다")

             elif self.query_language == "JSONPath":
-                return False if JSONPathParser.parse(self.timestamp_path) is False else True
+                return False if JSONPathParser.parse(timestamp_path) is False else True

         else:
             raise TypeError("지원하지 않는 Type의 timestamp_path입니다. ")

         return True

-    def post_validate(self) -> bool:
+    def post_validate(self):
         if self.evaluated_timestamp is None:
             raise ValueError("평가된 Timestamp가 없습니다")
         if type(self.evaluated_timestamp) is not str:
             raise TypeError("TimeStamp의 값이 올바르지 않습니다")
-        if self._is_within_one_year(self.evaluated_timestamp) is False:
-            raise ValueError("Wait은 1년 내로 실행되어야합니다.")
-        return True

-    def _is_within_one_year(self, iso_format_str_datetime):
-        # 현재 날짜와 시간 가져오기
-        now = datetime.now()
-
-        # 주어진 ISO 포맷 날짜 문자열을 datetime 객체로 변환
-        target_date = datetime.fromisoformat(iso_format_str_datetime)
-
-        # 1년 후의 날짜 계산
-        one_year_later = now + timedelta(days=365)
+        return True

-        # 타겟 날짜가 현재 날짜와 1년 이내인지 확인
-        if now <= target_date <= one_year_later:
-            return True
-        else:
-            return False
diff --git a/Operator/WaitOperator.py b/Operator/WaitOperator.py
index d2d6a2b..4d1241e 100644
--- a/Operator/WaitOperator.py
+++ b/Operator/WaitOperator.py
@@ -1,18 +1,16 @@
-from datetime import datetime
 from typing import Optional, Any
+from airflow.models import BaseOperator

-from airflow.sensors.date_time import DateTimeSensorAsync
-
-from Classes.Common.JSONPathObj import JSONPathObj
+from Classes.Common.JSONpathObj import JSONPathObj
 from Classes.Common.JSONataObj import JSONataObj
 from Classes.Common.StateMeta import StateMeta
-from Classes.ObjectVariables.WaitObjectVariables import WaitObjectVariables
+from Classes.Validators.WaitObjectValidator import WaitObjectValidator
+from Util.JSONPathParser import JSONPathParser

 import logging
 logger = logging.getLogger(__name__)
-logger.setLevel(logging.DEBUG)

-class WaitOperator(DateTimeSensorAsync):
+class WaitOperator(BaseOperator):
     def __init__(self,
                  meta: dict,
                  io_variable: dict,
@@ -21,6 +19,9 @@ class WaitOperator(DateTimeSensorAsync):
                  **kwargs
                  ):

+        super().__init__(
+            *args,
+            **kwargs)

         self.meta = StateMeta(**meta)

@@ -31,35 +32,48 @@ class WaitOperator(DateTimeSensorAsync):

         self.object_variable = object_variable
         self.evaluated_wait_timestamp = None
-        self.input_value_process()

-        logger.info(f"evaluated_wait_timestamp: {self.evaluated_wait_timestamp}")
+        self.json_parser = JSONPathParser()

-        #필요할경우 end_from_trigger를 통해 wait until로 구현할 수 있을지도..?
-        super().__init__(
-            target_time = self.evaluated_wait_timestamp,
-            *args,
-            **kwargs)

     def input_value_process(self):
-        # input을 IO_Variables에 맞게 처리함
-        self.io_variable.filterling_input_by_types(self.meta.type)
+        logger.info("평가전 evaluated_wait_timestamp", self.evaluated_wait_timestamp)
+        if self.meta.query_language == "JSONPath":
+            if hasattr(self.io_variable, 'input_path') and self.io_variable.input_path is not None:
+                self.io_variable.input_filter_by_input_path()
+
+        elif self.meta.query_language == "JSONata":
+            print("hello")
+
+        # io_vairable의 input_value를 이용해서 평가된 wait_time

-        # io_vairable의 input_value를 이용해서 평가된 wait_time timestamp를 확인
-        self.evaluated_wait_timestamp = WaitObjectVariables(self.object_variable).evaluate(self.io_variable.input_value)
+
+        self.evaluated_wait_timestamp = WaitObjectValidator(self.object_variable).evaluate(self.io_variable.input_value)
+        logger.info(f"평가후 Evaluated Wait Time Stamp: {self.evaluated_wait_timestamp}")
+
+
+
+    def process(self):
+        pass

     def output_value_process(self):
-        self.io_variable.filterling_output_by_types(self.meta.type)
+        if self.io_variable.output_path is not None:
+            self.io_variable.output_filter_by_output_path()
+

-    def execute(self, context: Any):
-        logger.info(f"현재: {datetime.now().isoformat()}, 평가후 Evaluated Wait Time Stamp:  {self.evaluated_wait_timestamp}")
-        logger.info(f"execute 시작, {datetime.now().isoformat()}")
-        logger.info(f"context: {context}")
-        super().execute(context)
+    def pre_execute(self, context: Any):

-
-    def post_execute(self, context, result):
-        logger.info(f"execute 종료, {datetime.now().isoformat()}")
+        logger.info("airflow started")
+        self.input_value_process()
+        logger.info(context.execution_date)
+        context.execution_date = self.evaluated_wait_timestamp
+        logger.info(context.execution_date)
+        super().pre_execute(context)
+
+    def execute(self, context):
+        logging.info(context.execution_date)
+        self.process()
         self.output_value_process()
-        logger.debug(context)
-        super().post_execute(context, result)
+
+        return self.io_variable.output_value
+
diff --git a/app/routes/Mapper/VariableObjectMapper.py b/app/routes/Mapper/VariableObjectMapper.py
index d3b60fe..9f6e4c9 100644
--- a/app/routes/Mapper/VariableObjectMapper.py
+++ b/app/routes/Mapper/VariableObjectMapper.py
@@ -1,4 +1,4 @@
-from Classes.ObjectVariables.WaitObjectVariables import WaitObjectVariables
+from Classes.Validators.WaitObjectValidator import WaitObjectValidator
 from Util.JSONPathParser import JSONPathParser


@@ -79,7 +79,7 @@ def wait_object_variable_mapping(object_detail : dict) -> dict:
         "timestamp": object_detail.get('Timestamp'),  # str
         "timestamp_path": object_detail.get('TimestampPath')
     })
-    if WaitObjectVariables(obj, object_detail.get("QueryLanguage")).validate():
+    if WaitObjectValidator(obj, object_detail.get("QueryLanguage")).validate():
         return obj


diff --git a/dags/test_my_Wait_Operator.py b/dags/test_my_Wait_Operator.py
index f7fdfa5..c0c7376 100644
--- a/dags/test_my_Wait_Operator.py
+++ b/dags/test_my_Wait_Operator.py
@@ -23,14 +23,17 @@ with DAG(
     sample_json = """
         {
             "io_variable": {
-                "query_language": "JSONPath"
+                "assign": {
+                    "CheckpointCount": "{% $CheckpointCount + 1 %}"
+                },
+                "query_language": "JSONata"
             },
             "meta": {
                 "comment": "A Wait state delays the state machine from continuing for a specified time.",
                 "end": false,
                 "name": "Wait for X Seconds",
                 "next": "Execute in Parallel",
-                "query_language": "JSONPath",
+                "query_language": "JSONata",
                 "type": "Wait"
             },
             "object_variable": {

