CREATE PROC [dbo].[CrossValidationGetLatestFile] @FileTYpe [nvarchar](50),@FileNname [nvarchar](4000) OUT AS
BEGIN
/*****************************************************************************************************************
	History:

	Created 2024-07-23: SN000:	This stored procudure get latest file (based on file type) to Colate and compare Organisation 
								and POM file details for cross validation report. 
								Ticket 412664 (Crosss Validation)
	
	Updated 2024-07-24: SN001: Logic added to compare only latest POM and ORG file if 'Direct Producer' selected

	Updated 2024-MM-DD: [Initials]002: Change Description

*****************************************************************************************************************/

	Select
		@FileNname = DisplayFilenameTS
	From
		dbo.v_CrossValidation_FileDetails_Main	src
	Where
		src.LatestSubmissionFile = 1 And src.FileType = @FileTYpe;
END