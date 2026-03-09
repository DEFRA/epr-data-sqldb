CREATE VIEW [dbo].[v_extract_recent_pom_org_small_data] AS
with base as (
    select *,
        cast(Reporting_Year as varchar(4)) reporting_year_str
    from dbo.t_extract_recent_pom_org_data
    where 'S' in (Packaging_data_latest_submission_organisation_size, Organisation_data_latest_submission_organisation_size)
    and Reporting_Year >= 2024
),
legacy as (
    select * from base
	where reporting_year in (2024, 2025)
        and organisation_data_latest_submission_organisation_size = 'S'
        and organisation_data_latest_submission_status not in ('Refused', 'Rejected', 'Cancelled')
        and Organisation_data_submission_period = 'July to Dec ' + reporting_year_str + ' - H2'
),

small_producer_recent_pom_org as (
	select * from base
	where packaging_data_latest_submission_organisation_size = 'S'
        and Organisation_data_first_submission_datetime is null
        and Organisation_data_latest_submission_datetime is null
        and Packaging_data_latest_submission_period_code = reporting_year_str + '-P0'

	union all

	select * from legacy
)

select
    so.Org_ID,
    Org_name,
    CH_number,
    Nation_of_enrolment,
    Enrolment_date_time,
    Enrolment_status,
    Nation_of_Compliance_Scheme_regulator,
    'Jan to Dec ' + reporting_year_str as Packaging_data_submission_period,
    Packaging_data_first_submission_datetime,
    Packaging_data_first_submitted_CS_or_Direct,
    Packaging_data_first_submitted_CS_Nation,
    Packaging_data_first_submission_status,
    Packaging_data_first_submission_organisation_size,
    Packaging_data_latest_submission_datetime,
    Packaging_data_latest_submitted_CS_or_Direct,
    Packaging_data_latest_submitted_CS_Nation,
    Packaging_data_latest_submission_status,
    Packaging_data_latest_submission_organisation_size,
    'Jan to Dec ' + cast(reporting_year + 1 as nvarchar(4)) as Organisation_data_submission_period,
    Organisation_data_first_submission_datetime,
    Organisation_data_first_submitted_CS_or_Direct,
    Organisation_data_first_submitted_CS_Nation,
    Organisation_data_first_submission_status,
    Organisation_data_first_submission_organisation_size,
    Organisation_data_latest_submission_datetime,
    Organisation_data_latest_submitted_CS_or_Direct,
    Organisation_data_latest_submitted_CS_Nation,
    Organisation_data_latest_submission_status,
    Organisation_data_latest_submission_organisation_size,
    Organisation_exists_in_most_recent_packaging_data_submission,
    Organisation_exists_in_most_recent_organisation_data_submission,
    Organisation_visible_in_PowerBI_Packaging_reports,
    Organisation_visible_in_PowerBI_Orgdata_reports,
    Single_File_Submission_Packaging,
    Single_File_Submission_Orgdata,
    ds.Reported_mandated_data_sets,
    Organisation_soft_deleted,
    [Household drinks containers-Aluminium (Kg)],
    [Household drinks containers-Aluminium (No.Units)],
    [Household drinks containers-Fibre Composite (Kg)],
    [Household drinks containers-Fibre Composite (No.Units)],
    [Household drinks containers-Glass (Kg)],
    [Household drinks containers-Glass (No.Units)],
    [Household drinks containers-Other (Kg)],
    [Household drinks containers-Other (No.Units)],
    [Household drinks containers-Paper / Card (Kg)],
    [Household drinks containers-Paper / Card (No.Units)],
    [Household drinks containers-Plastic (Kg)],
    [Household drinks containers-Plastic (No.Units)],
    [Household drinks containers-Steel (Kg)],
    [Household drinks containers-Steel (No.Units)],
    [Household drinks containers-Wood (Kg)],
    [Household drinks containers-Wood (No.Units)],
    [Small organisation packaging - all-Aluminium],
    [Small organisation packaging - all-Fibre Composite],
    [Small organisation packaging - all-Glass],
    [Small organisation packaging - all-Other],
    [Small organisation packaging - all-Paper / Card],
    [Small organisation packaging - all-Plastic],
    [Small organisation packaging - all-Steel],
    [Small organisation packaging - all-Wood],
    so.Reporting_Year
from small_producer_recent_pom_org so
left join dbo.v_reported_mandated_data_sets ds on  ds.[Org_ID] = so.[Org_ID]
    and ds.ReportingYear = so.Reporting_Year;