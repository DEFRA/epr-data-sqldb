CREATE VIEW [dbo].[v_PayCal_Pom_myc]
AS WITH latest_accepted_registration AS(
/*****************************************************************************************************************
	History:
	Created 2024-10-04:	ST001: 425541: Created initial version of the view based on the logic we had in pyspark notebook
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
	Updated 2025-07-14: ST005: 577281: Overhaul of the logic that determines the latest file 
	Updated 2025-07-16: ST006: 577281: Additional CTE's: latest_accepted_registration and Latest_Org_Data_Selection + joins to the dataset to check pom data for valid registration in place
	Updated 2025-08-12: ST007: 601349: Added in 'Accepted' status alongside 'Granted' as resubmission registration files only ever go to Accepted
	Updated 2025-08-12: ST008: 601349: Added in additional criteria on check for to_country IS NULL to cater for pom files that have a blank space instead of null in production
	Updated 2025-08-19: ST009: 603939: Converting Subsidiary_id's that are 'Blank' to Nulls so that it matches org extraction due to bad front end validation. Blanks causing issues for the calculator application
	Updated 2025-08-20: ST010: 603381: Removal of filtering for Large organisations from CTE latest_accepted_registration and moving to other CTE Latest_Org_Data_Selection which selects data. Ensuring latest file found regardless of org size
 *****************************************************************************************************************/	
  ----Find latest Registration file with data submitted for a given organisation--
  --ST006
							SELECT * FROM (
											SELECT DISTINCT 
											cfm.filename,
											cfm.originalfilename,
											cfm.submissionperiod as submission_period_desc,
											o.id as Org_Id
											, cd.organisation_id 
											, cd.subsidiary_id
											, cd.organisation_name
											, cd.trading_name				
											, CONVERT(DATETIME,substring(cfm.Created,1,23)) as Submission_time
											--ST004 Updated logic to determine the latest accepted file submission with data for a given organisation 
											, row_number() over(partition by cd.organisation_id, cfm.SubmissionPeriod order by cfm.created desc) as latest_producer_accepted_record_per_SP
											,cd.leaver_code
											,cd.leaver_date
											,cd.organisation_change_reason
											,cd.joiner_date
											,Right(dbo.udf_DQ_SubmissionPeriod(cfm.SubmissionPeriod),4)as Submission_Period_Year
											FROM [rpd].[CompanyDetails] cd
											INNER JOIN rpd.Organisations o on o.ReferenceNumber = cd.organisation_id 
											--Excluding soft deleted organisations
											AND o.IsDeleted = 0
											INNER JOIN [rpd].[cosmos_file_metadata] cfm on cfm.FileName = cd.FileName 
											--ST003 Restricting the extraction to just Registration files (Excluding older Org type files)
											AND Right(dbo.udf_DQ_SubmissionPeriod(cfm.SubmissionPeriod),4) > 2024
											-- Only considering Granted files--
											INNER JOIN dbo.v_submitted_pom_org_file_status sofs ON sofs.cfm_fileid = cfm.fileid 
											AND sofs.filetype = 'CompanyDetails' 
											--ST007 Added Accepted Status to cater for resubmission registration files
											AND sofs.Regulator_Status IN ('Granted','Accepted')
											) a
									WHERE latest_producer_accepted_record_per_SP = 1
									)		
 ----Find latest POM file with data submitted for a given organisation--
, latest_accepted_pom AS(
						SELECT * FROM (
						SELECT
						cfm.[OrganisationId]	
						,cfm.[FileName]
						,cfm.[FileType]
						,cfm.submissionperiod as submission_period_desc
						,cfm.created
						--ST005 Updated logic to determine the latest accepted file submission with data for a given organisation
						, row_number() over(partition by p.organisation_id, cfm.SubmissionPeriod order by cfm.created desc) as latest_producer_accepted_record_per_SP
						,p.organisation_id
						--,o.isDeleted
						,Right(dbo.udf_DQ_SubmissionPeriod(cfm.SubmissionPeriod),4)as Submission_Period_Year
						,coalesce(cfm.ComplianceSchemeId, o.ExternalId) as submitter_id
						FROM rpd.Pom p
						INNER JOIN rpd.Organisations o on o.ReferenceNumber = p.organisation_id
						--Excluding soft deleted organisations
						AND o.IsDeleted = 0
						--Restricting to just accepted pom files
						INNER JOIN [rpd].[cosmos_file_metadata] cfm on cfm.FileName = p.FileName 
						INNER JOIN dbo.v_submitted_pom_org_file_status sofs ON sofs.cfm_fileid = cfm.fileid 
						AND sofs.filetype = 'Pom' 
						AND sofs.Regulator_Status = 'Accepted')
						a
						WHERE latest_producer_accepted_record_per_SP = 1
)

--ST006
, Latest_Org_Data_Selection AS(
								SELECT DISTINCT
								cd.organisation_id,
								lar.Submission_Period_Year -1 as Submission_Period_Year_minus_1
								FROM rpd.CompanyDetails cd
								INNER JOIN latest_accepted_registration lar ON cd.filename = lar.filename 
								--Ensuring this is kept at a per org level of extraction, otherwise we would extract all data from the file 
								--In latest_accepted_registration finding the latest file regardless of org size
								--Restricting here to those records where the organisation size is Large
								AND cd.Organisation_size = 'L' 
								AND lar.organisation_id = cd.organisation_id
								AND cd.organisation_id IS NOT NULL
								AND cd.organisation_name IS NOT NULL
							)

--SELECT * FROM Latest_Org_Data_Selection
-----------------------------
-----Main Selection of Data--
-----------------------------
SELECT 
p.organisation_id,
NULLIF(LTRIM(RTRIM(p.subsidiary_id)), '') as subsidiary_id,
p.submission_period,
p.packaging_activity,
p.packaging_type,
p.packaging_class,
p.packaging_material,
p.packaging_material_weight,
lap.submission_period_desc,
lap.submitter_id
FROM
rpd.POM p
INNER JOIN latest_accepted_pom lap ON trim(p.FileName) = trim(lap.FileName) AND lap.organisation_id = p.organisation_id
--ST006 Join to latest registration data to ensure a registration is present for the associated pom data
INNER JOIN Latest_Org_Data_Selection lods ON lods.organisation_id = p.organisation_id
--Additional criteria on the join to ensure the match is at a submission period year level
AND lods.Submission_Period_Year_minus_1 = lap.Submission_Period_Year
WHERE p.packaging_type IN ('HH','CW','PB') 
and Organisation_size = 'L' 
AND (to_country IS NULL OR  LTRIM(RTRIM(to_country)) = '')
AND p.organisation_id IS NOT NULL

UNION ALL

--HDC packaging_type - specifically restricted to just GL (Glass) materials--
SELECT 
p.organisation_id,
NULLIF(LTRIM(RTRIM(p.subsidiary_id)), '') as subsidiary_id,
p.submission_period,
p.packaging_activity,
p.packaging_type,
p.packaging_class,
p.packaging_material,
p.packaging_material_weight,
lap.submission_period_desc,
lap.submitter_id
FROM
rpd.POM p
INNER JOIN latest_accepted_pom lap ON trim(p.FileName) = trim(lap.FileName) AND lap.organisation_id = p.organisation_id
-- ST006 Join to latest registration data to ensure a registration is present for the associated pom data
INNER JOIN Latest_Org_Data_Selection lods ON lods.organisation_id = p.organisation_id
--Additional criteria on the join to ensure the match is at a submission period year level
AND lods.Submission_Period_Year_minus_1 = lap.Submission_Period_Year
WHERE p.packaging_type = 'HDC' 
and p.packaging_material = 'GL' 
and Organisation_size = 'L' 
AND (to_country IS NULL OR  LTRIM(RTRIM(to_country)) = '')
AND p.organisation_id IS NOT NULL;
