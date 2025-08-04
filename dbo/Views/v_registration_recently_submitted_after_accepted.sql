CREATE VIEW [dbo].[v_registration_recently_submitted_after_accepted]
AS WITH LastAccepted AS (
    SELECT 
        rv.organisation_id,
        rv.subsidiary_id,
        MAX(se.created) AS LastAcceptedDate
    FROM 
        rpd.CompanyDetails rv
    JOIN 
        v_cosmos_file_metadata cs ON cs.filename = rv.[FileName]
    INNER JOIN 
        rpd.SubmissionEvents se ON se.fileid = cs.fileid 
        AND se.[type] = 'RegulatorRegistrationDecision' 
        AND se.[Decision] = 'Accepted'
    GROUP BY 
        rv.organisation_id, rv.subsidiary_id
),
RecentlySubmitted AS (
    SELECT DISTINCT
        rv.organisation_id,
        rv.subsidiary_id,
        rv.registration_type_code,
        cs.created AS SubmittedDateTime,
        cs.filename,
        rv.organisation_type_code,
        rv.companies_house_number,
        rv.organisation_name,
        rv.Trading_Name,
        rv.registered_addr_line1,
        rv.registered_addr_line2,
        rv.registered_city,
        rv.registered_addr_country,
        rv.registered_addr_county,
        rv.registered_addr_postcode,
        CASE 
            WHEN rv.organisation_sub_type_code = 'LIC' THEN 'Licensor'
            WHEN rv.organisation_sub_type_code = 'POB' THEN 'Pub operating business'
            WHEN rv.organisation_sub_type_code = 'FRA' THEN 'Franchisor'
            WHEN rv.organisation_sub_type_code = 'NAO' THEN 'Non-associated organisation'
            WHEN rv.organisation_sub_type_code = 'HCY' THEN 'Holding company'
            WHEN rv.organisation_sub_type_code = 'SUB' THEN 'Subsidiary'
            WHEN rv.organisation_sub_type_code = 'LFR' THEN 'Licensee/Franchisee'
            WHEN rv.organisation_sub_type_code = 'TEN' THEN 'Tenant'
            WHEN rv.organisation_sub_type_code = 'OTH' THEN 'Others'
            ELSE NULL
        END AS Org_Sub_Type,
        CASE
            WHEN rv.organisation_type_code = 'SOL' THEN 'Sole trader'
            WHEN rv.organisation_type_code = 'PAR' THEN 'Partnership'
            WHEN rv.organisation_type_code = 'REG' THEN 'Regulator'
            WHEN rv.organisation_type_code = 'PLC' THEN 'Public limited company'
            WHEN rv.organisation_type_code = 'LLP' THEN 'Limited Liability partnership'
            WHEN rv.organisation_type_code = 'LTD' THEN 'Limited Liability company'
            WHEN rv.organisation_type_code = 'LPA' THEN 'Limited partnership'
            WHEN rv.organisation_type_code = 'COP' THEN 'Co-operative'
            WHEN rv.organisation_type_code = 'CIC' THEN 'Community interest Company'
            WHEN rv.organisation_type_code = 'OUT' THEN 'Outside UK'
            WHEN rv.organisation_type_code = 'OTH' THEN 'Others'
            ELSE NULL
        END AS organisation_type_code_description,
        ROW_NUMBER() OVER(PARTITION BY rv.organisation_id, rv.subsidiary_id ORDER BY cs.created DESC) AS rn
    FROM 
        rpd.CompanyDetails rv
    JOIN 
        v_cosmos_file_metadata cs ON cs.filename = rv.[FileName]
    LEFT JOIN 
        LastAccepted la ON la.organisation_id = rv.organisation_id 
        AND la.subsidiary_id = rv.subsidiary_id
    WHERE 
        cs.created > ISNULL(la.LastAcceptedDate, '1900-01-01') -- if no accepted record, takes all submitted files
)
SELECT *
FROM RecentlySubmitted
WHERE rn = 1;