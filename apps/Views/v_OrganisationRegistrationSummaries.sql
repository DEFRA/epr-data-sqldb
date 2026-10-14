CREATE VIEW [apps].[v_OrganisationRegistrationSummaries_EMR_656_v2]
AS
WITH DedupedSubmissionEvents AS
(
    SELECT
        se.SubmissionId,
        se.SubmissionEventId,
        se.Created AS DecisionDate,
        se.Comments AS Comment,
        se.UserId,
        se.Type,
        se.FileId,
        se.Decision,
        se.IsResubmission,
        se.RegistrationReferenceNumber,
        se.DecisionDate AS StatusPendingDate,
        ROW_NUMBER() OVER
        (
            PARTITION BY se.SubmissionId, se.SubmissionEventId
            ORDER BY se.Created DESC
        ) AS EventRowNum
    FROM rpd.SubmissionEvents AS se
    WHERE se.Type IN
    (
        'RegistrationApplicationSubmitted',
        'RegulatorRegistrationDecision',
        'Submitted'
    )
      AND se.SubmissionId IS NOT NULL
),
BaseSubmissionEvents AS
(
    SELECT
        e.SubmissionId,
        e.SubmissionEventId,
        e.DecisionDate,
        e.Comment,
        e.UserId,
        e.Type,
        e.FileId,
        CASE
            WHEN e.Type = 'RegulatorRegistrationDecision'
             AND e.FileId IS NULL
                THEN CASE
                    WHEN LTRIM(RTRIM(e.Decision)) = 'Accepted' THEN 'Granted'
                    WHEN LTRIM(RTRIM(e.Decision)) = 'Rejected' THEN 'Refused'
                    WHEN e.Decision IS NULL THEN 'Pending'
                    ELSE e.Decision
                END
        END AS SubmissionStatus,
        CASE
            WHEN e.Type = 'RegulatorRegistrationDecision'
             AND e.FileId IS NOT NULL
                THEN ISNULL(e.Decision, 'Pending')
        END AS ResubmissionStatus,
        CASE
            WHEN e.Type = 'RegulatorRegistrationDecision'
             AND e.FileId IS NULL THEN 1
            ELSE 0
        END AS IsRegulatorDecision,
        CASE
            WHEN e.Type = 'RegulatorRegistrationDecision'
             AND e.FileId IS NOT NULL THEN 1
            ELSE 0
        END AS IsRegulatorResubmissionDecision,
        CASE
            WHEN e.Type = 'Submitted' THEN 1
            ELSE 0
        END AS UploadEvent,
        CASE
            WHEN e.Type = 'RegistrationApplicationSubmitted'
             AND ISNULL(e.IsResubmission, 0) = 0 THEN 1
            ELSE 0
        END AS IsProducerSubmission,
        CASE
            WHEN e.Type = 'RegistrationApplicationSubmitted'
             AND ISNULL(e.IsResubmission, 0) = 1 THEN 1
            ELSE 0
        END AS IsProducerResubmission,
        e.RegistrationReferenceNumber,
        e.StatusPendingDate
    FROM DedupedSubmissionEvents AS e
    WHERE e.EventRowNum = 1
),
UploadEvents AS
(
    SELECT
        e.SubmissionId,
        e.DecisionDate,
        e.FileId,
        ROW_NUMBER() OVER
        (
            PARTITION BY e.SubmissionId
            ORDER BY e.DecisionDate DESC
        ) AS UploadOrder
    FROM BaseSubmissionEvents AS e
    WHERE e.UploadEvent = 1
),
ReconciledSubmissionEvents AS
(
    SELECT
        e.SubmissionId,
        e.SubmissionEventId,
        e.DecisionDate,
        e.Comment,
        e.UserId,
        e.Type,
        u.FileId,
        e.RegistrationReferenceNumber,
        e.SubmissionStatus,
        e.ResubmissionStatus,
        e.StatusPendingDate,
        e.IsRegulatorDecision,
        e.IsRegulatorResubmissionDecision,
        e.IsProducerSubmission,
        e.IsProducerResubmission
    FROM BaseSubmissionEvents AS e
    OUTER APPLY
    (
        SELECT TOP 1
            u.FileId
        FROM UploadEvents AS u
        WHERE u.SubmissionId = e.SubmissionId
          AND u.DecisionDate < e.DecisionDate
        ORDER BY u.UploadOrder ASC
    ) AS u
    WHERE e.IsProducerSubmission = 1
       OR e.IsProducerResubmission = 1
       OR e.IsRegulatorDecision = 1
       OR e.IsRegulatorResubmissionDecision = 1
),
RankedSubmissionEvents AS
(
    SELECT
        e.*,
        ROW_NUMBER() OVER
        (
            PARTITION BY e.SubmissionId
            ORDER BY
                CASE WHEN e.IsProducerSubmission = 1 AND e.IsProducerResubmission = 0 THEN 0 ELSE 1 END,
                e.DecisionDate DESC
        ) AS InitialSubmissionRank,
        ROW_NUMBER() OVER
        (
            PARTITION BY e.SubmissionId
            ORDER BY
                CASE WHEN e.IsProducerSubmission = 1 AND e.IsProducerResubmission = 0 THEN 0 ELSE 1 END,
                e.DecisionDate ASC
        ) AS FirstSubmissionRank,
        ROW_NUMBER() OVER
        (
            PARTITION BY e.SubmissionId
            ORDER BY
                CASE WHEN e.IsRegulatorDecision = 1 AND e.IsRegulatorResubmissionDecision = 0 THEN 0 ELSE 1 END,
                e.DecisionDate DESC
        ) AS InitialDecisionRank,
        ROW_NUMBER() OVER
        (
            PARTITION BY e.SubmissionId
            ORDER BY
                CASE WHEN e.IsRegulatorDecision = 1 AND e.IsRegulatorResubmissionDecision = 0 THEN 0 ELSE 1 END,
                e.DecisionDate DESC
        ) AS LatestDecisionRank,
        ROW_NUMBER() OVER
        (
            PARTITION BY e.SubmissionId
            ORDER BY
                CASE
                    WHEN e.IsRegulatorDecision = 1
                     AND e.IsRegulatorResubmissionDecision = 0
                     AND e.SubmissionStatus = 'Granted' THEN 0
                    ELSE 1
                END,
                e.DecisionDate ASC
        ) AS RegistrationDecisionRank,
        ROW_NUMBER() OVER
        (
            PARTITION BY e.SubmissionId
            ORDER BY
                CASE WHEN e.IsProducerResubmission = 1 THEN 0 ELSE 1 END,
                e.DecisionDate DESC
        ) AS ResubmissionRank,
        ROW_NUMBER() OVER
        (
            PARTITION BY e.SubmissionId
            ORDER BY
                CASE WHEN e.IsRegulatorResubmissionDecision = 1 THEN 0 ELSE 1 END,
                e.DecisionDate DESC
        ) AS ResubmissionDecisionRank
    FROM ReconciledSubmissionEvents AS e
),
InitialSubmission AS
(
    SELECT *
    FROM RankedSubmissionEvents
    WHERE IsProducerSubmission = 1
      AND IsProducerResubmission = 0
      AND InitialSubmissionRank = 1
),
FirstSubmission AS
(
    SELECT *
    FROM RankedSubmissionEvents
    WHERE IsProducerSubmission = 1
      AND IsProducerResubmission = 0
      AND FirstSubmissionRank = 1
),
InitialDecision AS
(
    SELECT *
    FROM RankedSubmissionEvents
    WHERE IsRegulatorDecision = 1
      AND IsRegulatorResubmissionDecision = 0
      AND InitialDecisionRank = 1
),
LatestDecision AS
(
    SELECT *
    FROM RankedSubmissionEvents
    WHERE IsRegulatorDecision = 1
      AND IsRegulatorResubmissionDecision = 0
      AND LatestDecisionRank = 1
),
RegistrationDecision AS
(
    SELECT *
    FROM RankedSubmissionEvents
    WHERE IsRegulatorDecision = 1
      AND IsRegulatorResubmissionDecision = 0
      AND SubmissionStatus = 'Granted'
      AND RegistrationDecisionRank = 1
),
LatestResubmission AS
(
    SELECT *
    FROM RankedSubmissionEvents
    WHERE IsProducerResubmission = 1
      AND ResubmissionRank = 1
),
LatestResubmissionDecision AS
(
    SELECT *
    FROM RankedSubmissionEvents
    WHERE IsRegulatorResubmissionDecision = 1
      AND ResubmissionDecisionRank = 1
),
SubmissionStatus AS
(
    SELECT
        s.SubmissionId,
        CASE
            WHEN s.DecisionDate > id.DecisionDate THEN 'Pending'
            ELSE COALESCE(ld.SubmissionStatus, id.SubmissionStatus, reg.SubmissionStatus, 'Pending')
        END AS SubmissionStatus,
        CASE
            WHEN r.SubmissionEventId IS NOT NULL
             AND rd.SubmissionEventId IS NOT NULL THEN rd.ResubmissionStatus
            WHEN r.SubmissionEventId IS NOT NULL THEN 'Pending'
            ELSE NULL
        END AS ResubmissionStatus,
        s.DecisionDate AS SubmissionDate,
        fs.DecisionDate AS FirstSubmissionDate,
        s.SubmissionEventId AS ProducerSubmissionEventId,
        COALESCE(reg.DecisionDate, ld.DecisionDate, id.DecisionDate) AS RegistrationDate,
        id.SubmissionEventId AS SubmissionDecisionEventId,
        COALESCE(ld.StatusPendingDate, id.StatusPendingDate) AS StatusPendingDate,
        COALESCE(ld.DecisionDate, reg.DecisionDate, id.DecisionDate) AS RegulatorDecisionDate,
        rd.DecisionDate AS ResubmissionDecisionDate,
        rd.SubmissionEventId AS ResubmissionDecisionEventId,
        r.DecisionDate AS ResubmissionDate,
        r.Comment AS ResubmissionComment,
        r.UserId AS ResubmittedUserId,
        r.SubmissionEventId AS ResubmissionEventId,
        COALESCE(r.FileId, s.FileId) AS FileId,
        COALESCE(r.UserId, s.UserId) AS ProducerUserId,
        COALESCE(rd.UserId, id.UserId) AS RegulatorUserId,
        reg.RegistrationReferenceNumber,
        COALESCE(r.Comment, s.Comment) AS ProducerComment,
        COALESCE(rd.Comment, reg.Comment, id.Comment) AS RegulatorComment
    FROM InitialSubmission AS s
    LEFT JOIN FirstSubmission AS fs
        ON fs.SubmissionId = s.SubmissionId
    LEFT JOIN InitialDecision AS id
        ON id.SubmissionId = s.SubmissionId
    LEFT JOIN LatestDecision AS ld
        ON ld.SubmissionId = s.SubmissionId
    LEFT JOIN RegistrationDecision AS reg
        ON reg.SubmissionId = s.SubmissionId
    LEFT JOIN LatestResubmission AS r
        ON r.SubmissionId = s.SubmissionId
    LEFT JOIN LatestResubmissionDecision AS rd
        ON rd.SubmissionId = r.SubmissionId
       AND rd.FileId = r.FileId
),
LatestOrganisationRegistrationSubmissions AS
(
    SELECT
        x.*
    FROM
    (
        SELECT
            s.SubmissionId,
            o.Name AS OrganisationName,
            org.UploadOrgName AS UploadedOrganisationName,
            o.ReferenceNumber,
            o.Id AS OrganisationInternalId,
            o.ExternalId AS OrganisationId,
            s.AppReferenceNumber AS ApplicationReferenceNumber,
            CASE
                WHEN cs.NationId IS NOT NULL THEN cs.NationId
                ELSE CASE UPPER(org.NationCode)
                    WHEN 'EN' THEN 1
                    WHEN 'NI' THEN 2
                    WHEN 'SC' THEN 3
                    WHEN 'WS' THEN 4
                    WHEN 'WA' THEN 4
                END
            END AS NationId,
            CASE
                WHEN cs.NationId IS NOT NULL THEN
                    CASE cs.NationId
                        WHEN 1 THEN 'GB-ENG'
                        WHEN 2 THEN 'GB-NIR'
                        WHEN 3 THEN 'GB-SCT'
                        WHEN 4 THEN 'GB-WLS'
                    END
                ELSE CASE UPPER(org.NationCode)
                    WHEN 'EN' THEN 'GB-ENG'
                    WHEN 'NI' THEN 'GB-NIR'
                    WHEN 'SC' THEN 'GB-SCT'
                    WHEN 'WS' THEN 'GB-WLS'
                    WHEN 'WA' THEN 'GB-WLS'
                END
            END AS NationCode,
            ss.RegistrationReferenceNumber,
            ss.RegistrationDate,
            ss.SubmissionDate AS SubmittedDateTime,
            ss.FirstSubmissionDate,
            CASE
                WHEN ss.ResubmissionDate IS NOT NULL THEN 1
                ELSE 0
            END AS IsResubmission,
            ss.ResubmissionStatus,
            ss.SubmissionStatus,
            ss.ResubmissionDecisionDate,
            ss.RegulatorDecisionDate,
            ss.StatusPendingDate,
            ss.ProducerComment,
            ss.RegulatorComment,
            s.SubmissionPeriod,
            CAST
            (
                SUBSTRING
                (
                    s.SubmissionPeriod,
                    PATINDEX('%[0-9][0-9][0-9][0-9]%', s.SubmissionPeriod),
                    4
                ) AS INT
            ) AS RelevantYear,
            CASE UPPER(TRIM(org.organisationsize))
                WHEN 'S' THEN 'Small'
                WHEN 'L' THEN 'Large'
            END AS ProducerSize,
            CASE
                WHEN s.ComplianceSchemeId IS NOT NULL THEN 1
                ELSE 0
            END AS IsComplianceScheme,
            ss.RegulatorUserId,
            ss.ProducerSubmissionEventId,
            ss.SubmissionDecisionEventId AS RegulatorGrantedEventId,
            ss.ResubmissionDecisionEventId,
            ss.ResubmissionEventId,
            ss.ResubmissionDate,
            s.OrganisationId AS InternalOrgId,
            s.SubmissionType,
            s.UserId AS SubmittedUserId,
            CAST
            (
                CASE
                    WHEN ss.SubmissionDate >
                         DATEFROMPARTS
                         (
                             CONVERT
                             (
                                 INT,
                                 SUBSTRING
                                 (
                                     s.SubmissionPeriod,
                                     PATINDEX('%[0-9][0-9][0-9][0-9]', s.SubmissionPeriod),
                                     4
                                 )
                             ),
                             4,
                             1
                         )
                    THEN 1
                    ELSE 0
                END AS BIT
            ) AS IsLateSubmission,
            s.ComplianceSchemeId,
            ss.FileId,
            ss.ResubmissionComment,
            ss.ResubmittedUserId,
            ss.ProducerUserId,
            ROW_NUMBER() OVER
            (
                PARTITION BY
                    s.OrganisationId,
                    s.SubmissionPeriod,
                    s.ComplianceSchemeId,
                    s.AppReferenceNumber
                ORDER BY
                    s.Created DESC,
                    s.load_ts DESC
            ) AS RowNum
        FROM rpd.Submissions AS s
        INNER JOIN dbo.v_UploadedRegistrationDataBySubmissionPeriod AS org
            ON org.SubmittingExternalId = s.OrganisationId
           AND org.SubmissionPeriod = s.SubmissionPeriod
        INNER JOIN rpd.Organisations AS o
            ON o.ExternalId = s.OrganisationId
        INNER JOIN SubmissionStatus AS ss
            ON ss.SubmissionId = s.SubmissionId
        LEFT JOIN rpd.ComplianceSchemes AS cs
            ON cs.ExternalId = s.ComplianceSchemeId
        WHERE s.AppReferenceNumber IS NOT NULL
          AND s.SubmissionType = 'Registration'
          AND s.IsSubmitted = 1
    ) AS x
    WHERE x.RowNum = 1
)
SELECT
    a.SubmissionId,
    a.OrganisationId,
    a.OrganisationInternalId,
    a.OrganisationName,
    a.UploadedOrganisationName,
    a.ReferenceNumber AS OrganisationReference,
    a.SubmittedUserId,
    a.IsComplianceScheme,
    CASE
        WHEN a.IsComplianceScheme = 1 THEN 'Compliance'
        ELSE a.ProducerSize
    END AS OrganisationType,
    a.ProducerSize,
    a.ApplicationReferenceNumber,
    a.RegistrationReferenceNumber,
    a.SubmittedDateTime,
    a.FirstSubmissionDate,
    a.RegistrationDate,
    a.IsResubmission,
    a.ResubmissionDate,
    a.RelevantYear,
    a.SubmissionPeriod,
    a.IsLateSubmission,
    ISNULL(a.SubmissionStatus, 'Pending') AS SubmissionStatus,
    a.ResubmissionStatus,
    a.ResubmissionDecisionDate,
    a.RegulatorDecisionDate,
    a.StatusPendingDate,
    a.NationId,
    a.NationCode,
    a.ComplianceSchemeId,
    a.ProducerComment,
    a.RegulatorComment,
    a.FileId,
    a.ResubmissionComment,
    a.ResubmittedUserId,
    a.ProducerUserId,
    a.RegulatorUserId,
    CASE
        WHEN s.RegistrationJourney IS NOT NULL THEN s.RegistrationJourney
        WHEN a.IsComplianceScheme = 0 AND a.ProducerSize = 'Large' THEN 'DirectLargeProducer'
        WHEN a.IsComplianceScheme = 0 AND a.ProducerSize = 'Small' THEN 'DirectSmallProducer'
        ELSE 'CsoLegacy'
    END AS RegistrationJourney
FROM LatestOrganisationRegistrationSubmissions AS a
INNER JOIN rpd.Submissions AS s
    ON s.SubmissionId = a.SubmissionId;