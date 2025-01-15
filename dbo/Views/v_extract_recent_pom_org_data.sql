CREATE VIEW [dbo].[v_extract_recent_pom_org_data] AS with 
TwoRow as
(
	select 1 as RankId , 'Jan to June 2023 - H1' as SP, 2023 as Reporting_Year
	union 
	select 2 as RankId , 'July to Dec 2023 - H2' as SP, 2023 as Reporting_Year
	union
	select 3 as RankId , 'Jan to June 2024 - H1' as SP, 2024 as Reporting_Year
	union 
	select 4 as RankId , 'July to Dec 2024 - H2' as SP, 2024 as Reporting_Year
	union
	select 5 as RankId , 'Jan to June 2025 - H1' as SP, 2025 as Reporting_Year
	union 
	select 6 as RankId , 'July to Dec 2025 - H2' as SP, 2025 as Reporting_Year
	union
	select 7 as RankId , 'Jan to June 2026 - H1' as SP, 2026 as Reporting_Year
	union 
	select 8 as RankId , 'July to Dec 2026 - H2' as SP, 2026 as Reporting_Year
	union
	select 9 as RankId , 'Jan to June 2027 - H1' as SP, 2027 as Reporting_Year
	union 
	select 10 as RankId , 'July to Dec 2027 - H2' as SP, 2027 as Reporting_Year
	union
	select 11 as RankId , 'Jan to June 2028 - H1' as SP, 2028 as Reporting_Year
	union 
	select 12 as RankId , 'July to Dec 2028 - H2' as SP, 2028 as Reporting_Year
),

ORG as
(
		select *
			, row_number() over(partition by OrganisationId, ReferenceNumber, SubmissionPeriod order by Submission_time asc, Source asc) as First_submission
			, row_number() over(partition by OrganisationId, ReferenceNumber, SubmissionPeriod order by Submission_time desc, Source asc) as Last_submission
		from 
		(
			select distinct o.id as OrganisationId, cd.organisation_id as ReferenceNumber
					, case when cfm.SubmissionPeriod in ('Jan to Jun 2023','January to June 2023') then 1 
							when cfm.SubmissionPeriod = 'July to December 2023' then 2
							when cfm.SubmissionPeriod in ('Jan to Jun 2024','January to June 2024') then 3 
							when cfm.SubmissionPeriod = 'July to December 2024' then 4
							when cfm.SubmissionPeriod in ('Jan to Jun 2025','January to June 2025') then 5 
							when cfm.SubmissionPeriod = 'July to December 2025' then 6
							when cfm.SubmissionPeriod in ('Jan to Jun 2026','January to June 2026') then 7 
							when cfm.SubmissionPeriod = 'July to December 2026' then 8
							when cfm.SubmissionPeriod in ('Jan to Jun 2027','January to June 2027') then 9 
							when cfm.SubmissionPeriod = 'July to December 2027' then 10
							when cfm.SubmissionPeriod in ('Jan to Jun 2028','January to June 2028') then 11 
							when cfm.SubmissionPeriod = 'July to December 2028' then 12
							else 0
							end as SubmissionPeriod
					, case when cfm.SubmissionPeriod in ('Jan to Jun 2023','January to June 2023','July to December 2023') then 2023 
							when cfm.SubmissionPeriod in ('Jan to Jun 2024','January to June 2024','July to December 2024') then 2024
							when cfm.SubmissionPeriod in ('Jan to Jun 2025','January to June 2025','July to December 2025') then 2025
							when cfm.SubmissionPeriod in ('Jan to Jun 2026','January to June 2026','July to December 2026') then 2026
							when cfm.SubmissionPeriod in ('Jan to Jun 2027','January to June 2027','July to December 2027') then 2027
							when cfm.SubmissionPeriod in ('Jan to Jun 2028','January to June 2028','July to December 2028') then 2028
							else 0
							end as ReportingYear
					, CONVERT(DATETIME,substring(cfm.Created,1,23)) as Submission_time
					, cs.id as ComplianceSchemeId
					, cfm.FileName
					, 'Processed' as File_Status
					, 'CD table' as Source
					, p.FirstName
					, cs.Name as 'CS_Name'
					, N.Name as 'CS Nation'
					, case when cs.id is NULL then 'DP' else 'CS' end as 'Who submitted'
					, cd.FileName as cd_filename
					, upper(trim(ISNULL(fs.Regulator_Status,'PENDING'))) as Regulator_Status
			from [rpd].[CompanyDetails] cd
			left join rpd.Organisations o on o.ReferenceNumber = cd.organisation_id
			left join [rpd].[cosmos_file_metadata] cfm on cfm.FileName = cd.FileName
			left join [rpd].[ComplianceSchemes] cs on cs.ExternalId = cfm.ComplianceSchemeId
			left join rpd.users u on u.USerId = cfm.UserId
			left join rpd.persons p on p.UserId = u.id
			left join rpd.Nations N on N.Id = cs.NationId
			left join [dbo].[v_submitted_pom_org_file_status] fs on fs.FileName = cd.filename
		) A
),
ORG_REJECTED_ONLY as
(
	select *
		, row_number() over(partition by OrganisationId, ReferenceNumber, SubmissionPeriod order by Submission_time asc, Source asc) as First_rejected_submission
		, row_number() over(partition by OrganisationId, ReferenceNumber, SubmissionPeriod order by Submission_time desc, Source asc) as Last_rejected_submission
	from ORG
	where Regulator_Status = 'REJECTED' 
),
ORG_PENDING_ACCEPT_ONLY as
(
	select *
		, row_number() over(partition by OrganisationId, ReferenceNumber, SubmissionPeriod order by Submission_time asc, Source asc) as First_pending_accepted_submission
		, row_number() over(partition by OrganisationId, ReferenceNumber, SubmissionPeriod order by Submission_time desc, Source asc) as Last_pending_accepted_submission
	from ORG
	where (Regulator_Status = 'PENDING' or  Regulator_Status = 'ACCEPTED') 
),
ORG_REJECTED_WITH_OUT_PENDING_ACCEPTED as
(
	select rej.*
	from ORG_REJECTED_ONLY rej
	left join ORG_PENDING_ACCEPT_ONLY pa on pa.OrganisationId = rej.OrganisationId and pa.ReferenceNumber = rej.ReferenceNumber and pa.SubmissionPeriod = rej.SubmissionPeriod
	where pa.OrganisationId is null
),
f_org_sql as
 (
	select ReferenceNumber as 'Org ID', SubmissionPeriod as 'Rank', ReportingYear, Submission_time as 'Submission date time', case when ComplianceSchemeId is null then 'DP' else CS_Name end as 'Submitted by',	File_Status as 'Submission status', Regulator_Status as 'Regulator Decision',	[Who submitted], [CS Nation] , cd_filename, ComplianceSchemeId
	from ORG_PENDING_ACCEPT_ONLY 
	where First_pending_accepted_submission = 1
	union 
	select ReferenceNumber as 'Org ID', SubmissionPeriod as 'Rank', ReportingYear, Submission_time as 'Submission date time', case when ComplianceSchemeId is null then 'DP' else CS_Name end as 'Submitted by',	File_Status as 'Submission status', Regulator_Status as 'Regulator Decision',	[Who submitted], [CS Nation] , cd_filename, ComplianceSchemeId
	from ORG_REJECTED_WITH_OUT_PENDING_ACCEPTED 
	where Last_rejected_submission = 1
 ),
l_org_sql as
 (
	select ReferenceNumber as 'Org ID', SubmissionPeriod as 'Rank', ReportingYear, Submission_time as 'Submission date time', case when ComplianceSchemeId is null then 'DP' else CS_Name end as 'Submitted by',	File_Status as 'Submission status', Regulator_Status as 'Regulator Decision',	[Who submitted], [CS Nation] , cd_filename, ComplianceSchemeId
	from ORG_PENDING_ACCEPT_ONLY 
	where Last_pending_accepted_submission = 1
 ),

POM as
(
		select *
			, row_number() over(partition by OrganisationId, ReferenceNumber, SubmissionPeriod order by Submission_time asc, Source desc) as First_submission
			, row_number() over(partition by OrganisationId, ReferenceNumber, SubmissionPeriod order by Submission_time desc, Source desc) as Last_submission
		from 
		(
			select distinct o.id as OrganisationId, pm.organisation_id as ReferenceNumber
					, case when cfm.SubmissionPeriod in ('Jan to Jun 2023','January to June 2023') then 1 
							when cfm.SubmissionPeriod = 'July to December 2023' then 2
							when cfm.SubmissionPeriod in ('Jan to Jun 2024','January to June 2024') then 3 
							when cfm.SubmissionPeriod = 'July to December 2024' then 4
							when cfm.SubmissionPeriod in ('Jan to Jun 2025','January to June 2025') then 5 
							when cfm.SubmissionPeriod = 'July to December 2025' then 6
							when cfm.SubmissionPeriod in ('Jan to Jun 2026','January to June 2026') then 7 
							when cfm.SubmissionPeriod = 'July to December 2026' then 8
							when cfm.SubmissionPeriod in ('Jan to Jun 2027','January to June 2027') then 9 
							when cfm.SubmissionPeriod = 'July to December 2027' then 10
							when cfm.SubmissionPeriod in ('Jan to Jun 2028','January to June 2028') then 11 
							when cfm.SubmissionPeriod = 'July to December 2028' then 12
							else 0
							end as SubmissionPeriod
					, case when cfm.SubmissionPeriod in ('Jan to Jun 2023','January to June 2023','July to December 2023') then 2023 
							when cfm.SubmissionPeriod in ('Jan to Jun 2024','January to June 2024','July to December 2024') then 2024
							when cfm.SubmissionPeriod in ('Jan to Jun 2025','January to June 2025','July to December 2025') then 2025
							when cfm.SubmissionPeriod in ('Jan to Jun 2026','January to June 2026','July to December 2026') then 2026
							when cfm.SubmissionPeriod in ('Jan to Jun 2027','January to June 2027','July to December 2027') then 2027
							when cfm.SubmissionPeriod in ('Jan to Jun 2028','January to June 2028','July to December 2028') then 2028
							else 0
							end as ReportingYear
					, CONVERT(DATETIME,substring(cfm.Created,1,23)) as Submission_time
					, cs.id as ComplianceSchemeId
					, cfm.FileName
					, 'Processed' as File_Status
					, 'POM table' as Source
					, p.FirstName
					, cs.Name as 'CS_Name'
					, N.Name as 'CS Nation'
					, case when cs.id is NULL then 'DP' else 'CS' end as 'Who submitted'
					, pm.FileName as pm_filename
					, upper(trim(ISNULL(fs.Regulator_Status,'PENDING'))) as Regulator_Status
			from [rpd].[Pom] pm
			left join rpd.Organisations o on o.ReferenceNumber = pm.organisation_id
			left join [rpd].[cosmos_file_metadata] cfm on cfm.FileName = pm.FileName
			left join [rpd].[ComplianceSchemes] cs on cs.ExternalId = cfm.ComplianceSchemeId
			left join rpd.users u on u.USerId = cfm.UserId
			left join rpd.persons p on p.UserId = u.id
			left join rpd.Nations N on N.Id = cs.NationId
			left join [dbo].[v_submitted_pom_org_file_status] fs on fs.FileName = pm.filename
		) A
),
POM_REJECTED_ONLY as
(
	select *
		, row_number() over(partition by OrganisationId, ReferenceNumber, SubmissionPeriod order by Submission_time asc, Source asc) as First_rejected_submission
		, row_number() over(partition by OrganisationId, ReferenceNumber, SubmissionPeriod order by Submission_time desc, Source asc) as Last_rejected_submission
	from POM
	where Regulator_Status = 'REJECTED' 
),
POM_PENDING_ACCEPT_ONLY as
(
	select *
		, row_number() over(partition by OrganisationId, ReferenceNumber, SubmissionPeriod order by Submission_time asc, Source asc) as First_pending_accepted_submission
		, row_number() over(partition by OrganisationId, ReferenceNumber, SubmissionPeriod order by Submission_time desc, Source asc) as Last_pending_accepted_submission
	from POM
	where (Regulator_Status = 'PENDING' or  Regulator_Status = 'ACCEPTED') 
),
POM_REJECTED_WITH_OUT_PENDING_ACCEPTED as
(
	select rej.*
	from POM_REJECTED_ONLY rej
	left join POM_PENDING_ACCEPT_ONLY pa on pa.OrganisationId = rej.OrganisationId and pa.ReferenceNumber = rej.ReferenceNumber and pa.SubmissionPeriod = rej.SubmissionPeriod
	where pa.OrganisationId is null
),
f_pom_sql as
 (
	select ReferenceNumber as 'Org ID', SubmissionPeriod as 'Rank', ReportingYear, Submission_time as 'Submission date time', case when ComplianceSchemeId is null then 'DP' else CS_Name end as 'Submitted by',	File_Status as 'Submission status', Regulator_Status as 'Regulator Decision',	[Who submitted], [CS Nation] , pm_filename, ComplianceSchemeId
	from POM_PENDING_ACCEPT_ONLY 
	where First_pending_accepted_submission = 1
	union
	select ReferenceNumber as 'Org ID', SubmissionPeriod as 'Rank', ReportingYear, Submission_time as 'Submission date time', case when ComplianceSchemeId is null then 'DP' else CS_Name end as 'Submitted by',	File_Status as 'Submission status', Regulator_Status as 'Regulator Decision',	[Who submitted], [CS Nation] , pm_filename, ComplianceSchemeId
	from POM_REJECTED_WITH_OUT_PENDING_ACCEPTED 
	where Last_rejected_submission = 1
 ),
l_pom_sql as
 (
	select ReferenceNumber as 'Org ID', SubmissionPeriod as 'Rank', ReportingYear, Submission_time as 'Submission date time', case when ComplianceSchemeId is null then 'DP' else CS_Name end as 'Submitted by',	File_Status as 'Submission status', Regulator_Status as 'Regulator Decision',	[Who submitted], [CS Nation] , pm_filename, ComplianceSchemeId
	from POM_PENDING_ACCEPT_ONLY 
	where Last_pending_accepted_submission = 1
 ),
Rank_On_CS_Submission as
(
	select *
		, row_number() over(partition by ComplianceSchemeId, FileType, SubmissionPeriod order by Submission_time desc) as Rank_on_submission_timestamp
	from
	(
		select cfm.OrganisationId,  cfm.FileType, 
							case when cfm.SubmissionPeriod in ('Jan to Jun 2023','January to June 2023') then 1 
								when cfm.SubmissionPeriod = 'July to December 2023' then 2
								when cfm.SubmissionPeriod in ('Jan to Jun 2024','January to June 2024') then 3 
								when cfm.SubmissionPeriod = 'July to December 2024' then 4
								when cfm.SubmissionPeriod in ('Jan to Jun 2025','January to June 2025') then 5 
								when cfm.SubmissionPeriod = 'July to December 2025' then 6
								when cfm.SubmissionPeriod in ('Jan to Jun 2026','January to June 2026') then 7 
								when cfm.SubmissionPeriod = 'July to December 2026' then 8
								when cfm.SubmissionPeriod in ('Jan to Jun 2027','January to June 2027') then 9 
								when cfm.SubmissionPeriod = 'July to December 2027' then 10
								when cfm.SubmissionPeriod in ('Jan to Jun 2028','January to June 2028') then 11 
								when cfm.SubmissionPeriod = 'July to December 2028' then 12
								else 0
								end as SubmissionPeriod
							, case when cfm.SubmissionPeriod in ('Jan to Jun 2023','January to June 2023','July to December 2023') then 2023 
								when cfm.SubmissionPeriod in ('Jan to Jun 2024','January to June 2024','July to December 2024') then 2024
								when cfm.SubmissionPeriod in ('Jan to Jun 2025','January to June 2025','July to December 2025') then 2025
								when cfm.SubmissionPeriod in ('Jan to Jun 2026','January to June 2026','July to December 2026') then 2026
								when cfm.SubmissionPeriod in ('Jan to Jun 2027','January to June 2027','July to December 2027') then 2027
								when cfm.SubmissionPeriod in ('Jan to Jun 2028','January to June 2028','July to December 2028') then 2028
								else 0
								end as ReportingYear
								, cfm.ComplianceSchemeId
		, CONVERT(DATETIME,substring(cfm.Created,1,23)) as Submission_time
		, cfm.FileName
		From [rpd].[cosmos_file_metadata] cfm
		left join [rpd].[error_files_not_processed] ef on ef.FileName = cfm.FileName
		where cfm.FileType in ('CompanyDetails','Pom')
		and cfm.ComplianceSchemeId is not null
	) A
),

Latest_org_by_CS as
(
	select distinct CD.organisation_id, cs.id as ComplianceSchemeId, SubmissionPeriod, 'Y' as Is_present_latest_cs_sub_org
	from Rank_On_CS_Submission RS
	inner join [rpd].[CompanyDetails] CD on RS.FileName = CD.FileName
	inner join [rpd].[ComplianceSchemes] cs on cs.ExternalId = RS.ComplianceSchemeId
	where Rank_on_submission_timestamp = 1
	and FileType = 'CompanyDetails' 
),
Latest_pom_by_CS as
(
	select distinct PM.organisation_id, cs.id as ComplianceSchemeId, SubmissionPeriod, 'Y' as Is_present_latest_cs_sub_pom
	from Rank_On_CS_Submission RS
	inner join [rpd].[Pom] PM on RS.FileName = PM.FileName
	inner join [rpd].[ComplianceSchemes] cs on cs.ExternalId = RS.ComplianceSchemeId
	where Rank_on_submission_timestamp = 1
	and FileType = 'POM'
),
rptRegistrationRegistered as
(
	select distinct organisation_id, 'Y' as Is_Present_in_Reg_report
	from [dbo].[registration]
),
rptPOM_All_Submissions as
(
	select distinct organisation_id, 'Y' as Is_Present_in_POM_report
	from [dbo].[v_POM_All_Submissions]
),
 enr as
 (
		select pocon.OrganisationId, ES.[Name] , CONVERT(DATETIME,substring(E.CreatedOn,1,23)) 'Enrolment_date_time', CONVERT(DATETIME,substring(E.LastUpdatedOn,1,23)) 'Enrolment_status_date_time',
		row_number() over(partition by pocon.OrganisationId order by ES.Name) as RN
		From rpd.PersonOrganisationConnections pocon
		inner join rpd.Enrolments E on E.ConnectionId = pocon.Id
		inner join rpd.ServiceRoles SR on SR.Id = E.ServiceRoleId
		inner join rpd.EnrolmentStatuses ES on ES.Id = E.EnrolmentStatusId
		where SR.[Key] = 'Packaging.ApprovedPerson'
 ),

 CSN as
 (
	 select O.Id as OrganisationId, N.Name as CS_Nation
	from rpd.Organisations O
	inner join [rpd].[OrganisationsConnections] OC 
		on OC.FromOrganisationId = O.Id
	inner join [rpd].[SelectedSchemes] SS 
		on SS.OrganisationConnectionId = OC.Id
	inner join [rpd].[ComplianceSchemes] CS 
		on SS.ComplianceSchemeId = CS.Id
	inner join rpd.Nations N on N.Id = CS.NationId
	where O.IsComplianceScheme = 0 and OC.IsDeleted = 0 and SS.IsDeleted = 0
 ),
base_sql as
(
	select --Org.Id,
		TwoRow.RankId,
		TwoRow.SP,
		TwoRow.Reporting_Year,
		Org.ReferenceNumber as 'Org ID',
		Org.Name as 'Org Name',
		ISNULL(Org.CompaniesHouseNumber,'') as CH,
		N.Name as 'Nation of Enrolment',
		enr.Enrolment_date_time,
		enr.[Name] as 'Status of enrolment',
		enr.Enrolment_status_date_time,
		ISNULL(CSN.CS_Nation,'') as 'Nation of Compliance Scheme regulator',
		Org.IsDeleted as 'Org soft deleted?'
	from rpd.Organisations Org
	inner join TwoRow on 1 = 1
	left join rpd.Nations N on N.Id = Org.NationId
	left join enr on enr.OrganisationId = org.Id and enr.RN = 1
	left join CSN on CSN.OrganisationId = org.Id 
	where Org.IsComplianceScheme = 0
),
submission_count as
(
	select [Org ID],ReportingYear, count(1) as cnt
	from
	(
		select * from l_org_sql
		union all 
		select * From l_pom_sql
	) A 
	group by [Org ID],ReportingYear
),
agg_POM as
(
	select FileName,organisation_id,[CW-AL],[CW-FC],[CW-GL],[CW-OT],[CW-PC],[CW-PL],[CW-ST],[CW-WD],[HDC-AL],[HDC-FC],[HDC-GL],[HDC-OT],[HDC-PC],[HDC-PL],[HDC-ST],[HDC-WD],[HH-AL],[HH-FC],[HH-GL],[HH-OT],[HH-PC],[HH-PL],[HH-ST],[HH-WD],[NDC-AL],[NDC-FC],[NDC-GL],[NDC-OT],[NDC-PC],[NDC-PL],[NDC-ST],[NDC-WD],[NH-AL],[NH-FC],[NH-GL],[NH-OT],[NH-PC],[NH-PL],[NH-ST],[NH-WD],[OW-AL],[OW-FC],[OW-GL],[OW-OT],[OW-PC],[OW-PL],[OW-ST],[OW-WD],[PB-AL],[PB-FC],[PB-GL],[PB-OT],[PB-PC],[PB-PL],[PB-ST],[PB-WD],[RU-AL],[RU-FC],[RU-GL],[RU-OT],[RU-PC],[RU-PL],[RU-ST],[RU-WD],[SP-AL],[SP-FC],[SP-GL],[SP-OT],[SP-PC],[SP-PL],[SP-ST],[SP-WD]
	FROM
	(
			select FileName, organisation_id, Packaging_type +'-'+ packaging_material as Type_Material, packaging_material_weight
			from rpd.pom
	) as TablePivot
	PIVOT
	(
		sum(packaging_material_weight)
		FOR Type_Material in ([CW-AL],[CW-FC],[CW-GL],[CW-OT],[CW-PC],[CW-PL],[CW-ST],[CW-WD],[HDC-AL],[HDC-FC],[HDC-GL],[HDC-OT],[HDC-PC],[HDC-PL],[HDC-ST],[HDC-WD],[HH-AL],[HH-FC],[HH-GL],[HH-OT],[HH-PC],[HH-PL],[HH-ST],[HH-WD],[NDC-AL],[NDC-FC],[NDC-GL],[NDC-OT],[NDC-PC],[NDC-PL],[NDC-ST],[NDC-WD],[NH-AL],[NH-FC],[NH-GL],[NH-OT],[NH-PC],[NH-PL],[NH-ST],[NH-WD],[OW-AL],[OW-FC],[OW-GL],[OW-OT],[OW-PC],[OW-PL],[OW-ST],[OW-WD],[PB-AL],[PB-FC],[PB-GL],[PB-OT],[PB-PC],[PB-PL],[PB-ST],[PB-WD],[RU-AL],[RU-FC],[RU-GL],[RU-OT],[RU-PC],[RU-PL],[RU-ST],[RU-WD],[SP-AL],[SP-FC],[SP-GL],[SP-OT],[SP-PC],[SP-PL],[SP-ST],[SP-WD])
	) AS PivotTable
),
agg_units_POM as
(
	select FileName,organisation_id,[CW-AL],[CW-FC],[CW-GL],[CW-OT],[CW-PC],[CW-PL],[CW-ST],[CW-WD],[HDC-AL],[HDC-FC],[HDC-GL],[HDC-OT],[HDC-PC],[HDC-PL],[HDC-ST],[HDC-WD],[HH-AL],[HH-FC],[HH-GL],[HH-OT],[HH-PC],[HH-PL],[HH-ST],[HH-WD],[NDC-AL],[NDC-FC],[NDC-GL],[NDC-OT],[NDC-PC],[NDC-PL],[NDC-ST],[NDC-WD],[NH-AL],[NH-FC],[NH-GL],[NH-OT],[NH-PC],[NH-PL],[NH-ST],[NH-WD],[OW-AL],[OW-FC],[OW-GL],[OW-OT],[OW-PC],[OW-PL],[OW-ST],[OW-WD],[PB-AL],[PB-FC],[PB-GL],[PB-OT],[PB-PC],[PB-PL],[PB-ST],[PB-WD],[RU-AL],[RU-FC],[RU-GL],[RU-OT],[RU-PC],[RU-PL],[RU-ST],[RU-WD],[SP-AL],[SP-FC],[SP-GL],[SP-OT],[SP-PC],[SP-PL],[SP-ST],[SP-WD]
	FROM
	(
			select FileName, organisation_id, Packaging_type +'-'+ packaging_material as Type_Material, packaging_material_units
			from rpd.pom
	) as TablePivot
	PIVOT
	(
		sum(packaging_material_units)
		FOR Type_Material in ([CW-AL],[CW-FC],[CW-GL],[CW-OT],[CW-PC],[CW-PL],[CW-ST],[CW-WD],[HDC-AL],[HDC-FC],[HDC-GL],[HDC-OT],[HDC-PC],[HDC-PL],[HDC-ST],[HDC-WD],[HH-AL],[HH-FC],[HH-GL],[HH-OT],[HH-PC],[HH-PL],[HH-ST],[HH-WD],[NDC-AL],[NDC-FC],[NDC-GL],[NDC-OT],[NDC-PC],[NDC-PL],[NDC-ST],[NDC-WD],[NH-AL],[NH-FC],[NH-GL],[NH-OT],[NH-PC],[NH-PL],[NH-ST],[NH-WD],[OW-AL],[OW-FC],[OW-GL],[OW-OT],[OW-PC],[OW-PL],[OW-ST],[OW-WD],[PB-AL],[PB-FC],[PB-GL],[PB-OT],[PB-PC],[PB-PL],[PB-ST],[PB-WD],[RU-AL],[RU-FC],[RU-GL],[RU-OT],[RU-PC],[RU-PL],[RU-ST],[RU-WD],[SP-AL],[SP-FC],[SP-GL],[SP-OT],[SP-PC],[SP-PL],[SP-ST],[SP-WD])
	) AS PivotTable
)
select 
	
	bs.[Org ID]  as Org_ID								--,case when bs.RankId = 1 then bs.[Org ID] else '' end as Org_ID
	,bs.[Org Name] as Org_name							--,case when bs.RankId = 1 then bs.[Org Name] else '' end as Org_name	
	,bs.CH as CH_number									--,case when bs.RankId = 1 then bs.CH else '' end as CH_number
	,bs.[Nation of Enrolment] as Nation_of_enrolment	--,case when bs.RankId = 1 then bs.[Nation of Enrolment] else '' end as Nation_of_enrolment
	,bs.Enrolment_date_time as Enrolment_date_time		--,case when bs.RankId = 1 then bs.Enrolment_date_time else NULL end as Enrolment_date_time
	,bs.[Status of enrolment] as Enrolment_status		--,case when bs.RankId = 1 then bs.[Status of enrolment] else '' end as Enrolment_status
	--,case when bs.RankId = 1 then bs.Enrolment_status_date_time else '' end as Enrolment_status_date_time 
	,bs.[Nation of Compliance Scheme regulator] as Nation_of_Compliance_Scheme_regulator	--,case when bs.RankId = 1 then bs.[Nation of Compliance Scheme regulator] else '' end as Nation_of_Compliance_Scheme_regulator

	,bs.SP as Packaging_data_submission_period

	, fps.[Submission date time] as Packaging_data_first_submission_datetime
	,ISNULL(fps.[Submitted by],'') as Packaging_data_first_submitted_CS_or_Direct
	--, case when fps.[Who submitted] = 'CS' then fps.[Submitted by] else 'DP' end as Packaging_data_first_submitted_CS_or_Direct
	--, fps.[Submitted by] as [F POM Submitted by]
	, ISNULL(fps.[CS Nation],'') Packaging_data_first_submitted_CS_Nation
	--, fps.[Submission status] as [F POM Submission status]
	, ISNULL(fps.[Regulator Decision],'') as Packaging_data_first_submission_status
	--, fps.[Who submitted] as [F POM Who submitted]
	--, fps.pm_filename as F_pm_filename
	--, fps.ComplianceSchemeId as F_pm_CS_id


	, lps.[Submission date time] as Packaging_data_latest_submission_datetime
	, ISNULL(lps.[Submitted by],'') as Packaging_data_latest_submitted_CS_or_Direct
	--, case when lps.[Who submitted] = 'CS' then lps.[Submitted by] else 'DP' end as Packaging_data_latest_submitted_CS_or_Direct
	--, lps.[Submitted by] as [L POM Submitted by]
	, ISNULL(lps.[CS Nation],'') Packaging_data_latest_submitted_CS_Nation
	--, lps.[Submission status] as [L POM Submission status]
	, ISNULL(lps.[Regulator Decision],'') as Packaging_data_latest_submission_status
	--, lps.[Who submitted] as [L POM Who submitted]
	--, lps.pm_filename as L_pm_filename
	--, lps.ComplianceSchemeId as L_pm_CS_id

	,bs.SP as Organisation_data_submission_period



	, fos.[Submission date time] as Organisation_data_first_submission_datetime
	, ISNULL(fos.[Submitted by],'') as Organisation_data_first_submitted_CS_or_Direct
	--, case when fos.[Who submitted] = 'CS' then fos.[Submitted by] else 'DP' end as Organisation_data_first_submitted_CS_or_Direct
	--, fos.[Submitted by] as [F ORG Submitted by]
	, ISNULL(fos.[CS Nation],'') Organisation_data_first_submitted_CS_Nation
	--, fos.[Submission status] as [F ORG Submission status]
	, ISNULL(fos.[Regulator Decision],'') as Organisation_data_first_submission_status
	--, fos.[Who submitted] as [F ORG Who submitted]
	--, fos.cd_filename as F_cd_filename
	--, fos.ComplianceSchemeId as F_org_CS_id

	, los.[Submission date time] as Organisation_data_latest_submission_datetime
	, ISNULL(los.[Submitted by],'') as Organisation_data_latest_submitted_CS_or_Direct
	--, case when los.[Who submitted] = 'CS' then los.[Submitted by] else 'DP' end as Organisation_data_latest_submitted_CS_or_Direct
	--, los.[Submitted by] as [L ORG Submitted by]
	, ISNULL(los.[CS Nation],'') Organisation_data_latest_submitted_CS_Nation
	--, los.[Submission status] as [L ORG Submission status]
	, ISNULL(los.[Regulator Decision],'') as Organisation_data_latest_submission_status
	--, los.[Who submitted] as [L ORG Who submitted]
	--, los.cd_filename as L_cd_filename
	--, los.ComplianceSchemeId as L_org_CS_id
	

	, case 
		when lps.[Submitted by] is null or lps.[Submitted by] = 'DP'
			then 'NA'
		else
			ISNULL(lpbc.Is_present_latest_cs_sub_pom,'N') 
		end as Organisation_exists_in_most_recent_packaging_data_submission
	, case
		when los.[Submitted by] is null or los.[Submitted by] = 'DP'
			then 'NA'
		else
			ISNULL(loby.Is_present_latest_cs_sub_org,'N') 
		end as Organisation_exists_in_most_recent_organisation_data_submission
	,ISNULL(rptPom.Is_Present_in_POM_report,'N') as Organisation_visible_in_PowerBI_Packaging_reports	--, case when bs.RankId = 1 then ISNULL(rptPom.Is_Present_in_POM_report,'') else '' end as Organisation_visible_in_PowerBI_Packaging_reports
	,ISNULL(rptReg.Is_Present_in_Reg_report,'N') as Organisation_visible_in_PowerBI_Orgdata_reports		--, case when bs.RankId = 1 then ISNULL(rptReg.Is_Present_in_Reg_report,'') else '' end as Organisation_visible_in_PowerBI_Orgdata_reports

	, case 
		when fps.pm_filename = lps.pm_filename 
			then 'Y' 
		when ISNULL(fps.pm_filename,'') <> ISNULL(lps.pm_filename,'') and fps.pm_filename is not null 
			then 'N' 
		else 'NA' 
	end as Single_File_Submission_Packaging
	, case 
		when fos.cd_filename = los.cd_filename 
			then 'Y' 
		when ISNULL(fos.cd_filename,'') <> ISNULL(los.cd_filename,'') and fos.cd_filename is not null 
			then 'N' 
		else 'NA' 
	end as Single_File_Submission_Orgdata   
	, case when sub_c.cnt = 4 then 'Y' else 'N' end as Reported_mandated_data_sets						--, case when sub_c.cnt = 4 and bs.RankId = 1 then 'Y' else '' end as Reported_mandated_data_sets
	,CAST(bs.[Org soft deleted?] as varchar(2)) as Organisation_soft_deleted							--, case when bs.RankId = 1 then CAST(bs.[Org soft deleted?] as varchar(2)) else '' end as Organisation_soft_deleted

	--,ap.FileName
	--,ap.organisation_id
	,ISNULL(ap.[CW-AL],0) as [Self-managed consumer waste-Aluminium]
	,ISNULL(ap.[CW-FC],0) as [Self-managed consumer waste-Fibre Composite]
	,ISNULL(ap.[CW-GL],0) as [Self-managed consumer waste-Glass]
	,ISNULL(ap.[CW-OT],0) as [Self-managed consumer waste-Other]
	,ISNULL(ap.[CW-PC],0) as [Self-managed consumer waste-Paper / Card]
	,ISNULL(ap.[CW-PL],0) as [Self-managed consumer waste-Plastic]
	,ISNULL(ap.[CW-ST],0) as [Self-managed consumer waste-Steel]
	,ISNULL(ap.[CW-WD],0) as [Self-managed consumer waste-Wood]

	,ISNULL(ap.[HDC-AL],0) as [Household drinks containers-Aluminium (Kg)]
	,ISNULL(aup.[HDC-AL],0) as [Household drinks containers-Aluminium (No.Units)]
	,ISNULL(ap.[HDC-FC],0) as [Household drinks containers-Fibre Composite (Kg)]
	,ISNULL(aup.[HDC-FC],0) as [Household drinks containers-Fibre Composite (No.Units)]
	,ISNULL(ap.[HDC-GL],0) as [Household drinks containers-Glass (Kg)]
	,ISNULL(aup.[HDC-GL],0) as [Household drinks containers-Glass (No.Units)]
	,ISNULL(ap.[HDC-OT],0) as [Household drinks containers-Other (Kg)]
	,ISNULL(aup.[HDC-OT],0) as [Household drinks containers-Other (No.Units)]
	,ISNULL(ap.[HDC-PC],0) as [Household drinks containers-Paper / Card (Kg)]
	,ISNULL(aup.[HDC-PC],0) as [Household drinks containers-Paper / Card (No.Units)]
	,ISNULL(ap.[HDC-PL],0) as [Household drinks containers-Plastic (Kg)]
	,ISNULL(aup.[HDC-PL],0) as [Household drinks containers-Plastic (No.Units)]
	,ISNULL(ap.[HDC-ST],0) as [Household drinks containers-Steel (Kg)]
	,ISNULL(aup.[HDC-ST],0) as [Household drinks containers-Steel (No.Units)]
	,ISNULL(ap.[HDC-WD],0) as [Household drinks containers-Wood (Kg)]
	,ISNULL(aup.[HDC-WD],0) as [Household drinks containers-Wood (No.Units)]

	,ISNULL(ap.[HH-AL],0) as [Total Household packaging-Aluminium]
	,ISNULL(ap.[HH-FC],0) as [Total Household packaging-Fibre Composite]
	,ISNULL(ap.[HH-GL],0) as [Total Household packaging-Glass]
	,ISNULL(ap.[HH-OT],0) as [Total Household packaging-Other]
	,ISNULL(ap.[HH-PC],0) as [Total Household packaging-Paper / Card]
	,ISNULL(ap.[HH-PL],0) as [Total Household packaging-Plastic]
	,ISNULL(ap.[HH-ST],0) as [Total Household packaging-Steel]
	,ISNULL(ap.[HH-WD],0) as [Total Household packaging-Wood]

	,ISNULL(ap.[NDC-AL],0) as [Non-household drinks containers-Aluminium (Kg)]
	,ISNULL(aup.[NDC-AL],0) as [Non-household drinks containers-Aluminium (No.Units)]
	,ISNULL(ap.[NDC-FC],0) as [Non-household drinks containers-Fibre Composite (Kg)]
	,ISNULL(aup.[NDC-FC],0) as [Non-household drinks containers-Fibre Composite (No.Units)]
	,ISNULL(ap.[NDC-GL],0) as [Non-household drinks containers-Glass (Kg)]
	,ISNULL(aup.[NDC-GL],0) as [Non-household drinks containers-Glass (No.Units)]
	,ISNULL(ap.[NDC-OT],0) as [Non-household drinks containers-Other (Kg)]
	,ISNULL(aup.[NDC-OT],0) as [Non-household drinks containers-Other (No.Units)]
	,ISNULL(ap.[NDC-PC],0) as [Non-household drinks containers-Paper / Card (Kg)]
	,ISNULL(aup.[NDC-PC],0) as [Non-household drinks containers-Paper / Card (No.Units)]
	,ISNULL(ap.[NDC-PL],0) as [Non-household drinks containers-Plastic (Kg)]
	,ISNULL(aup.[NDC-PL],0) as [Non-household drinks containers-Plastic (No.Units)]
	,ISNULL(ap.[NDC-ST],0) as [Non-household drinks containers-Steel (Kg)]
	,ISNULL(aup.[NDC-ST],0) as [Non-household drinks containers-Steel (No.Units)]
	,ISNULL(ap.[NDC-WD],0) as [Non-household drinks containers-Wood (Kg)]
	,ISNULL(aup.[NDC-WD],0) as [Non-household drinks containers-Wood (No.Units)]

	,ISNULL(ap.[NH-AL],0) as [Total Non-Household packaging-Aluminium]
	,ISNULL(ap.[NH-FC],0) as [Total Non-Household packaging-Fibre Composite]
	,ISNULL(ap.[NH-GL],0) as [Total Non-Household packaging-Glass]
	,ISNULL(ap.[NH-OT],0) as [Total Non-Household packaging-Other]
	,ISNULL(ap.[NH-PC],0) as [Total Non-Household packaging-Paper / Card]
	,ISNULL(ap.[NH-PL],0) as [Total Non-Household packaging-Plastic]
	,ISNULL(ap.[NH-ST],0) as [Total Non-Household packaging-Steel]
	,ISNULL(ap.[NH-WD],0) as [Total Non-Household packaging-Wood]
	,ISNULL(ap.[OW-AL],0) as [Self-managed organisation waste-Aluminium]
	,ISNULL(ap.[OW-FC],0) as [Self-managed organisation waste-Fibre Composite]
	,ISNULL(ap.[OW-GL],0) as [Self-managed organisation waste-Glass]
	,ISNULL(ap.[OW-OT],0) as [Self-managed organisation waste-Other]
	,ISNULL(ap.[OW-PC],0) as [Self-managed organisation waste-Paper / Card]
	,ISNULL(ap.[OW-PL],0) as [Self-managed organisation waste-Plastic]
	,ISNULL(ap.[OW-ST],0) as [Self-managed organisation waste-Steel]
	,ISNULL(ap.[OW-WD],0) as [Self-managed organisation waste-Wood]
	,ISNULL(ap.[PB-AL],0) as [Public binned-Aluminium]
	,ISNULL(ap.[PB-FC],0) as [Public binned-Fibre Composite]
	,ISNULL(ap.[PB-GL],0) as [Public binned-Glass]
	,ISNULL(ap.[PB-OT],0) as [Public binned-Other]
	,ISNULL(ap.[PB-PC],0) as [Public binned-Paper / Card]
	,ISNULL(ap.[PB-PL],0) as [Public binned-Plastic]
	,ISNULL(ap.[PB-ST],0) as [Public binned-Steel]
	,ISNULL(ap.[PB-WD],0) as [Public binned-Wood]
	,ISNULL(ap.[RU-AL],0) as [Reusable packaging-Aluminium]
	,ISNULL(ap.[RU-FC],0) as [Reusable packaging-Fibre Composite]
	,ISNULL(ap.[RU-GL],0) as [Reusable packaging-Glass]
	,ISNULL(ap.[RU-OT],0) as [Reusable packaging-Other]
	,ISNULL(ap.[RU-PC],0) as [Reusable packaging-Paper / Card]
	,ISNULL(ap.[RU-PL],0) as [Reusable packaging-Plastic]
	,ISNULL(ap.[RU-ST],0) as [Reusable packaging-Steel]
	,ISNULL(ap.[RU-WD],0) as [Reusable packaging-Wood]
	,ISNULL(ap.[SP-AL],0) as [Small organisation packaging - all-Aluminium]
	,ISNULL(ap.[SP-FC],0) as [Small organisation packaging - all-Fibre Composite]
	,ISNULL(ap.[SP-GL],0) as [Small organisation packaging - all-Glass]
	,ISNULL(ap.[SP-OT],0) as [Small organisation packaging - all-Other]
	,ISNULL(ap.[SP-PC],0) as [Small organisation packaging - all-Paper / Card]
	,ISNULL(ap.[SP-PL],0) as [Small organisation packaging - all-Plastic]
	,ISNULL(ap.[SP-ST],0) as [Small organisation packaging - all-Steel]
	,ISNULL(ap.[SP-WD],0) as [Small organisation packaging - all-Wood]
	,bs.Reporting_Year
	
From base_sql bs

left join f_org_sql fos on fos.[Org ID] = bs.[Org ID] and fos.[Rank] = bs.RankId
left join l_org_sql los on los.[Org ID] = bs.[Org ID] and los.[Rank] = bs.RankId

left join f_pom_sql fps on fps.[Org ID] = bs.[Org ID] and fps.[Rank] = bs.RankId
left join l_pom_sql lps on lps.[Org ID] = bs.[Org ID] and lps.[Rank] = bs.RankId

left join submission_count sub_c on sub_c.[Org ID] = bs.[Org ID] and sub_c.ReportingYear = bs.Reporting_Year

left join Latest_org_by_CS loby on loby.organisation_id = bs.[Org ID] and loby.ComplianceSchemeId = los.ComplianceSchemeId and loby.SubmissionPeriod = bs.RankId
left join Latest_pom_by_CS lpbc on lpbc.organisation_id = bs.[Org ID] and lpbc.ComplianceSchemeId = lps.ComplianceSchemeId and lpbc.SubmissionPeriod = bs.RankId
left join rptRegistrationRegistered rptReg on rptReg.organisation_id = bs.[Org ID]
left join rptPOM_All_Submissions rptPom on rptPom.organisation_id = bs.[Org ID]

left join agg_POM ap on ap.FileName = lps.pm_filename and ap.organisation_id = lps.[Org ID]
left join agg_units_POM aup on aup.FileName = lps.pm_filename and aup.organisation_id = lps.[Org ID];