CREATE TABLE [rpd].[cosmos_file_metadata] (
    [SubmissionId]        NVARCHAR (4000) NULL,
    [FileId]              NVARCHAR (4000) NULL,
    [UserId]              NVARCHAR (4000) NULL,
    [BlobName]            NVARCHAR (4000) NULL,
    [BlobContainerName]   NVARCHAR (4000) NULL,
    [FileType]            NVARCHAR (4000) NULL,
    [Created]             NVARCHAR (4000) NULL,
    [OriginalFileName]    NVARCHAR (4000) NULL,
    [RegistrationSetId]   NVARCHAR (4000) NULL,
    [OrganisationId]      NVARCHAR (4000) NULL,
    [DataSourceType]      NVARCHAR (4000) NULL,
    [SubmissionPeriod]    NVARCHAR (4000) NULL,
    [IsSubmitted]         BIT             NULL,
    [SubmissionType]      NVARCHAR (4000) NULL,
    [ComplianceSchemeId]  NVARCHAR (4000) NULL,
    [TargetDirectoryName] NVARCHAR (4000) NULL,
    [TargetContainerName] NVARCHAR (4000) NULL,
    [SourceContainerName] NVARCHAR (4000) NULL,
    [FileName]            NVARCHAR (4000) NULL,
    [load_ts]             DATETIME2 (7)   NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

