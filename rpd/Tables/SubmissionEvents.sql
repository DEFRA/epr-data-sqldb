﻿CREATE TABLE [rpd].[SubmissionEvents] (
    [RequiresRowValidation]    BIT             NULL,
    [Created]                  NVARCHAR (4000) NULL,
    [RequiresBrandsFile]       BIT             NULL,
    [Comments]                 NVARCHAR (4000) NULL,
    [RegistrationSetId]        NVARCHAR (4000) NULL,
    [IsResubmissionRequired]   NVARCHAR (4000) NULL,
    [SubmissionEventId]        NVARCHAR (4000) NULL,
    [DataCount]                INT             NULL,
    [RowErrorCount]            INT             NULL,
    [HasMaxRowErrors]          BIT             NULL,
    [CompanyDetailsFileId]     NVARCHAR (4000) NULL,
    [SubmissionId]             NVARCHAR (4000) NULL,
    [Decision]                 NVARCHAR (4000) NULL,
    [RegulatorDecision]        NVARCHAR (4000) NULL,
    [FileId]                   NVARCHAR (4000) NULL,
    [RejectionComments]        NVARCHAR (4000) NULL,
    [IsValid]                  BIT             NULL,
    [BlobName]                 NVARCHAR (4000) NULL,
    [AntivirusScanResult]      NVARCHAR (4000) NULL,
    [id]                       NVARCHAR (4000) NULL,
    [RequiresPartnershipsFile] BIT             NULL,
    [Errors]                   NVARCHAR (4000) NULL,
    [FileName]                 NVARCHAR (4000) NULL,
    [ResubmissionRequired]     NVARCHAR (4000) NULL,
    [FileType]                 NVARCHAR (4000) NULL,
    [UserId]                   NVARCHAR (4000) NULL,
    [ProducerId]               NVARCHAR (4000) NULL,
    [SubmittedBy]              NVARCHAR (4000) NULL,
    [RegulatorUserId]          NVARCHAR (4000) NULL,
    [Type]                     NVARCHAR (4000) NULL,
    [BlobContainerName]        NVARCHAR (4000) NULL,
    [load_ts]                  DATETIME2 (7)   NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);



