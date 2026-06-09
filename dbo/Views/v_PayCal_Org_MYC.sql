CREATE VIEW dbo.v_PayCal_Org_MYC AS
/*****************************************************************************************************************
  History:
	Created 2024-10-04: VK001:425541: Created initial version of the view based on the logic we had in pyspark notebook
	Updated 2024-10-24: ST002: 457711: Added submission_period_desc column
	Updated 2024-07-23: ST002: 510600: 	Added in additional null validation to OrganisationId and OrganisationName to ensure no null value records passed to PayCal
  Updated 2025-03-26: HA001: 522656: Added the field "trading_name" from CompanyDetails as per PayCal new requirements
	Updated 2025-07-10: ST003: 577281: Adding additional criteria to exclude data from Old Org files from coming through, ensuring data only from Registration files
	Updated 2025-07-15: ST004: 577281: Overhaul of the logic that determines the latest file including a join to v_submitted_pom_org_file_status to handle resubmission files granted status
	Updated 2025-07-16: ST005: 577281: Exclude Small Producers from the extraction as agreed on PayCal Surgery Session with DG3. Only Large Producers to be extracted
	Updated 2025-08-12: ST006: 601349: Added in 'Accepted' status alongside 'Granted' as resubmission files only ever go to Accepted
	Updated 2025-08-20: ST007: 603381: Removed filtering for Large organisations from CTE latest_accepted_record as we need to identify latest file regardless of org size
 *****************************************************************************************************************/
WITH latest_accepted_pom AS (
  SELECT * FROM (
    SELECT
        p.organisation_id
      , NULLIF(TRIM(p.subsidiary_id), '') AS subsidiary_id
      , p.submission_period
        --ST005 Updated logic to determine the latest accepted file submission with data for a given organisation
      , row_number() over(
          partition by p.organisation_id, coalesce(cfm.ComplianceSchemeId, o.ExternalId), cfm.SubmissionPeriod
          order by cfm.created desc
        ) as latest_producer_accepted_record_per_SP
      , Right(dbo.udf_DQ_SubmissionPeriod(cfm.SubmissionPeriod),4) as Submission_Period_Year
      , coalesce(cfm.ComplianceSchemeId, o.ExternalId) as submitter_id
    FROM rpd.Pom p
    INNER JOIN rpd.Organisations o
      on o.ReferenceNumber = p.organisation_id
      --Excluding soft deleted organisations
      AND o.IsDeleted = 0
      --Restricting to just accepted pom files
    INNER JOIN rpd.cosmos_file_metadata cfm
      on cfm.FileName = p.FileName
    INNER JOIN dbo.v_submitted_pom_org_file_status sofs ON sofs.cfm_fileid = cfm.fileid
      AND sofs.filetype = 'Pom'
      AND sofs.Regulator_Status = 'Accepted'
  ) a
  WHERE latest_producer_accepted_record_per_SP = 1
),

organisation_period_flags AS (
  SELECT
    organisation_id
  , subsidiary_id
  , submitter_id
  , CAST(submission_period_year AS INT) AS submission_period_year
  , CAST(
      CASE
        WHEN submission_period_year = 2024 AND
          MAX(CASE WHEN submission_period LIKE '%-P1' THEN 1 ELSE 0 END) = 1 OR
          MAX(CASE WHEN submission_period LIKE '%-P2' THEN 1 ELSE 0 END) = 1 OR
          MAX(CASE WHEN submission_period LIKE '%-P3' THEN 1 ELSE 0 END) = 1
        THEN 1
        WHEN submission_period_year > 2024 AND
          MAX(CASE WHEN submission_period LIKE '%-H1' THEN 1 ELSE 0 END) = 1
        THEN 1
        ELSE 0
      END AS BIT
  ) AS has_h1
  , CAST(
      CASE
        WHEN submission_period_year = 2024 AND
          MAX(CASE WHEN submission_period LIKE '%-P4' THEN 1 ELSE 0 END) = 1
        THEN 1
        WHEN submission_period_year > 2024 AND
          MAX(CASE WHEN submission_period LIKE '%-H2' THEN 1 ELSE 0 END) = 1
        THEN 1
        ELSE 0
      END AS BIT
    ) AS has_h2
    FROM latest_accepted_pom
    GROUP BY organisation_id, subsidiary_id, submitter_id, submission_period_year
)

SELECT
  ob.*
, COALESCE(opf.has_h1, CAST(0 AS BIT)) AS has_h1
, COALESCE(opf.has_h2, CAST(0 AS BIT)) AS has_h2
FROM dbo.t_producer_obligation_determination ob
LEFT JOIN organisation_period_flags opf
  ON opf.organisation_id = ob.organisation_id
  AND ISNULL(opf.subsidiary_id, '') = ISNULL(ob.subsidiary_id, '')
  AND ISNULL(opf.submitter_id, '') = ISNULL(ob.submitter_id, '')
  AND opf.submission_period_year = ob.submission_period_year;
GO
