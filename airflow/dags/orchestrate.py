import os
import time
from airflow.sdk import dag, task
from airflow.providers.standard.operators.bash import BashOperator
from databricks.sdk import WorkspaceClient
from databricks.sdk.service.jobs import ( RunLifeCycleState, RunResultState)


DBT_PROJECT_DIR = "/opt/airflow/DBT/walmart_dbt_project"


@dag
def orchestrate():

    @task
    def ingest_cdc():

        ws = WorkspaceClient(
                host=os.environ["DATABRICKS_HOST"],
                token=os.environ["DATABRICKS_TOKEN"]
            )

        job_trigger = ws.jobs.run_now( job_id="309028202234856" )

        print(f"Databricks job triggered.Run ID: {job_trigger.run_id}" )

        while True:
            job_run = ws.jobs.get_run( run_id=job_trigger.run_id )

            lifecycle_state = job_run.state.life_cycle_state
            result_state = job_run.state.result_state

            print( f"Databricks Run ID: {job_trigger.run_id} | Lifecycle: {lifecycle_state} | Result: {result_state}" )

            if lifecycle_state in [RunLifeCycleState.TERMINATED,RunLifeCycleState.SKIPPED,RunLifeCycleState.INTERNAL_ERROR]:
                if result_state == RunResultState.SUCCESS:
                    print("Databricks CDC job completed successfully!")
                    break
                else:
                    raise Exception(f"Databricks job failed. Result state: {result_state}")
            time.sleep(5)
        return "CDC Ingestion Completed"


    @task.bash
    def clean_target():

        return (f"rm -rf {DBT_PROJECT_DIR}/target && rm -rf {DBT_PROJECT_DIR}/logs" )


    @task.bash
    def source_freshness():
        return ( f"cd {DBT_PROJECT_DIR} && dbt source freshness")


    silver_technical = BashOperator(
        task_id="silver_technical",
        cwd=DBT_PROJECT_DIR,
        bash_command=("dbt run --select enriched_tech --target-path target/silver_technical" )
    )


    silver_technical_tests = BashOperator(
        task_id="silver_technical_tests",
        cwd=DBT_PROJECT_DIR,
        bash_command=("dbt test --select enriched_tech --target-path target/silver_technical_tests")
    )


    silver_business = BashOperator(
        task_id="silver_business",
        cwd=DBT_PROJECT_DIR,
        bash_command=("dbt run --select enriched_b --target-path target/silver_business")
    )


    silver_business_tests = BashOperator(
        task_id="silver_business_tests",
        cwd=DBT_PROJECT_DIR,
        bash_command=("dbt test --select enriched_b --target-path target/silver_business_tests")
    )


    gold_ephemeral = BashOperator(
        task_id="gold_ephemeral",
        cwd=DBT_PROJECT_DIR,
        bash_command=(
            "dbt run --select curated/ephemeral --target-path target/gold_ephemeral")
    )


    gold_dimensions = BashOperator(
        task_id="gold_dimensions",
        cwd=DBT_PROJECT_DIR,
        bash_command=("dbt snapshot --target-path target/gold_dimensions")
    )


    gold_facts = BashOperator(
        task_id="gold_facts",
        cwd=DBT_PROJECT_DIR,
        bash_command=("dbt run --select curated/fact --target-path target/gold_facts")
    )


    cdc = ingest_cdc()
    clean = clean_target()
    freshness = source_freshness()

    cdc >> clean >> freshness >> silver_technical

    freshness >> silver_business

    silver_technical >> silver_technical_tests
    silver_business >> silver_business_tests

    silver_technical_tests >> gold_ephemeral
    silver_technical_tests >> gold_facts
    silver_technical_tests >> gold_dimensions
    
    silver_business_tests >> gold_dimensions 
    silver_business_tests >> gold_ephemeral
    silver_business_tests >> gold_facts

    
orchestrate_dag = orchestrate()