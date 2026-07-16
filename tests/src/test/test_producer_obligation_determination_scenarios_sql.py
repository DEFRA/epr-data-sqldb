"""Standalone SQL scenario test suite.

Runs the deployable T-SQL stored procedure (dbo/Stored Procedures/sp_producer_obligation_determination.sql)
against the same scenario cases that cover the PySpark pipeline, using a real SQL
Server container (see stubs_mssql.py).

This file is intentionally self-contained: the load_*_from_case helpers below are
pure data transforms with no PySpark dependency, so this suite does not import the
PySpark scenarios module. The PySpark scenario test keeps its own equivalent loaders.
"""

import pytest

from .load_myc_obligation_determination_test_cases import cases, Case
from .markdown_helper import print_case_title
from .stubs_mssql import run_test_case_mssql


def get_organisations(case: Case):
    return list(dict.fromkeys(c.organisation_id for c in case.records))


def load_company_details_from_case(case: Case):
    res = [
        # organisation_id | subsidiary_id | FileName | organisation_name | trading_name | leaver_code | joiner_date | leaver_date | organisation_size
        (
            int(c.organisation_id),
            c.subsidiary_id,
            f"file-{c.submission_period_year}-{c.compliance_scheme if c.compliance_scheme else ''}-{c.organisation_id}",
            c.organisation_name,
            c.organisation_name,
            c.status_code,
            c.joiner_date,
            None,
            "L",
        )
        for c in case.records
    ]
    return list(dict.fromkeys(res))  # unique


def load_organisations_from_case(case: Case):
    return [
        # ReferenceNumber | ExternalId | IsDeleted
        (id, f"EXT{id}", 0)
        for id in get_organisations(case)
    ]


def load_cosmos_file_metadata(case: Case):
    res = [
        # FileName | FileId | Created | SubmissionPeriod | ComplianceSchemeId
        (
            f"file-{c.submission_period_year}-{c.compliance_scheme if c.compliance_scheme else ''}-{c.organisation_id}",
            f"F{c.organisation_id}",
            f"{c.submission_period_year}-01-01T10:00:00.000",
            f"January to December {c.submission_period_year}",
            c.compliance_scheme,
        )
        for c in case.records
    ]
    return list(dict.fromkeys(res))  # unique


def load_submitted_pom_org_file_status_from_case(case: Case):
    return [
        # cfm_fileid | filetype | Regulator_Status
        (f"F{id}", "CompanyDetails", "Accepted")
        for id in get_organisations(case)
    ]


def load_input_data_from_case(case: Case):
    return {
        "company_details": load_company_details_from_case(case),
        "organisations": load_organisations_from_case(case),
        "cosmos_file_metadata": load_cosmos_file_metadata(case),
        "submitted_pom_org_file_status": load_submitted_pom_org_file_status_from_case(
            case
        ),
    }


def load_output_data_from_case(case: Case):
    return [
        # |organisation_id|subsidiary_id|submitter_id|organisation_name|trading_name|status_code|leaver_date|joiner_date|obligation_status|num_days_obligated|error_code|submission_period_year|
        (
            c.organisation_id,
            c.subsidiary_id,
            c.compliance_scheme if c.compliance_scheme else f"EXT{c.organisation_id}",
            c.organisation_name,
            c.organisation_name,
            c.status_code,
            None,
            c.joiner_date,
            (
                c.expected_obligation[0] if len(c.expected_obligation) > 0 else ""
            ),  # O, N or E
            c.expected_partial,
            c.expected_error_code,
            c.submission_period_year,
        )
        for c in case.records
    ]


@pytest.mark.scenario
@pytest.mark.parametrize("case", cases, ids=[f"{c.sub_title}" for c in cases])
def test_sql_business_rules(request, mssql_conn, case: Case):
    if not (0 <= case.number):
        pytest.skip("Skipped")
    verbose = request.config.getoption("-v")
    if verbose:
        print_case_title(case)
    run_test_case_mssql(
        mssql_conn,
        load_input_data_from_case(case),
        load_output_data_from_case(case),
    )
