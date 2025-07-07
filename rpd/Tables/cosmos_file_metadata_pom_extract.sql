CREATE TABLE [rpd].[cosmos_file_metadata_pom_extract] (
    [SubmissionId]        NVARCHAR (50)  NULL,
    [FileId]              NVARCHAR (50)  NULL,
    [UserId]              NVARCHAR (50)  NULL,
    [BlobName]            NVARCHAR (50)  NULL,
    [BlobContainerName]   NVARCHAR (50)  NULL,
    [FileType]            NVARCHAR (50)  NULL,
    [Created]             NVARCHAR (50)  NULL,
    [OriginalFileName]    NVARCHAR (100) NULL,
    [RegistrationSetId]   NVARCHAR (50)  NULL,
    [OrganisationId]      NVARCHAR (50)  NULL,
    [DataSourceType]      NVARCHAR (50)  NULL,
    [SubmissionPeriod]    NVARCHAR (50)  NULL,
    [IsSubmitted]         BIT            NULL,
    [SubmissionType]      NVARCHAR (50)  NULL,
    [ComplianceSchemeId]  NVARCHAR (50)  NULL,
    [TargetDirectoryName] NVARCHAR (50)  NULL,
    [TargetContainerName] NVARCHAR (50)  NULL,
    [SourceContainerName] NVARCHAR (50)  NULL,
    [FileName]            NVARCHAR (50)  NULL,
    [load_ts]             DATETIME2 (7)  NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([FileName]));

