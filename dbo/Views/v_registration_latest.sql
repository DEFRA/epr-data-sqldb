CREATE VIEW [dbo].[v_registration_latest] AS SELECT  distinct
rv.organisation_id,
rv.subsidiary_id,
registration_type_code
,case 
    when rv.[organisation_sub_type_code]  = 'LIC' then 'Licensor'
    when rv.[organisation_sub_type_code]  = 'POB' then 'Pub operating business '
    when rv.[organisation_sub_type_code]  = 'FRA' then 'Franchisor '
    when rv.[organisation_sub_type_code]  = 'NAO' then 'Non-associated organisation'
    when rv.[organisation_sub_type_code]  = 'HCY' then 'Holding company'
    when rv.[organisation_sub_type_code]  = 'SUB' then 'Subsidiary'
    when rv.[organisation_sub_type_code]  = 'LFR' then 'Licensee/Franchisee'
    when rv.[organisation_sub_type_code]  = 'TEN' then 'Tenant'
    when rv.[organisation_sub_type_code]  = 'OTH' then 'Others'
else NULL end [Org_Sub_Type], 
cs.created
FROM 
       rpd.CompanyDetails rv
        join v_cosmos_file_metadata cs on cs.filename = rv.[FileName]
INNER JOIN 
    (
        SELECT 
            organisation_id, 
            subsidiary_id, 
            MAX(cs.created) AS created
        FROM 
         rpd.CompanyDetails cd
             join v_cosmos_file_metadata cs on cs.filename = cd.[FileName]
        GROUP BY 
            organisation_id, 
            subsidiary_id
    ) latest_files ON rv.organisation_id = latest_files.organisation_id 
                    AND rv.subsidiary_id = latest_files.subsidiary_id
                    AND cs.created = latest_files.created;