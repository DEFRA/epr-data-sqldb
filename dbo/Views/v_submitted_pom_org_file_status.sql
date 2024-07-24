CREATE VIEW [dbo].[v_submitted_pom_org_file_status] AS WITH submitted_file_status AS (
SELECT distinct
		c.[SubmissionId]
		,c.[RegistrationSetId]
		,c.[OrganisationId]	
		,c.[FileName]
		,c.[FileType]
		,c.[OriginalFileName]
		,c.[TargetDirectoryName]
		,se.[created]  AS Decision_Date
		,se.[Decision] AS Regulator_Status
		,'' AS [RegulatorDecision] --not represented in Cosmos DB
		,ISNULL(p.[FirstName],'') +' '+ ISNULL(p.[LastName],'') as Regulator_User_Name
		,se.[Comments]  AS Regulator_Rejection_Comments
		,'' AS [RejectionComments] --not represented in Cosmos DB
		,se.[type]
		,se.[UserId]
		,Row_Number() Over(Partition by c.[filename] order by se.[created]  desc) as RowNumber
  FROM [rpd].[cosmos_file_metadata] c
  lEFT JOIN [rpd].[SubmissionEvents] se on se.fileid = c.fileid and se.[type] in ('RegulatorPoMDecision', 'RegulatorRegistrationDecision')
  lEFT JOIN [rpd].[Users] u on se.[Userid] = u.[userid] and u.[isdeleted] = 0
  lEFT JOIN rpd.[persons] p on u.[id] =p.[userid] and p.[isdeleted] = 0
  
) 

select sfs.SubmissionId
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
 from submitted_file_status sfs
where sfs.[RowNumber] = 1;