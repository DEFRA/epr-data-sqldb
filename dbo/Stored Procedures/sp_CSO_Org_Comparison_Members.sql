CREATE PROC [dbo].[sp_CSO_Org_Comparison_Members] @CSOorganisation_id [INT],@SubmissionPeriod [NVARCHAR](100) AS
BEGIN
 -- Disable row count for performance
    SET NOCOUNT ON;
	DECLARE @NewFileName NVARCHAR(4000);
	DECLARE @OldFileName NVARCHAR(4000);

--CTE to find the latest Compliance Scheme Org File--
WITH latest_CSO_org_file AS 
	(SELECT distinct
	c.[OrganisationId]	
	,c.[FileName]
	,c.[FileType]
	,c.submissionperiod as submission_period_desc
	,c.created
	--For a given Organisation, in a given submission period, finding the most recently accepted org file based on the submission date--
	,Row_Number() Over(Partition by c.organisationid
	,c.submissionperiod 
	order by CONVERT(DATETIME, Substring(c.[created], 1, 23))  desc) as RowNumber
	FROM rpd.organisations o
	INNER JOIN [rpd].[cosmos_file_metadata] c ON c.organisationid = o.externalid AND FileType = 'CompanyDetails'
	WHERE o.referencenumber = @CSOorganisation_id
	AND c.submissionperiod = @SubmissionPeriod
		)

--From the CTE retrieve the filename of the latest file--
SELECT @NewFileName = Filename 
FROM latest_CSO_org_file lof
WHERE lof.RowNumber = 1;


--CTE to find the latest ACCEPTED Compliance Scheme Org File--
WITH latest_Accepted_CSO_org_file AS 
	(SELECT distinct
	c.[OrganisationId]	
	,c.[FileName]
	,c.[FileType]
	,c.submissionperiod as submission_period_desc
	,c.created
	--For a given Organisation, in a given submission period, finding the most recently accepted Pom file based on the submission date--
	,Row_Number() Over(Partition by c.organisationid
	, c.submissionperiod 
	order by CONVERT(DATETIME, Substring(c.[created], 1, 23))  desc) as RowNumber
	FROM rpd.organisations o
	INNER JOIN [rpd].[cosmos_file_metadata] c ON c.organisationid = o.externalid
	INNER JOIN [rpd].[submissionevents] se ON Trim(se.fileid) = Trim(c.fileid)
											AND se.[type] = 'RegulatorRegistrationDecision'
											AND se.decision = 'Accepted'
											AND Trim(c.filetype) = 'CompanyDetails'
	WHERE o.referencenumber = @CSOorganisation_id
	AND c.submissionperiod = @SubmissionPeriod
		)
--From the CTE retrieve the Filename of the identified file--
SELECT @OldFileName = Filename 
FROM latest_Accepted_CSO_org_file laof
WHERE laof.RowNumber = 1;





--ORG FILE COMPARISON
--Using the 2 identified files, compare to find the new members of the compliance scheme
 --New file (Latest submission)
 SELECT DISTINCT organisation_ID as New_Members_Org_IDs from rpd.companyDetails
 WHERE filename = @NewFileName
 EXCEPT
 --minus the OLD file (Latest accepted)
 SELECT DISTINCT organisation_ID as New_Members_Org_IDs from rpd.companyDetails
 WHERE filename = @OldFileName;

 END;