CREATE VIEW [dbo].[v_RS_433844_A] AS WITH 
setid_fileid
AS (
   SELECT DISTINCT
          RegistrationSetId,
          FileId,
          FileType
   FROM [rpd].[SubmissionEvents]
   WHERE RegistrationSetId IS NOT NULL
   ),

file_data
AS (SELECT DISTINCT
           FileId,
           FileName,
           FileType
    FROM [rpd].[SubmissionEvents]
    WHERE FileName IS NOT NULL
          AND FileType IS NOT NULL
	),

blob_name_with_File_id
AS (SELECT DISTINCT
           FileId,
           BlobName
    FROM [rpd].[SubmissionEvents]
    WHERE FileId IS NOT NULL
          AND BlobName IS NOT NULL
	),
     
sub_data
AS (SELECT DISTINCT
           SubmissionId,
           OrganisationId,
           SubmissionPeriod,
           SubmissionType
    FROM [rpd].[Submissions]
	),
     
se
AS (SELECT DISTINCT
           RequiresRowValidation,
           Created,
           RequiresBrandsFile,
           ErrorCount,
           WarningCount,
           RegistrationSetId,
           SubmissionEventId,
           DataCount,
           RowErrorCount,
           HasMaxRowErrors,
           SubmissionId,
           FileId,
           IsValid,
           BlobName,
           AntivirusScanResult,
           id,
           RequiresPartnershipsFile,
           Errors,
           FileName,
           FileType,
           UserId,
           ProducerId,
           SubmittedBy,
           Type,
           BlobContainerName,
           load_ts
    FROM [rpd].[SubmissionEvents] se1
    WHERE Type = 'Submitted'
    UNION ALL
    SELECT RequiresRowValidation,
           Created,
           RequiresBrandsFile,
           ErrorCount,
           WarningCount,
           RegistrationSetId,
           SubmissionEventId,
           DataCount,
           RowErrorCount,
           HasMaxRowErrors,
           SubmissionId,
           FileId,
           IsValid,
           BlobName,
           AntivirusScanResult,
           id,
           RequiresPartnershipsFile,
           Errors,
           FileName,
           FileType,
           UserId,
           ProducerId,
           SubmittedBy,
           Type,
           BlobContainerName,
           load_ts
    FROM
    (
        SELECT DISTINCT
               seb.RequiresRowValidation,
               ses.Created,
               seb.RequiresBrandsFile,
               seb.ErrorCount,
               seb.WarningCount,
               seb.RegistrationSetId,
               seb.SubmissionEventId,
               seb.DataCount,
               seb.RowErrorCount,
               seb.HasMaxRowErrors,
               seb.SubmissionId,
               seb.FileId,
               seb.IsValid,
               seb.BlobName,
               seb.AntivirusScanResult,
               seb.id,
               seb.RequiresPartnershipsFile,
               seb.Errors,
               seb.FileName,
               seb.FileType,
               ses.UserId,
               seb.ProducerId,
               seb.SubmittedBy,
               seb.Type,
               seb.BlobContainerName,
               seb.load_ts
        FROM [rpd].[SubmissionEvents] ses
            INNER JOIN setid_fileid ses_setid
                ON ses_setid.FileId = ses.FileId
            INNER JOIN [rpd].[SubmissionEvents] seb
                ON seb.RegistrationSetId = ses_setid.RegistrationSetId
        WHERE seb.FileType IN ( 'Brands', 'Partnerships' )
              AND ses.Type = 'Submitted'
    ) A )

SELECT DISTINCT
       OrgId,
       Org_Name,
       CompaniesHouseNumber,
       IsComplianceScheme,
       FileType,
       SubmissionPeriod,
       SubmissionType,
       Submission_date_time,
       Submitter_email,
       BlobName,
       Csv_file_name,
       FirstName,
       LastName,
       Status
FROM
(
    SELECT DISTINCT
           org.Id AS Org_Id,
           org.ReferenceNumber AS OrgId,
           org.Name AS Org_Name,
           org.CompaniesHouseNumber,
           org.IsComplianceScheme,
           f.FileType,
           s.SubmissionPeriod,
           s.SubmissionType,
           CONVERT(DATETIME, SUBSTRING(e.Created, 1, 23)) AS Submission_date_time,
           p.email AS Submitter_email,
           e.FileId,
           bn.BlobName,
           f.FileName AS Csv_file_name,
           e.SubmissionId,
           p.FirstName,
           p.LastName,
           CASE
               WHEN pr.FileId IS NOT NULL THEN
                   'Processed'
               WHEN npr.FileId IS NOT NULL THEN
                   'Unprocessed'
           END AS Status,
           ROW_NUMBER() OVER (partition BY e.FileId
                              ORDER BY CONVERT(DATETIME, SUBSTRING(e.Created, 1, 23)) DESC
                             ) AS Rank_On_File_Name
    FROM se e
        LEFT JOIN [rpd].[Users] u
            ON e.UserId = u.UserId
        LEFT JOIN [rpd].[Persons] p
            ON p.userid = u.id
        LEFT JOIN file_data f
            ON f.FileId = e.FileId
        LEFT JOIN sub_data s
            ON s.SubmissionId = e.SubmissionId
        LEFT JOIN [rpd].[Organisations] org
            ON org.externalid = s.OrganisationId
        LEFT JOIN [rpd].[files_processed] pr
            ON pr.FileId = e.FileId
               AND UPPER(TRIM(pr.FileType)) = UPPER(TRIM(f.FileType))
        LEFT JOIN [rpd].[files_not_processed] npr
            ON npr.FileId = e.FileId
               AND UPPER(TRIM(npr.FileType)) = UPPER(TRIM(f.FileType))
        LEFT JOIN blob_name_with_File_id bn
            ON bn.FileId = e.FileId
) A
WHERE FileId IS NOT NULL
      AND submissionperiod IS NOT NULL
      AND Rank_On_File_Name = 1
      AND BlobName IS NOT NULL;