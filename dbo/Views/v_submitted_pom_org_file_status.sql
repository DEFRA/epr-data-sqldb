CREATE VIEW [dbo].[v_submitted_pom_org_file_status] AS With
 
/****************************************************************************************************************************
	History:
 
	Updated: 2025-01-27:	SN001:	Ticket - 500601:	Additional SQL added to v_submitted_pom_org_file_status capture status of records.  
	Updated: 2025-01-29:	SN002:	Ticket - 500408:	Additonal SQL required to get correct sumbission date for New Regulator process
														Additonal Type to identify path of data (Reg/Org) JourneyType 
															1= Organisation/Existing, 2=New/Reglulator
														Change Status From 'Accpeted' to 'Granted' for New path.  
														Rejected to Refused.. Commented out Implementation data TBC
	
******************************************************************************************************************************/
RegSubDate As 
(
	Select
		 se.SubmissionId
		,se.ApplicationReferenceNumber
		,se.created  
		,se.[Type]
		,RowNo						= Row_Number() Over(Partition By se.SubmissionId Order By se.created Asc)
	From
		rpd.SubmissionEvents		se
	Where
		se.[type] in ('RegistrationApplicationSubmitted') And se.ApplicationReferenceNumber is not null
),
se As (

	Select
		 cfm.FileId
		,se.SubmissionId
		,se.AppReferenceNumber
		,Decision_Date					= se.[created]   
		,Regulator_Status				= se.[Decision] 
		,Regulator_Rejection_Comments	= se.[Comments] 
		,RejectionComments				= ''  --not represented in Cosmos DB
		,se.[Type]
		,se.[UserId]
		,Created	= NULL									/*** SN002: Added 500408 -SubmissionDate ***/
		,RegistrationType					= 1		/*** SN002: Added 500408 ***/
	From
		rpd.cosmos_file_metadata	cfm
	Left Join
		rpd.SubmissionEvents		se
			on cfm.FileId = se.FileId
	Where
		se.[type] in ('RegulatorPoMDecision', 'RegulatorRegistrationDecision')
	
	/*** SN001: Added: New Entries since change in Application  ***/
	Union
	Select
		 cfm.FileId
		,se.SubmissionId
		,se.AppReferenceNumber
		,Decision_Date					= se.[created] 
		,Regulator_Status				= Case se.[Decision] /*** SN002: Added 500408 ***/
											When 'Accepted' Then 'Granted'
											/*** When 'Rejected' Then 'Refused'   SN002: Implementation TBC 500408 ***/
											Else se.[Decision]
										 End 
		,Regulator_Rejection_Comments	= se.[Comments] 
		,RejectionComments				= ''  --not represented in Cosmos DB
		,se.[Type]
		,se.[UserId]
		,rsd.Created						/*** SN002: Added 500408 -- SubmissionDate ***/
		,RegistrationType					= 2		/*** SN002: Added 500408 ***/
	From
		rpd.cosmos_file_metadata	cfm
	Left Join
		rpd.SubmissionEvents		se
			on cfm.SubmissionId = se.SubmissionId
	Left Join
		RegSubDate					rsd
			on se.SubmissionId = rsd.SubmissionId And rsd.RowNo=1
	Where
		se.[type] in ('RegulatorRegistrationDecision') And se.AppReferenceNumber is not null
	/*** SN001: Added: New Entries since change in Application  ***/
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
		,se.Decision_Date
		,se.Regulator_Status
		,'' AS [RegulatorDecision] --not represented in Cosmos DB
		,ISNULL(p.[FirstName],'') +' '+ ISNULL(p.[LastName],'') as Regulator_User_Name
		,se.Regulator_Rejection_Comments
		,'' AS [RejectionComments] --not represented in Cosmos DB
		,se.[type]
		,se.[UserId]
		,Row_Number() Over(Partition by c.[filename] order by se.Decision_Date desc) as RowNumber
		,se.Created
		,se.RegistrationType
FROM [rpd].[cosmos_file_metadata] c
  Left Join se on se.fileid = c.fileid 
				/*** SN:001 Removed: and se.[type] in ('RegulatorPoMDecision', 'RegulatorRegistrationDecision') ***/
  Left Join [rpd].[Users] u on se.[Userid] = u.[userid] and u.[isdeleted] = 0
  Left Join rpd.[persons] p on u.[id] =p.[userid] and p.[isdeleted] = 0
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
 from submitted_file_status sfs
where sfs.[RowNumber] = 1;