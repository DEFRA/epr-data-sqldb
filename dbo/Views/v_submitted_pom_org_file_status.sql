CREATE VIEW [dbo].[v_submitted_pom_org_file_status] AS With
/****************************************************************************************************************************
	History: 
 
	Updated: 2025-01-27:	SN001:	Ticket - 500601:	Additional SQL added to v_submitted_pom_org_file_status capture status of records.  
	Updated: 2025-01-29:	SN002:	Ticket - 501408:	Additonal SQL required to get correct sumbission date for New Regulator process
														Additonal Type to identify path of data (Reg/Org) JourneyType 
															1= Organisation/Existing, 2=New/Reglulator
														Change Status From 'Accpeted' to 'Granted' for New path.  
														Rejected to Refused.. Commented out Implementation data TBC

														RegistrationType added to allow IF/CASE statement logic in POwerBI 
														regulatorbrandwithpartner so new records show NULL not Pending.
	Updated: 2025-02-06:	YM001:	Ticket - 506054		Rejected to Refused Status change registration file for relevant_year 2025 onwards
	Updated: 2025-02-11:	YM002:	Ticket - 506055		Changing the decision as Pending from null for the 2nd submission under the ticket 506055
	Updated: 2025-02-18:	SN003:	Ticket - 510914		Remove values Comment, DecisionDate, User values for RegulatorRegistration 'Pending/Upload' rows
	Updated: 2025-03-19:	PM004:	Ticket - 512853		Bring the Registration file status as 'Uploaded' if not fully submitted in front end. This is the status before pending.
	Updated: 2025-03-24:	SN005:	Ticket - 520206		Add Application/App Reference Number to be passed to output for display on Power BI Report
	Updated: 2025-04-03:	RM006:	Ticket - 527578		Add registrationreferencenumber to be passed on to v_public_register_all_producers
******************************************************************************************************************************/
 
--Sub query to find the resubmission records
resubmission_ids as
(
select distinct ISNULL(IsResubmission,0) as IsResubmission_identifier, Fileid 
from rpd.SubmissionEvents
where Fileid is not null and IsResubmission is not null
),


--Find file id for the records that are missing fileid in decision records
null_fileid_decision_records as
(
select CONVERT(DATETIME,substring(Created,1,23)) as Created_ts , SubmissionEventId, SubmissionId
 from rpd.SubmissionEvents where type = 'RegulatorRegistrationDecision' 
 and fileid is null
 ),
 all_submitted_records as
 (
 select CONVERT(DATETIME,substring(Created,1,23)) as Created_ts, SubmissionEventId, SubmissionId, fileid
 from rpd.SubmissionEvents where type = 'Submitted' 
 ),
rank_list as
(
 select D.SubmissionId, D.SubmissionEventId/*, D.Created_ts, S.Created_ts*/, S.fileid as fileid_new
	, row_number() over(partition by D.SubmissionId, D.SubmissionEventId order by S.Created_ts desc) as RN
 from null_fileid_decision_records D
 inner join all_submitted_records S 
	on D.SubmissionId = S.SubmissionId
		and D.Created_ts >= S.Created_ts
),
final_result_set as
(
select distinct * from rank_list where RN = 1
),
SubmissionEvents_updated as
(
	select se.*, fs.fileid_new
	from rpd.SubmissionEvents se
	left join final_result_set fs on fs.SubmissionId = se.SubmissionId and fs.SubmissionEventId = se.SubmissionEventId
),


--Find fileid that are submitted
submitted_Fileids as
(
	select distinct Fileid as submitted_Fileid, SubmissionEventId as SubmissionEventId_of_submitted_record, SubmissionId as SubmissionId_of_submitted_record, CONVERT(DATETIME,substring(Created,1,23)) as Submitted_ts
	From rpd.SubmissionEvents where Type = 'Submitted' and Fileid is not null
),

--File file id matching to the RegistrationApplicationSubmitted
get_all_RegistrationApplicationSubmitted as
(
	select distinct sub.submitted_Fileid as app_submitted_Fileid, sub.SubmissionEventId_of_submitted_record
		, app_sub.SubmissionEventId as SubmissionEventId_of_application_submitted_record
		, CONVERT(DATETIME,substring(app_sub.Created,1,23)) as Submitted_ts
		, app_sub.ApplicationReferenceNumber
		, row_number() over(partition by app_sub.SubmissionId, app_sub.SubmissionEventId order by sub.Submitted_ts desc) as RN
	From rpd.SubmissionEvents app_sub
		 inner join submitted_Fileids sub 
			on sub.SubmissionId_of_submitted_record = app_sub.SubmissionId
				and CONVERT(DATETIME,substring(app_sub.Created,1,23)) >= sub.Submitted_ts 
	where app_sub.Type = 'RegistrationApplicationSubmitted' 
),
top_matching_og_get_all_RegistrationApplicationSubmitted as
(
	select * From get_all_RegistrationApplicationSubmitted where RN = 1
)

,res as (
		select distinct
				 cfm.[SubmissionId]
				,cfm.[RegistrationSetId]
				,cfm.[OrganisationId]	
				,cfm.[FileName]
				,cfm.[FileType]
				,cfm.[OriginalFileName]
				,cfm.[TargetDirectoryName]
				, se.created as Decision_Date
				, case when Right(dbo.udf_DQ_SubmissionPeriod(s.SubmissionPeriod),4) >= 2025 and ISNULL(rid.IsResubmission_identifier,0) = 0 and se.Decision = 'Accepted' Then 'Granted'
					   when Right(dbo.udf_DQ_SubmissionPeriod(s.SubmissionPeriod),4) >= 2025 and ISNULL(rid.IsResubmission_identifier,0) = 0 and se.Decision = 'Rejected' Then 'Refused'
					   when app_submitted.SubmissionEventId_of_application_submitted_record is not null and se.Decision is null then 'Pending'
					   when app_submitted.SubmissionEventId_of_application_submitted_record is null and se.Decision is null and Right(dbo.udf_DQ_SubmissionPeriod(s.SubmissionPeriod),4) >= 2025 then 'Uploaded'
					   when app_submitted.SubmissionEventId_of_application_submitted_record is null and se.Decision is null and Right(dbo.udf_DQ_SubmissionPeriod(s.SubmissionPeriod),4) < 2025  then 'Pending'
					   else se.Decision
					   end
					as Regulator_Status
				,'' AS [RegulatorDecision] --not represented in Cosmos DB
				, ISNULL(p.[FirstName],'') +' '+ ISNULL(p.[LastName],'') as Regulator_User_Name
				, se.Comments as Regulator_Rejection_Comments
				, '' as RejectionComments

				, case when se.[Type] is null 
							and SubmissionEventId_of_application_submitted_record is not null 
							then 'RegistrationApplicationSubmitted'
						when se.[Type] is null
							and sfs.SubmissionEventId_of_submitted_record is not null
							then 'Submitted'
						else se.[Type]
						end as [Type]
				, se.UserId
				, cfm.Created
				, case when Right(dbo.udf_DQ_SubmissionPeriod(s.SubmissionPeriod),4) >= 2025 and s.SubmissionType = 'Registration' then 2
					   when Right(dbo.udf_DQ_SubmissionPeriod(s.SubmissionPeriod),4) < 2025 then 1
						else NULL
						end
					as RegistrationType 
				,s.SubmissionPeriod
				, coalesce(app_submitted.ApplicationReferenceNumber,se.AppReferenceNumber) as ApplicationReferenceNo
				, se.registrationreferencenumber
				--Supporting columns
				, se.Decision as Original_Regulator_Status
		
				,s.SubmissionType
				, ISNULL(rid.IsResubmission_identifier,0) as IsResubmission_identifier
				, cfm.FileId as cfm_FileId
				, se.FileId
				, se.fileid_new
				, sfs.submitted_Fileid
				, sfs.SubmissionEventId_of_submitted_record
				, app_submitted.app_submitted_Fileid 
				, app_submitted.SubmissionEventId_of_application_submitted_record

		From rpd.cosmos_file_metadata cfm
		inner join rpd.Submissions s on s.SubmissionId = cfm.SubmissionId
		left Join
			SubmissionEvents_updated		se
				on cfm.FileId = ISNULL(se.FileId,se.fileid_new) 
					and se.[type] in ('RegulatorPoMDecision', 'RegulatorRegistrationDecision')
		left join resubmission_ids rid on cfm.fileid = rid.fileid 
		left join submitted_Fileids sfs on sfs.submitted_Fileid = cfm.fileid
		left join top_matching_og_get_all_RegistrationApplicationSubmitted app_submitted on app_submitted.app_submitted_Fileid = cfm.fileid
		Left Join [rpd].[Users] u on se.[Userid] = u.[userid] and u.[isdeleted] = 0
		Left Join rpd.[persons] p on u.[id] =p.[userid] and p.[isdeleted] = 0
		where cfm.FileType in ('CompanyDetails','Pom')
),

rank_on_res as
(
select  
	 *
	 ,row_number() over(partition by cfm_FileId order by Decision_Date desc, Created desc) as RowNumber
from res
),

cd_pom_result as 
(
	select * From rank_on_res where RowNumber = 1
)

select distinct pom_cd.SubmissionId, pom_cd.RegistrationSetId, pom_cd.OrganisationId, pom_cd.FileName, pom_cd.FileType, pom_cd.OriginalFileName, pom_cd.TargetDirectoryName, pom_cd.Decision_Date, pom_cd.Regulator_Status, pom_cd.RegulatorDecision, pom_cd.Regulator_User_Name, pom_cd.Regulator_Rejection_Comments, pom_cd.RejectionComments, pom_cd.Type, pom_cd.UserId, pom_cd.RowNumber, pom_cd.Created, pom_cd.RegistrationType, pom_cd.SubmissionPeriod, pom_cd.ApplicationReferenceNo, pom_cd.registrationreferencenumber, pom_cd.Original_Regulator_Status, pom_cd.SubmissionType, pom_cd.IsResubmission_identifier, pom_cd.cfm_FileId, pom_cd.FileId, pom_cd.fileid_new, pom_cd.submitted_Fileid, pom_cd.SubmissionEventId_of_submitted_record, pom_cd.app_submitted_Fileid, pom_cd.SubmissionEventId_of_application_submitted_record
from cd_pom_result pom_cd
union
select distinct cfm.SubmissionId, cfm.RegistrationSetId, cfm.OrganisationId, cfm.FileName, cfm.FileType, cfm.OriginalFileName, cfm.TargetDirectoryName, cp.Decision_Date, cp.Regulator_Status, cp.RegulatorDecision, cp.Regulator_User_Name, cp.Regulator_Rejection_Comments, cp.RejectionComments, cp.Type, cp.UserId, cp.RowNumber, cp.Created, cp.RegistrationType, cp.SubmissionPeriod, cp.ApplicationReferenceNo, cp.registrationreferencenumber, cp.Original_Regulator_Status, cp.SubmissionType, cp.IsResubmission_identifier, cp.cfm_FileId, cp.FileId, cp.fileid_new, cp.submitted_Fileid, cp.SubmissionEventId_of_submitted_record, cp.app_submitted_Fileid, cp.SubmissionEventId_of_application_submitted_record
From rpd.cosmos_file_metadata cfm
inner join cd_pom_result cp on cfm.RegistrationSetId = cp.RegistrationSetId
where cfm.FileType in ('Partnerships','Brands');