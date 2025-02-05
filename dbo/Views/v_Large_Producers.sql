CREATE VIEW [dbo].[v_Large_Producers] AS with all_org_with_status as
(
	select distinct cd.organisation_id
					, cd.filename
					, CAST(CONVERT(datetimeoffset, meta.created) as datetime) AS submitted_time
					,'20'+reverse(substring(reverse(trim(meta.SubmissionPeriod)),1,2)) as SubmissionYear
					,file_status.Regulator_Status
	from [rpd].[CompanyDetails] cd
	left join [dbo].[v_submitted_pom_org_file_status] file_status on file_status.FileName = cd.filename
	left join [rpd].[cosmos_file_metadata] meta on meta.filename = cd.filename
),
all_pom_with_status as
(
	select distinct pom.organisation_id
					, pom.filename
					, CAST(CONVERT(datetimeoffset, meta.created) as datetime) AS submitted_time
					,'20'+reverse(substring(reverse(trim(meta.SubmissionPeriod)),1,2)) as SubmissionYear
					,file_status.Regulator_Status
	from [rpd].[Pom] pom
	left join [dbo].[v_submitted_pom_org_file_status] file_status on file_status.FileName = pom.filename
	left join [rpd].[cosmos_file_metadata] meta on meta.filename = pom. filename
),
all_accepted_org as
(
	select * from all_org_with_status where upper(Regulator_Status) = 'ACCEPTED'
),
all_accepted_org_with_rank as
(
	select *
		, row_number() over(partition by organisation_id, SubmissionYear order by submitted_time desc) as cd_rn
	from all_accepted_org
),
latest_accepted_org as
(
	select * from all_accepted_org_with_rank where cd_rn = 1
),--till here it is fine (1)
all_accepted_pom as
(
	select * from all_pom_with_status where upper(Regulator_Status) = 'ACCEPTED'
),
all_accepted_pom_without_org as
(
	select all_accepted_pom.* 
	from all_accepted_pom
	left join all_org_with_status 
		on all_org_with_status.organisation_id = all_accepted_pom.organisation_id 
		and all_accepted_pom.SubmissionYear = all_org_with_status.SubmissionYear
		and ISNULL(upper(all_org_with_status.Regulator_Status),'') <> 'REJECTED'
	where all_org_with_status.organisation_id is null 

),
all_accepted_pom_without_org_with_rank as 
(
	select *
		, row_number() over(partition by organisation_id, SubmissionYear order by submitted_time desc) as cd_rn
	from all_accepted_pom_without_org
),
latest_accepted_pom_without_org as
(
	select * from all_accepted_pom_without_org_with_rank where cd_rn = 1
),--this is fine (2)
all_pending_andaccepted_pom as
(
	select * from all_pom_with_status where upper(ISNULL(Regulator_Status,'')) in ('', 'ACCEPTED')
),
all_pending_and_accepted_org as
(
	select * from all_org_with_status where upper(ISNULL(Regulator_Status,'')) in ('', 'ACCEPTED')
),
all_pending_and_accepted_org_With_pom as
(
	select distinct all_pending_and_accepted_org.* 
	from all_pending_and_accepted_org
	/*
	inner join all_pending_andaccepted_pom 
		on all_pending_and_accepted_org.organisation_id = all_pending_andaccepted_pom.organisation_id
		and all_pending_and_accepted_org.SubmissionYear = all_pending_andaccepted_pom.SubmissionYear
	*/
),
all_pending_and_accepted_org_With_pom_removed_case1_case2 as
(
	select distinct all_pending_and_accepted_org_With_pom.organisation_id,	
		all_pending_and_accepted_org_With_pom.filename,	
		all_pending_and_accepted_org_With_pom.submitted_time,	
		all_pending_and_accepted_org_With_pom.SubmissionYear,	
		upper(ISNULL(all_pending_and_accepted_org_With_pom.Regulator_Status,'PENDING')) as Regulator_Status
	from all_pending_and_accepted_org_With_pom
	left join latest_accepted_org
		on latest_accepted_org.organisation_id = all_pending_and_accepted_org_With_pom.organisation_id
		and latest_accepted_org.SubmissionYear = all_pending_and_accepted_org_With_pom.SubmissionYear
	left join latest_accepted_pom_without_org
		on latest_accepted_pom_without_org.organisation_id = all_pending_and_accepted_org_With_pom.organisation_id
		and latest_accepted_pom_without_org.SubmissionYear = all_pending_and_accepted_org_With_pom.SubmissionYear
	where latest_accepted_org.organisation_id is null
	and latest_accepted_pom_without_org.organisation_id is null
),
all_pending_and_accepted_org_With_pom_removed_case1_case2_with_rank as
(
	select *
		, row_number() over(partition by organisation_id, SubmissionYear order by Regulator_Status, submitted_time desc) as cd_rn
	from all_pending_and_accepted_org_With_pom_removed_case1_case2
),
all_pending_and_accepted_org_With_pom_removed_case1_case2_with_rank_as_1 as
(
	select * from all_pending_and_accepted_org_With_pom_removed_case1_case2_with_rank
	where cd_rn = 1
),--this is fine (3)
final_org as
(
	select *,'1' as criteria from latest_accepted_org
	union
	select *,'3' as criteria from all_pending_and_accepted_org_With_pom_removed_case1_case2_with_rank_as_1		
),
final_pom as
(
	select *,'2' as criteria from latest_accepted_pom_without_org
),
pom_result as
(
	select distinct
		p.organisation_id  as 'RPD_Organisation_ID'
		,'' AS 'submission_period'
		, cs.Name AS 'Compliance_scheme'
		, case when v.organisation_id is not null then v.companies_house_number else prr.CompaniesHouseNumber end as 'Companies_House_number'
		, COALESCE(v.subsidiary_id, pm.subsidiary_id, '') AS 'Subsidiary_ID'
		, case when v.organisation_id is not null then v.organisation_name else prr.Name end as 'Organisation_name'
		, case when v.organisation_id is not null then v.Trading_Name else prr.TradingName end as 'Trading_name'
		, case 
			when v.organisation_id is not null 
				then ISNULL(v.registered_addr_line1,'') 
			else TRIM( ISNULL(prr.BuildingName,'') + ' ' +ISNULL(prr.BuildingNumber,'') ) 
				end as 'Address_line_1'
		, case 
			when v.organisation_id is not null 
				then ISNULL(v.registered_addr_line2,'') 
			else ISNULL(prr.Street,'') 
				end as 'Address_line_2'
		, '' as 'Address_line_3'
		, '' as 'Address_line_4'
		, case 
			when v.organisation_id is not null 
				then ISNULL(v.registered_city,'') 
			else ISNULL(prr.Town,'') 
				end as 'Town'
		, case 
			when v.organisation_id is not null 
				then ISNULL(v.registered_addr_county,'') 
			else ISNULL(prr.County,'') 
				end as 'County'
		, case 
			when v.organisation_id is not null 
				then ISNULL(v.registered_addr_country,'') 
			else ISNULL(prr.Country,'') 
				end as 'Country'									
		, case 
			when v.organisation_id is not null 
				then ISNULL(v.registered_addr_postcode,'') 
			else ISNULL(prr.Postcode,'') 
				end as 'Postcode'
		, producernation.Name AS ProducerNation
		, producernation.Id AS ProducerNationId
		, csnation.Name AS ComplianceSchemeNation
		, csnation.Id AS ComplianceSchemeNationId
		, prr.ReferenceNumber AS ProducerId
		, (CASE producernation.Id
			WHEN 1 THEN 'Environment Agency (England)'
			WHEN 2 THEN 'Northern Ireland Environment Agency'
			WHEN 3 THEN 'Scottish Environment Protection Agency'
			WHEN 4 THEN 'Natural Resources Wales'
			END) As 'Environmental_regulator'
		, (CASE csnation.Id
			WHEN 1 THEN 'Environment Agency (England)'
			WHEN 2 THEN 'Northern Ireland Environment Agency'
			WHEN 3 THEN 'Scottish Environment Protection Agency'
			WHEN 4 THEN 'Natural Resources Wales'
			END) As 'Compliance_scheme_regulator'
		,p.SubmissionYear as 'Reporting_year'
		,meta.created SubmittedDateTime
	from final_pom p
		inner join [rpd].[Pom] pm 
			on pm.FileName = p.FileName
				and p.organisation_id = pm.organisation_id
		left join [dbo].[v_cosmos_file_metadata] meta
			on meta.FileName = p.FileName
		LEFT JOIN dbo.v_rpd_ComplianceSchemes_Active cs
			ON meta.ComplianceSchemeId = cs.ExternalId
		left join [dbo].[v_registration_latest_by_Year] v
			ON p.Organisation_id = v.organisation_id
				and isnull(pm.subsidiary_id,'') = isnull(v.subsidiary_id,'')
				and v.Reporting_year = p.SubmissionYear
		left JOIN dbo.v_rpd_Organisations_Active prr
			ON p.organisation_id = prr.ReferenceNumber
		LEFT JOIN rpd.Nations producernation   
			ON prr.NationId = producernation.Id
		LEFT JOIN rpd.Nations csnation
			ON cs.NationId = csnation.Id
		left JOIN (SELECT FromOrganisation_ReferenceNumber, EnrolmentStatuses_EnrolmentStatus
						FROM t_rpd_data_SECURITY_FIX
						GROUP BY FromOrganisation_ReferenceNumber, EnrolmentStatuses_EnrolmentStatus) e_status
			ON e_status.FromOrganisation_ReferenceNumber = p.organisation_id
		where  pm.organisation_size = 'L'
				AND (cs.IsDeleted = 0 OR cs.IsDeleted IS NULL)  ---> If only company-details file is submitted cs.IsDeleted would be NULL
				AND (prr.isdeleted = 0 OR prr.isdeleted IS NULL)
				AND e_status.EnrolmentStatuses_EnrolmentStatus <> 'Rejected'
				AND (prr.IsComplianceScheme = 0 OR prr.IsComplianceScheme IS NULL)
),
org_result as
(
			SELECT DISTINCT
				cd.organisation_id AS 'RPD_Organisation_ID'
				, '' AS 'submission_period'
				, cs.Name AS 'Compliance_scheme'
				, case when cds.organisation_id is not null then cds.companies_house_number else pr.CompaniesHouseNumber end as 'Companies_House_number'
				, COALESCE( cds.subsidiary_id, '') AS 'Subsidiary_ID'
				, case when cds.organisation_id is not null then cds.organisation_name else pr.Name end as 'Organisation_name'
				, case when cds.organisation_id is not null then cds.Trading_Name else pr.TradingName end as 'Trading_name'
				, case 
					when cds.organisation_id is not null 
						then ISNULL(cds.registered_addr_line1,'') 
					else TRIM( ISNULL(pr.BuildingName,'') + ' ' +ISNULL(pr.BuildingNumber,'') )
						end as 'Address_line_1'									
				, case 
					when cds.organisation_id is not null 
						then ISNULL(cds.registered_addr_line2,'') 
					else ISNULL(pr.Street,'') 
						end as 'Address_line_2'								
				, '' as 'Address_line_3'
				, '' as 'Address_line_4'
				, case 
					when cds.organisation_id is not null 
						then ISNULL(cds.registered_city,'') 
					else ISNULL(pr.Town,'') 
						end as 'Town'
				, case 
					when cds.organisation_id is not null 
						then ISNULL(cds.registered_addr_county,'') 
					else ISNULL(pr.County,'') 
						end as 'County'
				, case 
					when cds.organisation_id is not null 
						then ISNULL(cds.registered_addr_country,'') 
					else ISNULL(pr.Country,'') 
						end as 'Country'
				, case 
					when cds.organisation_id is not null 
						then ISNULL(cds.registered_addr_postcode,'') 
					else ISNULL(pr.Postcode,'') 
						end as 'Postcode'
				, producernation.Name AS ProducerNation
				, producernation.Id AS ProducerNationId
				, csnation.Name AS ComplianceSchemeNation
				, csnation.Id AS ComplianceSchemeNationId
				, pr.ReferenceNumber AS ProducerId
				, (CASE producernation.Id
					WHEN 1 THEN 'Environment Agency (England)'
					WHEN 2 THEN 'Northern Ireland Environment Agency'
					WHEN 3 THEN 'Scottish Environment Protection Agency'
					WHEN 4 THEN 'Natural Resources Wales'
					END) As 'Environmental_regulator'
				, (CASE csnation.Id
					WHEN 1 THEN 'Environment Agency (England)'
					WHEN 2 THEN 'Northern Ireland Environment Agency'
					WHEN 3 THEN 'Scottish Environment Protection Agency'
					WHEN 4 THEN 'Natural Resources Wales'
					END) As 'Compliance_scheme_regulator'
				,cd.SubmissionYear as 'Reporting_year'
				, meta.created SubmittedDateTime
			FROM final_org cd
			inner join [rpd].[CompanyDetails] cds 
				on cds.Filename = cd.Filename
					and cds.organisation_id = cd.organisation_id
 			left join [dbo].[v_cosmos_file_metadata] meta
				on meta.FileName = cd.FileName
			LEFT JOIN dbo.v_rpd_ComplianceSchemes_Active cs
				ON meta.ComplianceSchemeId = cs.ExternalId
			left JOIN dbo.v_rpd_Organisations_Active pr
				ON cd.organisation_id = pr.ReferenceNumber
			LEFT JOIN rpd.Nations producernation 
				ON pr.NationId = producernation.Id
			LEFT JOIN rpd.Nations csnation
				ON cs.NationId = csnation.Id
			left JOIN [dbo].[v_registration_latest_by_Year] rl
				ON cd.organisation_id = rl.organisation_id
				and isnull(cds.subsidiary_id,'') = isnull(rl.subsidiary_id,'')
				and rl.Reporting_year = cd.SubmissionYear
			left JOIN (SELECT FromOrganisation_ReferenceNumber, EnrolmentStatuses_EnrolmentStatus
					FROM t_rpd_data_SECURITY_FIX
					GROUP BY FromOrganisation_ReferenceNumber, EnrolmentStatuses_EnrolmentStatus) e_status
				ON e_status.FromOrganisation_ReferenceNumber = cd.organisation_id
				WHERE (cs.IsDeleted = 0 OR cs.IsDeleted IS NULL)
					AND (pr.isdeleted = 0 OR pr.isdeleted IS NULL)
					AND e_status.EnrolmentStatuses_EnrolmentStatus <> 'Rejected'
					AND (pr.IsComplianceScheme = 0 OR pr.IsComplianceScheme IS NULL)
		)


		select 
				RPD_Organisation_ID,		submission_period,		Compliance_scheme,		Companies_House_number,		Subsidiary_ID,		Organisation_name,
				Trading_name,		Address_line_1,		Address_line_2,		Address_line_3,		Address_line_4,		Town,		County,		Country,
				Postcode,		ProducerNation,		ProducerNationId,		ComplianceSchemeNation,		ComplianceSchemeNationId,		ProducerId,
				Environmental_regulator,		Compliance_scheme_regulator,		Reporting_year
		
			from
			(
				select *, Row_number() over(Partition by RPD_Organisation_ID, Subsidiary_ID, Reporting_year order by SubmittedDateTime desc) as rn
				from
				(	
					select * from pom_result
					union
					select * from org_result
				) A
			) B;