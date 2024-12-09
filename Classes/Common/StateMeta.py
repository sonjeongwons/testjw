from typing import Optional

class StateMeta():
    def __init__(self,
                 name: str,
                 type: str,
                 comment: Optional[str] = "",
                 query_language: str = "JSONPath",
                 next: Optional[str] = None,
                 end: Optional[bool] = None,
                 ):

        self.name = name
        self.query_language = query_language
        self.comment = comment
        self.type = type

        self.next = next
        # If the current state is the last state in your workflow, or a terminal state, such as Succeed workflow state or Fail workflow state, you don't need to specify the Next field.


        self.end = end
        # Designates this state as a terminal state (ends the execution) if set to true.
        # There can be any number of terminal states per state machine.
        # Only one of Next or End can be used in a state.
        # Some state types, such as Choice, or terminal states, such as Succeed workflow state and Fail workflow state, don't support or use the End field.
