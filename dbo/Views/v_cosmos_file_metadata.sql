CREATE VIEW [dbo].[v_cosmos_file_metadata]
AS WITH RankedData AS (
    SELECT
        distinct 
        a.[SubmissionId],
        a.[FileId],
        a.[UserId],
        --b.Submitter_Name [SubmittedBy],
        a.[BlobName],
        a.[BlobContainerName],
        a.[FileType],
        a.[Created],
        a.[OriginalFileName],
        a.[OrganisationId],
        a.[DataSourceType],
        a.[SubmissionPeriod],
        a.[IsSubmitted],
        a.[SubmissionType],
        a.[TargetDirectoryName],
        a.[TargetContainerName],
        a.[SourceContainerName],
        a.[FileName],
        a.[load_ts],
		a.[ComplianceSchemeId],
        ROW_NUMBER() OVER (PARTITION BY a.[FileName] ORDER BY a.[load_ts] DESC) AS RowNum
    FROM rpd.cosmos_file_metadata a
)

select 
a.[SubmissionId]
,a.[FileId]
,a.[UserId]
,b.Submitter_Name [SubmittedBy]
,a.[BlobName]
,a.[BlobContainerName]
,a.[FileType]
--,a.[Created]
,CAST(CONVERT(datetimeoffset, created) AT TIME ZONE 'UTC' AT TIME ZONE 'GMT Standard Time' AS datetime) AS created--_in_gmt
,a.[OriginalFileName]
,a.[OrganisationId]
,a.[DataSourceType]
,a.[SubmissionPeriod]
,a.[IsSubmitted]
,a.[SubmissionType]
,a.[TargetDirectoryName]
,a.[TargetContainerName]
,a.[SourceContainerName]
,a.[FileName]
,a.[load_ts]
,b.[Submitter_Email] SubmtterEmail
,b.[ServiceRoles_Name]
,a.[ComplianceSchemeId]
from RankedData a
left join dbo.v_submitter_name b on a.UserId = b.UserId
where a.RowNum =1;