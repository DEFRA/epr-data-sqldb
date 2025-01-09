CREATE VIEW [dbo].[v_CrossValidation_FileDetails_ORG]
AS Select
/*****************************************************************************************************************
	History:

	Created 2024-07-18: SN000: File Details for ORG 
									Ticket 404904,412664 (Crosss Validation)
	
	Updated 2024-07-25: SN001: ComplianceYear Added


*****************************************************************************************************************/
	 FileId
	,FileType
	,DisplayFilenameTS
	,ComplianceSchemeName
	,CS_or_DP
	,SubmissionPeriod
	,ComplianceYear
	,LatestFileBySubmissionPeriod
	,Regulator_Status
From
	v_CrossValidation_FileDetails_Main
Where
	FileType='ORG';