CREATE VIEW [dbo].[v_public_register_all_producers]
AS
WITH all_org_with_status AS (
    SELECT DISTINCT
        meta.organisationid,
        cd.organisation_id,
        cd.filename,
        CAST(CONVERT(DATETIMEOFFSET, meta.created) AS DATETIME) AS submitted_time,
        '20' + REVERSE(SUBSTRING(REVERSE(TRIM(meta.SubmissionPeriod)), 1, 2)) AS SubmissionYear,
        meta.RegistrationJourney,
        UPPER(TRIM(ISNULL(file_status.Regulator_Status, ''))) AS Regulator_Status,
        file_status.decision_date,
        file_status.SubmissionId,
        file_status.ApplicationReferenceNo,
        file_status.registrationreferencenumber
    FROM [rpd].[CompanyDetails] cd
    LEFT JOIN [dbo].[v_submitted_pom_org_file_status] file_status
        ON (file_status.filetype = 'CompanyDetails' AND file_status.FileName = cd.filename)
    LEFT JOIN [rpd].[cosmos_file_metadata] meta
        ON meta.filename = cd.filename
),
all_latest_org_files AS (
    SELECT *
    FROM (
        SELECT *,
            ROW_NUMBER() OVER(
                PARTITION BY organisationid, SubmissionYear, RegistrationJourney
                ORDER BY submitted_time DESC
            ) AS rn
        FROM all_org_with_status
        WHERE Regulator_Status IN ('ACCEPTED', 'CANCELLED', 'GRANTED')
          AND SubmissionYear >= 2025
    ) al
    WHERE al.rn = 1
),
accepted_status_for_apps AS (
    SELECT DISTINCT
        SubmissionId,
        registrationreferencenumber,
        Decision
    FROM (
        SELECT
            se.SubmissionId,
            se.ApplicationReferenceNumber,
            se.created,
            se.[Type],
            se.registrationreferencenumber,
            se.Decision,
            ROW_NUMBER() OVER(PARTITION BY se.SubmissionId ORDER BY se.created DESC) AS rownum
        FROM rpd.SubmissionEvents se
        WHERE se.type = 'RegulatorRegistrationDecision'
          AND se.Decision = 'Accepted'
          AND se.AppReferenceNumber IS NOT NULL
    ) a
    WHERE a.rownum = 1
),
cancelled_status_for_apps AS (
    SELECT DISTINCT
        SubmissionId,
        registrationreferencenumber,
        Decision
    FROM (
        SELECT
            se.SubmissionId,
            se.ApplicationReferenceNumber,
            se.created,
            se.[Type],
            se.registrationreferencenumber,
            se.Decision,
            ROW_NUMBER() OVER(PARTITION BY se.SubmissionId ORDER BY se.created DESC) AS rownum
        FROM rpd.SubmissionEvents se
        WHERE se.type = 'RegulatorRegistrationDecision'
          AND se.Decision = 'Cancelled'
          AND se.AppReferenceNumber IS NOT NULL
    ) a
    WHERE a.rownum = 1
),
assign_accepted_to_cancelled AS (
    SELECT
        ca.SubmissionId,
        aa.registrationreferencenumber AS acc_registrationreferencenumber,
        ca.registrationreferencenumber AS can_registrationreferencenumber
    FROM cancelled_status_for_apps ca
    LEFT JOIN accepted_status_for_apps aa
        ON ca.SubmissionId = aa.SubmissionId
),
org_result AS (
    SELECT DISTINCT
        cds.organisation_id AS 'Organisation_ID',
        cds.organisation_size AS 'Large/Small',
        cds.liable_for_disposal_costs_flag AS required_to_pay_disposal_fee,
        CASE
            WHEN UPPER(ISNULL(cds.organisation_size, 'L')) = 'L'
                 AND (meta.ComplianceSchemeId IS NULL AND cds.subsidiary_id IS NULL) THEN 'Yes'
            ELSE 'No'
        END AS subject_to_recycling_and_certification_obligations,
        '' AS 'submission_period',
        cs.Name AS 'Name_of_compliance_scheme',
        TRIM(cds.companies_house_number) AS 'Companies_House_number',
        COALESCE(cds.subsidiary_id, '') AS 'Subsidiary_ID',
        TRIM(cds.organisation_name) AS 'Organisation_name',
        TRIM(cds.Trading_Name) AS 'Trading_name',
        TRIM(cds.registered_addr_line1) AS 'Address_line_1',
        TRIM(cds.registered_addr_line2) AS 'Address_line_2',
        '' AS 'Address_line_3',
        '' AS 'Address_line_4',
        TRIM(cds.registered_city) AS 'Town',
        TRIM(cds.registered_addr_county) AS 'County',
        TRIM(cds.registered_addr_country) AS 'Country',
        TRIM(cds.registered_addr_postcode) AS 'Postcode',
        producernation.Name AS ProducerNation,
        producernation.Id AS ProducerNationId,
        csnation.Name AS ComplianceSchemeNation,
        csnation.Id AS ComplianceSchemeNationId,
        pr.ReferenceNumber AS ProducerId,
        CASE producernation.Id
            WHEN 1 THEN 'Environment Agency (England)'
            WHEN 2 THEN 'Northern Ireland Environment Agency'
            WHEN 3 THEN 'Scottish Environment Protection Agency'
            WHEN 4 THEN 'Natural Resources Wales'
        END AS 'Environmental_regulator',
        CASE csnation.Id
            WHEN 1 THEN 'Environment Agency (England)'
            WHEN 2 THEN 'Northern Ireland Environment Agency'
            WHEN 3 THEN 'Scottish Environment Protection Agency'
            WHEN 4 THEN 'Natural Resources Wales'
        END AS 'Compliance_scheme_regulator',
        cd.SubmissionYear AS 'Reporting_year',
        meta.created AS SubmittedDateTime,
        cd.regulator_status,
        CASE WHEN cd.regulator_status IN ('GRANTED', 'ACCEPTED') THEN cd.decision_date END AS registration_date,
        CASE WHEN cd.regulator_status = 'CANCELLED' THEN cd.decision_date END AS cancellation_date,
        CASE
            WHEN meta.ComplianceSchemeId IS NOT NULL AND cd.regulator_status IN ('GRANTED', 'ACCEPTED')
                THEN CONCAT(cd.registrationreferencenumber, cds.organisation_id, cds.subsidiary_id)
            WHEN meta.ComplianceSchemeId IS NOT NULL AND cd.regulator_status = 'CANCELLED'
                THEN CONCAT(aac.acc_registrationreferencenumber, cds.organisation_id, cds.subsidiary_id)
            WHEN meta.ComplianceSchemeId IS NULL AND cd.regulator_status IN ('GRANTED', 'ACCEPTED')
                THEN CONCAT(cd.registrationreferencenumber, cds.subsidiary_id)
            WHEN meta.ComplianceSchemeId IS NULL AND cd.regulator_status = 'CANCELLED'
                THEN CONCAT(aac.acc_registrationreferencenumber, cds.subsidiary_id)
            ELSE ''
        END AS Producer_Registration_Number
    FROM all_latest_org_files cd
    INNER JOIN [rpd].[CompanyDetails] cds
        ON cds.Filename = cd.Filename
        AND cds.leaver_date IS NULL
    LEFT JOIN [dbo].[v_cosmos_file_metadata] meta
        ON meta.FileName = cd.FileName
    LEFT JOIN dbo.v_rpd_ComplianceSchemes_Active cs
        ON meta.ComplianceSchemeId = cs.ExternalId
    LEFT JOIN dbo.v_rpd_Organisations_Active pr
        ON cd.organisation_id = pr.ReferenceNumber
    LEFT JOIN rpd.Nations producernation
        ON pr.NationId = producernation.Id
    LEFT JOIN rpd.Nations csnation
        ON cs.NationId = csnation.Id
    LEFT JOIN [dbo].[v_registration_latest_by_Year] rl
        ON cd.organisation_id = rl.organisation_id
        AND ISNULL(cds.subsidiary_id, '') = ISNULL(rl.subsidiary_id, '')
        AND rl.Reporting_year = cd.SubmissionYear
    LEFT JOIN assign_accepted_to_cancelled aac
        ON aac.SubmissionId = cd.SubmissionId
    LEFT JOIN (
        SELECT FromOrganisation_ReferenceNumber, EnrolmentStatuses_EnrolmentStatus
        FROM dbo.t_rpd_data_SECURITY_FIX
        GROUP BY FromOrganisation_ReferenceNumber, EnrolmentStatuses_EnrolmentStatus
    ) e_status
        ON e_status.FromOrganisation_ReferenceNumber = cd.organisation_id
    WHERE (cs.IsDeleted = 0 OR cs.IsDeleted IS NULL)
      AND (pr.isdeleted = 0 OR pr.isdeleted IS NULL)
      AND e_status.EnrolmentStatuses_EnrolmentStatus <> 'Rejected'
      AND (pr.IsComplianceScheme = 0 OR pr.IsComplianceScheme IS NULL)
)
SELECT
    Organisation_ID,
    [Large/Small],
    Required_to_pay_disposal_fee,
    Subject_to_recycling_and_certification_obligations,
    Producer_Registration_Number,
    submission_period,
    Name_of_compliance_scheme,
    Companies_House_number,
    Subsidiary_ID,
    Organisation_name,
    Trading_name,
    Address_line_1,
    Address_line_2,
    Address_line_3,
    Address_line_4,
    Town,
    County,
    Country,
    Postcode,
    ProducerNation,
    ProducerNationId,
    ComplianceSchemeNation,
    ComplianceSchemeNationId,
    ProducerId,
    Environmental_regulator,
    Compliance_scheme_regulator,
    Reporting_year,
    regulator_status,
    Registration_date,
    Cancellation_date
FROM org_result;