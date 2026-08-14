CREATE TABLE [dbo].[t_cosmos_file_metadata]
(
    [SubmissionId]           nvarchar(4000) NULL,
    [FileId]                 nvarchar(4000) NULL,
    [UserId]                 nvarchar(4000) NULL,
    [SubmittedBy]            nvarchar(4000) NOT NULL,
    [BlobName]               nvarchar(4000) NULL,
    [BlobContainerName]      nvarchar(4000) NULL,
    [FileType]               nvarchar(4000) NULL,
    [created]                datetime       NULL,
    [OriginalFileName]       nvarchar(4000) NULL,
    [OrganisationId]         nvarchar(4000) NULL,
    [DataSourceType]         nvarchar(4000) NULL,
    [SubmissionPeriod]       nvarchar(4000) NULL,
    [IsSubmitted]            bit            NULL,
    [SubmissionType]         nvarchar(4000) NULL,
    [TargetDirectoryName]    nvarchar(4000) NULL,
    [TargetContainerName]    nvarchar(4000) NULL,
    [SourceContainerName]    nvarchar(4000) NULL,
    [FileName]               nvarchar(4000) NULL,
    [load_ts]                datetime2      NULL,
    [SubmtterEmail]          nvarchar(4000) NULL,
    [ServiceRoles_Name]      nvarchar(100)  NULL,
    [ComplianceSchemeId]     nvarchar(4000) NULL,
    [RegistrationJourney]    nvarchar(128)  NULL,
    [LastUpdatedOn_History]  datetime       NULL,
    [Service_Name_History]   nvarchar(100)  NULL,
    [RegistrationSetId]      nvarchar(4000) NULL
)
WITH
(
    CLUSTERED COLUMNSTORE INDEX,
    DISTRIBUTION = ROUND_ROBIN
);