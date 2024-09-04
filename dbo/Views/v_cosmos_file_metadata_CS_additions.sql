CREATE VIEW [dbo].[v_cosmos_file_metadata_CS_additions] AS WITH RankedData AS (
    SELECT
        distinct 
        a.[SubmissionId],
        a.[FileId],
        a.[UserId],
        --b.Submitter_Name [SubmittedBy],
        a.[BlobName],
        a.[BlobContainerName],
        a.[FileType],
        a.[Created],
        a.[OriginalFileName],
        a.[OrganisationId],
        a.[DataSourceType],
        a.[SubmissionPeriod],
        a.[IsSubmitted],
        a.[SubmissionType],
        a.[TargetDirectoryName],
        a.[TargetContainerName],
        a.[SourceContainerName],
        a.[FileName],
        a.[load_ts],
		a.[ComplianceSchemeId],
        ROW_NUMBER() OVER (PARTITION BY a.[FileName] ORDER BY a.[load_ts] DESC) AS RowNum
    FROM rpd.cosmos_file_metadata a
)

select 
a.[SubmissionId]
,a.[FileId]
,a.[UserId]
, concat(p.FirstName, ' ', p.LastName) [SubmittedBy]
,a.[BlobName]
,a.[BlobContainerName]
,a.[FileType]
--,a.[Created]
,CAST(CONVERT(datetimeoffset, created) AT TIME ZONE 'UTC' AT TIME ZONE 'GMT Standard Time' AS datetime) AS created--_in_gmt
,a.[OriginalFileName]
,a.[OrganisationId]
,a.[DataSourceType]
,a.[SubmissionPeriod]
,a.[IsSubmitted]
,a.[SubmissionType]
,a.[TargetDirectoryName]
,a.[TargetContainerName]
,a.[SourceContainerName]
,a.[FileName]
,a.[load_ts]
,p.Email  SubmtterEmail
,roles.[ServiceRoles_Name]
,a.[ComplianceSchemeId]
,o.name submitter_organisation_name
,o.referenceNumber submitter_reference_number
,cs.name compliancescheme_name
,n.name compliancescheme_nation
from RankedData a
left  join  dbo.v_rpd_Organisations_Active o on a.organisationId = o.externalid and o.isdeleted = 0
left join  dbo.v_rpd_ComplianceSchemes_Active cs on cs.externalid = a.[ComplianceSchemeId] and cs.isdeleted = 0
left join rpd.nations n on cs.nationid = n.id 
left join dbo.v_rpd_Users_Active u on a.userid = u.userid and u.isdeleted = 0
left join dbo.v_rpd_Persons_Active p on u.id =p.userid and p.isdeleted = 0
left join dbo.v_rpd_PersonOrganisationConnections_Active poc on p.Id = poc.PersonId and poc.isdeleted = 0
left join  (select enrolments.Id as Enrolments_Id
    ,enrolments.ConnectionId as Enrolments_ConnectionId
    ,enrolments.CreatedOn as Enrolments_CreatedOn
    ,enrolments.IsDeleted as Enrolments_IsDeleted
    ,serviceroles.Name as ServiceRoles_Name
    ,enrolments.LastUpdatedOn as Enrolments_LastUpdatedOn
    ,ROW_NUMBER() OVER (PARTITION BY enrolments.ConnectionId ORDER BY enrolments.LastUpdatedOn DESC) AS RowNum

    from dbo.v_rpd_Enrolments_Active enrolments

    left join rpd.ServiceRoles serviceroles
    on enrolments.ServiceRoleId = serviceroles.Id) roles on roles.Enrolments_ConnectionId = poc.id and roles.RowNum = 1
--left join dbo.v_submitter_name b on a.UserId = b.UserId
where a.RowNum =1;