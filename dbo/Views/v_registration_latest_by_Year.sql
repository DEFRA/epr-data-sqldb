﻿CREATE VIEW [dbo].[v_registration_latest_by_Year] AS select *
from
(


	select *,
		row_number() over(partition by organisation_id, subsidiary_id, Reporting_year order by SubmittedDateTime desc) as rn
	from
	(
		SELECT  distinct
		rv.organisation_id,
		rv.subsidiary_id,
		registration_type_code
		,cs.created as SubmittedDateTime
		,cs.filename
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
		rv.companies_house_number,
		rv.organisation_name,
		rv.Trading_Name,
		rv.registered_addr_line1,
		rv.registered_addr_line2,
		rv.registered_city,
		rv.registered_addr_country,
		rv.registered_addr_county,
		rv.registered_addr_postcode,
		cs.created,
		'20'+reverse(substring(reverse(trim(cs.SubmissionPeriod)),1,2)) as 'Reporting_year'
		
		FROM 
			   rpd.CompanyDetails rv
				join v_cosmos_file_metadata cs on cs.filename = rv.[FileName]
	) B


)A
where A.rn = 1;