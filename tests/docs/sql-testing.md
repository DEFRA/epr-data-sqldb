# SQL Testing via SQL Server

## What this is

`dbo.sp_producer_obligation_determination` is a hand-written T-SQL stored procedure
deployed to Azure Synapse. This harness runs the **actual, deployable procedure file**
against a set of scenario test cases, using a real SQL Server (via testcontainers), so
the procedure's behaviour is verified byte-for-byte with no dialect-translation layer.

```
tests/src/test/myc-obligation-determination-test-cases.csv   <- scenarios (source of truth)
        |
        +-> test_producer_obligation_determination_scenarios_sql.py  (SQL Server runner)
                  |
                  +-> stubs_mssql.py
                        starts a real SQL Server container,
                        runs dbo/Stored Procedures/sp_producer_obligation_determination.sql
                        unmodified, and compares output
```

The runner executes the same `CREATE OR ALTER PROCEDURE` statement that gets deployed -
`stubs_mssql.py::_SQL_PATH` points directly at
`dbo/Stored Procedures/sp_producer_obligation_determination.sql`, the SSDT source of
truth for this repository.

## Running locally

The SQL runner requires a running Docker daemon - it pulls and starts
`mcr.microsoft.com/mssql/server:2022-latest` once per test session (~10-15s startup) and
reuses that one container across all scenario cases via the session-scoped `mssql_conn`
fixture in `conftest.py`.

```shell
# From the tests/ directory, with a Docker daemon running:
make install
make scenario-test selector=sql
```

No `DOCKER_HOST` or other environment variables are needed: testcontainers discovers the
daemon from the active Docker context, and the testcontainers Ryuk resource-reaper is
disabled in `conftest.py` (the `mssql_conn` fixture stops its own container).

### macOS on Apple Silicon (M-series)

The `mssql/server:2022` image is **amd64-only**, and SQL Server 2022 does **not** run
under QEMU emulation - it runs fine under **Rosetta 2**, and needs ~2GB RAM. Start Colima
with the `vz` backend, Rosetta, and enough memory:

```shell
brew install colima docker
colima start --vm-type vz --vz-rosetta --cpu 4 --memory 8
```

Docker Desktop and OrbStack (which use Rosetta by default) work too. GitHub-hosted
`ubuntu-latest` runners are amd64 with Docker preinstalled, so CI needs none of this.

## Running in CI

`.github/workflows/sql-tests.yml` reproduces the Azure DevOps SQL Server stage: it
installs Python, installs the dev dependencies, verifies a Docker daemon is present, and
runs `make scenario-test selector=sql`.

## Input tables

The runner populates the four tables that mirror the real Synapse sources (as real tables
in the container):

| Table name | Source in test data |
|---|---|
| `rpd.CompanyDetails` | `company_details` input |
| `rpd.Organisations` | `organisations` input |
| `rpd.cosmos_file_metadata` | `cosmos_file_metadata` input |
| `dbo.v_submitted_pom_org_file_status` | `submitted_pom_org_file_status` input |

`dbo.v_submitted_pom_org_file_status` (a complex upstream view in production) is bypassed:
the test provides its three relevant columns (`cfm_fileid`, `filetype`, `Regulator_Status`)
directly. For the SQL Server runner this is a plain table created under that same name -
the view's own SQL is never executed by these tests.
