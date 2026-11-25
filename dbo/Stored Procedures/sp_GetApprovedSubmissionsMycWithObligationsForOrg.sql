CREATE PROCEDURE [dbo].[sp_GetApprovedSubmissionsMycWithObligationsForOrg]
    @PeriodYear [varchar](4),
    @ExternalId [varchar](max)
AS
BEGIN
    DECLARE @start_dt datetime;
    DECLARE @batch_id INT;

    SELECT @batch_id = ISNULL(MAX(batch_id), 0) + 1
    FROM [dbo].[batch_log];
    SET @start_dt = GETDATE();

    BEGIN
        SET NOCOUNT ON;

        DECLARE @RelevantYear varchar(4) = CAST(CAST(@PeriodYear AS int) + 1 AS varchar);
        DECLARE @RequestedExternalId uniqueidentifier = TRY_CONVERT(uniqueidentifier, @ExternalId);

        WITH LatestAcceptedPomFiles AS (
            SELECT
                FileId,
                Created
            FROM (
                SELECT
                    FileId,
                    Created,
                    ROW_NUMBER() OVER (PARTITION BY SubmissionId ORDER BY Created DESC) AS rn
                FROM rpd.SubmissionEvents
                WHERE Type = 'RegulatorPoMDecision'
                    AND Decision = 'Accepted'
                    AND FileId IS NOT NULL
            ) AS a
            WHERE a.rn = 1
        ),

        activeRpdOrgs AS (
            SELECT
                ExternalId,
                ReferenceNumber
            FROM rpd.Organisations
            WHERE IsDeleted = 0
        ),

        LatestAcceptedPoms AS (
            SELECT
                FileName,
                organisation_id,
                subsidiary_id,
                submission_period,
                submission_period_year,
                submitter_id,
                producer_id,
                submitter_type
            FROM (
                SELECT
                    cfm.FileName,
                    --ST005 Updated logic to determine the latest accepted file submission with data for a given organisation
                    ROW_NUMBER() OVER (
                        PARTITION BY
                            p.organisation_id,
                            NULLIF(TRIM(p.subsidiary_id), ''), -- important - sometimes is blank, sometimes is null
                            p.submission_period,
                            COALESCE(cfm.ComplianceSchemeId, o.ExternalId) -- keep alternative submissions... (especially submitter_type)
                        ORDER BY latest.created DESC
                    ) AS rn,
                    p.organisation_id,
                    NULLIF(TRIM(p.subsidiary_id), '') AS subsidiary_id,
                    p.submission_period,
                    RIGHT(dbo.udf_DQ_SubmissionPeriod(cfm.SubmissionPeriod), 4) AS submission_period_year,
                    COALESCE(cfm.ComplianceSchemeId, o.ExternalId) AS submitter_id,
                    COALESCE(NULLIF(TRIM(p.subsidiary_id), ''), CAST(p.organisation_id AS nvarchar(50))) AS producer_id,
                    CASE
                        WHEN NULLIF(TRIM(cfm.ComplianceSchemeId), '') IS NULL THEN 'DirectRegistrant'
                        ELSE 'ComplianceScheme'
                    END AS submitter_type
                FROM rpd.Pom AS p
                INNER JOIN activeRpdOrgs AS o
                    ON o.ReferenceNumber = p.organisation_id
                INNER JOIN rpd.cosmos_file_metadata AS cfm
                    ON cfm.FileName = p.FileName
                INNER JOIN LatestAcceptedPomFiles AS latest
                    ON latest.FileId = cfm.FileId
                WHERE p.organisation_size = 'L'
                    AND (
                        (
                            @PeriodYear = '2024'
                            AND p.submission_period IN (
                                CONCAT(@PeriodYear, '-P1'),
                                CONCAT(@PeriodYear, '-P2'),
                                CONCAT(@PeriodYear, '-P3'),
                                CONCAT(@PeriodYear, '-P4')
                            )
                        )
                        OR (
                            @PeriodYear > '2024'
                            AND p.submission_period IN (
                                CONCAT(@PeriodYear, '-H1'),
                                CONCAT(@PeriodYear, '-H2')
                            )
                        )
                    )
                    AND EXISTS (
                        SELECT 1
                        FROM rpd.Organisations AS producerOrg
                        WHERE producerOrg.ReferenceNumber = COALESCE(
                            NULLIF(TRIM(p.subsidiary_id), ''),
                            CAST(p.organisation_id AS nvarchar(50))
                        )
                            AND TRY_CONVERT(uniqueidentifier, producerOrg.ExternalId) = @RequestedExternalId
                    )
            ) AS a
            WHERE a.rn = 1
        ),

        LatestAcceptedPomsWithPeriodFlags AS (
            SELECT
                lap.*,
                MAX(
                    CASE
                        WHEN (
                            @PeriodYear = '2024'
                            AND lap.submission_period IN (
                                CONCAT(@PeriodYear, '-P1'),
                                CONCAT(@PeriodYear, '-P2'),
                                CONCAT(@PeriodYear, '-P3')
                            )
                        )
                            OR (
                                @PeriodYear > '2024'
                                AND lap.submission_period = CONCAT(@PeriodYear, '-H1')
                            )
                        THEN 1
                        ELSE 0
                    END
                ) OVER (PARTITION BY lap.producer_id, lap.submitter_id) AS HasFirstPeriod,
                MAX(
                    CASE
                        WHEN (
                            @PeriodYear = '2024'
                            AND lap.submission_period = CONCAT(@PeriodYear, '-P4')
                        )
                            OR (
                                @PeriodYear > '2024'
                                AND lap.submission_period = CONCAT(@PeriodYear, '-H2')
                            )
                        THEN 1
                        ELSE 0
                    END
                ) OVER (PARTITION BY lap.producer_id, lap.submitter_id) AS HasSecondPeriod
            FROM LatestAcceptedPoms AS lap
        ),

        LatestAcceptedPomsWith2Period AS (
            SELECT
                FileName,
                organisation_id,
                subsidiary_id,
                submission_period,
                submission_period_year,
                submitter_id,
                producer_id,
                submitter_type
            FROM LatestAcceptedPomsWithPeriodFlags
            WHERE producer_id IS NOT NULL
                AND submitter_id IS NOT NULL
                AND HasFirstPeriod = 1
                AND HasSecondPeriod = 1
        ),

        RegistrationsWithObligations AS (
            SELECT
                organisation_id,
                subsidiary_id,
                status_code AS leaver_code,
                leaver_date,
                joiner_date,
                submitter_id,
                obligation_status,
                num_days_obligated
            FROM dbo.t_producer_obligation_determination
            WHERE submission_period_year = @RelevantYear
        ),

        LatestAcceptedPomEntries AS (
            SELECT
                lap.organisation_id,
                lap.subsidiary_id,
                lap.submitter_id,
                prodOrg.ExternalId AS external_producer_id,
                lap.submitter_type,
                lap.submission_period_year,
                pom.packaging_type,
                pom.packaging_material,
                -- TODO could use v_POM which already does this
                CASE
                    WHEN pom.submission_period = '2023-P2'
                        THEN CAST(pom.packaging_material_weight * 1.50 AS decimal(16, 2))
                    WHEN pom.submission_period = '2024-P2'
                        THEN CAST(pom.packaging_material_weight * 2 AS decimal(16, 2))
                    -- v_POM uses 3 - but 182/61 preserves value previously used
                    -- (for 182 days in P1, 61 in P3).
                    WHEN pom.submission_period = '2024-P3'
                        THEN CAST(pom.packaging_material_weight * 182.0 / 61 AS decimal(16, 2))
                    ELSE pom.packaging_material_weight
                END AS packaging_material_weight,
                pom.transitional_packaging_units
            FROM LatestAcceptedPomsWith2Period AS lap
            INNER JOIN rpd.Organisations AS prodOrg
                ON prodOrg.ReferenceNumber = lap.producer_id
                AND TRY_CONVERT(uniqueidentifier, prodOrg.ExternalId) = @RequestedExternalId
            INNER JOIN rpd.Pom AS pom
                ON pom.FileName = lap.FileName
                AND COALESCE(NULLIF(TRIM(pom.subsidiary_id), ''), '') = COALESCE(lap.subsidiary_id, '')
                AND pom.organisation_id = lap.organisation_id
        )

        SELECT
            pom.submission_period_year AS SubmissionPeriod,
            pom.submitter_type AS SubmitterType,
            CAST(pom.submitter_id AS uniqueidentifier) AS SubmitterId,
            CAST(external_producer_id AS uniqueidentifier) AS OrganisationId,
            packaging_material AS PackagingMaterial,
            CAST(
                ROUND(
                    (SUM(packaging_material_weight) - COALESCE(SUM(transitional_packaging_units), 0)) / 1000.0,
                    0
                ) AS int
            ) AS PackagingMaterialWeight,
            obl.num_days_obligated AS NumberOfDaysObligated,
            CAST(
                ROUND(
                    SUM(packaging_material_weight) - COALESCE(SUM(transitional_packaging_units), 0),
                    0
                ) AS bigint
            ) AS PackagingMaterialWeightKg,
            obl.obligation_status AS ObligationStatus,
            obl.leaver_code AS LeaverCode,
            TRY_CONVERT(date, obl.joiner_date, 103) AS JoinerDate,
            TRY_CONVERT(date, obl.leaver_date, 103) AS LeaverDate
        FROM LatestAcceptedPomEntries AS pom
        LEFT JOIN RegistrationsWithObligations AS obl
            ON pom.organisation_id = obl.organisation_id
            AND COALESCE(pom.subsidiary_id, '') = COALESCE(obl.subsidiary_id, '')
            AND pom.submitter_id = obl.submitter_id
        WHERE packaging_material IN ('AL', 'FC', 'GL', 'PC', 'PL', 'ST', 'WD')
            AND packaging_type IN ('HH', 'NH', 'PB', 'HDC', 'NDC')
        GROUP BY
            pom.submission_period_year,
            pom.submitter_id,
            pom.submitter_type,
            external_producer_id,
            packaging_material,
            obl.num_days_obligated,
            obl.obligation_status,
            obl.leaver_code,
            obl.joiner_date,
            obl.leaver_date
        ORDER BY
            pom.submitter_id,
            external_producer_id,
            packaging_material;
    END;

    INSERT INTO [dbo].[batch_log] (
        [ID],
        [ProcessName],
        [SubProcessName],
        [Count],
        [start_time_stamp],
        [end_time_stamp],
        [Comments],
        batch_id
    )
    SELECT
        (SELECT ISNULL(MAX(id), 1) + 1 FROM [dbo].[batch_log]),
        'dbo.sp_GetApprovedSubmissionsMycWithObligationsForOrg',
        '',
        NULL,
        @start_dt,
        GETDATE(),
        '',
        @batch_id;
END;
