from app.routes.Mapper.VariableObjectMapper import get_only_vaild_dict

CONDITIONS_TO_CHECK_DICT = {
    'And': 'and',
    'BooleanEquals': 'boolean_equals',
    'BooleanEqualsPath': 'boolean_equals_path',
    'IsBoolean': 'is_boolean',
    'IsNull': 'is_null',
    'IsNumeric': 'is_numeric',
    'IsPresent': 'is_present',
    'IsString': 'is_string',
    'IsTimestamp': 'is_timestamp',
    'Not': 'not',
    'NumericEquals': 'numeric_equals',
    'NumericEqualsPath': 'numeric_equals_path',
    'NumericGreaterThan': 'numeric_greater_than',
    'NumericGreaterThanPath': 'numeric_greater_than_path',
    'NumericGreaterThanEquals': 'numeric_greater_than_equals',
    'NumericGreaterThanEqualsPath': 'numeric_greater_than_equals_path',
    'NumericLessThan': 'numeric_less_than',
    'NumericLessThanPath': 'numeric_less_than_path',
    'NumericLessThanEquals': 'numeric_less_than_equals',
    'NumericLessThanEqualsPath': 'numeric_less_than_equals_path',
    'Or': 'or',
    'StringEquals': 'string_equals',
    'StringEqualsPath': 'string_equals_path',
    'StringGreaterThan': 'string_greater_than',
    'StringGreaterThanPath': 'string_greater_than_path',
    'StringGreaterThanEquals': 'string_greater_than_equals',
    'StringGreaterThanEqualsPath': 'string_greater_than_equals_path',
    'StringLessThan': 'string_less_than',
    'StringLessThanPath': 'string_less_than_path',
    'StringLessThanEquals': 'string_less_than_equals',
    'StringLessThanEqualsPath': 'string_less_than_equals_path',
    'StringMatches': 'string_matches',
    'TimestampEquals': 'timestamp_equals',
    'TimestampEqualsPath': 'timestamp_equals_path',
    'TimestampGreaterThan': 'timestamp_greater_than',
    'TimestampGreaterThanPath': 'timestamp_greater_than_path',
    'TimestampGreaterThanEquals': 'timestamp_greater_than_equals',
    'TimestampGreaterThanEqualsPath': 'timestamp_greater_than_equals_path',
    'TimestampLessThan': 'timestamp_less_than',
    'TimestampLessThanPath': 'timestamp_less_than_path',
    'TimestampLessThanEquals': 'timestamp_less_than_equals',
    'TimestampLessThanEqualsPath': 'timestamp_less_than_equals_path'
}


def choice_object_variable_mapping(object_detail : dict) -> dict:
    def choice_validate_variables_mapping(obj: dict) -> bool:
        if obj.get('Choices') is not None:
            raise ValueError("Choices에서는 choice가 있어야합니다")
        return True

    # Choice states don't support the End field. In addition, they use Next only inside their Choices field.
    obj = get_only_vaild_dict({
        "default" : object_detail.get('Default'), # 기본으로 동작될 실행
        "choices" : object_detail.get('Choices'),
    })
    if choice_validate_variables_mapping(obj):
        return obj




def choice_jsonata_parse_choices(choices : dict) -> dict:
    """
    "Choice": {
      "Type": "Choice",
      "Choices": [
        {
          "Condition": "{% $placeholder %}",
          "Output": {
            "placeholder": "{% $text.example %}"
          },
          "Assign": {
            "variableName": "{% $states.result.Payload %}"
          },
          "End": true
        },
        {
          "Condition": "{% $placeholder %}",
          "Output": {
            "placeholder": "{% $text.example %}"
          },
          "Assign": {
            "variableName": "{% $states.result.Payload %}"
          },
          "End": true
        }
      ],
      "Default": "Is Hello World Example?"
    },

    """

    def choice_jsonata_validate_choices(obj):
        if obj.get('condition') is not None:
            raise ValueError("Jsonata에서는 Conditon이 필수입니다.")
        if obj.get('end') is None and obj.get('next') is None:
            raise ValueError("Jsonata에서 End나 Next가 필수입니다.")
        return True

    condition_list = []
    for choice in choices:
        obj = get_only_vaild_dict({
            "condition" : choice.get('condition'),
            "output" : choice.get('Output'),
            "assign" : choice.get('Assign'),
            "end" : choice.get('End', None),
            "next" : choice.get('Next', None),
        })
        if choice_jsonata_validate_choices(obj):
            condition_list.append(obj)

    return condition_list






def choice_parse_jsonpath_choices(choices :dict) -> dict:


    condition_list = []
    for choice in choices:
        obj = get_only_vaild_dict(choice_condition_Jsonpath_parser(choice))
        condition_list.append(obj)

    return condition_list




def choice_parse_choices(choices: dict, query_language : str) -> dict:
    if query_language == "JSONata":
        return choice_jsonata_parse_choices(choices)
    elif query_language == "JSONPath":
        return choice_parse_jsonpath_choices(choices)
    else:
        raise ValueError("Choice에서 지원하지 않는 언어입니다")


def choice_condition_Jsonpath_parser(condition : dict) -> dict:

    def choice_jsonpath_validate_choices(obj):
        if obj.get('variable') is None:
            raise ValueError("Jsonpath에서는 variable이 필수입니다.")

        return True

    def condition_extractor(condition: dict):
        for cond_key, cond_key_mapping in CONDITIONS_TO_CHECK_DICT.items():
            if condition.get(cond_key) is not None:
                return cond_key_mapping, condition.get(cond_key)

    condition_key, found_condition = condition_extractor(condition)

    parsed = get_only_vaild_dict({
        "variable": condition.get("Variable"),
        "next": condition.get("Next", None),
        condition_key : found_condition
    })

    if condition_key == "and" or condition_key == "or":
        parsed[condition_key] = []
        for condition in found_condition: # and나 or안의 조건들은 condition_key없이 list형태가 된다
            parsed[condition_key].append(choice_condition_Jsonpath_parser(condition))

    else:
        choice_jsonpath_validate_choices(parsed)

    return parsed
