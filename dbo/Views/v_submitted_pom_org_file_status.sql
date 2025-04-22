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
resubmission_ids as
(
select distinct ISNULL(IsResubmission,0) as IsResubmission_identifier, Fileid 
from rpd.SubmissionEvents
where Fileid is not null and IsResubmission is not null
),
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
)
,
RegSubDate As
/*** SN002: Added 501408 - Retrieves rows with regulator SubmissionDate values  Lastest type='RegistrationApplicationSubmitted' ***/
(
	Select
		 se.SubmissionId
		,se.ApplicationReferenceNumber
		,se.created 
		,se.[Type]
		,RowNo		= Row_Number() Over(Partition By se.SubmissionId Order By se.created Desc)
	From
		rpd.SubmissionEvents		se
	Where
		se.[type] in ('RegistrationApplicationSubmitted') And se.ApplicationReferenceNumber is not null
)

, 
se As (

	Select
		 cfm.FileId
		,se.SubmissionId
		,se.AppReferenceNumber
		,se.ApplicationReferenceNumber				/*** SN005: Added ***/
		,Decision_Date					= se.[created]   
		,Regulator_Status				= Case 
											When ISNULL(rid.IsResubmission_identifier,0) = 0 and se.[type] = 'RegulatorRegistrationDecision' and cfm.SubmissionPeriod not in ('January to June 2023','January to June 2024','July to December 2023','July to December 2024') and se.[Decision] = 'Accepted' Then 'Granted'
										    When ISNULL(rid.IsResubmission_identifier,0) = 0 and se.[type] = 'RegulatorRegistrationDecision' and cfm.SubmissionPeriod not in ('January to June 2023','January to June 2024','July to December 2023','July to December 2024') and se.[Decision] = 'Rejected' Then 'Refused' 
											Else se.[Decision]
										 End 
		,Regulator_Rejection_Comments	= se.[Comments] 
		,RejectionComments				= ''  --not represented in Cosmos DB
		,se.[Type]
		,se.[UserId]
		,cfm.Created as Created
		--,Created	= NULL							/*** SN002: Added 501408 - SubmissionDate ***/
		,RegistrationType					= 1		/*** SN002: Added 501408 - To allow logic in PowerBI Regulator_Status to be set to Pending ***/
		,se.registrationreferencenumber
		--,rid.IsResubmission_identifier
	From
		rpd.cosmos_file_metadata	cfm
	left join resubmission_ids rid on rid.fileid = cfm.fileid
	inner Join
		SubmissionEvents_updated		se
			on cfm.FileId = ISNULL(se.FileId,se.fileid_new) and se.[type] in ('RegulatorPoMDecision', 'RegulatorRegistrationDecision')
	--where cfm.SubmissionId = '10a15b92-57cf-48ec-885d-c170202d8933'
		
	
/*
	Union
	Select
		 cfm.FileId
		,se.SubmissionId
		,se.AppReferenceNumber
		,se.ApplicationReferenceNumber				/*** SN005: Added ***/
		,Decision_Date					= se.[created] 
		,Regulator_Status				= Case se.[Decision] /*** SN002: Added 501408 ***/
											When 'Accepted' Then 'Granted'
										    When 'Rejected' Then 'Refused' /***  SN002, YM001: Implementation TBC 501408 ,Rejected to Refused Status change***/
											Else se.[Decision]
										 End 
		,Regulator_Rejection_Comments	=  se.[Comments]					
		,RejectionComments				= ''  --not represented in Cosmos DB
		,se.[Type]
		,se.[UserId]
		,rsd.Created								/*** SN002: Added 501408 -- SubmissionDate ***/
		,RegistrationType				= 2			/*** SN002: Added 501408 - To allow logic in PowerBI Regulator_Status to be set to NULL ***/
		,se.registrationreferencenumber
	From
		rpd.cosmos_file_metadata	cfm
	Left Join
		SubmissionEvents_updated		se
			on cfm.FileId = ISNULL(se.FileId,se.fileid_new) 
	Left Join
		RegSubDate					rsd
			on se.SubmissionId = rsd.SubmissionId And rsd.RowNo=1
Where
se.[type] in ('RegulatorRegistrationDecision') And 
se.AppReferenceNumber is not null

*/
	union
	Select
		 cfm.FileId
		,se.SubmissionId
		,se.AppReferenceNumber
		,se.ApplicationReferenceNumber				/*** SN005: Added ***/
		,Decision_Date					= NULL /*** SN003: Commented out value causes confusion ***/ --se.[created] 
		,Regulator_Status = Case when se.[Decision] is null then 'Pending'
								else se.[Decision]
							END
		,Regulator_Rejection_Comments	= NULL /*** SN003: Commented out value causes confusion ***/ --se.[Comments] 
		,RejectionComments				= ''  --not represented in Cosmos DB
		,se.[Type]
		,se.[UserId]
		,rsd.Created								/*** SN002: Added 501408 -- SubmissionDate ***/
		,RegistrationType				= 2			/*** SN002: Added 501408 - To allow logic in PowerBI Regulator_Status to be set to NULL ***/
		,se.registrationreferencenumber
	From
		rpd.cosmos_file_metadata	cfm
	Left Join
		rpd.SubmissionEvents		se
			on cfm.SubmissionId = se.SubmissionId
	Left Join
		RegSubDate					rsd
			on se.SubmissionId = rsd.SubmissionId And rsd.RowNo=1
Where
se.[type] in ( 'RegistrationApplicationSubmitted') And se.ApplicationReferenceNumber is not null

)
,
Reg_set as
(
select distinct RegistrationSetId, Fileid
from [rpd].[SubmissionEvents]
where RegistrationSetId is not null and Fileid is not null
),
UploadedRegFiles as
(
	select rs.RegistrationSetId, ses.FileId, max(ses.Created) as uploaded_ts
	from [rpd].[Submissions] s
	inner join [rpd].[SubmissionEvents] ses on ses.SubmissionId = s.SubmissionId
	left join Reg_set rs on rs.Fileid = ses.FileId
	where s.SubmissionType = 'Registration'
	and reverse(substring(reverse(trim(s.SubmissionPeriod)),1,2)) in ('25','26','27','28')
	and ses.[Type] in ('Submitted')
	group by  rs.RegistrationSetId, ses.FileId
),
se_with_reg as
(
	select distinct se.*, Reg_set.RegistrationSetId
	from se
	left join Reg_set on Reg_set.fileid = se.fileid
),
submitted_file_status AS (
SELECT distinct
		 c.[SubmissionId]
		,c.[RegistrationSetId]
		,c.[OrganisationId]	
		,c.[FileName]
		,c.[FileType]
		,c.[OriginalFileName]
		,c.[TargetDirectoryName]
		,case when se.Regulator_Status is NULL and ugf.FileId is not NULL then ugf.uploaded_ts else se.Decision_Date end as Decision_Date
		,case when se.Regulator_Status is NULL and ugf.FileId is not NULL then 'Uploaded' else se.Regulator_Status end as Regulator_Status
		,'' AS [RegulatorDecision] --not represented in Cosmos DB
		,Regulator_User_Name = Case When RegistrationType=2 and Regulator_Status='Pending' Then NULL Else ISNULL(p.[FirstName],'') +' '+ ISNULL(p.[LastName],'') End
		,Regulator_Rejection_Comments = se.Regulator_Rejection_Comments
		,'' AS [RejectionComments] --not represented in Cosmos DB
		,se.[type]
		,se.[UserId]
		,Row_Number() Over(Partition by c.[filename] order by se.Decision_Date desc) as RowNumber
		,se.Created
		,se.RegistrationType
		,c.SubmissionPeriod
		,ApplicationReferenceNo		= Coalesce(se.AppReferenceNumber,se.ApplicationReferenceNumber,Null)		/*** SN005: Added ***/
		,se.registrationreferencenumber
FROM [rpd].[cosmos_file_metadata] c
  Left Join se on se.FileId = c.FileId 
  				/*** SN:001 Removed: and se.[type] in ('RegulatorPoMDecision', 'RegulatorRegistrationDecision') ***/
  Left Join [rpd].[Users] u on se.[Userid] = u.[userid] and u.[isdeleted] = 0
  Left Join rpd.[persons] p on u.[id] =p.[userid] and p.[isdeleted] = 0
  left join UploadedRegFiles ugf on ugf.RegistrationSetId = c.RegistrationSetId
  where c.FileType = 'Pom'

  union

SELECT distinct
		 c.[SubmissionId]
		,c.[RegistrationSetId]
		,c.[OrganisationId]	
		,c.[FileName]
		,c.[FileType]
		,c.[OriginalFileName]
		,c.[TargetDirectoryName]
		,case when se.Regulator_Status is NULL and ugf.FileId is not NULL then ugf.uploaded_ts else se.Decision_Date end as Decision_Date
		,case when se.Regulator_Status is NULL and ugf.FileId is not NULL then 'Uploaded' else se.Regulator_Status end as Regulator_Status
		,'' AS [RegulatorDecision] --not represented in Cosmos DB
		,Regulator_User_Name = Case When RegistrationType=2 and Regulator_Status='Pending' Then NULL Else ISNULL(p.[FirstName],'') +' '+ ISNULL(p.[LastName],'') End
		,Regulator_Rejection_Comments = se.Regulator_Rejection_Comments
		,'' AS [RejectionComments] --not represented in Cosmos DB
		,se.[type]
		,se.[UserId]
		,Row_Number() Over(Partition by c.[filename] order by se.Decision_Date desc) as RowNumber
		,se.Created
		,se.RegistrationType
		,c.SubmissionPeriod
		,ApplicationReferenceNo		= Coalesce(se.AppReferenceNumber,se.ApplicationReferenceNumber,Null)		/*** SN005: Added ***/
		,se.registrationreferencenumber
FROM [rpd].[cosmos_file_metadata] c
  Left join se_with_reg se on se.RegistrationSetId = c.RegistrationSetId
  				/*** SN:001 Removed: and se.[type] in ('RegulatorPoMDecision', 'RegulatorRegistrationDecision') ***/
  Left Join [rpd].[Users] u on se.[Userid] = u.[userid] and u.[isdeleted] = 0
  Left Join rpd.[persons] p on u.[id] =p.[userid] and p.[isdeleted] = 0
  left join UploadedRegFiles ugf on ugf.RegistrationSetId = c.RegistrationSetId
  where c.FileType <> 'Pom'

) 
select distinct sfs.SubmissionId
		,sfs.[RegistrationSetId]
		,sfs.[OrganisationId]
		,sfs.[FileName]
		,sfs.[FileType]
		,sfs.[OriginalFileName]
		,sfs.[TargetDirectoryName]
		,sfs.[Decision_Date]
		,sfs.[Regulator_Status]
		,sfs.[RegulatorDecision]
		,sfs.[Regulator_User_Name]
		,sfs.[Regulator_Rejection_Comments]
		,sfs.[RejectionComments]
		,sfs.[type]
		,sfs.[UserId]
		,sfs.[RowNumber]
		,sfs.Created
		,sfs.RegistrationType
		,sfs.SubmissionPeriod
		,sfs.ApplicationReferenceNo			/*** SN005: Added ***/
		,sfs.registrationreferencenumber
 from submitted_file_status sfs
where sfs.[RowNumber] = 1;