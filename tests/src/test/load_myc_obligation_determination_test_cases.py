# load_myc_obligation_determination_test_cases.py
from dataclasses import dataclass
from typing import Optional, List
import csv
from decimal import Decimal
from datetime import datetime
import re

csvFilePath = "src/test/myc-obligation-determination-test-cases.csv"


@dataclass
class Obligation:
    value: Optional[Decimal] = None
    msg: Optional[str] = None

    @staticmethod
    def obligated(val: Optional[str] = None):
        return Obligation(value=Decimal(val) if val else None)

    @staticmethod
    def validation(msg: str):
        return Obligation(msg=msg)


# ----- Data classes -----
@dataclass
class Org:
    organisation_id: int
    subsidiary_id: Optional[str] = None
    compliance_scheme: Optional[str] = None
    organisation_name: str = ""
    status_code: Optional[str] = None
    joiner_date: Optional[datetime] = None
    expected_obligation: str = None
    expected_partial: int = 100
    expected_error_code: str = None
    submission_period_year: int = 2024


@dataclass
class Case:
    title: str
    sub_title: str
    records: List[Org]
    number: float = ""


# ----- Helper functions -----
def to_org(
    org_id: int,
    subsidiary_id: str,
    compliance_scheme: str,
    org_name: str = "",
    status_code: str = "",
    joiner_date: Optional[str] = None,
    expected_obligation: str = None,
    expected_partial: int = None,
    expected_error_code: str = None,
    submission_period_year: int = 2024
) -> Org:

    return Org(
        organisation_id = org_id,
        subsidiary_id = subsidiary_id if subsidiary_id and subsidiary_id.strip() else None,
        compliance_scheme = compliance_scheme if compliance_scheme and compliance_scheme.strip() else None,
        organisation_name = org_name,
        status_code = status_code if status_code.strip() else None,
        joiner_date = datetime.strptime(joiner_date, "%Y-%m-%d").strftime("%d/%m/%Y") if joiner_date else None,
        expected_obligation = expected_obligation,
        expected_partial = expected_partial or None,
        expected_error_code = expected_error_code,
        submission_period_year = submission_period_year,
    )


def format_row(org: Org, obligation: Obligation) -> str:
    return f"| {org.organisation_id:<2} | {org.subsidiary_id or '':<13} | {org.organisation_name:<27} | {org.status_code or '':<6} | {obligation_to_string(obligation):<55} |"


def obligation_to_string(o: Obligation) -> str:
    if o.msg:
        return o.msg
    elif o.value is not None:
        return str(o.value)
    else:
        return "True"


# ----- Read CSV -----
parsed_records = []
last_title = ""
last_sub_title = ""

cases: List[Case] = []
with open(csvFilePath, newline="") as csvfile:
    reader = csv.reader(csvfile)
    next(reader)  # skip header
    title_pattern = re.compile(r"^[0-9]+[ ]+.*")
    subtitle_pattern = re.compile(r"(^[0-9]+\.[0-9]+)[ ]+.*")

    for cols in reader:
        if not cols or all(c.strip() == "" for c in cols):
            continue
        col0 = cols[0].strip()
        subtitleMatch = subtitle_pattern.match(col0)
        if title_pattern.match(col0):
            if len(parsed_records) > 0:
                cases.append(
                    Case(
                        last_title,
                        last_sub_title,
                        parsed_records.copy(),
                        float(last_test_number),
                    )
                )
                parsed_records.clear()
            last_title = col0
            continue
        elif subtitleMatch:
            if len(parsed_records) > 0:
                cases.append(
                    Case(
                        last_title,
                        last_sub_title,
                        parsed_records.copy(),
                        float(last_test_number),
                    )
                )
                parsed_records.clear()
            last_sub_title = col0
            last_test_number = subtitleMatch.group(1)
            continue
        org_id = int(cols[0].replace('"', ""))
        subsidiary_id = cols[1].replace('"', "")
        submitter_id = cols[2].replace('"', "")
        name = cols[3].replace('"', "")
        status_code = cols[4].replace('"', "")
        date = cols[5]
        expected = cols[6]
        additional = cols[7]
        submission_period_year = int(cols[8].strip() or 2024)

        if expected == "Obligated":
            expected_obligation = "Obligated"
            expected_partial = None
            expected_error_code = additional or None
        elif expected.startswith("Partial"):
            expected_obligation = "Obligated"
            expected_partial = int(additional) if (len(additional)) else None
            expected_error_code = None
        else:
            expected_obligation = expected
            expected_partial = None
            expected_error_code = additional or None
        org = to_org(
            org_id,
            subsidiary_id,
            submitter_id,
            name,
            status_code,
            joiner_date=date if date else None,
            expected_obligation=expected_obligation,
            expected_partial=expected_partial,
            expected_error_code=expected_error_code,
            submission_period_year=submission_period_year
        )
        parsed_records.append(org)


def dump_case_to_markdown(case: Case):
    md = []
    # Define fixed widths for each column
    widths = [
        6,
        13,
        13,
        27,
        6,
        10,
        17,
        11,
        55,
    ]

    headers = [
        "Org ID",
        "Subsidiary ID",
        "Submitter ID",
        "Organisation Name",
        "Status",
        "Date",
        "Exp Obligation",
        "Exp Partial",
        "Exp Message",
    ]

    # Helper to format a row with fixed widths
    def format_row(row):
        return (
            "| "
            + " | ".join(f"{cell:<{widths[i]}}" for i, cell in enumerate(row))
            + " |"
        )

    # Header
    md.append(format_row(headers))
    md.append("|" + "|".join("-" * (w + 2) for w in widths) + "|")

    # Data rows
    for org in case.records:
        row = [
            str(org.organisation_id),
            org.subsidiary_id or "",
            org.submitter_id or "",
            org.organisation_name,
            org.status_code or "",
            datetime.strptime(org.joiner_date, "%d/%m/%Y").strftime("%Y-%m-%d") or "",
            org.expected_obligation or "",
            org.expected_partial or 0,
            org.expected_error_code or "",
        ]
        md.append(format_row(row))

    md.append("\n")  # blank line after table

    return "\n".join(md)


def dump_cases_to_markdown(cases):
    md = []
    for case in cases:
        md.append(f"## {case.title} - {case.sub_title}\n")
        md.append(dump_case_to_markdown(case))

    return "\n".join(md)


# print(dump_cases_to_markdown(cases))

__all__ = ["cases", "Case", "Org", "Obligation"]
