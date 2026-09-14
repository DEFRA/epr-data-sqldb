-- =============================================================================================
-- sp_GetPaycalPomDataByOrganisation
--
-- A copy of dbo.sp_GetPaycalPomData with two filters added:
--
--   @OrganisationId   restrict to a single organisation. Pass NULL for all, as the original does.
--   @RelativeYear     now nullable. Pass NULL for all years rather than one.
--
-- Every PayCal business filter is unchanged, so calling this with both new parameters NULL returns
-- what dbo.sp_GetPaycalPomData returns.
--
-- Note the parameters carry no default values. A dedicated SQL pool runs on the PDW engine, which
-- rejects defaults with "CREATE or ALTER PROCEDURE statement uses syntax or features that are not
-- supported in SQL Server PDW", so all three must be supplied on every call.
--
-- Unlike the original, this procedure does not write to dbo.batch_log. It is intended to be called
-- per request by an API rather than by a scheduled extract, and a write on every call is not
-- appropriate for that.
-- =============================================================================================
CREATE PROCEDURE [cdp].[sp_GetPaycalPomDataByOrganisation]
  @RelativeYear   INT
, @OrganisationId INT
, @CutOffDate     DATETIME
AS
BEGIN
  SET NOCOUNT ON;
  SET @CutOffDate = ISNULL(@CutOffDate, '9999-12-31');

  BEGIN
    ----Find latest Registration file with data submitted for a given organisation--
    --ST006
    WITH latest_accepted_registration AS (
      SELECT * FROM (
        SELECT
          sofs.filename
        , cd.organisation_id
        --ST004 Updated logic to determine the latest accepted file submission with data for a given organisation
        , row_number() over(
            partition by cd.organisation_id, coalesce(sofs.ComplianceSchemeId, o.ExternalId), sofs.SubmissionPeriod
            order by sofs.CreatedDateTime desc
        ) as latest_producer_accepted_record_per_SP
        , sofs.SubmissionPeriodYear as Submission_Period_Year
        FROM rpd.CompanyDetails cd
        INNER JOIN rpd.Organisations o
          on  o.ReferenceNumber    = cd.organisation_id
          --Excluding soft deleted organisations
          AND o.IsDeleted          = 0
          INNER JOIN dbo.t_submitted_pom_org_file_status sofs
            ON  sofs.filetype             =  'CompanyDetails'
            AND sofs.FileName             =  cd.FileName
            --ST007 Added Accepted Status to cater for resubmission registration files
            AND sofs.Regulator_Status     IN ('Granted','Accepted')
            AND sofs.SubmissionPeriodYear >  2024
            AND (sofs.IsResubmission_identifier = 0 OR sofs.CreatedDateTime <= @CutOffDate)
        -- NEW: restrict to one organisation as early as possible
        WHERE (@OrganisationId IS NULL OR cd.organisation_id = @OrganisationId)
      ) a
      WHERE latest_producer_accepted_record_per_SP = 1
    ),
    ----Find latest POM file with data submitted for a given organisation--
    latest_accepted_pom AS (
      SELECT * FROM (
        SELECT
          p.organisation_id
        , sofs.FileName
        , p.submission_period
        , sofs.submissionperiod as submission_period_desc
        --ST005 Updated logic to determine the latest accepted file submission with data for a given organisation
        , row_number() over(
            partition by p.organisation_id, coalesce(sofs.ComplianceSchemeId, o.ExternalId), sofs.SubmissionPeriod
            order by sofs.CreatedDateTime desc
        ) as latest_producer_accepted_record_per_SP
        , sofs.SubmissionPeriodYear as Submission_Period_Year
        , coalesce(sofs.ComplianceSchemeId, o.ExternalId) as submitter_id
        -- NEW: the organisation's name, taken from the join that is already here. Safe because
        -- rpd.Organisations is keyed on ReferenceNumber, so this cannot fan rows out.
        , o.Name as organisation_name
        FROM rpd.Pom p
        INNER JOIN rpd.Organisations o
          on  o.ReferenceNumber = p.organisation_id
          --Excluding soft deleted organisations
          AND o.IsDeleted = 0
        INNER JOIN dbo.t_submitted_pom_org_file_status sofs
          ON  sofs.filetype         =  'Pom'
          AND sofs.FileName         =  p.FileName
          AND sofs.Regulator_Status =  'Accepted'
          -- CHANGED: year is now optional
          AND (@RelativeYear IS NULL OR sofs.SubmissionPeriodYear = @RelativeYear - 1)
          AND (sofs.Is_resubmitted_POM_identifier = 0 OR sofs.CreatedDateTime <= @CutOffDate)
        -- NEW: restrict to one organisation as early as possible
        WHERE (@OrganisationId IS NULL OR p.organisation_id = @OrganisationId)
      ) a
      WHERE latest_producer_accepted_record_per_SP = 1
    ),
    -- Assign period flags for organisations
    organisation_period_flags AS (
      SELECT
        organisation_id
      , submitter_id
      , CAST(submission_period_year AS INT) AS submission_period_year
      , MAX(CASE
              WHEN CAST(submission_period_year AS INT) > 2024 AND RIGHT(submission_period, 3) = '-H1' THEN 1
              WHEN submission_period in ('2024-P1', '2024-P2', '2024-P3') THEN 1
              ELSE 0
            END) AS has_h1
      , MAX(CASE
              WHEN CAST(submission_period_year AS INT) > 2024 AND RIGHT(submission_period, 3) = '-H2' THEN 1
              WHEN submission_period = '2024-P4' THEN 1
              ELSE 0
            END) AS has_h2
      FROM latest_accepted_pom
      GROUP BY
        organisation_id
      , submitter_id
      , submission_period_year
    ),
    -- The following is to ensure we only consider orgs which have submitted two periods
    LatestAcceptedPomsWith2Period as (
      select pom.*
      from latest_accepted_pom pom
      inner join organisation_period_flags as periods
        on  pom.organisation_id        = periods.organisation_id
        and pom.submitter_id           = periods.submitter_id
        and pom.Submission_Period_Year = periods.Submission_Period_Year
      where has_h1 = 1
        and has_h2 = 1
    ),

    Latest_Org_Data_Selection AS (
      SELECT DISTINCT
        cd.organisation_id
      , lar.Submission_Period_Year -1 as Submission_Period_Year_minus_1
      FROM rpd.CompanyDetails cd
      INNER JOIN latest_accepted_registration lar
        ON  cd.filename          = lar.filename
        --Ensuring this is kept at a per org level of extraction, otherwise we would extract all data from the file
        --In latest_accepted_registration finding the latest file regardless of org size
        --Restricting here to those records where the organisation size is Large
        AND cd.Organisation_size = 'L'
        AND lar.organisation_id  = cd.organisation_id
        AND cd.organisation_id   IS NOT NULL
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
    , p.ram_rag_rating
    , p.packaging_material_subtype
    -- NEW: the reporting nation. Always populated, and required by the archive contract. It is a
    -- column on the row already being selected, so this adds no joins and no rows.
    , p.from_country
    , lap.submission_period_desc
    , lap.submitter_id
    -- NEW
    , lap.organisation_name
    FROM rpd.POM p
    INNER JOIN LatestAcceptedPomsWith2Period lap
      ON  trim(p.FileName)    = trim(lap.FileName)
      AND lap.organisation_id = p.organisation_id
      -- ST006 Join to latest registration data to ensure a registration is present for the associated pom data
    INNER JOIN Latest_Org_Data_Selection lods
      ON  lods.organisation_id                = p.organisation_id
      -- Additional criteria on the join to ensure the match is at a submission period year level
      AND lods.Submission_Period_Year_minus_1 = lap.Submission_Period_Year
    WHERE (
      p.packaging_type IN ('HH','CW','PB')
      -- HDC packaging_type - specifically restricted to just GL (Glass) materials--
      or (p.packaging_type = 'HDC' and p.packaging_material = 'GL')
    )
      and p.organisation_size = 'L'
      AND (p.to_country IS NULL OR trim(p.to_country) = '')
      AND p.organisation_id IS NOT NULL
      -- CHANGED: year is now optional
      AND (@RelativeYear IS NULL OR LEFT(p.submission_period,4) = (@RelativeYear - 1))
      -- NEW: final organisation filter
      AND (@OrganisationId IS NULL OR p.organisation_id = @OrganisationId)

  END
END
