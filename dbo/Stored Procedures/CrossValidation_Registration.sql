CREATE PROC [dbo].[CrossValidation_Registration] @CS_or_DP [nvarchar](50),@RelevanYear [int] AS
BEGIN

 /*****************************************************************************************************************
	History:

	Created 2024-07-23: SN000:	Colate and compare Organisation and POM file details for cross validation report. 
								Ticket 412664 (Crosss Validation)
	
	Updated 2024-07-24: SN001:	Logic added to compare only latest POM and ORG file if 'Direct Producer' selected
	Updated 2024-07-24: SN002:	Changed Submission Year to ComplianceYear


 *****************************************************************************************************************/


	Select
		/*** File Data ***/
		 fd.FileName_Guid
		,fd.FileType
		,fd.OriginalFileName
		,fd.DisplayFilenameTS
		,fd.ComplianceSchemeName
		,fd.CS_or_DP
		,fd.SubmissionPeriod
		,fd.RelevantYear
		,fd.SubmissionType
		,fd.TargetDirectoryName
		,fd.LatestFileBySubmissionPeriod
		,fd.Regulator_Status
	From
		dbo.v_CrossValidation_FileDetails_Registration	fd
	Where
	    fd.CS_or_DP = @CS_or_DP and fd.RelevantYear = @RelevanYear
END