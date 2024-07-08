CREATE PROC [dbo].[sp_delete_duplicate_rows] AS
BEGIN TRY


--rpd.cosmos_file_metadata
WITH RowsToDelete AS (
  SELECT
    [SubmissionId], [FileId], [UserId], [BlobName], [BlobContainerName], [FileType], [Created], [OriginalFileName], [RegistrationSetId], [OrganisationId], [DataSourceType], [SubmissionPeriod],
    [IsSubmitted], [SubmissionType], [ComplianceSchemeId], [TargetDirectoryName], [TargetContainerName], [SourceContainerName], [FileName],
    ROW_NUMBER() OVER (PARTITION BY [FileName] ORDER BY created,load_ts DESC) AS rnk
  FROM
    rpd.cosmos_file_metadata
)

DELETE a

FROM  rpd.cosmos_file_metadata a
left JOIN RowsToDelete b
  ON isnull(a.[SubmissionId],'') = isnull(b.[SubmissionId],'')
  AND isnull(a.[FileId],'') = isnull(b.[FileId],'')
  AND isnull(a.[UserId],'') = isnull(b.[UserId],'')
  AND isnull(a.[BlobName],'') = isnull(b.[BlobName],'')
  AND isnull(a.[BlobContainerName],'') = isnull(b.[BlobContainerName],'')
  AND isnull(a.[FileType] ,'')= isnull(b.[FileType],'')
  AND isnull(a.[Created],'') = isnull(b.[Created],'')
  AND isnull(a.[OriginalFileName],'') = isnull(b.[OriginalFileName],'')
  AND isnull(a.[RegistrationSetId],'') = isnull(b.[RegistrationSetId],'')
  AND isnull(a.[OrganisationId] ,'')= isnull(b.[OrganisationId],'')
  AND isnull(a.[DataSourceType],'') = isnull(b.[DataSourceType],'')
  AND isnull(a.[SubmissionPeriod],'') = isnull(b.[SubmissionPeriod],'')
  AND isnull(a.[IsSubmitted],'') = isnull(b.[IsSubmitted],'')
  AND isnull(a.[SubmissionType],'') = isnull(b.[SubmissionType],'')
  AND isnull(a.[ComplianceSchemeId],'') = isnull(b.[ComplianceSchemeId],'')
  AND isnull(a.[TargetDirectoryName],'') = isnull(b.[TargetDirectoryName],'')
  AND isnull(a.[TargetContainerName],'') = isnull(b.[TargetContainerName],'')
  AND isnull(a.[SourceContainerName],'') = isnull(b.[SourceContainerName],'')
  AND isnull(a.[FileName],'') = isnull(b.[FileName],'')
WHERE b.rnk > 1;


/*--
--submissions
WITH RowsToDelete_submissions AS (
  SELECT
   [Created]
      ,[IsSubmitted]
      ,[SubmissionPeriod]
      ,[SubmissionId]
      ,[id]
      ,[ComplianceSchemeId]
    ,ROW_NUMBER() OVER (PARTITION BY [id] ORDER BY created,load_ts DESC) AS rnk
  FROM
    rpd.submissions
)



DELETE a
FROM  rpd.submissions a
left JOIN RowsToDelete_submissions b
  ON  isnull(a.[Created],'') = isnull(b.[Created],'')
   and isnull(a.[IsSubmitted],'') = isnull(b.[IsSubmitted],'')
   and isnull(a.[SubmissionPeriod],'') = isnull(b.[SubmissionPeriod],'')
   and isnull(a.[SubmissionId],'') = isnull(b.[SubmissionId],'')
   and isnull(a.[id],'') = isnull(b.[id],'')
   and isnull(a.[ComplianceSchemeId],'') = isnull(b.[ComplianceSchemeId],'')
WHERE b.rnk > 1;
 

 --submissionevents
WITH RowsToDelete_submissionsevents AS (
  SELECT
  [Created]
      ,[RequiresBrandsFile]
      ,[RegistrationSetId]
      ,[SubmissionId]
      ,[RegulatorDecision]
      ,[IsValid]
      ,[BlobName]
      ,[id]
      ,[RequiresPartnershipsFile]
      ,[Errors]
      ,[FileName]
      ,[BlobContainerName]
    ,ROW_NUMBER() OVER (PARTITION BY [id] ORDER BY created,load_ts DESC) AS rnk
  FROM
    rpd.submissionEvents
)



DELETE a
FROM  rpd.submissionEvents a
left JOIN RowsToDelete_submissionsevents b
  ON  isnull(a.[Created],'')  = isnull(b.[Created],'')
   and   isnull(a.[RequiresBrandsFile],'')  = isnull(b.[RequiresBrandsFile],'')
         and   isnull(a.[RegistrationSetId],'')  = isnull(b.[RegistrationSetId],'')
         and   isnull(a.[SubmissionId],'')  = isnull(b.[SubmissionId],'')
         and   isnull(a.[RegulatorDecision],'')  = isnull(b.[RegulatorDecision],'')
         and   isnull(a.[IsValid],'')  = isnull(b.[IsValid],'')
         and   isnull(a.[BlobName],'')  = isnull(b.[BlobName],'')
         and   isnull(a.[id],'')  = isnull(b.[id],'')
         and   isnull(a.[RequiresPartnershipsFile],'')  = isnull(b.[RequiresPartnershipsFile],'')
         and   isnull(a.[Errors],'')  = isnull(b.[Errors],'')
         and   isnull(a.[FileName],'')  = isnull(b.[FileName],'')
         and   isnull(a.[BlobContainerName],'')  = isnull(b.[BlobContainerName],'')
WHERE b.rnk > 1




--*
*/


END TRY
BEGIN CATCH
  SELECT ERROR_MESSAGE() AS ErrorMessage
END CATCH
