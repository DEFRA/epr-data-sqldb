from pathlib import Path

import pandas as pd
import pymssql
from testcontainers.mssql import SqlServerContainer

# The deployable stored procedure lives with the other SSDT objects. The test
# executes this exact file byte-for-byte - it is the single source of truth for
# both deployment and testing, so there is no dialect-translation layer to drift.
_SQL_PATH = (
    Path(__file__).parents[3]
    / "dbo"
    / "Stored Procedures"
    / "sp_producer_obligation_determination.sql"
)

OUTPUT_COLS = [
    "organisation_id",
    "subsidiary_id",
    "submitter_id",
    "organisation_name",
    "trading_name",
    "status_code",
    "leaver_date",
    "joiner_date",
    "obligation_status",
    "num_days_obligated",
    "error_code",
    "submission_period_year",
]

# dbo.v_submitted_pom_org_file_status is a complex upstream view in production;
# here it is a plain table under the same name, matching what the PySpark test
# stub already does - the real view's SQL is never executed by these tests.
_DDL = "CREATE SCHEMA rpd;"

_TABLES = """
CREATE TABLE rpd.CompanyDetails (
    organisation_id INT,
    subsidiary_id NVARCHAR(256),
    FileName NVARCHAR(512),
    organisation_name NVARCHAR(512),
    trading_name NVARCHAR(512),
    leaver_code NVARCHAR(10),
    joiner_date NVARCHAR(50),
    leaver_date NVARCHAR(50),
    organisation_size NVARCHAR(10)
);
CREATE TABLE rpd.Organisations (
    ReferenceNumber INT,
    ExternalId NVARCHAR(256),
    IsDeleted INT
);
CREATE TABLE rpd.cosmos_file_metadata (
    FileName NVARCHAR(512),
    FileId NVARCHAR(256),
    Created NVARCHAR(50),
    SubmissionPeriod NVARCHAR(50),
    ComplianceSchemeId NVARCHAR(256)
);
CREATE TABLE dbo.v_submitted_pom_org_file_status (
    cfm_fileid NVARCHAR(256),
    filetype NVARCHAR(50),
    Regulator_Status NVARCHAR(50)
);
"""


def start_mssql_container():
    """Starts a real SQL Server container, creates the schema/tables, and deploys the
    stored procedure from the unmodified T-SQL source file (no dialect translation).

    Returns (container, connection). Caller owns the container lifecycle - stop it
    (e.g. from a session-scoped pytest fixture) once all test cases have run.
    """
    container = SqlServerContainer("mcr.microsoft.com/mssql/server:2022-latest", dialect="pymssql")
    container.start()
    conn = pymssql.connect(
        server=container.get_container_host_ip(),
        port=container.get_exposed_port(1433),
        user="sa",
        password=container.password,
        database="master",
        autocommit=True,
    )
    cur = conn.cursor()
    cur.execute(_DDL)
    for stmt in _TABLES.strip().split(";"):
        if stmt.strip():
            cur.execute(stmt)
    cur.execute(_SQL_PATH.read_text())
    return container, conn


def run_test_case_mssql(conn, test_data_input: dict, test_data_output: list) -> None:
    cur = conn.cursor()
    cur.execute("DELETE FROM rpd.CompanyDetails")
    cur.execute("DELETE FROM rpd.Organisations")
    cur.execute("DELETE FROM rpd.cosmos_file_metadata")
    cur.execute("DELETE FROM dbo.v_submitted_pom_org_file_status")

    if test_data_input["company_details"]:
        cur.executemany(
            "INSERT INTO rpd.CompanyDetails VALUES (%d,%s,%s,%s,%s,%s,%s,%s,%s)",
            test_data_input["company_details"],
        )
    if test_data_input["organisations"]:
        cur.executemany(
            "INSERT INTO rpd.Organisations VALUES (%d,%s,%d)",
            test_data_input["organisations"],
        )
    if test_data_input["cosmos_file_metadata"]:
        cur.executemany(
            "INSERT INTO rpd.cosmos_file_metadata VALUES (%s,%s,%s,%s,%s)",
            test_data_input["cosmos_file_metadata"],
        )
    if test_data_input["submitted_pom_org_file_status"]:
        cur.executemany(
            "INSERT INTO dbo.v_submitted_pom_org_file_status VALUES (%s,%s,%s)",
            test_data_input["submitted_pom_org_file_status"],
        )

    cur.execute("EXEC dbo.sp_producer_obligation_determination")
    actual_df = pd.DataFrame(cur.fetchall(), columns=OUTPUT_COLS)
    expected_df = pd.DataFrame(test_data_output, columns=OUTPUT_COLS)

    pd.testing.assert_frame_equal(
        _normalise(actual_df),
        _normalise(expected_df),
        check_dtype=False,
    )


def _normalise(df: pd.DataFrame) -> pd.DataFrame:
    df = df[OUTPUT_COLS].copy().drop_duplicates()
    df["organisation_id"] = pd.to_numeric(df["organisation_id"], errors="coerce").astype("Int64")
    df["submission_period_year"] = pd.to_numeric(df["submission_period_year"], errors="coerce").astype("Int64")
    df["num_days_obligated"] = pd.to_numeric(df["num_days_obligated"], errors="coerce").astype("Int64")
    return df.sort_values(OUTPUT_COLS, na_position="last").reset_index(drop=True)
