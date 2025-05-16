CREATE VIEW [dbo].[v_extract_recent_pom_org_small_data] AS With Small_producer_recent_pom_org as
(
	Select * from dbo.t_extract_recent_pom_org_data
	where Reporting_Year=2024
	and Organisation_data_first_submission_datetime is null 
	and Organisation_data_latest_submission_datetime is null 
	and Packaging_data_latest_submission_period_code ='2024-P0'
	and Packaging_data_latest_submission_organisation_size ='S'

	union all

	Select * from dbo.t_extract_recent_pom_org_data
	where Reporting_Year=2024
	and Organisation_data_submission_period='July to Dec 2024 - H2'
	and Organisation_data_latest_submission_organisation_size='S'
	and Organisation_data_latest_submission_status not in ('Refused','Rejected','Cancelled')
)
select Org_ID
,Org_name
,CH_number
,Nation_of_enrolment
,Enrolment_date_time
,Enrolment_status
,Nation_of_Compliance_Scheme_regulator
,'Jan to Dec 2024 - H0' as Packaging_data_submission_period
,Packaging_data_first_submission_datetime
,Packaging_data_first_submitted_CS_or_Direct
,Packaging_data_first_submitted_CS_Nation
,Packaging_data_first_submission_status
,Packaging_data_first_submission_organisation_size
,Packaging_data_latest_submission_datetime
,Packaging_data_latest_submitted_CS_or_Direct
,Packaging_data_latest_submitted_CS_Nation
,Packaging_data_latest_submission_status
,Packaging_data_latest_submission_organisation_size
,'Jan to Dec 2024 - H0' as Organisation_data_submission_period
,Organisation_data_first_submission_datetime
,Organisation_data_first_submitted_CS_or_Direct
,Organisation_data_first_submitted_CS_Nation
,Organisation_data_first_submission_status
,Organisation_data_first_submission_organisation_size
,Organisation_data_latest_submission_datetime
,Organisation_data_latest_submitted_CS_or_Direct
,Organisation_data_latest_submitted_CS_Nation
,Organisation_data_latest_submission_status
,Organisation_data_latest_submission_organisation_size
,Organisation_exists_in_most_recent_packaging_data_submission
,Organisation_exists_in_most_recent_organisation_data_submission
,Organisation_visible_in_PowerBI_Packaging_reports
,Organisation_visible_in_PowerBI_Orgdata_reports
,Single_File_Submission_Packaging
,Single_File_Submission_Orgdata
,Reported_mandated_data_sets
,Organisation_soft_deleted
,[Household drinks containers-Aluminium (Kg)]
,[Household drinks containers-Aluminium (No.Units)]
,[Household drinks containers-Fibre Composite (Kg)]
,[Household drinks containers-Fibre Composite (No.Units)]
,[Household drinks containers-Glass (Kg)]
,[Household drinks containers-Glass (No.Units)]
,[Household drinks containers-Other (Kg)]
,[Household drinks containers-Other (No.Units)]
,[Household drinks containers-Paper / Card (Kg)]
,[Household drinks containers-Paper / Card (No.Units)]
,[Household drinks containers-Plastic (Kg)]
,[Household drinks containers-Plastic (No.Units)]
,[Household drinks containers-Steel (Kg)]
,[Household drinks containers-Steel (No.Units)]
,[Household drinks containers-Wood (Kg)]
,[Household drinks containers-Wood (No.Units)]
,[Small organisation packaging - all-Aluminium]
,[Small organisation packaging - all-Fibre Composite]
,[Small organisation packaging - all-Glass]
,[Small organisation packaging - all-Other]
,[Small organisation packaging - all-Paper / Card]
,[Small organisation packaging - all-Plastic]
,[Small organisation packaging - all-Steel]
,[Small organisation packaging - all-Wood]
,Reporting_Year
from Small_producer_recent_pom_org;