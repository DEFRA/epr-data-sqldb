CREATE VIEW [dbo].[v_extract_recent_pom_org_large_data] AS select 
/****************************************************************************************************************************
	History:
	Created: 2025-05-16:	YM001:	Ticket - 515337:	Masterscript - MasterScript - Master script to be split into Large producer master script and small producer master script
	Created: 2025-05-21:	YM002:	Ticket - 515336:	Masterscript - Addition of Transitional packaging Data in Large producer master script for 2024
******************************************************************************************************************************/
Org_ID
,Org_name
,CH_number
,Nation_of_enrolment
,Enrolment_date_time
,Enrolment_status
,Nation_of_Compliance_Scheme_regulator
,Packaging_data_submission_period
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
,Organisation_data_submission_period
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
,[Self-managed consumer waste-Aluminium]
,[Self-managed consumer waste-Fibre Composite]
,[Self-managed consumer waste-Glass]
,[Self-managed consumer waste-Other]
,[Self-managed consumer waste-Paper / Card]
,[Self-managed consumer waste-Plastic]
,[Self-managed consumer waste-Steel]
,[Self-managed consumer waste-Wood]
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
,[Total Household packaging-Aluminium]
,[Total Household packaging-Fibre Composite]
,[Total Household packaging-Glass]
,[Total Household packaging-Other]
,[Total Household packaging-Paper / Card]
,[Total Household packaging-Plastic]
,[Total Household packaging-Steel]
,[Total Household packaging-Wood]
,[Non-household drinks containers-Aluminium (Kg)]
,[Non-household drinks containers-Aluminium (No.Units)]
,[Non-household drinks containers-Fibre Composite (Kg)]
,[Non-household drinks containers-Fibre Composite (No.Units)]
,[Non-household drinks containers-Glass (Kg)]
,[Non-household drinks containers-Glass (No.Units)]
,[Non-household drinks containers-Other (Kg)]
,[Non-household drinks containers-Other (No.Units)]
,[Non-household drinks containers-Paper / Card (Kg)]
,[Non-household drinks containers-Paper / Card (No.Units)]
,[Non-household drinks containers-Plastic (Kg)]
,[Non-household drinks containers-Plastic (No.Units)]
,[Non-household drinks containers-Steel (Kg)]
,[Non-household drinks containers-Steel (No.Units)]
,[Non-household drinks containers-Wood (Kg)]
,[Non-household drinks containers-Wood (No.Units)]
,[Total Non-Household packaging-Aluminium]
,[Total Non-Household packaging-Fibre Composite]
,[Total Non-Household packaging-Glass]
,[Total Non-Household packaging-Other]
,[Total Non-Household packaging-Paper / Card]
,[Total Non-Household packaging-Plastic]
,[Total Non-Household packaging-Steel]
,[Total Non-Household packaging-Wood]
,[Self-managed organisation waste-Aluminium]
,[Self-managed organisation waste-Fibre Composite]
,[Self-managed organisation waste-Glass]
,[Self-managed organisation waste-Other]
,[Self-managed organisation waste-Paper / Card]
,[Self-managed organisation waste-Plastic]
,[Self-managed organisation waste-Steel]
,[Self-managed organisation waste-Wood]
,[Public binned-Aluminium]
,[Public binned-Fibre Composite]
,[Public binned-Glass]
,[Public binned-Other]
,[Public binned-Paper / Card]
,[Public binned-Plastic]
,[Public binned-Steel]
,[Public binned-Wood]
,[Reusable packaging-Aluminium]
,[Reusable packaging-Fibre Composite]
,[Reusable packaging-Glass]
,[Reusable packaging-Other]
,[Reusable packaging-Paper / Card]
,[Reusable packaging-Plastic]
,[Reusable packaging-Steel]
,[Reusable packaging-Wood]
/** YM001 515336 Transitional_packaging_unit addition **/
,[Transitional organisation packaging - all-Aluminium]
,[Transitional organisation packaging - all-Fibre Composite]
,[Transitional organisation packaging - all-Glass]
,[Transitional organisation packaging - all-Other]
,[Transitional organisation packaging - all-Paper / Card]
,[Transitional organisation packaging - all-Plastic]
,[Transitional organisation packaging - all-Steel]
,[Transitional organisation packaging - all-Wood]
,Reporting_Year
from dbo.t_extract_recent_pom_org_data a
where not exists 
(
	select 1
	from dbo.v_extract_recent_pom_org_small_data b
	where a.org_id = b.org_id
	and a.Reporting_Year=b.Reporting_Year
);