# conftest.py
import os

import pytest

# Disable the testcontainers Ryuk resource-reaper. Ryuk bind-mounts the Docker
# socket into a sidecar container, which fails on Colima (the host-side socket path
# is not mountable from inside the VM: "operation not supported"). The mssql_conn
# fixture below stops its container explicitly in teardown, so Ryuk's safety-net
# cleanup is unnecessary. setdefault lets a caller still opt back in if they want it.
os.environ.setdefault("TESTCONTAINERS_RYUK_DISABLED", "true")


def pytest_report_teststatus(report, config):
    if report.when == "call":
        if report.passed:
            return report.outcome, "PASS", "PASSED"
        elif report.failed:
            return report.outcome, "FAIL", "FAILED"


@pytest.fixture(scope="session")
def mssql_conn():
    # Imported lazily so pymssql/testcontainers/Docker are only required when a test
    # actually requests this fixture, not for every pytest run in this package.
    from .stubs_mssql import start_mssql_container

    container, conn = start_mssql_container()
    yield conn
    container.stop()
