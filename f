$ git diff develop...developd-cloudpark-DAGs-Templating|cat
diff --git a/.gitgnore b/.gitignore
similarity index 88%
rename from .gitgnore
rename to .gitignore
index acb801e..773f0ba 100644
--- a/.gitgnore
+++ b/.gitignore
@@ -1,3 +1,4 @@
+/app/.tmp/
 # PyCharm specific
 .idea/
 .vscode/
@@ -7,6 +8,7 @@
 __pycache__/
 *.pyo
 *.pyd
+**/__pycache__/

 # Virtual environments
 venv/
@@ -32,3 +34,6 @@ Thumbs.db
 docker-compose/logs/*
 docker-compose/plugins/*
 docker-compose/config/*
+
+app/.tmp/*
+!/.tmp/*
diff --git a/Dockerfile b/Dockerfile
index e97f09b..7e206da 100644
--- a/Dockerfile
+++ b/Dockerfile
@@ -12,7 +12,7 @@ COPY /dags /opt/airflow/dags
 COPY /Classes  /opt/airflow/plugins/Classes
 COPY /Operator /opt/airflow/plugins/Operator
 COPY /Util /opt/airflow/plugins/Util
-COPY /TestTemplate /opt/airflow/plugins/TestTemplate
+COPY /TestTemplate/ParsedJSON /opt/airflow/plugins/TestTemplate/ParsedJSON

 USER airflow
 RUN pip install --no-cache-dir "apache-airflow==${AIRFLOW_VERSION}" -r /requirements.txt
diff --git a/Operator/FailOperator.py b/Operator/FailOperator.py
index ed2c369..4367318 100644
--- a/Operator/FailOperator.py
+++ b/Operator/FailOperator.py
@@ -3,62 +3,49 @@ from typing import Optional, Any
 from airflow.exceptions import AirflowException
 from airflow.models import BaseOperator

-from Classes.Common import IOVariable, StateMeta
+from Classes.Common.JSONPathObj import JSONPathObj
+from Classes.Common.JSONataObj import JSONataObj
+from Classes.Common.StateMeta import StateMeta
 from Util.JSONPathParser import JSONPathParser

-class FailOperator(BaseOperator, AirflowException):
+class FailOperator(BaseOperator):
     def __init__(self,
                  meta: dict,
                  io_variable: dict,
                  object_variable: Optional[dict] = None,
+                 *args,
                  **kwargs
                  ):
-        super().__init__(**kwargs)
+        self.meta = StateMeta(**meta)
+
+        super().__init__(*args, **kwargs)

-        self.meta = StateMeta(meta)
         if meta.get('query_language') == "JSONata":
-            self.io_variable = IOVariable(io_variable).JSONataObj(io_variable)
+            self.io_variable = JSONataObj(**io_variable)
         elif meta.get('query_language') in ["JSONPath", None]:
-            self.io_variable = IOVariable(io_variable).JSONPathObj(io_variable)
-
-        self.error = object_variable.get('error')
-        self.error_path = object_variable.get('error_path')
-        self.cause = object_variable.get('cause')
-        self.cause_path = object_variable.get('cause_path')
+            self.io_variable = JSONPathObj(**io_variable,)

-        self.json_parser = JSONPathParser()
+        # self.error = object_variable.get('error')
+        # self.error_path = object_variable.get('error_path')
+        # self.cause = object_variable.get('cause')
+        # self.cause_path = object_variable.get('cause_path')

-    def execute(self) -> IOVariable:
-        self.pre_process()
-        self.process()
-        self.post_process()

-        return self.io_variable.output_value
+    def execute(self):
+        pass

     def pre_execute(self, context: Any):
-        self.input_value_process()
+        pass

     def execute(self, context):
-        self.process()
-        self.output_value_process()
-
-        return self.io_variable.output_value
+        pass

     def input_value_process(self):
-        if self.io_variable.input_path is not None:
-            self.io_variable.input_filter_by_input_path()
-
-        if self.io_variable.parameter is not None:
-            self.io_variable.input_by_parameter()
+        pass

     def process(self):
         pass

     def output_value_process(self):
         #에러 처리
-        if self.error_path is not None:
-            self.error = self.json_parser.get_value_with_jsonpath_from_json_data(self.io_variable.input_value, self.error_path)
-
-        #오류 원인 처리
-        if self.cause_path is not None:
-            self.error = self.json_parser.get_value_with_jsonpath_from_json_data(self.io_variable.input_value, self.cause_path)
\ No newline at end of file
+        pass
\ No newline at end of file
diff --git a/TestTemplate/ParsedJSON/Pass_with_two_type.json b/TestTemplate/ParsedJSON/Pass_with_two_type.json
index f1c67c2..1632611 100644
--- a/TestTemplate/ParsedJSON/Pass_with_two_type.json
+++ b/TestTemplate/ParsedJSON/Pass_with_two_type.json
@@ -1,35 +1,35 @@
 {
-    "query_language": "JSONPath",
-    "start_at": "JSONPath state",
-    "states": {
-        "JSONPath state": {
-            "io_variable": {
-                "parameters": {
-                    "total.$": "$.transaction.total"
-                },
-                "query_language": "JSONPath"
-            },
-            "meta": {
-                "end": false,
-                "name": "JSONPath state",
-                "next": "JSONata state",
-                "query_language": "JSONPath",
-                "type": "Pass"
-            }
+  "query_language": "JSONPath",
+  "start_at": "JSONPath_state___6b3cc434",
+  "states": {
+    "JSONPath_state___6b3cc434": {
+      "io_variable": {
+        "parameters": {
+          "total.$": "$.transaction.total"
         },
-        "JSONata state": {
-            "io_variable": {
-                "output": {
-                    "total": "{% $states.input.transaction.total %}"
-                },
-                "query_language": "JSONata"
-            },
-            "meta": {
-                "end": true,
-                "name": "JSONata state",
-                "query_language": "JSONata",
-                "type": "Pass"
-            }
-        }
+        "query_language": "JSONPath"
+      },
+      "meta": {
+        "end": false,
+        "name": "JSONPath state",
+        "next": "JSONata_state___ec67a3da",
+        "query_language": "JSONPath",
+        "type": "Pass"
+      }
+    },
+    "JSONata_state___ec67a3da": {
+      "io_variable": {
+        "output": {
+          "total": "{% $states.input.transaction.total %}"
+        },
+        "query_language": "JSONata"
+      },
+      "meta": {
+        "end": true,
+        "name": "JSONata state",
+        "query_language": "JSONata",
+        "type": "Pass"
+      }
     }
-}
\ No newline at end of file
+  }
+}
diff --git a/TestTemplate/ParsedJSON/parsed_jsonata1.json b/TestTemplate/ParsedJSON/parsed_jsonata1.json
index b3889fc..b93cc7d 100644
--- a/TestTemplate/ParsedJSON/parsed_jsonata1.json
+++ b/TestTemplate/ParsedJSON/parsed_jsonata1.json
@@ -1,170 +1,170 @@
 {
-    "comment": "A Hello World example that demonstrates various state types in the Amazon States Language, and showcases data flow and transformations using variables and JSONata expressions. This example consists solely of flow control states, so no additional resources are needed to run it.",
-    "query_language": "JSONata",
-    "start_at": "Set Variables and State Output",
-    "states": {
-        "Choice": {
-            "io_variable": {
-                "query_language": "JSONata"
+  "comment": "A Hello World example that demonstrates various state types in the Amazon States Language, and showcases data flow and transformations using variables and JSONata expressions. This example consists solely of flow control states, so no additional resources are needed to run it.",
+  "query_language": "JSONata",
+  "start_at": "Set_Variables_and_State_Output___78572ec5",
+  "states": {
+    "Choice___efa0389a": {
+      "io_variable": {
+        "query_language": "JSONata"
+      },
+      "meta": {
+        "end": false,
+        "name": "Choice",
+        "query_language": "JSONata",
+        "type": "Choice"
+      },
+      "object_variable": {
+        "choice_values": [
+          {
+            "assign": {
+              "variableName": "{% $states.result.Payload %}"
             },
-            "meta": {
-                "end": false,
-                "name": "Choice",
-                "query_language": "JSONata",
-                "type": "Choice"
-            },
-            "object_variable": {
-                "choice_values": [
-                    {
-                        "assign": {
-                            "variableName": "{% $states.result.Payload %}"
-                        },
-                        "next": "Wait",
-                        "output": {
-                            "placeholder": "{% $text.example %}"
-                        }
-                    },
-                    {
-                        "assign": {
-                            "variableName": "{% $states.result.Payload %}"
-                        },
-                        "end": true,
-                        "output": {
-                            "placeholder": "{% $text.example %}"
-                        }
-                    }
-                ]
-            }
-        },
-        "Execute in Parallel": {
-            "io_variable": {
-                "query_language": "JSONata"
-            },
-            "meta": {
-                "comment": "A Parallel state can be used to create parallel branches of execution in your state machine.",
-                "end": false,
-                "name": "Execute in Parallel",
-                "next": "Set Checkpoint",
-                "query_language": "JSONata",
-                "type": "Parallel"
+            "next": "Wait",
+            "output": {
+              "placeholder": "{% $text.example %}"
             }
-        },
-        "Fail the Execution": {
-            "io_variable": {
-                "query_language": "JSONata"
-            },
-            "meta": {
-                "comment": "A Fail state stops the execution of the state machine and marks it as a failure, unless it is caught by a Catch block.",
-                "end": false,
-                "name": "Fail the Execution",
-                "query_language": "JSONata",
-                "type": "Fail"
+          },
+          {
+            "assign": {
+              "variableName": "{% $states.result.Payload %}"
             },
-            "object_variable": {
-                "error": "Not a Hello World Example"
+            "end": true,
+            "output": {
+              "placeholder": "{% $text.example %}"
             }
+          }
+        ]
+      }
+    },
+    "Execute_in_Parallel___3ae7b3b8": {
+      "io_variable": {
+        "query_language": "JSONata"
+      },
+      "meta": {
+        "comment": "A Parallel state can be used to create parallel branches of execution in your state machine.",
+        "end": false,
+        "name": "Execute in Parallel",
+        "next": "Set_Checkpoint___ab434f03",
+        "query_language": "JSONata",
+        "type": "Parallel"
+      }
+    },
+    "Fail_the_Execution___70b6dc4b": {
+      "io_variable": {
+        "query_language": "JSONata"
+      },
+      "meta": {
+        "comment": "A Fail state stops the execution of the state machine and marks it as a failure, unless it is caught by a Catch block.",
+        "end": false,
+        "name": "Fail the Execution",
+        "query_language": "JSONata",
+        "type": "Fail"
+      },
+      "object_variable": {
+        "error": "Not a Hello World Example"
+      }
+    },
+    "Is_Hello_World_Example?___66abc898": {
+      "io_variable": {
+        "query_language": "JSONata"
+      },
+      "meta": {
+        "comment": "A Choice state adds branching logic to a state machine. Choice rules use the Condition property to evaluate expressions with custom JSONata logic, allowing for flexible branching.",
+        "end": false,
+        "name": "Is Hello World Example?",
+        "query_language": "JSONata",
+        "type": "Choice"
+      },
+      "object_variable": {
+        "choice_values": [
+          {
+            "next": "Wait for X Seconds"
+          }
+        ]
+      }
+    },
+    "Set_Checkpoint___ab434f03": {
+      "io_variable": {
+        "assign": {
+          "CheckpointCount": "{% $CheckpointCount + 1 %}"
         },
-        "Is Hello World Example?": {
-            "io_variable": {
-                "query_language": "JSONata"
-            },
-            "meta": {
-                "comment": "A Choice state adds branching logic to a state machine. Choice rules use the Condition property to evaluate expressions with custom JSONata logic, allowing for flexible branching.",
-                "end": false,
-                "name": "Is Hello World Example?",
-                "query_language": "JSONata",
-                "type": "Choice"
-            },
-            "object_variable": {
-                "choice_values": [
-                    {
-                        "next": "Wait for X Seconds"
-                    }
-                ]
-            }
-        },
-        "Set Checkpoint": {
-            "io_variable": {
-                "assign": {
-                    "CheckpointCount": "{% $CheckpointCount + 1 %}"
-                },
-                "query_language": "JSONata"
-            },
-            "meta": {
-                "end": false,
-                "name": "Set Checkpoint",
-                "next": "Summarize the Execution",
-                "query_language": "JSONata",
-                "type": "Pass"
-            }
+        "query_language": "JSONata"
+      },
+      "meta": {
+        "end": false,
+        "name": "Set Checkpoint",
+        "next": "Summarize_the_Execution\ud83d\ude12___35b34b13",
+        "query_language": "JSONata",
+        "type": "Pass"
+      }
+    },
+    "Set_Variables_and_State_Output___78572ec5": {
+      "io_variable": {
+        "assign": {
+          "CheckpointCount": 0
         },
-        "Set Variables and State Output": {
-            "io_variable": {
-                "assign": {
-                    "CheckpointCount": 0
-                },
-                "output": {
-                    "ExecutionWaitTimeInSeconds": 3,
-                    "IsHelloWorldExample": true
-                },
-                "query_language": "JSONata"
-            },
-            "meta": {
-                "comment": "A Pass state passes its input to its output, without performing work. They can also generate static JSON output, or transform JSON input using JSONata expressions, and pass the transformed data to the next state. Pass states are useful when constructing and debugging state machines.",
-                "end": false,
-                "name": "Set Variables and State Output",
-                "next": "Choice",
-                "query_language": "JSONata",
-                "type": "Pass"
-            }
+        "output": {
+          "ExecutionWaitTimeInSeconds": 3,
+          "IsHelloWorldExample": true
         },
-        "Summarize the Execution": {
-            "io_variable": {
-                "output": {
-                    "Summary": "{% 'This Hello World execution began on ' & $states.input.FormattedExecutionStartDate & '. The state machine ran for ' & $states.input.ElapsedTimeToSnapshot & ' seconds before the snapshot was taken, passing through ' & $CheckpointCount & ' checkpoints, and has successfully completed.' %}"
-                },
-                "query_language": "JSONata"
-            },
-            "meta": {
-                "comment": "A Succeed state indicates successful completion of the state machine.",
-                "end": false,
-                "name": "Summarize the Execution",
-                "query_language": "JSONata",
-                "type": "Succeed"
-            }
+        "query_language": "JSONata"
+      },
+      "meta": {
+        "comment": "A Pass state passes its input to its output, without performing work. They can also generate static JSON output, or transform JSON input using JSONata expressions, and pass the transformed data to the next state. Pass states are useful when constructing and debugging state machines.",
+        "end": false,
+        "name": "Set Variables and State Output",
+        "next": "Choice___efa0389a",
+        "query_language": "JSONata",
+        "type": "Pass"
+      }
+    },
+    "Summarize_the_Execution\ud83d\ude12___35b34b13": {
+      "io_variable": {
+        "output": {
+          "Summary": "{% 'This Hello World execution began on ' & $states.input.FormattedExecutionStartDate & '. The state machine ran for ' & $states.input.ElapsedTimeToSnapshot & ' seconds before the snapshot was taken, passing through ' & $CheckpointCount & ' checkpoints, and has successfully completed.' %}"
         },
-        "Wait": {
-            "io_variable": {
-                "query_language": "JSONata"
-            },
-            "meta": {
-                "end": true,
-                "name": "Wait",
-                "query_language": "JSONata",
-                "type": "Wait"
-            },
-            "object_variable": {
-                "seconds": 5
-            }
+        "query_language": "JSONata"
+      },
+      "meta": {
+        "comment": "A Succeed state indicates successful completion of the state machine.",
+        "end": false,
+        "name": "Summarize the Execution\ud83d\ude12",
+        "query_language": "JSONata",
+        "type": "Succeed"
+      }
+    },
+    "Wait___26b83994": {
+      "io_variable": {
+        "query_language": "JSONata"
+      },
+      "meta": {
+        "end": true,
+        "name": "Wait",
+        "query_language": "JSONata",
+        "type": "Wait"
+      },
+      "object_variable": {
+        "seconds": 5
+      }
+    },
+    "Wait_for_X_Seconds___555a0ac7": {
+      "io_variable": {
+        "assign": {
+          "CheckpointCount": "{% $CheckpointCount + 1 %}"
         },
-        "Wait for X Seconds": {
-            "io_variable": {
-                "assign": {
-                    "CheckpointCount": "{% $CheckpointCount + 1 %}"
-                },
-                "query_language": "JSONata"
-            },
-            "meta": {
-                "comment": "A Wait state delays the state machine from continuing for a specified time.",
-                "end": false,
-                "name": "Wait for X Seconds",
-                "next": "Execute in Parallel",
-                "query_language": "JSONata",
-                "type": "Wait"
-            },
-            "object_variable": {
-                "seconds": "{% $states.input.ExecutionWaitTimeInSeconds %}"
-            }
-        }
+        "query_language": "JSONata"
+      },
+      "meta": {
+        "comment": "A Wait state delays the state machine from continuing for a specified time.",
+        "end": false,
+        "name": "Wait for X Seconds",
+        "next": "Execute_in_Parallel___3ae7b3b8",
+        "query_language": "JSONata",
+        "type": "Wait"
+      },
+      "object_variable": {
+        "seconds": "{% $states.input.ExecutionWaitTimeInSeconds %}"
+      }
     }
-}
\ No newline at end of file
+  }
+}
diff --git a/TestTemplate/ParsedJSON/parsed_jsonpath1.json b/TestTemplate/ParsedJSON/parsed_jsonpath1.json
index 59c278f..ba3ed32 100644
--- a/TestTemplate/ParsedJSON/parsed_jsonpath1.json
+++ b/TestTemplate/ParsedJSON/parsed_jsonpath1.json
@@ -1,128 +1,128 @@
 {
-    "comment": "A Hello World example demonstrating various state types of the Amazon States Language. It is composed of flow control states only, so it does not need resources to run.",
-    "query_language": "JSONPath",
-    "start_at": "Pass",
-    "states": {
-        "Hello World": {
-            "io_variable": {
-                "query_language": "JSONPath"
-            },
-            "meta": {
-                "end": true,
-                "name": "Hello World",
-                "query_language": "JSONPath",
-                "type": "Pass"
-            }
-        },
-        "Hello World example?": {
-            "io_variable": {
-                "query_language": "JSONPath"
-            },
-            "meta": {
-                "comment": "A Choice state adds branching logic to a state machine. Choice rules can implement many different comparison operators, and rules can be combined using And, Or, and Not",
-                "end": false,
-                "name": "Hello World example?",
-                "query_language": "JSONPath",
-                "type": "Choice"
-            },
-            "object_variable": {
-                "choice_values": [
-                    {
-                        "is_string": true,
-                        "next": "Yes",
-                        "variable": "$.IsHelloWorldExample"
-                    },
-                    {
-                        "and": [
-                            {
-                                "boolean_equals": false,
-                                "variable": "$.IsHelloWorldExampleinsideAnd1"
-                            },
-                            {
-                                "is_numeric": true,
-                                "variable": "$.IsHelloWorldExampleinsideAnd2"
-                            }
-                        ],
-                        "next": "No"
-                    },
-                    {
-                        "boolean_equals": false,
-                        "next": "No",
-                        "variable": "$.IsHelloWorldExample22"
-                    }
-                ]
-            }
-        },
-        "No": {
-            "io_variable": {
-                "query_language": "JSONPath"
-            },
-            "meta": {
-                "end": false,
-                "name": "No",
-                "query_language": "JSONPath",
-                "type": "Fail"
-            },
-            "object_variable": {
-                "cause": "Not Hello World"
-            }
-        },
-        "Parallel State": {
-            "io_variable": {
-                "query_language": "JSONPath"
-            },
-            "meta": {
-                "comment": "A Parallel state can be used to create parallel branches of execution in your state machine.",
-                "end": false,
-                "name": "Parallel State",
-                "next": "Hello World",
-                "query_language": "JSONPath",
-                "type": "Parallel"
-            }
-        },
-        "Pass": {
-            "io_variable": {
-                "query_language": "JSONata",
-                "result": {
-                    "IsHelloWorldExample": true
-                }
-            },
-            "meta": {
-                "comment": "A Pass state passes its input to its output, without performing work. They can also generate static JSON output, or transform JSON input using filters and pass the transformed data to the next state. Pass states are useful when constructing and debugging state machines.",
-                "end": false,
-                "name": "Pass",
-                "next": "Hello World example?",
-                "query_language": "JSONata",
-                "type": "Pass"
-            }
-        },
-        "Wait 3 sec": {
-            "io_variable": {
-                "query_language": "JSONPath"
-            },
-            "meta": {
-                "comment": "A Wait state delays the state machine from continuing for a specified time.",
-                "end": false,
-                "name": "Wait 3 sec",
-                "next": "Parallel State",
-                "query_language": "JSONPath",
-                "type": "Wait"
-            },
-            "object_variable": {
-                "seconds_path": "$.Hello"
-            }
-        },
-        "Yes": {
-            "io_variable": {
-                "query_language": "JSONPath"
-            },
-            "meta": {
-                "end": false,
-                "name": "Yes",
-                "next": "Wait 3 sec",
-                "query_language": "JSONPath",
-                "type": "Pass"
-            }
+  "comment": "A Hello World example demonstrating various state types of the Amazon States Language. It is composed of flow control states only, so it does not need resources to run.",
+  "query_language": "JSONPath",
+  "start_at": "Pass___ebdf8cc0",
+  "states": {
+    "Hello_World___a591a6d4": {
+      "io_variable": {
+        "query_language": "JSONPath"
+      },
+      "meta": {
+        "end": true,
+        "name": "Hello World",
+        "query_language": "JSONPath",
+        "type": "Pass"
+      }
+    },
+    "Hello_World_example?___71e1a85a": {
+      "io_variable": {
+        "query_language": "JSONPath"
+      },
+      "meta": {
+        "comment": "A Choice state adds branching logic to a state machine. Choice rules can implement many different comparison operators, and rules can be combined using And, Or, and Not",
+        "end": false,
+        "name": "Hello World example?",
+        "query_language": "JSONPath",
+        "type": "Choice"
+      },
+      "object_variable": {
+        "choice_values": [
+          {
+            "is_string": true,
+            "next": "Yes",
+            "variable": "$.IsHelloWorldExample"
+          },
+          {
+            "and": [
+              {
+                "boolean_equals": false,
+                "variable": "$.IsHelloWorldExampleinsideAnd1"
+              },
+              {
+                "is_numeric": true,
+                "variable": "$.IsHelloWorldExampleinsideAnd2"
+              }
+            ],
+            "next": "No"
+          },
+          {
+            "boolean_equals": false,
+            "next": "No",
+            "variable": "$.IsHelloWorldExample22"
+          }
+        ]
+      }
+    },
+    "No___1ea442a1": {
+      "io_variable": {
+        "query_language": "JSONPath"
+      },
+      "meta": {
+        "end": false,
+        "name": "No",
+        "query_language": "JSONPath",
+        "type": "Fail"
+      },
+      "object_variable": {
+        "cause": "Not Hello World"
+      }
+    },
+    "Parallel_State___f3bca4bd": {
+      "io_variable": {
+        "query_language": "JSONPath"
+      },
+      "meta": {
+        "comment": "A Parallel state can be used to create parallel branches of execution in your state machine.",
+        "end": false,
+        "name": "Parallel State",
+        "next": "Hello_World___a591a6d4",
+        "query_language": "JSONPath",
+        "type": "Parallel"
+      }
+    },
+    "Pass___ebdf8cc0": {
+      "io_variable": {
+        "query_language": "JSONata",
+        "result": {
+          "IsHelloWorldExample": true
         }
+      },
+      "meta": {
+        "comment": "A Pass state passes its input to its output, without performing work. They can also generate static JSON output, or transform JSON input using filters and pass the transformed data to the next state. Pass states are useful when constructing and debugging state machines.",
+        "end": false,
+        "name": "Pass",
+        "next": "Hello_World_example?___71e1a85a",
+        "query_language": "JSONata",
+        "type": "Pass"
+      }
+    },
+    "Wait_3_sec___bd8ecbd8": {
+      "io_variable": {
+        "query_language": "JSONPath"
+      },
+      "meta": {
+        "comment": "A Wait state delays the state machine from continuing for a specified time.",
+        "end": false,
+        "name": "Wait 3 sec",
+        "next": "Parallel_State___f3bca4bd",
+        "query_language": "JSONPath",
+        "type": "Wait"
+      },
+      "object_variable": {
+        "seconds_path": "$.Hello"
+      }
+    },
+    "Yes___85a39ab3": {
+      "io_variable": {
+        "query_language": "JSONPath"
+      },
+      "meta": {
+        "end": false,
+        "name": "Yes",
+        "next": "Wait_3_sec___bd8ecbd8",
+        "query_language": "JSONPath",
+        "type": "Pass"
+      }
     }
-}
\ No newline at end of file
+  }
+}
diff --git a/TestTemplate/RawJSONTemplate/Jsonata1.json b/TestTemplate/RawJSONTemplate/Jsonata1.json
index 9c867ac..ab367ab 100644
--- a/TestTemplate/RawJSONTemplate/Jsonata1.json
+++ b/TestTemplate/RawJSONTemplate/Jsonata1.json
@@ -116,12 +116,12 @@
     },
     "Set Checkpoint": {
       "Type": "Pass",
-      "Next": "Summarize the Execution",
+      "Next": "Summarize the Execution😒",
       "Assign": {
         "CheckpointCount": "{% $CheckpointCount + 1 %}"
       }
     },
-    "Summarize the Execution": {
+    "Summarize the Execution😒": {
       "Type": "Succeed",
       "Comment": "A Succeed state indicates successful completion of the state machine.",
       "Output": {
diff --git a/Util/FileManager.py b/Util/FileManager.py
new file mode 100644
index 0000000..d51c8b6
--- /dev/null
+++ b/Util/FileManager.py
@@ -0,0 +1,51 @@
+import json
+import os
+
+def _get_abs_path(file_path):
+    # 현재 실행 파일의 디렉토리 얻기
+    base_dir = os.path.dirname(os.path.abspath(__file__))
+
+    # 절대 경로로 변환 및 정규화
+    absolute_path = os.path.normpath(os.path.join(base_dir, file_path))
+    return absolute_path
+
+def export_file(file_path, content):
+    absolute_path = _get_abs_path(file_path)
+    try:
+        if isinstance(content, dict):
+            # 딕셔너리를 JSON 형식으로 변환하여 예쁘게 들여쓰기
+            content_str = json.dumps(content, indent=4, ensure_ascii=False)
+        else:
+            content_str = str(content)
+
+        with open(absolute_path, 'w', encoding='utf-8') as file:
+            file.write(content)
+        print(f"데이터가 {absolute_path}에 성공적으로 기록되었습니다.")
+    except Exception as e:
+        print(f"파일을 쓰는 동안 오류가 발생했습니다: {e}")
+
+
+def export_file(file_path, content):
+    absolute_path = _get_abs_path(file_path)
+    try:
+        if isinstance(content, dict):
+            # 딕셔너리를 JSON 형식으로 변환하여 예쁘게 들여쓰기
+            content_str = json.dumps(content, indent=4, ensure_ascii=False)
+        else:
+            content_str = str(content)
+
+        with open(absolute_path, 'w', encoding='utf-8') as file:
+            file.write(content_str)
+        print(f"데이터가 {absolute_path}에 성공적으로 기록되었습니다.")
+    except Exception as e:
+        print(f"파일을 쓰는 동안 오류가 발생했습니다: {e}")
+
+
+def load_json_template(template_path):
+    with open(_get_abs_path(template_path), 'r', encoding='utf-8') as file:
+        return json.load(file)
+
+
+def save_to_py_file(data, output_path):
+    with open(_get_abs_path(output_path), 'w', encoding='utf-8') as file:
+        file.write(str(data))
diff --git a/Util/FlaskUtil/MethodManager.py b/Util/FlaskUtil/MethodManager.py
new file mode 100644
index 0000000..e5e51cd
--- /dev/null
+++ b/Util/FlaskUtil/MethodManager.py
@@ -0,0 +1,15 @@
+import importlib
+import_blocks_module = importlib.import_module('app.routes.CodeBlocks.import_blocks')
+operator_blocks_module = importlib.import_module('app.routes.CodeBlocks.operator_blocks')
+
+def get_method_by_type(state_type, method_type):
+    if method_type == "import":
+        module = import_blocks_module
+    elif method_type == "operator":
+        module = operator_blocks_module
+
+    method_name = f"{state_type}_{method_type}_block"
+    if hasattr(module, method_name):
+        return getattr(module, method_name)
+    else:
+        raise NotImplementedError(f"No such method: {method_name}")
diff --git a/Util/FlaskUtil/TestCaseGenerator.py b/Util/FlaskUtil/TestCaseGenerator.py
new file mode 100644
index 0000000..37baf74
--- /dev/null
+++ b/Util/FlaskUtil/TestCaseGenerator.py
@@ -0,0 +1,33 @@
+from ..FileManager import load_json_template, _get_abs_path, export_file
+from app.routes.state_routes import parse_and_generate, parse_json_impl, dags_generate_impl
+import os
+
+
+def generate_parse():
+    folder_path = r'../TestTemplate/RawJSONTemplate'
+    target_parsed_path = r'../TestTemplate/ParsedJSON'
+    target_py_path = r'../TestTemplate/GeneratatedDAG'
+
+    folder_path = _get_abs_path(folder_path)
+    target_parsed_path = _get_abs_path(target_parsed_path)
+    target_py_path = _get_abs_path(target_py_path)
+    template_paths = [os.path.join(folder_path, f) for f in os.listdir(folder_path) if f.endswith('.json')]
+
+    for template_path in template_paths:
+        output_json_filepath = target_parsed_path + "\\" + os.path.splitext(os.path.basename(template_path))[0] + '.json'
+        output_py_filepath = target_py_path + "\\" + os.path.splitext(os.path.basename(template_path))[0] + '.py'
+
+        template_data = load_json_template(template_path)
+
+        output_json = parse_json_impl(data=template_data)
+        export_file(output_json_filepath, output_json)
+
+        output_py = dags_generate_impl(data=output_json)
+        export_file(output_py_filepath, output_py)
+
+    return 200
+
+
+
+
+
diff --git a/Util/NameBuilder.py b/Util/NameBuilder.py
new file mode 100644
index 0000000..67f9ef5
--- /dev/null
+++ b/Util/NameBuilder.py
@@ -0,0 +1,23 @@
+import hashlib
+import re
+
+def get_partial_sha256_hash(input_string, length=8):
+    sha256_hash = hashlib.sha256(input_string.encode()).hexdigest()
+    return sha256_hash[:length]
+
+def get_hashed_snake_case(camel_str):
+    if camel_str is None or len(camel_str) == 0:
+        raise ValueError("camel_str cannot be None")
+    # Hash값 구함 (치환하기전에 해야함.)
+    hash_8digit = get_partial_sha256_hash(camel_str)
+
+
+    # 공백을 _ 로 치환
+    camel_str = camel_str.replace(" ", "_")
+
+    # Step 2: 파이썬 변수규칙에 맞지 않는 문자는 0으로 치환'
+    camel_str = re.sub(r'[^a-zA-Z0-9_]', '0', camel_str)
+
+
+    return "_" + hash_8digit + "___" + camel_str
+
diff --git a/app/Templates/DAG_STATES/DAG_STATES.j2 b/app/Templates/DAG_STATES/DAG_STATES.j2
new file mode 100644
index 0000000..a31f1cb
--- /dev/null
+++ b/app/Templates/DAG_STATES/DAG_STATES.j2
@@ -0,0 +1,8 @@
+with (DAG(
+        dag_id="{{ uuid }}",
+        schedule=datetime.timedelta(hours=4),
+        start_date=datetime.datetime(2021, 1, 1),
+        catchup=False,
+        tags=["cloud.park", "Generated", "CustomOperator"],
+) as dag):
+
diff --git a/app/Templates/Dags/dags_template.j2 b/app/Templates/Dags/dags_template.j2
new file mode 100644
index 0000000..984c56f
--- /dev/null
+++ b/app/Templates/Dags/dags_template.j2
@@ -0,0 +1,43 @@
+{#data = {'imports': [], 'dags_info': [], 'states': [], 'work_orders' : []}#}
+{%- for import_setence in data.imports %}
+{{ import_setence }}
+{%- endfor %}
+
+
+{%- for dag_info in data.dags_info %}
+{{ dag_info }}
+{%- endfor %}
+
+
+    file_path = r'TestTemplate/ParsedJSON/Pass_with_two_type.json'
+    with open(f"/opt/airflow/plugins/{file_path}", 'r') as json_file:
+        input_json = json.load(json_file)
+
+    sample_state_variable = input_json["states"]["_6b3cc434___JSONPath_state"]
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
+    task1 = PythonOperator(
+        task_id="task1",
+        python_callable=lambda: print(datetime.datetime.now())
+    )
+
+    sample_state_variable["io_variable"]['input_value'] = global_io_variable["input_value"]
+
+{% for state in data.states %}
+    {{ state | indent(4) }}
+{% endfor %}
+
+{% for order in data.work_orders %}
+    {{ order | indent(4) }}
+{% endfor %}
+
+
+
diff --git a/app/Templates/Imports/basic_import_sentences.j2 b/app/Templates/Imports/basic_import_sentences.j2
new file mode 100644
index 0000000..4a4c27b
--- /dev/null
+++ b/app/Templates/Imports/basic_import_sentences.j2
@@ -0,0 +1,6 @@
+import datetime, json, logging
+logger = logging.getLogger('airflow.task')
+
+from airflow.models.dag import DAG
+from airflow.operators.python import PythonOperator
+
diff --git a/app/Templates/OPERATORS/CHOICE_OPERATOR.j2 b/app/Templates/OPERATORS/CHOICE_OPERATOR.j2
new file mode 100644
index 0000000..37a636d
--- /dev/null
+++ b/app/Templates/OPERATORS/CHOICE_OPERATOR.j2
@@ -0,0 +1,7 @@
+"""
+{{ name }} = ChoiceOperator(
+    task_id="{{ name }}",
+    meta=sample_state_variable["meta"],
+    io_variable=global_io_variable,
+)
+"""
\ No newline at end of file
diff --git a/app/Templates/OPERATORS/FAIL_OPERATOR.j2 b/app/Templates/OPERATORS/FAIL_OPERATOR.j2
new file mode 100644
index 0000000..b085c0f
--- /dev/null
+++ b/app/Templates/OPERATORS/FAIL_OPERATOR.j2
@@ -0,0 +1,7 @@
+"""
+{{ name }} = FailOperator(
+    task_id="{{ name }}",
+    meta=sample_state_variable["meta"],
+    io_variable=global_io_variable,
+)
+"""
\ No newline at end of file
diff --git a/app/Templates/OPERATORS/MAP_OPERATOR.j2 b/app/Templates/OPERATORS/MAP_OPERATOR.j2
new file mode 100644
index 0000000..e9f5226
--- /dev/null
+++ b/app/Templates/OPERATORS/MAP_OPERATOR.j2
@@ -0,0 +1,7 @@
+"""
+{{ name }} = MapOperator(
+    task_id="{{ name }}",
+    meta=sample_state_variable["meta"],
+    io_variable=global_io_variable,
+)
+"""
\ No newline at end of file
diff --git a/app/Templates/OPERATORS/PARALLEL_OPERATOR.j2 b/app/Templates/OPERATORS/PARALLEL_OPERATOR.j2
new file mode 100644
index 0000000..10dbef3
--- /dev/null
+++ b/app/Templates/OPERATORS/PARALLEL_OPERATOR.j2
@@ -0,0 +1,7 @@
+"""
+{{ name }} = ParallelOperator(
+    task_id="{{ name }}",
+    meta=sample_state_variable["meta"],
+    io_variable=global_io_variable,
+)
+"""
\ No newline at end of file
diff --git a/app/Templates/OPERATORS/PASS_OPERATOR.j2 b/app/Templates/OPERATORS/PASS_OPERATOR.j2
new file mode 100644
index 0000000..1a97e93
--- /dev/null
+++ b/app/Templates/OPERATORS/PASS_OPERATOR.j2
@@ -0,0 +1,5 @@
+{{ name }} = PassOperator(
+    task_id="{{ name }}",
+    meta=sample_state_variable["meta"],
+    io_variable=global_io_variable,
+)
\ No newline at end of file
diff --git a/app/Templates/OPERATORS/SUCCEED_OPERATOR.j2 b/app/Templates/OPERATORS/SUCCEED_OPERATOR.j2
new file mode 100644
index 0000000..5eb8005
--- /dev/null
+++ b/app/Templates/OPERATORS/SUCCEED_OPERATOR.j2
@@ -0,0 +1,5 @@
+{{ name }} = SucceedOperator(
+    task_id="{{ name }}",
+    meta=sample_state_variable["meta"],
+    io_variable=global_io_variable,
+)
\ No newline at end of file
diff --git a/app/Templates/OPERATORS/WAIT_OPERATOR.j2 b/app/Templates/OPERATORS/WAIT_OPERATOR.j2
new file mode 100644
index 0000000..6e3079e
--- /dev/null
+++ b/app/Templates/OPERATORS/WAIT_OPERATOR.j2
@@ -0,0 +1,6 @@
+{{ name }} = WaitOperator(
+    task_id="{{ name }}",
+    meta=sample_state_variable["meta"],
+    io_variable=global_io_variable,
+)
+
diff --git a/app/Template/__init__.py b/app/Templates/__init__.py
similarity index 100%
rename from app/Template/__init__.py
rename to app/Templates/__init__.py
diff --git a/app/routes/CodeBlocks/__init__.py b/app/routes/CodeBlocks/__init__.py
new file mode 100644
index 0000000..e69de29
diff --git a/app/routes/CodeBlocks/dags_blocks.py b/app/routes/CodeBlocks/dags_blocks.py
new file mode 100644
index 0000000..3b75c9a
--- /dev/null
+++ b/app/routes/CodeBlocks/dags_blocks.py
@@ -0,0 +1,63 @@
+from jinja2 import Environment, FileSystemLoader
+jinjaenv = Environment(loader=FileSystemLoader('./app/Templates'))
+
+def dags_states_command(workflow_info, *args, **kwargs):
+    # # DAG 템플릿 정의
+    # template = """
+    # with (DAG(
+    #     dag_id="{{ workflow_info.dag_id | default('my_default_dag') }}",
+    #     schedule=datetime.timedelta(hours={{ workflow_info.schedule_hours }}),
+    #     start_date=datetime.datetime( {{ workflow_info.start_date}} ),
+    #     catchup=False,
+    #     description={{ workflow_info.comment }},
+    #     tags=[ {{ workflow_info.tags }} ]
+    #     concurrency = {{ workflow_info.concurrency }}
+    # ) as dag):
+    # """
+    import uuid
+    task_uuid = str(uuid.uuid4())
+    template = jinjaenv.get_template('/DAG_STATES/DAG_STATES.j2')
+
+    # 템플릿 렌더링
+    return template.render(workflow_info, uuid=task_uuid)
+
+    # def __init__(
+    #     self,
+    #     dag_id: str,
+    #     description: str | None = None,
+    #     schedule: ScheduleArg = NOTSET,
+    #     schedule_interval: ScheduleIntervalArg = NOTSET,
+    #     timetable: Timetable | None = None,
+    #     start_date: datetime | None = None,
+    #     end_date: datetime | None = None,
+    #     full_filepath: str | None = None,
+    #     template_searchpath: str | Iterable[str] | None = None,
+    #     template_undefined: type[jinja2.StrictUndefined] = jinja2.StrictUndefined,
+    #     user_defined_macros: dict | None = None,
+    #     user_defined_filters: dict | None = None,
+    #     default_args: dict | None = None,
+    #     concurrency: int | None = None,
+    #     max_active_tasks: int = airflow_conf.getint("core", "max_active_tasks_per_dag"),
+    #     max_active_runs: int = airflow_conf.getint("core", "max_active_runs_per_dag"),
+    #     max_consecutive_failed_dag_runs: int = airflow_conf.getint(
+    #         "core", "max_consecutive_failed_dag_runs_per_dag"
+    #     ),
+    #     dagrun_timeout: timedelta | None = None,
+    #     sla_miss_callback: None | SLAMissCallback | list[SLAMissCallback] = None,
+    #     default_view: str = airflow_conf.get_mandatory_value("webserver", "dag_default_view").lower(),
+    #     orientation: str = airflow_conf.get_mandatory_value("webserver", "dag_orientation"),
+    #     catchup: bool = airflow_conf.getboolean("scheduler", "catchup_by_default"),
+    #     on_success_callback: None | DagStateChangeCallback | list[DagStateChangeCallback] = None,
+    #     on_failure_callback: None | DagStateChangeCallback | list[DagStateChangeCallback] = None,
+    #     doc_md: str | None = None,
+    #     params: abc.MutableMapping | None = None,
+    #     access_control: dict[str, dict[str, Collection[str]]] | dict[str, Collection[str]] | None = None,
+    #     is_paused_upon_creation: bool | None = None,
+    #     jinja_environment_kwargs: dict | None = None,
+    #     render_template_as_native_obj: bool = False,
+    #     tags: list[str] | None = None,
+    #     owner_links: dict[str, str] | None = None,
+    #     auto_register: bool = True,
+    #     fail_stop: bool = False,
+    #     dag_display_name: str | None = None,
+    # ):
\ No newline at end of file
diff --git a/app/routes/CodeBlocks/import_blocks.py b/app/routes/CodeBlocks/import_blocks.py
new file mode 100644
index 0000000..97bdafc
--- /dev/null
+++ b/app/routes/CodeBlocks/import_blocks.py
@@ -0,0 +1,40 @@
+from Operator.SucceedOperator import SucceedOperator
+from jinja2 import Environment, FileSystemLoader
+jinjaenv = Environment(loader=FileSystemLoader('./app/Templates'))
+
+SUCCEED_OPERATOR_IMPORT = "from Operator.SucceedOperator import SucceedOperator"
+PASS_OPERATOR_IMPORT = "from Operator.PassOperator import PassOperator"
+WAIT_OPERATOR_IMPORT = "from Operator.WaitOperator import WaitOperator"
+FAIL_OPERATOR_IMPORT = "from Operator.FailOperator import FailOperator"
+CHOICE_OPERATOR_IMPORT = "from Operator.ChoiceOperator import ChoiceOperator"
+PARALLEL_OPERATOR_IMPORT = "from Operator.ParallelOperator import ParallelOperator"
+MAP_OPERATOR_IMPORT = "from Operator.MapOperator import MapOperator"
+
+
+def basic_import_block(*args, **kwargs):
+    template = jinjaenv.get_template('/Imports/basic_import_sentences.j2')
+    return template.render()
+
+def succeed_import_block(*args, **kwargs):
+    return SUCCEED_OPERATOR_IMPORT
+
+def pass_import_block(*args, **kwargs):
+    return PASS_OPERATOR_IMPORT
+
+def wait_import_block(*args, **kwargs):
+    return WAIT_OPERATOR_IMPORT
+
+def fail_import_block(*args, **kwargs):
+    return FAIL_OPERATOR_IMPORT
+
+def choice_import_block(*args, **kwargs):
+    return "# Choice_WILL_IMPORT"
+    # return CHOICE_OPERATOR_IMPORT
+
+def parallel_import_block(*args, **kwargs):
+    return "# Parallel_WILL_IMPORT"
+    # return PARALLEL_OPERATOR_IMPORT
+
+def map_import_block(*args, **kwargs):
+    return "# MAP_WILL_IMPORT"
+    # return MAP_OPERATOR_IMPORT
diff --git a/app/routes/CodeBlocks/operator_blocks.py b/app/routes/CodeBlocks/operator_blocks.py
new file mode 100644
index 0000000..1d2bdb1
--- /dev/null
+++ b/app/routes/CodeBlocks/operator_blocks.py
@@ -0,0 +1,31 @@
+from jinja2 import Environment, FileSystemLoader
+jinjaenv = Environment(loader=FileSystemLoader('./app/Templates'))
+
+
+def succeed_operator_block(state_name, state_details, *args, **kwargs):
+    template = jinjaenv.get_template('/OPERATORS/SUCCEED_OPERATOR.j2')
+    return template.render(name=state_name, data=state_details)
+
+def pass_operator_block(state_name, state_details, *args, **kwargs):
+    template = jinjaenv.get_template('/OPERATORS/PASS_OPERATOR.j2')
+    return template.render(name=state_name, data=state_details)
+
+def wait_operator_block(state_name, state_details, *args, **kwargs):
+    template = jinjaenv.get_template('/OPERATORS/WAIT_OPERATOR.j2')
+    return template.render(name=state_name, data=state_details)
+
+def fail_operator_block(state_name, state_details, *args, **kwargs):
+    template = jinjaenv.get_template('/OPERATORS/FAIL_OPERATOR.j2')
+    return template.render(name=state_name, data=state_details)
+
+def choice_operator_block(state_name, state_details, *args, **kwargs):
+    template = jinjaenv.get_template('/OPERATORS/CHOICE_OPERATOR.j2')
+    return template.render(name=state_name, data=state_details)
+
+def parallel_operator_block(state_name, state_details, *args, **kwargs):
+    template = jinjaenv.get_template('/OPERATORS/PARALLEL_OPERATOR.j2')
+    return template.render(name=state_name, data=state_details)
+
+def map_operator_block(state_name, state_details, *args, **kwargs):
+    template = jinjaenv.get_template('/OPERATORS/MAP_OPERATOR.j2')
+    return template.render(name=state_name, data=state_details)
diff --git a/app/routes/Mapper/VariableObjectMapper.py b/app/routes/Mapper/VariableObjectMapper.py
index 739e4e9..6421727 100644
--- a/app/routes/Mapper/VariableObjectMapper.py
+++ b/app/routes/Mapper/VariableObjectMapper.py
@@ -1,5 +1,6 @@
 from Classes.ObjectVariables.WaitObjectVariables import WaitObjectVariables
 from Util.JSONPathParser import JSONPathParser
+from Util.NameBuilder import get_hashed_snake_case


 def get_only_vaild_dict(object_detail : dict) -> dict:
@@ -44,6 +45,10 @@ def meta_mapper(object_detail: dict, workflow_query_language: str) -> dict:
     if object_detail.get("QueryLanguage") == None:
         object_detail["QueryLanguage"] = workflow_query_language

+    # 추후 task_mapping을 위하여 "next"의 값이 있을경우, snake_case로 변환함.
+    if obj.get("next") is not None:
+        obj["next"] = get_hashed_snake_case(obj["next"])
+

     if meta_validate_variables_mapping(obj):
         return obj
@@ -89,7 +94,7 @@ def wait_object_variable_mapping(object_detail : dict) -> dict:

 def io_variable_mapper(object_detail: dict):
     return get_only_vaild_dict({
-            "query_language" : object_detail.get('QueryLanguage'),
+            # "query_language" : object_detail.get('QueryLanguage'),
             "output": object_detail.get('Output'),
             "assign" : object_detail.get('Assign'),
             "input_path": object_detail.get('InputPath'),
diff --git a/app/routes/dags_factory.py b/app/routes/dags_factory.py
new file mode 100644
index 0000000..06f8e10
--- /dev/null
+++ b/app/routes/dags_factory.py
@@ -0,0 +1,38 @@
+from Util.FlaskUtil.MethodManager import get_method_by_type
+
+from jinja2 import Environment, FileSystemLoader
+jinjaenv = Environment(loader=FileSystemLoader('./app/Templates'))
+
+
+
+def extract_from_states(state_name, state_details):
+    state_type = state_details['meta']['type']
+    states = []
+
+    if state_type in ['Pass', 'Choice', 'Parallel', "Map", "Pass", "Wait", "Succeed", "Fail"]:
+        method = get_method_by_type(state_type=state_type.lower(), method_type="operator")
+        states.append(method(state_name, state_details))
+    else:
+        raise ValueError(f"Unsupported state type: {state_type}")
+    return states
+
+
+def assemble_dags(dags_data):
+    # dags_data = {'imports_type': {},
+    #         'imports': [basic_import_block()],
+    #         'dags_info': [dags_states_command(workflow_info)],
+    #         'states': [],
+    #         'work_orders': []
+    #         }
+
+
+    for import_type in dags_data["imports_type"].keys():
+        import_type_method = get_method_by_type(state_type=import_type.lower(), method_type="import")
+        dags_data["imports"].append(import_type_method())
+
+    template = jinjaenv.get_template('/Dags/dags_template.j2')
+
+    # 템플릿 렌더링
+    return template.render(data=dags_data)
+
+
diff --git a/app/routes/state_routes.py b/app/routes/state_routes.py
index b7b1ea7..a0aae17 100644
--- a/app/routes/state_routes.py
+++ b/app/routes/state_routes.py
@@ -1,18 +1,35 @@
 from flask import request, jsonify, Blueprint
-import logging
 import traceback
 import json

+from Util.FileManager import export_file
+from Util.NameBuilder import get_hashed_snake_case
+from app.routes.CodeBlocks.dags_blocks import dags_states_command
+from app.routes.CodeBlocks.import_blocks import basic_import_block
 from app.routes.Mapper.VariableObjectMapper import get_only_vaild_dict
+from app.routes.dags_factory import extract_from_states, assemble_dags
 from app.routes.parser import parse_state

 state_bp = Blueprint('state', __name__)
 # Blueprint 생성: 'user'는 이름, __name__은 현재 모듈의 이름

+@state_bp.route('/parse_and_generate', methods=['POST'])
+def parse_and_generate(data=None):
+    try:
+        data = request.get_json() if data is None else data
+        data = parse_json_impl(data)
+        return dags_generate_impl(data)
+    except Exception as e:
+        return jsonify({"error": str(e)}), 500
+
+
 @state_bp.route('/parse', methods=['POST'])
 def parse_json():
+    data = request.get_json()
+    return parse_json_impl(data)
+
+def parse_json_impl(data):
     try:
-        data = request.get_json()
         # 필수 키 확인
         required_keys = ['StartAt', 'States']
         for key in required_keys:
@@ -22,7 +39,7 @@ def parse_json():

         workflow = get_only_vaild_dict({
             "query_language": data.get('QueryLanguage', 'JSONPath'),
-            "start_at" : data.get('StartAt', '2013-01-01'),
+            "start_at" : get_hashed_snake_case(data.get('StartAt')),
             "comment" : data.get('Comment', None),
             "timeout_seconds": data.get('TimeoutSeconds', None),
             "version" : data.get('Version', None),
@@ -36,8 +53,9 @@ def parse_json():
             parsed = parse_state(workflow["query_language"], state_name, state_details)
             print(json.dumps(parsed, indent=4))
             if parsed is not None:
+                #추후 Task로서 사용을 위하여, key를 snake_case로 변환함
+                state_name = get_hashed_snake_case(state_name)
                 workflow["states"][state_name] = parsed
-
         return workflow

     except Exception as e:
@@ -51,5 +69,91 @@ def parse_json():
         }), 500


+@state_bp.route('/generate', methods=['POST'])
+def dags_generate():
+    data = request.get_json()
+    return dags_generate_impl(data)
+
+def dags_generate_impl(data):
+    try:
+        # 필수 키 확인
+        required_keys = ['start_at', 'states']
+        for key in required_keys:
+            if key not in data:
+                return jsonify({"error": f"Missing required key: {key}"}), 400
+
+
+        workflow_info = get_only_vaild_dict({
+            "query_language": data.get('query_language', 'JSONPath'),
+            "start_at" : data.get('startd_at'),
+            "comment" : data.get('comment', None),
+            "timeout_seconds": data.get('timeoutseconds', None),
+            "version" : data.get('version', None),
+        })
+
+
+
+        dags = {'imports_type' : {},
+                'imports' : [basic_import_block()],
+                'dags_info' : [dags_states_command(workflow_info)],
+                'states' : [],
+                'work_orders' : []
+                }
+
+
+
+        for state_name, state_details in data["states"].items():
+            type = state_details["meta"]["type"]
+
+            # import Type 분류 후 추가
+            if dags["imports_type"].get(type) is None:
+                dags["imports_type"][type] = True
+
+            # work_order구하기
+            next_state = state_details["meta"].get("next")
+            if next_state is not None:
+                dags["work_orders"].append(f"{state_name} >> {next_state}")
+
+            states = extract_from_states(state_name, state_details)
+            if len(states) > 0:
+                dags["states"] += states
+
+        # state가 단일 state이며, next가 없을 경우
+        if len(workflow_info) == 0:
+            dags["work_orders"].append(workflow_info["start_at"])

+        print(json.dumps(dags, indent=4))

+        dags_text = assemble_dags(dags)
+
+        export_file('../.tmp/hello.py', dags_text)
+
+        return dags_text
+
+    except Exception as e:
+        print(traceback.format_exc())
+        return jsonify({
+            "error": {
+                "type": type(e).__name__,
+                "message": str(e),
+                "stack_trace": traceback.format_exc()
+            }
+        }), 500
+
+
+#Test를 위해 r'../TestTemplate/RawJSONTemplate'의 json을 기반하여 parsed_json과 py파일을 모두 생성함.
+@state_bp.route('/test_gen', methods=['get'])
+def test_gen():
+    try:
+        from Util.FlaskUtil.TestCaseGenerator import generate_parse
+        generate_parse()
+        return "All good"
+
+    except Exception as e:
+        return jsonify({
+            "error": {
+                "type": type(e).__name__,
+                "message": str(e),
+                "stack_trace": traceback.format_exc()
+            }
+        }), 500
diff --git a/dags/test_my_Pass_Operator.py b/dags/test_my_Pass_Operator.py
index a6a220c..0a3d995 100644
--- a/dags/test_my_Pass_Operator.py
+++ b/dags/test_my_Pass_Operator.py
@@ -21,7 +21,8 @@ with (DAG(
     with open(f"/opt/airflow/plugins/{file_path}", 'r') as json_file:
         input_json = json.load(json_file)

-    sample_state_variable = input_json["states"]["JSONPath state"]
+
+    sample_state_variable = input_json["states"]["_6b3cc434___JSONPath_state"]

     global_io_variable = {}
     global_io_variable["input_value"] = json.loads("""
diff --git a/dags/test_my_Suceed_Operator.py b/dags/test_my_Suceed_Operator.py
index 9ba3663..553356a 100644
--- a/dags/test_my_Suceed_Operator.py
+++ b/dags/test_my_Suceed_Operator.py
@@ -15,10 +15,11 @@ with (DAG(
         tags=["cloud.park", "SucceedOperator"],
 ) as dag):

-    with open("/opt/airflow/plugins/TestTemplate/ParsedJSON/parsed_jsonata1.json", 'r') as json_file:
+    with open("/opt/airflow/plugins/TestTemplate/ParsedJSON/jsonata1.json", 'r') as json_file:
         input_json = json.load(json_file)
+
+    sample_state_variable = input_json["states"]["_35b34b13___Summarize_the_Execution0"]

-    sample_state_variable = input_json["states"]["Summarize the Execution"]

     global_io_variable = {}
     global_io_variable["input_value"] = json.loads("""
diff --git a/dags/test_my_Wait_Operator.py b/dags/test_my_Wait_Operator.py
index dd93b0d..e789e2d 100644
--- a/dags/test_my_Wait_Operator.py
+++ b/dags/test_my_Wait_Operator.py
@@ -20,7 +20,7 @@ with (DAG(
     with open("/opt/airflow/plugins/TestTemplate/ParsedJSON/parsed_jsonpath1.json", 'r') as json_file:
         input_json = json.load(json_file)

-    sample_state_variable = input_json["states"]["Wait 3 sec"]
+    sample_state_variable = input_json["states"]["Wait_3_sec___bd8ecbd8"]

     global_io_variable = {}
     global_io_variable["input_value"] = json.loads("""
diff --git a/docker-compose.yaml b/docker-compose.yaml
index 55d56d2..09f39e4 100644
--- a/docker-compose.yaml
+++ b/docker-compose.yaml
@@ -75,12 +75,12 @@ x-airflow-common:
     # AIRFLOW_CONFIG: '/opt/airflow/config/airflow.cfg'
   volumes:
     - ${AIRFLOW_PROJ_DIR:-.}/dags:/opt/airflow/dags
-    - ${AIRFLOW_PROJ_DIR:-./docker-compose}/logs:/opt/airflow/logs
-    - ${AIRFLOW_PROJ_DIR:-./docker-compose}/config:/opt/airflow/config
+    - ${AIRFLOW_PROJ_DIR:-./.tmp/docker-compose}/logs:/opt/airflow/logs
+    - ${AIRFLOW_PROJ_DIR:-./.tmp/docker-compose}/config:/opt/airflow/config
     - ${AIRFLOW_PROJ_DIR:-.}/Operator:/opt/airflow/plugins/Operator
     - ${AIRFLOW_PROJ_DIR:-.}/Classes:/opt/airflow/plugins/Classes
     - ${AIRFLOW_PROJ_DIR:-.}/Util:/opt/airflow/plugins/Util
-    - ${AIRFLOW_PROJ_DIR:-.}/TestTemplate:/opt/airflow/plugins/TestTemplate
+    - ${AIRFLOW_PROJ_DIR:-.}/TestTemplate/ParsedJSON:/opt/airflow/plugins/TestTemplate/ParsedJSON
   user: "${AIRFLOW_UID:-50000}:0"
   depends_on:
     &airflow-common-depends-on


