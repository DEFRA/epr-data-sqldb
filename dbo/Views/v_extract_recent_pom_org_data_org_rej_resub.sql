CREATE VIEW [dbo].[v_extract_recent_pom_org_data_org_rej_resub]
AS with
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
							when cfm.SubmissionPeriod in ('January to December 2025') then 4
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
							when cfm.SubmissionPeriod in ('Jan to Jun 2024','January to June 2024','January to December 2025') then 2024
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
					, case upper(trim(ISNULL(fs.Regulator_Status,'PENDING')))
						when 'QUERIED' then 'PENDING'
						when 'GRANTED' then 'ACCEPTED'
						when 'REFUSED' then 'ACCEPTED'
						when 'CANCELLED' then 'ACCEPTED'
						when 'APPROVED' then 'ACCEPTED'
						else upper(trim(ISNULL(fs.Regulator_Status,'PENDING'))) end as Regulator_Status
					, upper(trim(ISNULL(fs.Regulator_Status,'PENDING'))) as Actual_Regulator_Status
					, cd.organisation_size as cd_organisation_size
					, '202X-P0'as cd_submission_period_code --YM001
					, fs.IsResubmission_identifier
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
ORG_REJECTED_SUBMISSION_ONLY as
(
	select *
		, row_number() over(partition by OrganisationId, ReferenceNumber, SubmissionPeriod order by Submission_time asc, Source asc) as First_rejected_submission
		, row_number() over(partition by OrganisationId, ReferenceNumber, SubmissionPeriod order by Submission_time desc, Source asc) as Last_rejected_submission
	from ORG
	where Regulator_Status = 'REJECTED' and IsResubmission_identifier=0
),
ORG_REJECTED_RESUBMISSION_ONLY as
(
	select *
		, row_number() over(partition by OrganisationId, ReferenceNumber, SubmissionPeriod order by Submission_time asc, Source asc) as First_rejected_resubmission
		, row_number() over(partition by OrganisationId, ReferenceNumber, SubmissionPeriod order by Submission_time desc, Source asc) as Last_rejected_resubmission
	from ORG
	where Regulator_Status = 'REJECTED' and IsResubmission_identifier=1
),
ORG_PENDING_ACCEPT_ONLY as
(
	select *
		, row_number() over(partition by OrganisationId, ReferenceNumber, SubmissionPeriod order by Submission_time asc, Source asc) as First_pending_accepted_submission
		, row_number() over(partition by OrganisationId, ReferenceNumber, SubmissionPeriod order by Submission_time desc, Source asc) as Last_pending_accepted_submission
	from ORG
	where (Regulator_Status = 'PENDING' or  Regulator_Status = 'ACCEPTED') 
),

/** YM003 : Logic change for First and Latest Registration File Submissions for status queried **/
ORG_QUERIED as
(select * from ORG_PENDING_ACCEPT_ONLY where Actual_Regulator_Status = 'QUERIED' ),

ORG_LATEST_IS_NOT_QUERIED as --YM003
(
select distinct pa.OrganisationId, pa.ReferenceNumber, pa.SubmissionPeriod
from ORG_PENDING_ACCEPT_ONLY pa
inner join ORG_QUERIED oq on oq.OrganisationId = pa.OrganisationId and oq.ReferenceNumber = pa.ReferenceNumber and oq.SubmissionPeriod = pa.SubmissionPeriod
where pa.Last_pending_accepted_submission = 1
and pa.Actual_Regulator_Status <> 'QUERIED'
),

ORG_PENDING_ACCEPT_ONLY_UPDATED as --YM003
(
select OPA.* from ORG_PENDING_ACCEPT_ONLY OPA
left join ORG_LATEST_IS_NOT_QUERIED ONQ on OPA.OrganisationId = ONQ.OrganisationId and OPA.ReferenceNumber = ONQ.ReferenceNumber and OPA.SubmissionPeriod = ONQ.SubmissionPeriod
where ONQ.OrganisationId is null 
		or 
		(OPA.Actual_Regulator_Status <> 'QUERIED' and  ONQ.OrganisationId is not null)
),

ORG_PENDING_ACCEPT_ONLY_UPDATED_WITH_LEAD as --YM005
(
	select * 
		, lead(Actual_Regulator_Status,1,NULL) over (partition by OrganisationId,	ReferenceNumber,	SubmissionPeriod order by Submission_time asc) as lead_Actual_Regulator_Status
		, lead(FileName,1,NULL) over (partition by OrganisationId,	ReferenceNumber,	SubmissionPeriod order by Submission_time asc) as lead_FileName
	from ORG_PENDING_ACCEPT_ONLY_UPDATED
),

ORG_PENDING_ACCEPT_ONLY_UPDATED_WITH_LEAD_DUPLICATE_QUERIED_REMOVED as --YM005
(
	select * from ORG_PENDING_ACCEPT_ONLY_UPDATED_WITH_LEAD
	except(
		select * 
		from ORG_PENDING_ACCEPT_ONLY_UPDATED_WITH_LEAD
		where Actual_Regulator_Status = 'QUERIED' and lead_Actual_Regulator_Status = 'QUERIED' and FileName <> lead_FileName
		)
),

ORG_PENDING_ACCEPT_ONLY_UPDATED_WITH_LEAD_DUPLICATE_QUERIED_REMOVED_WITH_RANK as --YM005
(
	select *
		, row_number() over(partition by OrganisationId, ReferenceNumber, SubmissionPeriod order by Submission_time asc, Source asc) as First_pending_accepted_submission_updated
		, row_number() over(partition by OrganisationId, ReferenceNumber, SubmissionPeriod order by Submission_time desc, Source asc) as Last_pending_accepted_submission_updated 
	from ORG_PENDING_ACCEPT_ONLY_UPDATED_WITH_LEAD_DUPLICATE_QUERIED_REMOVED
),

ORG_REJECTED_WITH_OUT_PENDING_ACCEPTED as --YM003
(
	select rej.*
	from ORG_REJECTED_SUBMISSION_ONLY rej
	left join ORG_PENDING_ACCEPT_ONLY_UPDATED_WITH_LEAD_DUPLICATE_QUERIED_REMOVED_WITH_RANK pa on pa.OrganisationId = rej.OrganisationId and pa.ReferenceNumber = rej.ReferenceNumber and pa.SubmissionPeriod = rej.SubmissionPeriod
	where pa.OrganisationId is null
),
ORG_REJECTED_WITH_OUT_PENDING_ACCEPTED_RESUB as --YM003
(
	select rej.* from ORG_REJECTED_RESUBMISSION_ONLY rej
	inner join ORG_PENDING_ACCEPT_ONLY_UPDATED_WITH_LEAD_DUPLICATE_QUERIED_REMOVED_WITH_RANK pa on pa.OrganisationId = rej.OrganisationId and pa.ReferenceNumber = rej.ReferenceNumber and pa.SubmissionPeriod = rej.SubmissionPeriod
	where rej.Actual_Regulator_Status ='Rejected'
),
f_org_sql as
 (
	select ReferenceNumber as 'Org ID', SubmissionPeriod as 'Rank', ReportingYear, Submission_time as 'Submission date time', case when ComplianceSchemeId is null then 'DP' else CS_Name end as 'Submitted by',	File_Status as 'Submission status', Regulator_Status as 'Regulator Decision', Actual_Regulator_Status as 'Actual Regulator Decision',	[Who submitted], [CS Nation] , cd_filename, ComplianceSchemeId, cd_organisation_size,cd_submission_period_code --YM001
	from ORG_PENDING_ACCEPT_ONLY_UPDATED_WITH_LEAD_DUPLICATE_QUERIED_REMOVED_WITH_RANK --YM003 --YM005
	where First_pending_accepted_submission_updated = 1
	union 
	select ReferenceNumber as 'Org ID', SubmissionPeriod as 'Rank', ReportingYear, Submission_time as 'Submission date time', case when ComplianceSchemeId is null then 'DP' else CS_Name end as 'Submitted by',	File_Status as 'Submission status', Regulator_Status as 'Regulator Decision', Actual_Regulator_Status as 'Actual Regulator Decision',	[Who submitted], [CS Nation] , cd_filename, ComplianceSchemeId, cd_organisation_size,cd_submission_period_code --YM001
	from ORG_REJECTED_WITH_OUT_PENDING_ACCEPTED 
	where Last_rejected_submission = 1
 ) ,
l_org_sql as
 (select * from (select a.*, row_number() over(partition by [Org ID], ReportingYear,[Rank] order by [Submission date time] desc) as Lastest_status from 
 (
select ReferenceNumber as 'Org ID', SubmissionPeriod as 'Rank', ReportingYear, Submission_time as 'Submission date time', case when ComplianceSchemeId is null then 'DP' else CS_Name end as 'Submitted by',	File_Status as 'Submission status', Regulator_Status as 'Regulator Decision', Actual_Regulator_Status as 'Actual Regulator Decision',	[Who submitted], [CS Nation] , cd_filename, ComplianceSchemeId, cd_organisation_size,cd_submission_period_code --YM001
	from ORG_PENDING_ACCEPT_ONLY_UPDATED_WITH_LEAD_DUPLICATE_QUERIED_REMOVED_WITH_RANK --YM003 --YM005
	where Last_pending_accepted_submission_updated = 1
	union 
	select ReferenceNumber as 'Org ID', SubmissionPeriod as 'Rank', ReportingYear, Submission_time as 'Submission date time', case when ComplianceSchemeId is null then 'DP' else CS_Name end as 'Submitted by',	File_Status as 'Submission status', Regulator_Status as 'Regulator Decision', Actual_Regulator_Status as 'Actual Regulator Decision',	[Who submitted], [CS Nation] , cd_filename, ComplianceSchemeId, cd_organisation_size,cd_submission_period_code --YM001
	from ORG_REJECTED_WITH_OUT_PENDING_ACCEPTED_RESUB 
	where Last_rejected_resubmission = 1) a
	) b where Lastest_status=1
 )select * from l_org_sql;