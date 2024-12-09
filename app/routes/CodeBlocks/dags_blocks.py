from jinja2 import Environment, FileSystemLoader
jinjaenv = Environment(loader=FileSystemLoader('./app/Templates'))

def dags_states_command(workflow_info, *args, **kwargs):
    # # DAG 템플릿 정의
    # template = """
    # with (DAG(
    #     dag_id="{{ workflow_info.dag_id | default('my_default_dag') }}",
    #     schedule=datetime.timedelta(hours={{ workflow_info.schedule_hours }}),
    #     start_date=datetime.datetime( {{ workflow_info.start_date}} ),
    #     catchup=False,
    #     description={{ workflow_info.comment }},
    #     tags=[ {{ workflow_info.tags }} ]
    #     concurrency = {{ workflow_info.concurrency }}
    # ) as dag):
    # """


    template = jinjaenv.get_template('/DAG_STATES/DAG_STATES.j2')

    # 템플릿 렌더링
    return template.render(workflow_info)

    # def __init__(
    #     self,
    #     dag_id: str,
    #     description: str | None = None,
    #     schedule: ScheduleArg = NOTSET,
    #     schedule_interval: ScheduleIntervalArg = NOTSET,
    #     timetable: Timetable | None = None,
    #     start_date: datetime | None = None,
    #     end_date: datetime | None = None,
    #     full_filepath: str | None = None,
    #     template_searchpath: str | Iterable[str] | None = None,
    #     template_undefined: type[jinja2.StrictUndefined] = jinja2.StrictUndefined,
    #     user_defined_macros: dict | None = None,
    #     user_defined_filters: dict | None = None,
    #     default_args: dict | None = None,
    #     concurrency: int | None = None,
    #     max_active_tasks: int = airflow_conf.getint("core", "max_active_tasks_per_dag"),
    #     max_active_runs: int = airflow_conf.getint("core", "max_active_runs_per_dag"),
    #     max_consecutive_failed_dag_runs: int = airflow_conf.getint(
    #         "core", "max_consecutive_failed_dag_runs_per_dag"
    #     ),
    #     dagrun_timeout: timedelta | None = None,
    #     sla_miss_callback: None | SLAMissCallback | list[SLAMissCallback] = None,
    #     default_view: str = airflow_conf.get_mandatory_value("webserver", "dag_default_view").lower(),
    #     orientation: str = airflow_conf.get_mandatory_value("webserver", "dag_orientation"),
    #     catchup: bool = airflow_conf.getboolean("scheduler", "catchup_by_default"),
    #     on_success_callback: None | DagStateChangeCallback | list[DagStateChangeCallback] = None,
    #     on_failure_callback: None | DagStateChangeCallback | list[DagStateChangeCallback] = None,
    #     doc_md: str | None = None,
    #     params: abc.MutableMapping | None = None,
    #     access_control: dict[str, dict[str, Collection[str]]] | dict[str, Collection[str]] | None = None,
    #     is_paused_upon_creation: bool | None = None,
    #     jinja_environment_kwargs: dict | None = None,
    #     render_template_as_native_obj: bool = False,
    #     tags: list[str] | None = None,
    #     owner_links: dict[str, str] | None = None,
    #     auto_register: bool = True,
    #     fail_stop: bool = False,
    #     dag_display_name: str | None = None,
    # ):
