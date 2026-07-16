from src.test.load_myc_obligation_determination_test_cases import Case

# This is the SQL-only harness. Only print_case_title (used by the SQL scenario
# test for verbose output) is kept here; the PySpark table-dumping helpers from
# the upstream epr-data project are intentionally omitted so this suite has no
# PySpark dependency.

seen_titles: set = set()


def print_case_title(case: Case):
    print("\n")
    if not case.title in seen_titles:
        seen_titles.add(case.title)
        print(case.title)
    print(case.sub_title)
