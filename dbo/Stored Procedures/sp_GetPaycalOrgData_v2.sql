CREATE PROCEDURE [dbo].[sp_GetPaycalOrgData_v2]
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

 -- candidate_registration_files: join source tables, deduplicate to one row per file.
                WITH candidate_registration_files AS (
                    SELECT DISTINCT
                        cd.FileName,
                        cd.organisation_id,
                        sofs.SubmissionPeriodYear                       AS submission_period_year,
                        COALESCE(sofs.ComplianceSchemeId, o.ExternalId) AS submitter_id,
                        sofs.CreatedDateTime,
                        sofs.Regulator_Status,
                        sofs.IsResubmission_identifier
                    FROM rpd.CompanyDetails cd
                    INNER JOIN rpd.Organisations o
                        ON o.ReferenceNumber = cd.organisation_id
                    INNER JOIN dbo.t_submitted_pom_org_file_status sofs
                        ON sofs.FileName = cd.FileName
                       AND sofs.FileType = 'CompanyDetails'
                       AND sofs.Regulator_Status IN ('Granted', 'Accepted', 'Cancelled')
                    WHERE o.IsDeleted = 0
                )
                -- Main selection of data: join back to CompanyDetails, filter to large orgs.
                SELECT
                    crf.FileName AS file_name,
                    crf.organisation_id,
                    cd.subsidiary_id,
                    crf.submitter_id,
                    cd.organisation_name,
                    cd.trading_name,
                    cd.leaver_code AS status_code,
                    cd.joiner_date,
                    cd.leaver_date,
                    crf.submission_period_year,
                    crf.Regulator_Status AS regulator_status,
                    crf.CreatedDateTime AS created_date_time,
                    crf.IsResubmission_identifier AS is_resubmission
                FROM candidate_registration_files crf
                INNER JOIN rpd.CompanyDetails cd
                    ON  cd.organisation_id = crf.organisation_id
                    AND cd.FileName = crf.FileName
                WHERE cd.organisation_size = 'L'
                  AND cd.organisation_id IS NOT NULL
                  AND cd.organisation_name IS NOT NULL
                  AND crf.submission_period_year = @RelativeYear;

  END

  INSERT INTO [dbo].[batch_log]
    ([ID], [ProcessName], [SubProcessName], [Count], [start_time_stamp], [end_time_stamp], [Comments], [batch_id])
  SELECT
    (SELECT ISNULL(MAX(id), 1) + 1 FROM [dbo].[batch_log])
  , 'dbo.sp_GetPaycalOrgDataV2'
  , ''
  , NULL
  , @start_dt
  , GETDATE()
  , ''
  , @batch_id;

END
