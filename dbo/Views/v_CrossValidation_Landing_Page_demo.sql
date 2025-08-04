CREATE VIEW [dbo].[v_CrossValidation_Landing_Page_demo]
AS WITH base_data AS (
    SELECT 
        m.OrganisationId,
        m.SubmissionPeriod,
        m.OriginalFileName,
        CASE 
            WHEN m.SubmissionPeriod IN ('Jan to Jun 2023', 'January to June 2023') THEN 1 
            WHEN m.SubmissionPeriod = 'July to December 2023' THEN 2
            WHEN m.SubmissionPeriod IN ('Jan to Jun 2024', 'January to June 2024') THEN 3 
            WHEN m.SubmissionPeriod = 'July to December 2024' THEN 4
            WHEN m.SubmissionPeriod IN ('Jan to Jun 2025', 'January to June 2025') THEN 5 
            WHEN m.SubmissionPeriod = 'July to December 2025' THEN 6
            WHEN m.SubmissionPeriod IN ('Jan to Jun 2026', 'January to June 2026') THEN 7 
            WHEN m.SubmissionPeriod = 'July to December 2026' THEN 8
            WHEN m.SubmissionPeriod IN ('Jan to Jun 2027', 'January to June 2027') THEN 9 
            WHEN m.SubmissionPeriod = 'July to December 2027' THEN 10
            WHEN m.SubmissionPeriod IN ('Jan to Jun 2028', 'January to June 2028') THEN 11 
            WHEN m.SubmissionPeriod = 'July to December 2028' THEN 12
            ELSE 0
        END AS SubmissionPeriod_id,
        CONVERT(DATETIME, SUBSTRING(m.Created, 1, 23)) AS Submission_time,
        m.FileType,
        m.filename,
        st.Regulator_Status,
        m.ComplianceSchemeId,
        cs.name AS CS_Name,
        n.name AS CS_nation,
        -- Corrected RelevantYear logic:
        CASE 
            WHEN m.SubmissionPeriod LIKE 'July to December%' 
                THEN CAST('20' + RIGHT(LTRIM(RTRIM(m.SubmissionPeriod)), 2) AS INT) + 1
            WHEN m.SubmissionPeriod LIKE 'Jan to Jun%' 
                THEN CAST('20' + RIGHT(LTRIM(RTRIM(m.SubmissionPeriod)), 2) AS INT)
            WHEN m.SubmissionPeriod LIKE 'January to June%' 
                THEN CAST('20' + RIGHT(LTRIM(RTRIM(m.SubmissionPeriod)), 2) AS INT)
            ELSE NULL
        END AS RelevantYear,
        CONVERT(datetime2, REPLACE(REPLACE(m.Created, 'T', ' '), 'Z', ' ')) AS Created_frmtDT,
        o.Name AS ProducerName,
        o.NationId AS ProducerNationId
    FROM 
        rpd.cosmos_file_metadata m
    INNER JOIN 
        dbo.v_submitted_pom_org_file_status st ON m.filename = st.FileName
    LEFT JOIN 
        rpd.ComplianceSchemes cs ON cs.externalid = m.ComplianceSchemeId
    LEFT JOIN 
        rpd.Nations n ON n.id = cs.NationId
    LEFT JOIN 
        rpd.Organisations o ON o.ExternalId = m.OrganisationId
),

all_CompanyDetails AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY OrganisationId, RelevantYear ORDER BY Submission_time DESC) AS cd_rn
    FROM base_data
    WHERE 
        UPPER(FileType) = 'COMPANYDETAILS' 
        AND (
            ComplianceSchemeId IS NOT NULL OR 
            (
                ComplianceSchemeId IS NULL AND UPPER(TRIM(ISNULL(Regulator_Status, 'PENDING'))) IN ('PENDING', 'ACCEPTED', 'GRANTED', 'QUERIED')
            )
        )
        -- Global filter to remove 'uploaded' for 2025 onwards
        AND NOT (
            UPPER(TRIM(ISNULL(Regulator_Status, ''))) = 'UPLOADED'
            AND RelevantYear >= 2025
        )
),

DP_latest_CS_all_companydetails AS (
    SELECT * 
    FROM all_CompanyDetails
    WHERE (cd_rn = 1 AND ComplianceSchemeId IS NULL) OR ComplianceSchemeId IS NOT NULL
),

all_pom AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY OrganisationId, RelevantYear ORDER BY Submission_time DESC) AS cd_rn
    FROM base_data
    WHERE 
        UPPER(FileType) = 'POM' 
        AND (
            ComplianceSchemeId IS NOT NULL OR 
            (
                ComplianceSchemeId IS NULL AND UPPER(TRIM(ISNULL(Regulator_Status, 'PENDING'))) IN ('PENDING', 'ACCEPTED', 'GRANTED', 'QUERIED')
            )
        )
        -- Global filter to remove 'uploaded' for 2025 onwards
        AND NOT (
            UPPER(TRIM(ISNULL(Regulator_Status, ''))) = 'UPLOADED'
            AND RelevantYear >= 2025
        )
),

DP_latest_CS_all_pom AS (
    SELECT * 
    FROM all_pom
    WHERE ComplianceSchemeId IS NOT NULL OR (cd_rn = 1 AND ComplianceSchemeId IS NULL)
),

org_pom_combined AS (
    SELECT 
        ISNULL(cd_o.ReferenceNumber, p_o.ReferenceNumber) AS file_submitted_organisation, 
        ISNULL(cd_o.IsComplianceScheme, p_o.IsComplianceScheme) AS file_submitted_organisation_IsComplianceScheme,
        ISNULL(cd.OrganisationId, p.OrganisationId) AS OrganisationId,
        cd.SubmissionPeriod, 
        cd.SubmissionPeriod_id, 
        cd.Submission_time AS cd_Submission_time,
        ISNULL(cd.Regulator_Status, 'Pending') AS Org_Regulator_Status,
        cd.FileType AS cd_filetype, 
        cd.filename AS cd_filename,
        p.Submission_time AS pom_Submission_time,
        ISNULL(p.Regulator_Status, 'Pending') AS Pom_Regulator_Status,
        p.FileType AS pom_filetype, 
        p.filename AS pom_filename,
        p.ComplianceSchemeId AS pom_cs_id,
        p.SubmissionPeriod AS pom_SubmissionPeriod,
        p.SubmissionPeriod_id AS pom_id,
        cd.ComplianceSchemeId AS org_cs_id,
        cd.RelevantYear,
        CASE 
            WHEN p.ComplianceSchemeId IS NULL THEN 'Direct Producer' 
            ELSE 'Compliance Scheme' 
        END AS CS_or_DP,
        p.CS_Name,
        p.CS_nation,
        CONCAT(cd.OriginalFileName, '_', FORMAT(CONVERT(datetime, cd.Created_frmtDT, 122), 'yyyyMMddHHmiss'), '_', ISNULL(cd.Regulator_Status, 'Pending')) AS DisplayFilenameCD,
        CONCAT(p.OriginalFileName, '_', FORMAT(CONVERT(datetime, p.Created_frmtDT, 122), 'yyyyMMddHHmiss'), '_', ISNULL(p.Regulator_Status, 'Pending')) AS DisplayFilenamePOM,
        CONCAT(FORMAT(CONVERT(datetime, cd.Created_frmtDT, 122), 'yyyyMMddHHmiss'), '_', cd.OriginalFileName, '_', ISNULL(cd.Regulator_Status, 'Pending')) AS DisplayFilenameCDSort,
        CONCAT(FORMAT(CONVERT(datetime, p.Created_frmtDT, 122), 'yyyyMMddHHmiss'), '_', p.OriginalFileName, '_', ISNULL(p.Regulator_Status, 'Pending')) AS DisplayFilenamePOMSort,
        ISNULL(cd_o.Name, p_o.Name) AS ProducerName,
        ISNULL(cd_o.NationId, p_o.NationId) AS ProducerNationId
    FROM 
        DP_latest_CS_all_companydetails cd 
    LEFT JOIN  
        DP_latest_CS_all_pom p ON p.OrganisationId = cd.OrganisationId
        AND ISNULL(p.ComplianceSchemeId, '') = ISNULL(cd.ComplianceSchemeId, '')
        AND p.RelevantYear = cd.RelevantYear
    LEFT JOIN 
        rpd.Organisations cd_o ON cd.OrganisationId = cd_o.ExternalId
    LEFT JOIN 
        rpd.Organisations p_o ON p.OrganisationId = p_o.ExternalId
)

SELECT 
    opc.*,
    np.Name AS ProducerNationName
FROM 
    org_pom_combined opc
JOIN 
    rpd.Nations np ON np.id = opc.ProducerNationId;