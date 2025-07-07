CREATE TABLE [dbo].[Staging_SubmissionsStatus] (
    [SubmissionId]                UNIQUEIDENTIFIER NOT NULL,
    [SubmissionStatus]            NVARCHAR (50)    NULL,
    [ResubmissionStatus]          NVARCHAR (50)    NULL,
    [SubmissionDate]              DATETIME2 (7)    NOT NULL,
    [ProducerSubmissionEventId]   UNIQUEIDENTIFIER NULL,
    [RegistrationDate]            DATETIME2 (7)    NULL,
    [SubmissionDecisionEventId]   UNIQUEIDENTIFIER NULL,
    [StatusPendingDate]           DATETIME2 (7)    NULL,
    [ResubmissionDecisionDate]    DATETIME2 (7)    NULL,
    [ResubmissionDecisionEventId] UNIQUEIDENTIFIER NULL,
    [ResubmissionDate]            DATETIME2 (7)    NULL,
    [ResubmissionEventId]         UNIQUEIDENTIFIER NULL,
    [FileId]                      UNIQUEIDENTIFIER NULL,
    [ProducerUserId]              UNIQUEIDENTIFIER NULL,
    [RegulatorUserId]             UNIQUEIDENTIFIER NULL,
    [RegistrationReferenceNumber] NVARCHAR (100)   NULL,
    [load_ts]                     DATETIME2 (7)    NOT NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

