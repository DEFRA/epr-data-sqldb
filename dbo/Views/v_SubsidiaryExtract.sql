CREATE VIEW [dbo].[v_SubsidiaryExtract] AS with base_data as (
				select m.OrganisationId
				, m.SubmissionPeriod
				, case when m.SubmissionPeriod in ('Jan to Jun 2023','January to June 2023') then 1 
						when m.SubmissionPeriod = 'July to December 2023' then 2
						when m.SubmissionPeriod in ('Jan to Jun 2024','January to June 2024') then 3 
						when m.SubmissionPeriod = 'July to December 2024' then 4
						when m.SubmissionPeriod in ('Jan to Jun 2025','January to June 2025') then 5 
						when m.SubmissionPeriod = 'July to December 2025' then 6
						when m.SubmissionPeriod in ('Jan to Jun 2026','January to June 2026') then 7 
						when m.SubmissionPeriod = 'July to December 2026' then 8
						when m.SubmissionPeriod in ('Jan to Jun 2027','January to June 2027') then 9 
						when m.SubmissionPeriod = 'July to December 2027' then 10
						when m.SubmissionPeriod in ('Jan to Jun 2028','January to June 2028') then 11 
						when m.SubmissionPeriod = 'July to December 2028' then 12
						else 0
						end as SubmissionPeriod_id
				, CONVERT(DATETIME,substring(m.Created,1,23)) as Submission_time
				, m.FileType
				, m.filename
				, st.Regulator_Status
				from rpd.cosmos_file_metadata m
				inner join dbo.v_submitted_pom_org_file_status st on m.filename = st.FileName
				where UPPER(TRIM(ISNULL(Regulator_Status,''))) <> 'REJECTED'
				),
latest_CompanyDetails as
(
	select *
	from
	(
		select *
			, Row_number() over(partition by OrganisationId, SubmissionPeriod_id order by Submission_time desc) as cd_rn
		from base_data
		where upper(FileType) = 'COMPANYDETAILS'
	) A
	where cd_rn = 1
	
)
,
/*latest_pom as
(
	select *
	from
	(
		select *
			, Row_number() over(partition by OrganisationId, SubmissionPeriod_id order by Submission_time desc) as pom_rn
		from base_data
		where upper(FileType) = 'POM'
	) A
	where pom_rn = 1
	
),
org_pom_combined as 
(
select 
	o.ReferenceNumber as file_submitted_organisation, o.IsComplianceScheme as file_submitted_organisation_IsComplianceScheme,
	cd.OrganisationId, cd.SubmissionPeriod, cd.SubmissionPeriod_id, cd.Submission_time as cd_Submission_time, cd.FileType as cd_filetype, cd.filename as cd_filename,
	p.Submission_time as pom_Submission_time, p.FileType as pom_filetype, p.filename as pom_filename

from latest_pom p 
inner join latest_CompanyDetails cd 
	on p.OrganisationId = cd. OrganisationId
	and p.SubmissionPeriod_id = cd.SubmissionPeriod_id
left join rpd.organisations o on p.OrganisationId = o.ExternalId

)*/
org_pom_combined as 
(
select 
	o.ReferenceNumber as file_submitted_organisation, o.IsComplianceScheme as file_submitted_organisation_IsComplianceScheme,
	cd.OrganisationId, cd.SubmissionPeriod, cd.SubmissionPeriod_id, cd.Submission_time as cd_Submission_time, cd.FileType as cd_filetype, cd.filename as cd_filename
from latest_CompanyDetails cd 
left join rpd.organisations o on cd.OrganisationId = o.ExternalId
),
sub_data as 
(
	select distinct
			cd.organisation_id
			, org.id as org_pk_id
			, cd.subsidiary_id
			, cd.organisation_type_code
			, cd.companies_house_number
			, cd.organisation_name	
			, cd.trading_name
			, cd.registered_addr_line1	
			, cd.registered_addr_line2	
			, cd.registered_city	
			, cd.registered_addr_county	
			, cd.registered_addr_postcode	
			, cd.registered_addr_country
			, cd.home_nation_code
	from org_pom_combined ops
	inner join rpd.CompanyDetails cd 
		on ops.cd_filename = cd.FileName
	inner join rpd.organisations org on org.ReferenceNumber = cd.organisation_id
	where cd.organisation_id is not NULL --remove NULL org id
	and ISNULL(trim(cd.subsidiary_id),'') <> '' -- remove NULL sub id
	and (ops.file_submitted_organisation_IsComplianceScheme = 1 --consider if file submitted by CS
			or (ops.file_submitted_organisation_IsComplianceScheme = 0 --consider if file submitted by DP then org id in the file should match to submitted by org id else consider as bad data
				and ops.file_submitted_organisation = cd.organisation_id
				)
		)
	and trim(upper(cd.subsidiary_id)) not in ('N/A', 'NA', 'NOT SET', '-', 'NONE') --Ignore bad data
	and org.IsComplianceScheme = 0 --Pick only direct producer, if CS id entered in the org file it should be ignored
)
select sub_data.*
	, ROW_NUMBER() OVER(ORDER BY sub_data.organisation_id, sub_data.subsidiary_id) as RN
from sub_data
left join [dbo].[v_subsidiaryorganisations] vs 
	on sub_data.organisation_id = vs.FirstOrganisation_ReferenceNumber
		and TRIM(ISNULL(sub_data.subsidiary_id,'')) = TRIM(ISNULL(vs.SubsidiaryId,''))
		and TRIM(ISNULL(sub_data.companies_house_number,'')) = TRIM(ISNULL(vs.SecondOrganisation_CompaniesHouseNumber,''))
where sub_data.subsidiary_id not in (select ReferenceNumber from rpd.organisations)-- this is to ignore if user defined sub id is same as system generated sub id
and vs.FirstOrganisationId IS NULL;