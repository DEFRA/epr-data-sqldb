CREATE VIEW [dbo].[v_SubsidiaryExtract] AS with base_data as (
				select OrganisationId
				, SubmissionPeriod
				, case when SubmissionPeriod in ('Jan to Jun 2023','January to June 2023') then 1 
						when SubmissionPeriod = 'July to December 2023' then 2
						when SubmissionPeriod in ('Jan to Jun 2024','January to June 2024') then 3 
						when SubmissionPeriod = 'July to December 2024' then 4
						when SubmissionPeriod in ('Jan to Jun 2025','January to June 2025') then 5 
						when SubmissionPeriod = 'July to December 2025' then 6
						when SubmissionPeriod in ('Jan to Jun 2026','January to June 2026') then 7 
						when SubmissionPeriod = 'July to December 2026' then 8
						when SubmissionPeriod in ('Jan to Jun 2027','January to June 2027') then 9 
						when SubmissionPeriod = 'July to December 2027' then 10
						when SubmissionPeriod in ('Jan to Jun 2028','January to June 2028') then 11 
						when SubmissionPeriod = 'July to December 2028' then 12
						else 0
						end as SubmissionPeriod_id
				, CONVERT(DATETIME,substring(Created,1,23)) as Submission_time
				, FileType
				, filename
				from rpd.cosmos_file_metadata
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
	
),
latest_pom as
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
	and org.IsComplianceScheme = 0 --Pick only direct producer
)
select *, ROW_NUMBER() OVER(ORDER BY organisation_id, subsidiary_id) as RN
from sub_data;