CREATE PROCEDURE [dbo].[sp_GetPaycalPomData_v2]
  @RelativeYear INT
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @start_dt DATETIME;
  DECLARE @batch_id INT;

  SELECT @batch_id = ISNULL(MAX(batch_id), 0) + 1
  FROM [dbo].[batch_log]

  SET @start_dt = GETDATE();

  BEGIN
-- candidate_pom_files: accepted POM files submitted for a given organisation/submitter/period.
                -- DISTINCT collapses rpd.Pom's per-line-item rows down to one row per file (every selected
                -- column here is a per-file attribute, not a per-line-item one).
                WITH candidate_pom_files AS (
                    SELECT DISTINCT
                      p.organisation_id
                    , sofs.FileName
                    , p.submission_period
                    , sofs.submissionperiod AS submission_period_desc
                    , sofs.SubmissionPeriodYear AS Submission_Period_Year
                    , COALESCE(sofs.ComplianceSchemeId, o.ExternalId) AS submitter_id
                    , sofs.CreatedDateTime
                    , sofs.Is_resubmitted_POM_identifier
                    FROM rpd.Pom p
                    INNER JOIN rpd.Organisations o
                      ON  o.ReferenceNumber = p.organisation_id
                      -- Excluding soft deleted organisations
                      AND o.IsDeleted = 0
                    INNER JOIN dbo.t_submitted_pom_org_file_status sofs
                      ON  sofs.filetype         = 'Pom'
                      AND sofs.FileName         = p.FileName
                      AND sofs.Regulator_Status = 'Accepted'
                      AND sofs.SubmissionPeriodYear = @RelativeYear - 1
                )
                -- Main selection of data
                SELECT
                  p.organisation_id
                , NULLIF(TRIM(p.subsidiary_id), '') AS subsidiary_id
                , p.submission_period
                , p.packaging_activity
                , p.packaging_type
                , p.packaging_class
                , p.packaging_material
                , p.packaging_material_weight
                , p.ram_rag_rating
                , p.packaging_material_subtype
                , cpf.submission_period_desc
                , cpf.submitter_id
                , cpf.FileName AS file_name
                , cpf.CreatedDateTime AS created_date_time
                , CAST(cpf.Is_resubmitted_POM_identifier AS bit) AS is_resubmission
                FROM rpd.POM p
                INNER JOIN candidate_pom_files cpf
                  ON  TRIM(p.FileName)    = TRIM(cpf.FileName)
                  AND cpf.organisation_id = p.organisation_id
                WHERE p.organisation_size = 'L'
                  AND (p.to_country IS NULL OR TRIM(p.to_country) = '')
                  AND p.organisation_id IS NOT NULL
                  AND LEFT(p.submission_period, 4) = (@RelativeYear - 1)

  END

  INSERT INTO [dbo].[batch_log]
    ([ID], [ProcessName], [SubProcessName], [Count], [start_time_stamp], [end_time_stamp], [Comments], [batch_id])
  SELECT
    (SELECT ISNULL(MAX(id), 1) + 1 FROM [dbo].[batch_log])
  , 'dbo.sp_GetPaycalPomDataV2'
  , ''
  , NULL
  , @start_dt
  , GETDATE()
  , ''
  , @batch_id;

END
