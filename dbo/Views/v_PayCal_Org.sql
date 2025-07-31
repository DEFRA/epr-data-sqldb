CREATE VIEW [dbo].[v_PayCal_Org] AS WITH latest_accepted_record AS(
/*****************************************************************************************************************
	History:
	Created 2024-10-04: VK001:425541: Created initial version of the view based on the logic we had in pyspark notebook
	Updated 2024-10-24: ST002: 457711: Added submission_period_desc column
	Updated 2024-07-23: ST002: 510600: 	Added in additional null validation to OrganisationId and OrganisationName to ensure no null value records passed to PayCal
    Updated 2025-03-26: HA001: 522656: Added the field "trading_name" from CompanyDetails as per PayCal new requirements
	Updated 2025-07-10: ST003: 577281: Adding additional criteria to exclude data from Old Org files from coming through, ensuring data only from Registration files 
	Updated 2025-07-15: ST004: 577281: Overhaul of the logic that determines the latest file including a join to v_submitted_pom_org_file_status to handle resubmission files granted status
	Updated 2025-07-16: ST005: 577281: Exclude Small Producers from the extraction as agreed on PayCal Surgery Session with DG3. Only Large Producers to be extracted
 *****************************************************************************************************************/

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
		FROM [rpd].[CompanyDetails] cd
		INNER JOIN rpd.Organisations o on o.ReferenceNumber = cd.organisation_id 
		--Excluding soft deleted organisations
		AND o.IsDeleted = 0
		INNER JOIN [rpd].[cosmos_file_metadata] cfm on cfm.FileName = cd.FileName 
		--ST003 Restricting the extraction to just Registration files (Excluding older Org type files)
		AND Right(dbo.udf_DQ_SubmissionPeriod(cfm.SubmissionPeriod),4) > 2024
		-- Only considering Granted files--
		INNER JOIN dbo.v_submitted_pom_org_file_status sofs ON sofs.cfm_fileid = cfm.fileid AND sofs.filetype = 'CompanyDetails' 
		AND sofs.Regulator_Status = 'Granted'
		--ST005 excluding Small Producers, only Large Producers extracted--
		WHERE		cd.Organisation_size = 'L' 
		--Filter to ensure only selecting the file where they are not a leaver (MYC) currently not in scope
		--AND leaver_code IS NULL	
		)


SELECT
cd.organisation_id,
cd.subsidiary_id,
cd.organisation_name,
cd.trading_name,
lar.submission_period_desc
FROM rpd.CompanyDetails cd
INNER JOIN latest_accepted_record lar ON cd.filename = lar.filename 
--Ensuring this is kept at a per org level of extraction, otherwise we would extract all data from the file 
AND lar.organisation_id = cd.organisation_id
--Making sure the latest record being joined to--
where latest_producer_accepted_record_per_SP = 1
AND cd.organisation_id IS NOT NULL
AND cd.organisation_name IS NOT NULL
AND cd.Organisation_size = 'L';