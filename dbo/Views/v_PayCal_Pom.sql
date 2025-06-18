CREATE VIEW [dbo].[v_PayCal_Pom]
AS WITH Most_recently_accepted_pom AS(
/*****************************************************************************************************************
	History:
	Created 2024-10-04:ST001:425541: Created initial version of the view based on the logic we had in pyspark notebook
	Updated 2024-10-09: YM001: 442375: Additional columns added:
										packaging_type
										packaging_class
										load_ts
	Updated 2024-10-10: ST001: 442376: Additional packaging_type to be extracted and additional filtering added
										'HH' (household) added
										'CW' (consumer waste) added 
										Additionally only bringing records where the to_country field is blank/null
	Updated 2024-10-24: ST002: 457711: Added submission_period_desc column
	Updated 2025-01-08: ST003: 492191: Added HDC & PB in paycal extract
	Updated 2025-01-24: YM002: 491690: Changed query to bring through PB as an new packaging_type and limit the materials brought through for HDC to just Glass:
										'PB' for all packaging materials
										'HDC' for just packaging_material = 'GL' (Glass)
										This required splitting out to 2 queries that we union together
	Updated 2025-02-19: ST004: 510600: Added null validation to OrganisationId field to ensure no records with null come through


 *****************************************************************************************************************/	
SELECT distinct
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
WHERE p.packaging_type IN ('HH','CW','PB') 
and Organisation_size = 'L' 
AND to_country IS NULL
AND p.organisation_id IS NOT NULL

UNION ALL

--HDC packaging_type - specifically restricted to just GL (Glass) materials--
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
WHERE p.packaging_type = 'HDC' 
and p.packaging_material = 'GL' 
and Organisation_size = 'L' 
AND to_country IS NULL
AND p.organisation_id IS NOT NULL;