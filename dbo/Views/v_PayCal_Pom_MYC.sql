CREATE VIEW [dbo].[v_PayCal_Pom_MYC] AS
/*****************************************************************************************************************
  History:
  Created 2024-10-04: ST001: 425541: Created initial version of the view based on the logic we had in pyspark notebook
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
  Updated 2025-12-10: EPRC93: Creating a new version of v_PayCal_Pom view to include SubmitterID
  Updated 2025-12-19: EPRC93: Filter for poms with both H1 and H2 (or P4 and one of P1,P2,P3 for 2024) periods
 *****************************************************************************************************************/
WITH
P1P4Table as (
  select '2024-P1' as period
  union
  select '2024-P4' as period
),
P2P4Table as (
  select '2024-P2' as period
  union
  select '2024-P4' as period
),
P3P4Table as (
  select '2024-P3' as period
  union
  select '2024-P4' as period
),
-- this will need extending for future years
H1H2Table as (
  select '2025-H1' as period
  union
  select '2025-H2' as period
  union
  select '2026-H1' as period
  union
  select '2026-H2' as period
),

AllPeriodsTable as (
  select * from P1P4Table
  union
  select * from P2P4Table
  union
  select * from P3P4Table
  union
  select * from H1H2Table
),
  ----Find latest Registration file with data submitted for a given organisation--
  --ST006
latest_accepted_registration AS (
  SELECT * FROM (
    SELECT DISTINCT
      cfm.filename
    , cd.organisation_id
      --ST004 Updated logic to determine the latest accepted file submission with data for a given organisation
    , row_number() over(
        partition by cd.organisation_id, coalesce(cfm.ComplianceSchemeId, o.ExternalId), cfm.SubmissionPeriod
        order by cfm.created desc
      ) as latest_producer_accepted_record_per_SP
    , Right(dbo.udf_DQ_SubmissionPeriod(cfm.SubmissionPeriod),4) as Submission_Period_Year
    , sofs.Regulator_Status
    FROM [rpd].[CompanyDetails] cd
    INNER JOIN rpd.Organisations o
      on o.ReferenceNumber = cd.organisation_id
      --Excluding soft deleted organisations
      AND o.IsDeleted = 0
    INNER JOIN [rpd].[cosmos_file_metadata] cfm
      on cfm.FileName = cd.FileName
      --ST003 Restricting the extraction to just Registration files (Excluding older Org type files)
      AND Right(dbo.udf_DQ_SubmissionPeriod(cfm.SubmissionPeriod),4) > 2024
      -- Only considering Granted files--
    INNER JOIN dbo.v_submitted_pom_org_file_status sofs
      ON sofs.cfm_fileid = cfm.fileid
      AND sofs.filetype = 'CompanyDetails'
      --ST007 Added Accepted Status to cater for resubmission registration files
      AND sofs.Regulator_Status IN ('Granted','Accepted','Cancelled')
  ) a
  WHERE latest_producer_accepted_record_per_SP = 1
    AND Regulator_Status <> 'Cancelled'
),
 ----Find latest POM file with data submitted for a given organisation--
latest_accepted_pom AS (
  SELECT * FROM (
    SELECT
      p.organisation_id
    , cfm.[FileName]
    , p.submission_period
    , cfm.submissionperiod as submission_period_desc
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
    INNER JOIN [rpd].[cosmos_file_metadata] cfm
      on cfm.FileName = p.FileName
    INNER JOIN dbo.v_submitted_pom_org_file_status sofs ON sofs.cfm_fileid = cfm.fileid
      AND sofs.filetype = 'Pom'
      AND sofs.Regulator_Status = 'Accepted'
  ) a
  WHERE latest_producer_accepted_record_per_SP = 1
),

-- The following is to ensure we only consider orgs which have submitted two periods
OrgsWithBothP1P4 as (
  select organisation_id, submitter_id, Submission_Period_Year
  from latest_accepted_pom
  where submission_period in (select period from P1P4Table)
  group by organisation_id, submitter_id, Submission_Period_Year
  having count(distinct submission_period) = (select count(*) from P1P4Table)
),
OrgsWithBothP2P4 as (
  select organisation_id, submitter_id, Submission_Period_Year
  from latest_accepted_pom
  where submission_period in (select period from P2P4Table)
  group by organisation_id, submitter_id, Submission_Period_Year
  having count(distinct submission_period) = (select count(*) from P2P4Table)
),
OrgsWithBothP3P4 as (
  select organisation_id, submitter_id, Submission_Period_Year
  from latest_accepted_pom
  where submission_period in (select period from P3P4Table)
  group by organisation_id, submitter_id, Submission_Period_Year
  having count(distinct submission_period) = (select count(*) from P3P4Table)
),
OrgsWithBothH1H2 as (
  select organisation_id, submitter_id, Submission_Period_Year
  from latest_accepted_pom
  where submission_period in (select period from H1H2Table)
  group by organisation_id, submitter_id, Submission_Period_Year
  having count(distinct submission_period) = (select count(*) from H1H2Table)
),
OrgsWith2Periods as (
  select organisation_id, submitter_id, Submission_Period_Year from OrgsWithBothP1P4
  union
  select organisation_id, submitter_id, Submission_Period_Year from OrgsWithBothP2P4
  union
  select organisation_id, submitter_id, Submission_Period_Year from OrgsWithBothP3P4
  union
  select organisation_id, submitter_id, Submission_Period_Year from OrgsWithBothH1H2
),

LatestAcceptedPomsWith2Period as (
  select pom.*
  from latest_accepted_pom pom
  inner join OrgsWith2Periods as periods
    on  pom.organisation_id = periods.organisation_id
    and pom.submitter_id = periods.submitter_id
    and pom.Submission_Period_Year = periods.Submission_Period_Year
),

--ST006
Latest_Org_Data_Selection AS (
  SELECT DISTINCT
    cd.organisation_id
  , lar.Submission_Period_Year -1 as Submission_Period_Year_minus_1
  FROM rpd.CompanyDetails cd
  INNER JOIN latest_accepted_registration lar
    ON cd.filename = lar.filename
    --Ensuring this is kept at a per org level of extraction, otherwise we would extract all data from the file
    --In latest_accepted_registration finding the latest file regardless of org size
    --Restricting here to those records where the organisation size is Large
    AND cd.Organisation_size = 'L'
    AND lar.organisation_id = cd.organisation_id
    AND cd.organisation_id IS NOT NULL
    AND cd.organisation_name IS NOT NULL
)

-----------------------------
-----Main Selection of Data--
-----------------------------
SELECT
  p.organisation_id
, NULLIF(trim(p.subsidiary_id), '') as subsidiary_id
, p.submission_period
, p.packaging_activity
, p.packaging_type
, p.packaging_class
, p.packaging_material
, p.packaging_material_weight
, lap.submission_period_desc
, lap.submitter_id
FROM rpd.POM p
INNER JOIN LatestAcceptedPomsWith2Period lap
  ON trim(p.FileName) = trim(lap.FileName)
  AND lap.organisation_id = p.organisation_id
-- ST006 Join to latest registration data to ensure a registration is present for the associated pom data
INNER JOIN Latest_Org_Data_Selection lods
  ON lods.organisation_id = p.organisation_id
  -- Additional criteria on the join to ensure the match is at a submission period year level
  AND lods.Submission_Period_Year_minus_1 = lap.Submission_Period_Year
WHERE (p.packaging_type IN ('HH','CW','PB')
       -- HDC packaging_type - specifically restricted to just GL (Glass) materials--
       or (p.packaging_type = 'HDC' and p.packaging_material = 'GL')
      )
  and p.organisation_size = 'L'
  AND (p.to_country IS NULL OR trim(p.to_country) = '')
  AND p.organisation_id IS NOT NULL
