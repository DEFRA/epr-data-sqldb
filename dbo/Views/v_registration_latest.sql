CREATE VIEW [dbo].[v_registration_latest] AS WITH lsubmitted AS (
/*****************************************************************************************************************
	History:

	Updated 2024-07-23: ST001:	Updated underlying logic for Organisation Detail columns: org_name, org_sub_type and registration_type_code
								Previously using the latest submitted file - now using the most recently accepted based on the decision date
								When there is no accepted file -  reverts to using the latest submitted


 *****************************************************************************************************************/
SELECT  distinct
	rv.organisation_id,
	rv.subsidiary_id,
	registration_type_code,
	rv.organisation_type_code,
	rv.companies_house_number,
	cs.created as SubmittedDateTime,
	cs.filename,
	rv.Trading_Name,
	rv.registered_addr_line1,
	rv.registered_addr_line2,
	rv.registered_city,
	rv.registered_addr_country,
	rv.registered_addr_county,
	rv.registered_addr_postcode,
	cs.created,
	rv.organisation_name,
	case 
		when rv.[organisation_sub_type_code]  = 'LIC' then 'Licensor'
		when rv.[organisation_sub_type_code]  = 'POB' then 'Pub operating business '
		when rv.[organisation_sub_type_code]  = 'FRA' then 'Franchisor '
		when rv.[organisation_sub_type_code]  = 'NAO' then 'Non-associated organisation'
		when rv.[organisation_sub_type_code]  = 'HCY' then 'Holding company'
		when rv.[organisation_sub_type_code]  = 'SUB' then 'Subsidiary'
		when rv.[organisation_sub_type_code]  = 'LFR' then 'Licensee/Franchisee'
		when rv.[organisation_sub_type_code]  = 'TEN' then 'Tenant'
		when rv.[organisation_sub_type_code]  = 'OTH' then 'Others'
	else NULL 
	end [Org_Sub_Type],
	row_number() over(partition by organisation_id, subsidiary_id order by cs.created desc) as RowNum
	FROM rpd.CompanyDetails rv
	join dbo.t_cosmos_file_metadata cs on cs.filename = rv.[FileName]
--Joining to the view to ensure still handling for soft deletes - however not doing any filtering on the status
--also filters out duplicate submissions of the same file
    INNER JOIN dbo.v_submitted_pom_org_file_status fs ON rv.[filename] = fs.[filename] WHERE fs.filetype = 'CompanyDetails'

),
--mraccepted retrieves just the accepted files and then orders on the Decision_Date in order get the most recently accepted--
mraccepted AS (
    SELECT  distinct
	rv.organisation_id,
	rv.subsidiary_id,
	registration_type_code,
	cs.filename,
	rv.organisation_name,
	case 
		when rv.[organisation_sub_type_code]  = 'LIC' then 'Licensor'
		when rv.[organisation_sub_type_code]  = 'POB' then 'Pub operating business '
		when rv.[organisation_sub_type_code]  = 'FRA' then 'Franchisor '
		when rv.[organisation_sub_type_code]  = 'NAO' then 'Non-associated organisation'
		when rv.[organisation_sub_type_code]  = 'HCY' then 'Holding company'
		when rv.[organisation_sub_type_code]  = 'SUB' then 'Subsidiary'
		when rv.[organisation_sub_type_code]  = 'LFR' then 'Licensee/Franchisee'
		when rv.[organisation_sub_type_code]  = 'TEN' then 'Tenant'
		when rv.[organisation_sub_type_code]  = 'OTH' then 'Others'
	else NULL 
	end [Org_Sub_Type],
--Orders on the decision date rather than the cs created which is the submitted date 
	row_number() over(partition by organisation_id, subsidiary_id order by fs.Decision_Date desc) as RowNum
	FROM rpd.CompanyDetails rv
	join dbo.t_cosmos_file_metadata cs on cs.filename = rv.[FileName]
	INNER JOIN dbo.v_submitted_pom_org_file_status fs ON rv.[filename] = fs.[filename] WHERE fs.filetype = 'CompanyDetails' AND fs.Regulator_Status = 'Accepted'
)
--The majority of the query is retrieving from subquery 1
--However for specific columns where the business requirement was to apply the new logic
--The script has CASE statements, ensuring that mraccepted (most recently accepted) is used where possible over latest submitted
--Note - most of these columns are not actually used by the stored procedure anyway
SELECT  distinct
	lsubmitted.organisation_id,
	lsubmitted.subsidiary_id,
	CASE 
		WHEN mraccepted.Organisation_id is not null
		THEN mraccepted.registration_type_code
	ELSE lsubmitted.registration_type_code
	END AS registration_type_code,
	lsubmitted.created as SubmittedDateTime,
	lsubmitted.filename,
	CASE 
		WHEN mraccepted.Organisation_id is not null
		THEN mraccepted.org_sub_type
	ELSE lsubmitted.org_sub_type
	END AS [org_sub_type],
	lsubmitted.organisation_type_code,
	CASE
		WHEN lsubmitted.organisation_type_code = 'SOL'	THEN	'Sole trader'
		WHEN lsubmitted.organisation_type_code = 'PAR'	THEN	'Partnership'
		WHEN lsubmitted.organisation_type_code = 'REG'	THEN	'Regulator'
		WHEN lsubmitted.organisation_type_code = 'PLC'	THEN	'Public limited company'
		WHEN lsubmitted.organisation_type_code = 'LLP'	THEN	'Limited Liability partnership'
		WHEN lsubmitted.organisation_type_code = 'LTD'	THEN	'Limited Liability company'
		WHEN lsubmitted.organisation_type_code = 'LPA'	THEN	'Limited partnership'
		WHEN lsubmitted.organisation_type_code = 'COP'	THEN	'Co-operative'
		WHEN lsubmitted.organisation_type_code = 'CIC'	THEN	'Community interest Company'
		WHEN lsubmitted.organisation_type_code = 'OUT'	THEN	'Outside UK'
		WHEN lsubmitted.organisation_type_code = 'OTH'	THEN	'Others'
	ELSE NULL 
	END as organisation_type_code_description,
	lsubmitted.companies_house_number,
	CASE 
		WHEN mraccepted.Organisation_id is not null 
		THEN mraccepted.organisation_name
	ELSE lsubmitted.organisation_name
	END AS [organisation_name],
	lsubmitted.Trading_Name,
	lsubmitted.registered_addr_line1,
	lsubmitted.registered_addr_line2,
	lsubmitted.registered_city,
	lsubmitted.registered_addr_country,
	lsubmitted.registered_addr_county,
	lsubmitted.registered_addr_postcode,
	lsubmitted.created,
	lsubmitted.RowNum as rn
	FROM 
	lsubmitted
	LEFT JOIN mraccepted  ON convert(int,mraccepted.organisation_id) = convert(int,lsubmitted.organisation_id) AND Isnull(mraccepted.subsidiary_id,'x') = Isnull(lsubmitted.subsidiary_id,'x') AND mraccepted.RowNum = 1
	WHERE lsubmitted.RowNum = 1;