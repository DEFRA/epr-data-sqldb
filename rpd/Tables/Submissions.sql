﻿CREATE TABLE [rpd].[Submissions] (
    [OrganisationMembers]    INT             NULL,
    [Created]                NVARCHAR (4000) NULL,
    [OrganisationId]         NVARCHAR (4000) NULL,
    [IsSubmitted]            BIT             NULL,
    [Comments]               NVARCHAR (4000) NULL,
    [IsResubmissionRequired] BIT             NULL,
    [DataSourceType]         NVARCHAR (4000) NULL,
    [SubmissionEventId]      NVARCHAR (4000) NULL,
    [SubmissionPeriod]       NVARCHAR (4000) NULL,
    [SubmissionType]         NVARCHAR (4000) NULL,
    [SubmissionId]           NVARCHAR (4000) NULL,
    [Decision]               NVARCHAR (4000) NULL,
    [RegulatorDecision]      NVARCHAR (4000) NULL,
    [FileId]                 NVARCHAR (4000) NULL,
    [RejectionComments]      NVARCHAR (4000) NULL,
    [id]                     NVARCHAR (4000) NULL,
    [UserId]                 NVARCHAR (4000) NULL,
    [SubmittedBy]            NVARCHAR (4000) NULL,
    [Type]                   NVARCHAR (4000) NULL,
    [ComplianceSchemeId]     NVARCHAR (4000) NULL,
    [load_ts]                DATETIME2 (7)   NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);





