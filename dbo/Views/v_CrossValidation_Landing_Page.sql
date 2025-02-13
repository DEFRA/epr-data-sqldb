CREATE VIEW [dbo].[v_CrossValidation_Landing_Page] AS with base_data as (
				select m.OrganisationId
				, m.SubmissionPeriod
				, m.OriginalFileName
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
				, m.[ComplianceSchemeId]
				, cs.name AS CS_Name
				, n.name as CS_nation
				, '20'+ Reverse(Substring(Reverse(Trim(m.submissionperiod)), 1, 2))+1 AS RelevantYear
				, Convert(datetime2,Replace(Replace(m.Created,'T', ' '),'Z', ' ')) AS Created_frmtDT
				, o.Name as ProducerName
				, o.NationId As ProducerNationId
				from rpd.cosmos_file_metadata m
				inner join dbo.v_submitted_pom_org_file_status st on m.filename = st.FileName
				left join [rpd].[ComplianceSchemes] cs on cs.externalid = m.[ComplianceSchemeId]
				left join [rpd].[Nations] n on n.id = cs.[NationId]
				left join rpd.Organisations o on o.ExternalId = m.OrganisationId

),

all_CompanyDetails as
(
	
		select *
			,Row_number() over(partition by OrganisationId, RelevantYear order by Submission_time desc) as cd_rn
		from base_data
		where upper(FileType) = 'COMPANYDETAILS' 
		and (
			[ComplianceSchemeId] is not null or 
				(
					[ComplianceSchemeId] is null and UPPER(TRIM(ISNULL(Regulator_Status,'PENDING'))) in ('ACCEPTED', 'PENDING')

				)
			)	
),

DP_latest_CS_all_companydetails as
(
	select * from all_CompanyDetails
	where (cd_rn =1 and [ComplianceSchemeId] is null) or [ComplianceSchemeId] is not null
),

all_pom as
(
	select *
		,Row_number() over(partition by OrganisationId, RelevantYear order by Submission_time desc) as cd_rn
		from base_data
		where upper(FileType) = 'POM' 
		and (
			[ComplianceSchemeId] is not null or 
				(
					[ComplianceSchemeId] is null and UPPER(TRIM(ISNULL(Regulator_Status,'PENDING'))) in ('ACCEPTED', 'PENDING')
				)
			)	
	
),

DP_latest_CS_all_pom as
(
	select * from all_pom
	where [ComplianceSchemeId] is not null 
		OR (cd_rn =1 and [ComplianceSchemeId] is null) 
),

org_pom_combined as 
(
select 
	ISNULL(cd_o.ReferenceNumber,p_o.ReferenceNumber) as file_submitted_organisation, 
	ISNULL(cd_o.IsComplianceScheme,p_o.IsComplianceScheme) as file_submitted_organisation_IsComplianceScheme,
	ISNULL(cd.OrganisationId, p.OrganisationId) as OrganisationId,
	cd.SubmissionPeriod, 
	cd.SubmissionPeriod_id, 
	cd.Submission_time as cd_Submission_time,
	ISNULL(cd.Regulator_Status,'Pending') AS Org_Regulator_Status,
	cd.FileType as cd_filetype, 
	cd.filename as cd_filename,
	p.Submission_time as pom_Submission_time,
	ISNULL(p.Regulator_Status, 'Pending') AS Pom_Regulator_Status,
	p.FileType as pom_filetype, 
	p.filename as pom_filename,
	p.[ComplianceSchemeId] as pom_cs_id,
	p.SubmissionPeriod as pom_SubmissionPeriod,
	p.SubmissionPeriod_id as pom_id,
	cd.[ComplianceSchemeId] as org_cs_id,
	cd.RelevantYear,
	
	Case 
		When p.[ComplianceSchemeId]  Is Null Then 'Direct Producer' 
		Else 'Compliance Scheme' End CS_or_DP,
	p.CS_Name,
	p.CS_nation,
	Concat(cd.OriginalFileName,'_',format(convert(datetime,cd.Created_frmtDT,122),'yyyyMMddHHmiss'),'_',IsNull(cd.Regulator_Status,'Pending')) AS DisplayFilenameCD,
	Concat(p.OriginalFileName,'_',format(convert(datetime,p.Created_frmtDT,122),'yyyyMMddHHmiss'),'_',IsNull(p.Regulator_Status,'Pending')) AS DisplayFilenamePOM,
	Concat(format(convert(datetime,cd.Created_frmtDT,122),'yyyyMMddHHmiss'),'_',cd.OriginalFileName,'_',IsNull(cd.Regulator_Status,'Pending')) AS DisplayFilenameCDSort,
	Concat(format(convert(datetime,p.Created_frmtDT,122),'yyyyMMddHHmiss'),'_',p.OriginalFileName,'_',IsNull(p.Regulator_Status,'Pending')) AS DisplayFilenamePOMSort,
	ISNULL(cd_o.Name,p_o.Name) as ProducerName,
	ISNULL(cd_o.NationId,p_o.NationId) as ProducerNationId
	--ISNULL(p.Producer_Nation,p.Producer_Nation) as ProducerNationName
	

from DP_latest_CS_all_companydetails cd 
left join  DP_latest_CS_all_pom p
	on p.OrganisationId = cd. OrganisationId
	and ISNULL(p.[ComplianceSchemeId],'') = ISNULL(cd.[ComplianceSchemeId],'')
	and p.RelevantYear = cd.RelevantYear
left join rpd.organisations cd_o on cd.OrganisationId = cd_o.ExternalId
left join rpd.organisations p_o on cd.OrganisationId = p_o.ExternalId

)

select opc.*,
		np.Name AS ProducerNationName
from org_pom_combined opc
join [rpd].[Nations] np on np.id = opc.ProducerNationId;