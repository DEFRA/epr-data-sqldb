CREATE VIEW [dbo].[v_SubmittedFiles_DashboardReport]
AS WITH
/*

+-------------------------------------------------------------------------------------+
| Script Name: [v_SubmittedFiles_DashboardReport.sql]                                 |
| Description: [This script generates a dashboard report for the submitted files.]    |
| Author: [Prasanna Thakku Mani]                                                      |
| Date Created: [2024-03-18]                                                          |
+-------------------------------------------------------------------------------------+

+----------------- +
| Version History: |
+------------------+

Version: 1.0 
Date: [2024-03-18]
Author: [Prasanna Thakku Mani]
Description: [First Working Version. User Story 341103]

Version: 1.1
Date: [2024-07-17]
Author: [Pritam Kumar Pawar]
Description: [Rewritten the logic as per User Story 403073]

Version: 2.0
Date: [2024-09-23]
Author: [Rakesh Mamidala & Roshan Shaikh]
Description: [Ignored the previous version 1.1 by Pritam and 
             worked on top of code version 1.0 to solve  the User Stories 403073 and 433844]

*/

setid_fileid
AS (
    /*----------------------------------------------------------------------
    This is CTE is used to lookup RegistrationSetId against 'FileId'. 
    This is used to get the correct 'Brands' and 'Partnerships' records 
        if submitted along with 'CompanyDetails' file.
    ----------------------------------------------------------------------*/  
   SELECT DISTINCT
          RegistrationSetId,
          FileId,
          FileType
   FROM [rpd].[SubmissionEvents]
   WHERE RegistrationSetId IS NOT NULL
   ),

file_data
AS (
    /*----------------------------------------------------------------------
    This is CTE is used to lookup 'FileName' and 'FileType' against 'FileId'. 
    ----------------------------------------------------------------------*/
    SELECT DISTINCT
           FileId,
           FileName,
           FileType
    FROM [rpd].[SubmissionEvents]
    WHERE FileName IS NOT NULL
          AND FileType IS NOT NULL
	),

blob_name_with_File_id
AS (
    /*----------------------------------------------------------------------
    This is CTE is used to lookup 'BlobName' against 'FileId'. 
    ----------------------------------------------------------------------*/
    SELECT DISTINCT
           FileId,
           BlobName
    FROM [rpd].[SubmissionEvents]
    WHERE FileId IS NOT NULL
          AND BlobName IS NOT NULL
	),
     
sub_data
AS (
    /*--------------------------------------------------------------------------------------------
    This is CTE is used to lookup 'SubmissionPeriod' and 'SubmissionType' against 'SubmissionId'. 
    ---------------------------------------------------------------------------------------------*/
    SELECT DISTINCT
           SubmissionId,
           OrganisationId,
           SubmissionPeriod,
           SubmissionType
    FROM [rpd].[Submissions]
	),
     
se
AS (
    /*--------------------------------------------------------------------------------------------
    This CTE  has two types of records picked by UNION clause. 
    First are 'Submitted' records which are POM, CompanyDetails only.
    Second ( After union clause) are only for Brand and Partner files which are optionally submitted with CompanyDetails.
    ----------------------------------------------------------------------------------------------*/
    SELECT DISTINCT
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
        /*-----------------------------------------------------------------------------------------------------------------------------------------------
           Below SQL SELECT has following logic implemented using self join on [rpd].[SubmissionEvents]  
             1. Pick the record from [rpd].[SubmissionEvents] where Type = 'Submitted'. 
                The 'Submitted' record has 'FileId' populated but It does not have 'RegistrationSetId' populated.
             2. We find out 'RegistrationSetId' using the 'FileId' column of 'Submitted' Records.
                This is done by using CTE setid_fileid. 
                All the records for FileType IN ( 'CompanyDetails', 'Brands', 'Partnerships' ) have same 'RegistrationSetId' for the given SubmissionId.
             3. Pick all the required fields for the Latest record for FileType IN ('Brands', 'Partnerships' )
                Ranking logic is added below to get the lastest record for FileType IN ('Brands', 'Partnerships' )
             4. Some fields like 'Created' and 'UserId' are taking from records where Type = 'Submitted'
        --------------------------------------------------------------------------------------------------------------------------------------------*/
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
               seb.load_ts,
               /*-----------------------------------------------------------------------------------------------------------------------------------------------
                    Below ranking (Rank_On_Brand_and_Partner) is used to pick the last record when the same Brand or Partnership file is uploaded multiple times before submission.
                    In such case, we need to show only the last file that got actually submitted.
               -----------------------------------------------------------------------------------------------------------------------------------------------*/
               ROW_NUMBER() OVER (partition BY seb.SubmissionId, seb.RegistrationSetId, seb.FileType
                              ORDER BY CONVERT(DATETIME, SUBSTRING(seb.Created, 1, 23)) DESC
                             ) AS Rank_On_Brand_and_Partner
        FROM [rpd].[SubmissionEvents] ses
            INNER JOIN setid_fileid ses_setid
                ON ses_setid.FileId = ses.FileId
            INNER JOIN [rpd].[SubmissionEvents] seb
                ON seb.RegistrationSetId = ses_setid.RegistrationSetId
        WHERE seb.FileType IN ( 'Brands', 'Partnerships' )
              AND ses.Type = 'Submitted'
    ) A WHERE A.Rank_On_Brand_and_Partner = 1 )

-- All CTE Expressions are above this line.
SELECT DISTINCT
       -- You can cncomment below 3 lines for debugging the data issues.
       --B.FileId,
	   --B.SubmissionId,
       --B.RegistrationSetId,
       B.OrgId,
       B.Org_Name,
       B.CompaniesHouseNumber,
       B.IsComplianceScheme,
       B.FileType,
       B.SubmissionPeriod,
       B.SubmissionType,
       B.Submission_date_time,
       B.Submitter_email,
       B.BlobName,
       B.Csv_file_name,
       B.FirstName,
       B.LastName,
       B.Status
FROM
(
    SELECT DISTINCT
           e.RegistrationSetId,
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
) B
WHERE B.FileId IS NOT NULL
      /*--------------------------------------------------------------------------
       When there is no record in [rpd].[Submissions] for the given 'SubmissionId'
       'SubmissionPeriod' will be NULL. Filter out such records.
      ---------------------------------------------------------------------------*/
      AND B.SubmissionPeriod IS NOT NULL
      AND B.FileType IS NOT NULL
      AND B.Rank_On_File_Name = 1;