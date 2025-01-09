CREATE PROC [dbo].[CrossValidation] @CS_or_DP [nvarchar](50),@PomFileName1 [nvarchar](4000),@OrgFileName1 [nvarchar](4000) AS
BEGIN

 /*****************************************************************************************************************
	History:

	Created 2024-07-23: SN000:	Colate and compare Organisation and POM file details for cross validation report. 
								Ticket 412664 (Crosss Validation)
	
	Updated 2024-07-24: SN001:	Logic added to compare only latest POM and ORG file if 'Direct Producer' selected
	Updated 2024-07-24: SN002:	Changed Submission Year to ComplianceYear
	Updated 2025-01-07: YM003:  Changing the name of the table dbo.v_412664_FileDetails_ORG to [dbo].[v_412664_Org_Data_YM] as this is the correct one


 *****************************************************************************************************************/

IF 	@CS_or_DP in ('DP', 'Direct Producer')  /** SN001: Added **/
BEGIN
	exec dbo.CrossValidationGetLatestFile 'POM', @PomFileName1 OUTPUT;
	exec dbo.CrossValidationGetLatestFile 'ORG', @OrgFileName1 OUTPUT;
	/*
	Set @PomFileName2	= '';
	Set @OrgFileName2	= '';
	*/
END
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
		/*** Org Data ***/
		,org.organisation_id
		,org.subsidiary_id
		,org.organisation_name
		,org.Scheme_Name
		,org.Org_Sub_Type
		,org.Single_or_Group
		,org.Registration_Submission_Period
		,org.Registration_Status
		,org.Registration_Submission_date
		,org.Brand_owner
		,org.Packer_filler
		,org.Importer
		,org.Distributor
		,org.Service_provider
		,org.Online_market_place
		,org.Seller
		,org.meet_reporting_requirements_flag
		,org.liable_for_disposal_costs_flag
		/*** POM Data ***/
		,POM_Organisation_Id	= pom.organisation_id
		,pom.subsidiary_Id
		,pom.organisation_size
		,pom.[FileName]
		,pom.SubmissionPeriod_PackagingDataFile
		,pom.Packaging_Data_Status
		,pom.SubmissionDate_PackagingDataFile
		,pom.BrandOwner
		,pom.Importer
		,pom.PackerFiller
		,pom.ServiceProvider
		,pom.Distributor
		,pom.OnlineMktplace
		,pom.rn
	From
		dbo.v_CrossValidation_FileDetails_Main	fd
	Left Join
		dbo.v_CrossValidation_FileDetails_ORG	org
			on fd.FileId = org.FileId
	Left Join
		dbo.v_CrossValidation_FileDetails_POM		pom
			on fd.FileName_Guid = pom.[Filename]
	Where
		fd.DisplayFilenameTS In ( @PomFileName1, @OrgFileName1 /*, @PomFileName2, @OrgFileName2 */ ) 
END