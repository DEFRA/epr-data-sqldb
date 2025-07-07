CREATE TABLE [dbo].[Staging_ValidSubmissions] (
    [OrganisationMembers]    INT              NULL,
    [Created]                DATETIME2 (7)    NOT NULL,
    [OrganisationId]         UNIQUEIDENTIFIER NOT NULL,
    [IsSubmitted]            BIT              NULL,
    [Comments]               NVARCHAR (4000)  NULL,
    [IsResubmissionRequired] BIT              NULL,
    [AppReferenceNumber]     NVARCHAR (50)    NOT NULL,
    [DataSourceType]         NVARCHAR (50)    NOT NULL,
    [SubmissionEventId]      UNIQUEIDENTIFIER NULL,
    [SubmissionPeriod]       NVARCHAR (100)   NOT NULL,
    [SubmissionType]         NVARCHAR (50)    NOT NULL,
    [SubmissionId]           UNIQUEIDENTIFIER NOT NULL,
    [Decision]               NVARCHAR (50)    NULL,
    [RegulatorDecision]      NVARCHAR (50)    NULL,
    [FileId]                 UNIQUEIDENTIFIER NULL,
    [RejectionComments]      NVARCHAR (4000)  NULL,
    [id]                     UNIQUEIDENTIFIER NOT NULL,
    [UserId]                 UNIQUEIDENTIFIER NOT NULL,
    [SubmittedBy]            NVARCHAR (100)   NULL,
    [IsResubmission]         BIT              NULL,
    [Type]                   NVARCHAR (50)    NULL,
    [ComplianceSchemeId]     UNIQUEIDENTIFIER NULL,
    [load_ts]                DATETIME2 (7)    NOT NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([SubmissionId]));

