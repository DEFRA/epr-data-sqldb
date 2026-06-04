/*
    CCoE extract the data as per the EPR Standard Change Runbook -> https://eaflood.atlassian.net/wiki/spaces/EDIA/pages/6283198465/EPR+Standard+Change+Runbook+-+Data+Files+Move+V5
    Main consumer -> Matthew Cooper <Matthew.Cooper2@environment-agency.gov.uk>
*/
WITH setid_fileid AS
(
    /*----------------------------------------------------------------------
      lookup RegistrationSetId against 'FileId' to get the correct 'Brands'
      and 'Partnerships' records if submitted along with 'CompanyDetails' file.
    ----------------------------------------------------------------------*/
    SELECT DISTINCT
        RegistrationSetId,
        FileId,
        FileType
    FROM [rpd].[SubmissionEvents]
    WHERE RegistrationSetId IS NOT NULL
),

file_data AS
(
    SELECT DISTINCT
        FileId,
        FileName,
        FileType
    FROM [rpd].[SubmissionEvents]
    WHERE FileName IS NOT NULL
      AND FileType IS NOT NULL
),

blob_name_with_File_id AS
(
    SELECT DISTINCT
        FileId,
        BlobName
    FROM [rpd].[SubmissionEvents]
    WHERE FileId IS NOT NULL
      AND BlobName IS NOT NULL
      AND Type != 'FileDownloadCheck'
      AND FileId != BlobName
),

sub_data AS
(
    SELECT DISTINCT
        SubmissionId,
        OrganisationId,
        SubmissionPeriod,
        SubmissionType,
        RegistrationJourney
    FROM [rpd].[Submissions]
),

se AS
(
    -- This CTE has two types of records combined by UNION:
    -- 1. 'Submitted' records (POM, CompanyDetails only)
    -- 2. Brand and Partner files optionally submitted with CompanyDetails

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
    FROM [rpd].[SubmissionEvents]
    WHERE Type = 'Submitted'

    UNION ALL

    SELECT
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
    FROM
    (
        /*----------------------------------------------------------------------
          Logic summary:
          1. Start with 'Submitted' records (FileId populated, RegistrationSetId not).
          2. Derive RegistrationSetId via FileId using setid_fileid CTE.
          3. Select latest Brands / Partnerships records per submission.
          4. Created/UserId sourced from 'Submitted' record.
        ----------------------------------------------------------------------*/
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
            ROW_NUMBER() OVER
            (
                PARTITION BY
                    seb.SubmissionId,
                    seb.RegistrationSetId,
                    seb.FileType
                ORDER BY
                    CONVERT(DATETIME, SUBSTRING(seb.Created, 1, 23)) DESC
            ) AS Rank_On_Brand_and_Partner
        FROM [rpd].[SubmissionEvents] ses
        JOIN setid_fileid ses_setid ON ses_setid.FileId = ses.FileId
        JOIN [rpd].[SubmissionEvents] seb ON seb.RegistrationSetId = ses_setid.RegistrationSetId
        WHERE seb.FileType IN ('Brands', 'Partnerships')
          AND ses.Type = 'Submitted'
    ) A
    WHERE A.Rank_On_Brand_and_Partner = 1
),

result AS
(
    SELECT DISTINCT
        SubmissionId,
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
        Status,
        RegistrationJourney,
        OrgSummary_SubmissionStatus,
        OrgSummary_ResubmissionStatus,
        POM_Decision
    FROM
    (
        SELECT DISTINCT
            se.RegistrationSetId,
            org.Id AS Org_Id,
            org.ReferenceNumber AS OrgId,
            org.Name AS Org_Name,
            org.CompaniesHouseNumber,
            org.IsComplianceScheme,
            f.FileType,
            s.SubmissionPeriod,
            try_cast(RIGHT(s.submissionperiod, 4) as int) AS SubmissionPeriod_Year,
            s.SubmissionType,
            CONVERT(DATETIME, SUBSTRING(se.Created, 1, 23)) AS Submission_date_time,
            p.Email AS Submitter_email,
            se.FileId,
            bn.BlobName,
            f.FileName AS Csv_file_name,
            se.SubmissionId,
            p.FirstName,
            p.LastName,
            CASE
                WHEN pr.FileId IS NOT NULL THEN 'Processed'
                WHEN npr.FileId IS NOT NULL THEN 'Unprocessed'
            END AS Status,
            s.RegistrationJourney,
            org_sum.SubmissionStatus as OrgSummary_SubmissionStatus,
            org_sum.ResubmissionStatus as OrgSummary_ResubmissionStatus,
            sub_sum.Decision as POM_Decision,
            ROW_NUMBER() OVER
            (
                PARTITION BY se.FileId
                ORDER BY CONVERT(DATETIME, SUBSTRING(se.Created, 1, 23)) DESC
            ) AS Rank_On_File_Name
        FROM se
        LEFT JOIN [rpd].[Users] u ON se.UserId = u.UserId
        LEFT JOIN [rpd].[Persons] p ON p.UserId = u.Id
        LEFT JOIN file_data f ON f.FileId = se.FileId
        LEFT JOIN sub_data s ON s.SubmissionId = se.SubmissionId
        LEFT JOIN [rpd].[Organisations] org ON org.ExternalId = s.OrganisationId
        LEFT JOIN [rpd].[files_processed] pr ON pr.FileId = se.FileId
           AND UPPER(TRIM(pr.FileType)) = UPPER(TRIM(f.FileType))
        LEFT JOIN [rpd].[files_not_processed] npr ON npr.FileId = se.FileId
           AND UPPER(TRIM(npr.FileType)) = UPPER(TRIM(f.FileType))
        LEFT JOIN blob_name_with_File_id bn ON bn.FileId = se.FileId
        LEFT JOIN apps.OrgRegistrationsSummaries org_sum ON org_sum.SubmissionId = se.SubmissionId
        LEFT JOIN apps.SubmissionsSummaries sub_sum ON sub_sum.SubmissionId = se.SubmissionId
    ) B
    WHERE FileId IS NOT NULL
      AND SubmissionPeriod IS NOT NULL
      AND FileType IS NOT NULL
      AND Rank_On_File_Name = 1
)

select *
from result
order by try_cast(right(SubmissionPeriod, 4) as int) desc,
         CompaniesHouseNumber,
         Submission_date_time