CREATE VIEW [dbo].[v_PayCal_Pom_HH_CW]
AS WITH Most_recently_accepted_pom AS 
	(SELECT distinct
	c.[OrganisationId]	
	,c.[FileName]
	,c.[FileType]
	,c.submissionperiod as submission_period_desc
	,c.created
	--For a given Organisation, in a given submission period, finding the most recently accepted Pom file based on the submission date--
	,Row_Number() Over(Partition by c.organisationid, c.submissionperiod order by CONVERT(DATETIME, Substring(c.[created], 1, 23))  desc) as RowNumber
	FROM [rpd].[cosmos_file_metadata] c
	INNER JOIN [rpd].[SubmissionEvents] se on trim(se.fileid) = trim(c.fileid) and se.[type] = 'RegulatorPoMDecision' and se.Decision = 'Accepted'
	WHERE c.FileType = 'Pom'
	--Comment below can be used to run this sub query in isolation and understand the row numbering
	--order by organisationid, submissionperiod, rownumber, filename
	)
SELECT 
p.organisation_id,
p.subsidiary_id,
p.submission_period,
--c.submissionperiod as submission_period,
p.packaging_activity,
p.packaging_type,
p.packaging_class,
p.packaging_material,
p.packaging_material_weight,
mrap.submission_period_desc
FROM
rpd.POM p
INNER JOIN Most_recently_accepted_pom mrap ON trim(p.FileName) = trim(mrap.FileName) 
AND mrap.RowNumber = 1
WHERE p.packaging_type IN ('HH','CW') and Organisation_size = 'L' AND to_country IS NULL;