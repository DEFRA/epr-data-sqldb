CREATE VIEW [dbo].[v_submission_report] AS WITH  file_id_set_id as
(
	select distinct RegistrationSetId, FileId, FileName, min(load_ts) as dw_loaded_ts
	from [rpd].[SubmissionEvents] 
	where FileId is not null
	and FileName is not null
	--and SubmissionId in ('df02046f-2d17-463b-9f2a-7d0067778b0d')
	group by RegistrationSetId, FileId, FileName
)
,file_type_id as
(
	select distinct FileType, FileId
	from [rpd].[SubmissionEvents] 
	where FileType is not null 
	and FileId is not null
)
, blob_and_File_id as
(
select distinct BlobName, FileId
from [rpd].[SubmissionEvents] 
where 
BlobName is not null
and 
FileId is not null
)
, file_type_id_blobname_filename as
(
	select ftyid.FileType, ftyid.FileId, bfid.BlobName, set_id.FileName, set_id.RegistrationSetId, set_id.dw_loaded_ts
	from blob_and_File_id bfid
	inner join file_type_id ftyid on bfid.FileId = ftyid.FileId
	inner join file_id_set_id set_id on set_id.FileId = bfid.FileId
)
--select * From file_type_id_blobname_filename
,
submitted_files as
(
	select 
		f.FileType, 
		f.FileName, 
		se.Created as submitted_ts,
		f.dw_loaded_ts,
		f.fileid,
		f.BlobName,
		f.RegistrationSetId,
		se.fileid as se_fileid
	from [rpd].[SubmissionEvents] se
	inner join file_type_id_blobname_filename f on f.fileid = se.fileid
	where se.Type = 'Submitted' 
)
select 
	distinct o.ReferenceNumber as 'Submitter Org id'
			, o.Name as 'Submitter Org Name'
			, orgNation.Name as 'Submitter Org Nation'
			,case when o.IsComplianceScheme = 1 then 'CS' when o.IsComplianceScheme = 0 then 'DP' else 'Error - No data' end as 'Is Sumitter a CS or DP'
			,sf.FileType
			,css.Name 'Compliance Scheme Name'
			,csNation.Name 'Compliance Scheme - Nation'
			,sf.FileName as 'Actual File name'
			,CONVERT(DATETIME,substring(sf.submitted_ts,1,23)) as 'File submitted timestamp'
			,sf.dw_loaded_ts 'File received at datawarehouse timestamp'
			, case when meta.filename is null then 'No' else 'Y' end as 'Is the file received by Datawarehouse'
			
			--, ISNULL(p.filename,'No') is_loaded_to_pom_table
			--, ISNULL(cd.filename,'No') is_loaded_to_org_table
			, case when p.filename is null and cd.filename is null then 'Error'
					when p.filename is not null or cd.filename is not null then 'Y'
					else 'No'
					end as 'Is the file loaded to rpd POM or ORG table'
			
			, case when sf.FileType = 'Pom' and SS.PomBlobName is not null then 'Y'
					when sf.FileType = 'CompanyDetails' and RS.CompanyDetailsBlobName is not null then 'Y'
					else 'No'
					end as 'Is the file loaded to apps POM or ORG table'

			, meta.SubmissionPeriod
			, us.Email as 'Submitter email id'
			, per.FirstName + ISNULL(per.LastName,'') as 'Submitter Name'

			, CONVERT(DATETIME,substring(fs.Application_submitted_ts,1,23)) as 'Application submitted timestamp'
			--, fs.ApplicationReferenceNo
			--,	fs.registrationreferencenumber

			, fs.IsResubmission_identifier as 'Is this resubmitted registration file'

			, fs.Decision_Date
			,	fs.Regulator_Status
			,	fs.Original_Regulator_Status
			,	fs.RegulatorDecision
			,	fs.Regulator_User_Name
			,	fs.Regulator_Rejection_Comments
			,	fs.RejectionComments

			,sf.BlobName
			--, case when cd.filename is not null then 'Yes' when cd.filename is null and sf.FileType = 'CompanyDetails' then 'No' else cd.filename end as is_loaded_to_org_table
			--case when sf.FileType <> 'CompanyDetails' then 'N/A' when sf.FileType = 'CompanyDetails' and cd.filename is null then 'No' else 'Yes' end as is_loaded_to_org_table
			,sf.fileid
			, meta.BlobContainerName
			, meta.SubmissionId
			, meta.UserId
			, meta.RegistrationSetId
			, meta.OrganisationId
			, meta.SubmissionType
			, meta.ComplianceSchemeId
			, ISNULL(meta.filename,'No') is_loaded_to_meta_table
			, coalesce( p.filename, cd.filename , 'Error') as is_loaded_to_pom_or_org_table
			, case when sf.FileType = 'Pom' then 'N/A' else ISNULL(RS.CompanyDetailsBlobName,'No') end is_loaded_to_apps_org_table
			, case when sf.FileType = 'CompanyDetails' then 'N/A' else ISNULL(SS.PomBlobName,'No') end is_loaded_to_apps_pom_table
			,	fs.Type
			, sf.submitted_ts as submitted_ts_str
			
From submitted_files sf
full outer join [rpd].[cosmos_file_metadata] meta on meta.fileid = sf.fileid
left join rpd.pom p on p.filename = meta.filename
left join rpd.companydetails cd on cd.filename = meta.filename
left join apps.RegistrationsSummaries RS on RS.CompanyDetailsBlobName = meta.filename
left join apps.SubmissionsSummaries SS on SS.PomBlobName = meta.filename
left join [dbo].[v_submitted_pom_org_file_status] fs on fs.FileName = meta.filename
left join rpd.Organisations o on o.ExternalId = meta.OrganisationId
left join [rpd].[Users] us on us.UserId = meta.UserId
left join [rpd].[Persons] per on per.UserId = us.Id
left join [rpd].[ComplianceSchemes] css on css.ExternalId = meta.ComplianceSchemeId
left join rpd.nations orgNation on orgNation.Id = o.NationId
left join rpd.nations csNation on csNation.Id = css.NationId
where sf.FileType is not null;