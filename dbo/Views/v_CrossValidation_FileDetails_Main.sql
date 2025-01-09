CREATE VIEW [dbo].[v_CrossValidation_FileDetails_Main] AS With cfm As (
/*****************************************************************************************************************
	History:

	Created 2024-07-18: SN000: File Details including regulator status.  Use for dropdown list boxes in PBI 
									Ticket 404904,412664 (Crosss Validation)

	Updated 2024-MM-DD: SN001: CS_or_DP, FileType derivation Added
	Updated 2024-MM-DD: SN002: Added LatestSubmissionFile.  Latest POM, and ORG file
	Updated 2024-MM-DD: SN003: Added Function to format SubmissionPeriod.  Added ComplianceYear.   

*****************************************************************************************************************/
	Select
		 FileId
		,[FileName]
		,FileType
		,OriginalFileName
		,Created
		,Created_frmtDT			= Convert(datetime2,Replace(Replace(Created,'T', ' '),'Z', ' '))
		,SubmissionPeriod		= dbo.udf_DQ_SubmissionPeriod(SubmissionPeriod) /** SN:003 **/																
		,SubmissionType
		,TargetDirectoryName
		,ComplianceSchemeName	= cs.[Name]
	From 
		rpd.cosmos_file_metadata c
	Left Join
		rpd.ComplianceSchemes    cs 
			on c.ComplianceSchemeId = cs.ExternalId And cs.IsDeleted = 0
	Where
		TargetDirectoryName In ('Pom','CompanyDetails')
 ), 
 se As (
	Select 
		 FileId					= se.FileId
		,Regulator_Status		= se.Decision
	From 
		rpd.SubmissionEvents se
	Where
		[type] in ('RegulatorPoMDecision', 'RegulatorRegistrationDecision')
 ),
 src As (
	Select 
		 cfm.FileId
		,FileName_Guid			= cfm.[FileName]
		,OrigFileType			= cfm.FileType
		,FileType				= Case  cfm.FileType			/** SN001: Added **/
									When 'Pom' Then 'POM' 
									When 'CompanyDetails' Then 'ORG'
									Else 'N/A'
								 End
		,cfm.Created
		,cfm.OriginalFileName
		,DisplayFilenameTS		= Concat(cfm.OriginalFileName,'_',format(convert(datetime,cfm.Created_frmtDT,122),'yyyyMMddHHmiss'),'_',IsNull(se.Regulator_Status,'Pending'))
		,ComplianceSchemeName	= IsNull(cfm.ComplianceSchemeName,'N/A')
		,CS_or_DP				= Case When cfm.ComplianceSchemeName Is Null  /** SN001: Added **/
									Then 'Direct Producer' 
									Else 'Compliance Scheme'
								  End 
		,cfm.SubmissionPeriod
		,RelevantYear			= Right(Rtrim(cfm.SubmissionPeriod),4)+1 /** SN:003 **/
		,cfm.SubmissionType
		,cfm.TargetDirectoryName
		,Regulator_Status		= IsNull(se.Regulator_Status,'Pending')
	From
		cfm
	Left Join
		se on cfm.FileId = se.fileid
)
Select 
	 src.*
	,LatestFileBySubmissionPeriod	= Row_Number() Over(Partition By SubmissionPeriod Order By Created Desc )
	,LatestSubmissionFile			= Case When Row_Number() Over(Partition By FileType Order By Created Desc)=1 Then 1 Else 0 End /** SN:002 **/
		
From 
	src
Where 
	Regulator_Status in ('Pending','Accepted');