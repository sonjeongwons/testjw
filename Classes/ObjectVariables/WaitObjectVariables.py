from datetime import datetime, timezone, timedelta
from typing import Optional

from Util.JSONPathParser import JSONPathParser
from Util.JSONataParser import JSONataParser


class WaitObjectVariables:
    def __init__(self,
                 obj : dict,
                 query_language : Optional[str] = "JSONPath",
                 *args,**kwargs):

        self.obj = obj
        self.validate_variables_mapping()

        self.seconds = obj.get("seconds")
        self.seconds_path = obj.get("seconds_path")
        self.timestamp = obj.get("timestamp")
        self.timestamp_path = obj.get("timestamp_path")

        self.query_language = query_language
        self.evaluated_timestamp = None


    def validate_variables_mapping(self) -> bool:
        # You must specify exactly one of Seconds, Timestamp, SecondsPath, or TimestampPath.
        if len(self.obj.items()) > 1:
            raise ValueError("Second, secondsPath, timestamp, timestampPath 중 1개만 입력 가능합니다.")

    # 값에 대한 유효성 검증을 수행한 후, 실제 wait해야하는 값에 대한 timestamp를 반환
    # Wait 값이 있을경우 Timestamp를 출력, 없을경우 현재시간의 datetime.now()를 출력함.
    def evaluate(self, input_value : dict) -> str:
        self.validate()
        self.inject(input_value)
        return self.evaluated_timestamp if self.post_validate() is True else datetime.now().isoformat()

    def inject(self, input_value : dict) -> bool:

        def _process_seconds(input_value) -> Optional[int]:
            if self.query_language == "JSONPath":
                seconds = self.seconds
            elif self.query_language == "JSONata":
                if isinstance(self.seconds, int):
                    seconds = self.seconds
                elif isinstance(self.seconds, str):
                    seconds = JSONataParser.get_value_with_jsonata_from_json_data(json_data = input_value, jsonata_str=self.seconds)
            return int(seconds)

        def _process_seconds_path(input_value) -> Optional[int]:
            try:
                seconds = JSONPathParser.get_value_with_jsonpath_from_json_data(json_data=input_value,
                                                                                json_path=self.seconds_path)
                return int(seconds)
            except:
                raise ValueError(f"유효하지 않은 secondsPath입니다. : {self.seconds_path}, {seconds}")

        def _process_timestamp() -> bool:
            try:
                self.evaluated_timestamp = datetime.fromisoformat(self.timestamp.replace('Z', '+00:00'))
                return True
            except:
                raise ValueError(f"유효하지 않은 timestamp입니다. : {self.timestamp}")

        def _process_timestamp_path(input_value) -> bool:
            try:
                timestamp = JSONPathParser.get_value_with_jsonpath_from_json_data(json_data= input_value, json_path=self.timestamp_path)
                self.evaluated_timestamp = datetime.fromisoformat(timestamp.replace('Z', '+00:00'))
                return True
            except:
                raise ValueError(f"유효하지 않은 timestampPath입니다. {self.timestamp_path}")

        # seconds, secondspath, timestamp, timestampPath를 이용해서 해당 값을 timestamp 방식으로 변환하여 `self.evauated_timestamp`로 리턴함
        if self.seconds is not None:
            int_seconds = _process_seconds(input_value)
        elif self.seconds_path is not None:
            int_seconds = _process_seconds_path(input_value)
        elif self.timestamp is not None:
            return _process_timestamp()
        elif self.timestamp_path is not None:
            return _process_timestamp_path(input_value)
        else:
            raise ValueError("Second, secondsPath, timestamp, timestampPath중 유효한 필드가 없습니다.")


        if self.seconds is not None or self.seconds_path is not None:
            try:
                now = datetime.now()
                future_time = now + timedelta(seconds=int_seconds)
                self.evaluated_timestamp = future_time.isoformat()
                return True
            except:
                raise ValueError("Invalid Seconds value")

        return False


    def validate(self) -> bool:
        #validation은 각각의 값이 제대로된 포맷인지만 확인.
        validations = [
            self.validate_seconds(),
            self.validate_seconds_path(),
            self.validate_timestamp(),
            self.validate_timestamp_path()]

        for validation in validations:
            return True if validation is True else False

    def validate_seconds(self) -> bool:
        if self.seconds == None:
            return True

        if isinstance(self.seconds, (int)):
            if not (0 <= self.seconds <= 99999999):
                raise ValueError("0에서 99999999까지의 양의 정수만 지원합니다.")

            if self.seconds > 31536000:
                raise ValueError("1년 이상의 Seconds는 지원하지 않습니다")

        elif isinstance(self.seconds, (str)):
            if self.query_language == "JSONata":
                JSONataParser.parse(jsonata_str = self.seconds)

            elif self.query_language == "JSONPath":
                raise ValueError("JSONPath 의 Wait Obejct seconds는 int여야합니다.")

        else:
            raise TypeError("지원하지 않는 Type의 Seconds입니다")

        return True


    def validate_seconds_path(self) -> bool:
        if self.seconds_path is None:
            return True

        if isinstance(self.seconds_path, (str)):
            if self.query_language == "JSONata":
                raise ValueError("JSONata는 seconds_path를 지원하지 않습니다")

            elif self.query_language == "JSONPath":
                return False if JSONPathParser.parse(self.seconds_path) is False else True

        else:
            raise TypeError("지원하지 않는 Type의 seconds_path입니다. ")

        return True



    def validate_timestamp(self):
        if self.timestamp is None:
            return True

        if isinstance(self.timestamp, (str)):
            current_time = datetime.now(timezone.utc)

            if self.query_language == "JSONata":
                # JSONATA Type의 Value인지 확인
                JSONataParser.get_value_with_jsonata_from_json_data(self.timestamp)


            elif self.query_language == "JSONPath":
                try:
                    timestamp_datetime = datetime.fromisoformat(self.timestamp.replace('Z', '+00:00'))
                    one_year_later = current_time + timedelta(days=365)
                    if not (current_time <= timestamp_datetime <= one_year_later):
                        raise ValueError(
                            "Timestamp is over a year older or in the future compared to the current time.")
                except:
                    raise ValueError("Invalid ISO format for timestamp")

        return True

    def validate_timestamp_path(self):
        if self.timestamp_path is None:
            return True

        if isinstance(self.timestamp_path, (str)):
            if self.query_language == "JSONata":
                raise ValueError("JSONata는 timestamp_path를 지원하지 않습니다")

            elif self.query_language == "JSONPath":
                return False if JSONPathParser.parse(self.timestamp_path) is False else True

        else:
            raise TypeError("지원하지 않는 Type의 timestamp_path입니다. ")

        return True

    def post_validate(self) -> bool:
        if self.evaluated_timestamp is None:
            raise ValueError("평가된 Timestamp가 없습니다")
        if type(self.evaluated_timestamp) is not str:
            raise TypeError("TimeStamp의 값이 올바르지 않습니다")
        if self._is_within_one_year(self.evaluated_timestamp) is False:
            raise ValueError("Wait은 1년 내로 실행되어야합니다.")
        return True

    def _is_within_one_year(self, iso_format_str_datetime):
        # 현재 날짜와 시간 가져오기
        now = datetime.now()

        # 주어진 ISO 포맷 날짜 문자열을 datetime 객체로 변환
        target_date = datetime.fromisoformat(iso_format_str_datetime)

        # 1년 후의 날짜 계산
        one_year_later = now + timedelta(days=365)

        # 타겟 날짜가 현재 날짜와 1년 이내인지 확인
        if now <= target_date <= one_year_later:
            return True
        else:
            return False
