CREATE VIEW [dbo].[v_New_Enrolment_Report] AS WITH 
cte_Enrolments_AND_DP AS (
    SELECT 
		e.[Enrolment_Id],
        e.[Enrolment_ConnectionId],
        e.[Enrolment_ServiceRoleId],
        e.[Enrolment_ValidFrom],
        e.[Enrolment_ValidTo],
        e.[Enrolment_ExternalId],
        e.[Enrolment_CreatedOn],
        e.[Enrolment_LAStUpdatedon],
        e.[Enrolment_IsDeleted],
        e.[Enrolment_RegulatorCommentId],
        e.[EnrolmentStatuses_EnrolmentStatus],
        e.[ServiceRoles_Id],
        e.[ServiceRoles_ServiceId],
        e.[ServiceRoles_Key],
        e.[ServiceRoles_Role],
        e.[ServiceRoles_Description],
        e.[Services_Key],
        e.[Services_Service],
        e.[Services_Description],
        d.[RelationshipType] AS DelegatedPersonEnrolment_RelationshipType,
        d.[ConsultancyName] AS DelegatedPersonEnrolment_ConsultancyName,
        d.[ComplianceSchemeName] AS DelegatedPersonEnrolment_ComplianceSchemeName,
        d.[OtherOrganisationName] AS DelegatedPersonEnrolment_OtherOrganisationNation,
        d.[OtherRelationshipDescription] AS DelegatedPersonEnrolment_OtherRelationshipDescription,
        d.[NominatorDeclaration] AS DelegatedPersonEnrolment_NominatorDeclaration,
        d.[NominatorDeclarationTime] AS DelegatedPersonEnrolment_NominatorDeclarationTime,
        d.[NomineeDeclaration] AS DelegatedPersonEnrolment_NomineeDeclaration,
        d.[NomineeDeclarationTime] AS DelegatedPersonEnrolment_NomineeDeclarationTime,
        d.[Createdon] AS DelegatedPersonEnrolment_CreatedOn,
        d.[LAStUpdatedon] AS DelegatedPersonEnrolment_LAStUpdatedon,
        d.[IsDeleted] AS DelegatedPersonEnrolment_IsDeleted,
		--newcolumns
		ApprovedPerson_Id = CASE
        WHEN e.ServiceRoles_Role = 'Approved Person'
        THEN con.PersonId
        ELSE ''
        END,
		ApprovedPerson_FirstName = CASE
        WHEN e.ServiceRoles_Role = 'Approved Person'
        THEN p.FirstName
        ELSE ''
        END,
    ApprovedPerson_LastName = CASE
        WHEN e.ServiceRoles_Role = 'Approved Person'
        THEN p.LastName
        ELSE ''
        END,
    ApprovedPerson_Email = CASE
        WHEN e.ServiceRoles_Role = 'Approved Person'
        THEN p.Email
        ELSE ''
        END,
    ApprovedPerson_Telephone = CASE
        WHEN e.ServiceRoles_Role = 'Approved Person'
        THEN p.Telephone
        ELSE ''
        END,
    ApprovedPerson_CreatedOn = CASE
        WHEN e.ServiceRoles_Role = 'Approved Person'
        THEN p.Createdon
        ELSE ''
        END,
    ApprovedPerson_LastUpdatedOn = CASE
        WHEN e.ServiceRoles_Role = 'Approved Person'
        THEN p.LastUpdatedon
        ELSE ''
        END,
    ApprovedPerson_IsDeleted = CASE
        WHEN e.ServiceRoles_Role = 'Approved Person'
        THEN p.IsDeleted
        ELSE ''
        END,
    ApprovedPerson_JobTitle = CASE
        WHEN e.ServiceRoles_Role = 'Approved Person'
        THEN con.JobTitle
        ELSE ''
        END,
	DelegatedPerson_Id = CASE
        WHEN e.ServiceRoles_Role = 'Delegated Person'
        THEN con.PersonId
        ELSE ''
        END,
    DelegatedPerson_FirstName = CASE
        WHEN e.ServiceRoles_Role = 'Delegated Person'
        THEN p.FirstName
        ELSE ''
        END,
    DelegatedPerson_LastName = CASE
        WHEN e.ServiceRoles_Role = 'Delegated Person'
        THEN p.LastName
        ELSE ''
        END,
    DelegatedPerson_Email = CASE
        WHEN e.ServiceRoles_Role = 'Delegated Person'
        THEN p.Email
        ELSE ''
        END,
    DelegatedPerson_Telephone = CASE
        WHEN e.ServiceRoles_Role = 'Delegated Person'
        THEN p.Telephone
        ELSE ''
        END,
    DelegatedPerson_CreatedOn = CASE
        WHEN e.ServiceRoles_Role = 'Delegated Person'
        THEN p.Createdon
        ELSE ''
        END,
    DelegatedPerson_LastUpdatedOn = CASE
        WHEN e.ServiceRoles_Role = 'Delegated Person'
        THEN p.LastUpdatedon
        ELSE ''
        END,
    DelegatedPerson_IsDeleted = CASE
        WHEN e.ServiceRoles_Role = 'Delegated Person'
        THEN p.IsDeleted
        ELSE ''
        END,
    DelegatedPerson_JobTitle = CASE
        WHEN e.ServiceRoles_Role = 'Delegated Person'
        THEN con.JobTitle
        ELSE ''
        END,
		--done
        n.[RelationshipType] AS NominatedDelegatedPersonEnrolment_RelationshipType,
        n.[ConsultancyName] AS NominatedDelegatedPersonEnrolment_ConsultancyName,
        n.[ComplianceSchemeName] AS NominatedDelegatedPersonEnrolment_ComplianceSchemeName,
        n.[OtherOrganisationName] AS NominatedDelegatedPersonEnrolment_OtherOrganisationNation,
        n.[OtherRelationshipDescription] AS NominatedDelegatedPersonEnrolment_OtherRelationshipDescription,
        n.[NominatorDeclaration] AS NominatedDelegatedPersonEnrolment_NominatorDeclaration,
        n.[NominatorDeclarationTime] AS NominatedDelegatedPersonEnrolment_NominatorDeclarationTime,
        n.[NomineeDeclaration] AS NominatedDelegatedPersonEnrolment_NomineeDeclaration,
        n.[NomineeDeclarationTime] AS NominatedDelegatedPersonEnrolment_NomineeDeclarationTime,
        n.[Createdon] AS NominatedDelegatedPersonEnrolment_CreatedOn,
        n.[LAStUpdatedon] AS NominatedDelegatedPersonEnrolment_LAStUpdatedon,
        n.[IsDeleted] AS NominatedDelegatedPersonEnrolment_IsDeleted
    FROM dbo.v_Enrolments e
    LEFT JOIN dbo.v_rpd_DelegatedPersonEnrolments_Active d ON e.Enrolment_Id = d.EnrolmentId
	LEFT JOIN dbo.v_rpd_DelegatedPersonEnrolments_Active n ON e.Enrolment_Id = n.NominatorEnrolmentId
	left join [rpd].[PersonOrganisationConnections] con on e.Enrolment_ConnectionId = con.Id
	left join [rpd].[Persons] p on p.id = con.PersonId
),

cte_PersonsUsers AS (
    SELECT 
        p.Id AS Persons_Id,
        p.FirstName AS Persons_FirstName,
        p.LastName AS Persons_LastName,
        p.Email AS Persons_Email,
        p.Telephone AS Persons_Telephone,
        p.CreatedOn AS Persons_Createdon,
        p.LastUpdatedOn AS Persons_LastUpdatedon,
        p.IsDeleted AS Persons_IsDeleted,
        u.Email AS Users_Email,
        u.IsDeleted AS Users_IsDeleted,
        u.InviteToken AS Users_InviteToken,
        u.InvitedBy AS Users_InvitedBy
    FROM dbo.v_rpd_Persons_Active AS p
    LEFT JOIN dbo.v_rpd_Users_Active AS u ON p.UserId = u.Id
),

cte_PersonOrganisationConnections AS (
SELECT 
    poc.Id AS PersonOrganisationConnections_Id,
    poc.OrganisationId AS PersonOrganisationConnections_OrganisationId,
    poc.JobTitle AS PersonOrganisationConnections_JobTitle,
    poc.ExternalId AS PersonOrganisationConnections_ExternalId,
    poc.CreatedOn AS PersonOrganisationConnections_Createdon,
    poc.LastUpdatedOn AS PersonOrganisationConnections_LastUpdatedon,
    poc.IsDeleted AS PersonOrganisationConnections_IsDeleted,
    otpr.Name AS OrganisationToPersonRoles_Role,
    pior.Name AS PersonInOrganisationRoles_Role,
    pu.Persons_Id,
    pu.Persons_FirstName,
    pu.Persons_LastName,
    pu.Persons_Email,
    pu.Persons_Telephone,
    pu.Persons_Createdon,
    pu.Persons_LastUpdatedon,
    pu.Persons_IsDeleted,
    pu.Users_Email,
    pu.Users_IsDeleted,
    pu.Users_InviteToken,
    pu.Users_InvitedBy
FROM dbo.v_rpd_PersonOrganisationConnections_Active AS poc
LEFT JOIN rpd.OrganisationToPersonRoles AS otpr ON poc.OrganisationRoleId = otpr.Id
LEFT JOIN rpd.PersonInOrganisationRoles AS pior ON poc.PersonRoleId = pior.Id
LEFT JOIN cte_PersonsUsers pu ON poc.PersonId = pu.Persons_Id
),

cte_PersonOrgConnectionsANDEnrolments AS (
SELECT 
    poc.*,
    e.*
FROM cte_PersonOrganisationConnections AS poc
LEFT JOIN cte_Enrolments_AND_DP AS e ON poc.PersonOrganisationConnections_Id = e.Enrolment_ConnectionId
), 

cte_Organisations_PreJoin AS (
SELECT 
    org.Id AS Organisations_Id,
    org.OrganisationTypeId AS Organisations_OrganisationTypeId,
    org.CompaniesHouseNumber AS Organisations_CompaniesHouseNumber,
    org.Name AS Organisations_Name,
    org.TradingName AS Organisations_TradingName,
    org.ReferenceNumber AS Organisations_ReferenceNumber,
    org.SubBuildingName AS Organisations_SubBuildingName,
    org.BuildingName AS Organisations_BuildingName,
    org.BuildingNumber AS Organisations_BuildingNumber,
    org.Street AS Organisations_Street,
    org.Locality AS Organisations_Locality,
    org.DepENDentLocality AS Organisations_DepENDentLocality,
    org.Town AS Organisations_Town,
    org.County AS Organisations_County,
    org.Country AS Organisations_Country,
    org.Postcode AS Organisations_Postcode,
    org.ValidatedWithCompaniesHouse AS Organisations_ValidatedWithCompaniesHouse,
    org.IsComplianceScheme AS Organisations_IsComplianceScheme,
    org.NationId AS Organisations_NationId,
	fn.Name AS FromOrganisation_NationName,
    org.CreatedOn AS Organisations_Createdon,
    org.LastUpdatedOn AS Organisations_LastUpdatedon,
    org.IsDeleted AS Organisations_IsDeleted,
    org.ProducerTypeId AS Organisations_ProducerTypeId,
    org.TransferNationId AS Organisations_TransferNationId,
    orgType.Name AS OrganisationTypes_OrganisationType,
	css.name AS ComplianceSchemeName,
	poc.*
FROM dbo.v_rpd_Organisations_Active AS org
LEFT JOIN rpd.OrganisationTypes AS orgType ON org.OrganisationTypeId = orgType.Id
left join cte_PersonOrgConnectionsANDEnrolments poc on poc.PersonOrganisationConnections_OrganisationId = org.id
LEFT JOIN rpd.Nations fn ON org.NationId = fn.Id
left join [rpd].[ComplianceSchemes] css on css.[CompaniesHouseNumber] = org.CompaniesHouseNumber
),

cte_OrganisationConnectionsANDComplianceSchemes AS (
SELECT 
    oc.Id AS OrganisationConnections_Id,
    oc.FromOrganisationId AS OrganisationConnections_FromOrganisationId,
	cs.Organisations_Name AS FromOrganisation_Name,
	cs.Organisations_CompaniesHouseNumber AS FromOrganisation_CompaniesHouseNumber,
    cs.Organisations_ReferenceNumber AS FromOrganisation_ReferenceNumber,
	cs.OrganisationTypes_OrganisationType as FromOrganisation_Type,
    oc.FromOrganisationRoleId AS OrganisationConnections_FromOrganisationRoleId,
    oc.ToOrganisationId AS OrganisationConnections_ToOrganisationId,
    oc.ToOrganisationRoleId AS OrganisationConnections_ToOrganisationRoleId,
    oc.CreatedOn AS OrganisationConnections_Createdon,
    oc.LastUpdatedOn AS OrganisationConnections_LastUpdatedon,
    oc.IsDeleted AS OrganisationConnections_IsDeleted,
    cs.*
FROM rpd.OrganisationsConnections oc
full outer JOIN cte_Organisations_PreJoin cs ON oc.FromOrganisationId = cs.Organisations_Id and oc.IsDeleted = 0
union
SELECT 
    oc.Id AS OrganisationConnections_Id,
    oc.FromOrganisationId AS OrganisationConnections_FromOrganisationId,
	cs.Organisations_Name AS FromOrganisation_Name,
	cs.Organisations_CompaniesHouseNumber AS FromOrganisation_CompaniesHouseNumber,
    cs.Organisations_ReferenceNumber AS FromOrganisation_ReferenceNumber,
	cs.OrganisationTypes_OrganisationType as FromOrganisation_Type,
    oc.FromOrganisationRoleId AS OrganisationConnections_FromOrganisationRoleId,
    oc.ToOrganisationId AS OrganisationConnections_ToOrganisationId,
    oc.ToOrganisationRoleId AS OrganisationConnections_ToOrganisationRoleId,
    oc.CreatedOn AS OrganisationConnections_Createdon,
    oc.LastUpdatedOn AS OrganisationConnections_LastUpdatedon,
    oc.IsDeleted AS OrganisationConnections_IsDeleted,
    cs.*
FROM rpd.OrganisationsConnections oc
INNER JOIN cte_Organisations_PreJoin cs ON oc.FromOrganisationId = cs.Organisations_Id and oc.IsDeleted = 1

),

cte_ComplianceSchemes AS (
SELECT 
    ss.Id AS SelectedSchemes_Id,
    ss.OrganisationConnectionId AS SelectedSchemes_OrganisationConnectionId,
    ss.ComplianceSchemeId AS SelectedSchemes_ComplianceSchemeId,
    ss.CreatedOn AS SelectedSchemes_Createdon,
    ss.LastUpdatedOn AS SelectedSchemes_LastUpdatedon,
    ss.IsDeleted AS SelectedSchemes_IsDeleted,
    cs.Id AS ComplianceSchemes_Id,
    cs.Name AS ComplianceSchemes_Name,
    cs.CreatedOn AS ComplianceSchemes_Createdon,
    cs.LastUpdatedOn AS ComplianceSchemes_LastUpdatedon,
    cs.IsDeleted AS ComplianceSchemes_IsDeleted,
    cs.CompaniesHouseNumber AS ComplianceSchemes_CompaniesHouseNumber,
	--LK - Added for CS Nation
	cs.NationId AS ComplianceSchemes_NationId,
	ss.*
FROM rpd.SelectedSchemes AS ss
LEFT JOIN rpd.ComplianceSchemes  AS cs ON ss.ComplianceSchemeId = cs.Id
),

cte_organisation_selected_scheme as (
select ocs.*,
	cs.SelectedSchemes_Id,
    cs.SelectedSchemes_OrganisationConnectionId,
    cs.SelectedSchemes_ComplianceSchemeId,
    cs.SelectedSchemes_Createdon,
    cs.SelectedSchemes_LastUpdatedon,
    cs.SelectedSchemes_IsDeleted,
    cs.ComplianceSchemes_Id,
    cs.ComplianceSchemes_Name,
    cs.ComplianceSchemes_Createdon,
    cs.ComplianceSchemes_LastUpdatedon,
    cs.ComplianceSchemes_IsDeleted,
    cs.ComplianceSchemes_CompaniesHouseNumber,
	ComplianceSchemes_NationId
from cte_OrganisationConnectionsANDComplianceSchemes  ocs
left join cte_ComplianceSchemes cs on cs.SelectedSchemes_OrganisationConnectionId = ocs.OrganisationConnections_Id
),

cte_enrolment_before_breakdown as (
select sec.FromOrganisation_Name
		,sec.ComplianceSchemes_Name
		,sec.Organisations_IsComplianceScheme
		--,sec.ComplianceSchemeName
		,coalesce(sec.ComplianceSchemeName, sec.ComplianceSchemes_Name) as ComplianceSchemesName 
		,sec.FromOrganisation_Type
		,CASE 
			WHEN sec.FromOrganisation_Type = 'Companies House Company' THEN sec.FromOrganisation_Type 
			ELSE ptf.Name
		END AS Organisation_Type
		,sec.Organisations_ProducerTypeId
		,sec.ServiceRoles_Role
		--,sec.Enrolment_CreatedOn
		,sec.FromOrganisation_ReferenceNumber
		,sec.FromOrganisation_CompaniesHouseNumber
		,sec.FromOrganisation_NationName
		,sec.ComplianceSchemes_NationId
		,n.name AS Compliance_Scheme_Nation
		,sec.ApprovedPerson_FirstName
		,sec.ApprovedPerson_LastName
		,sec.ApprovedPerson_JobTitle
		,sec.ApprovedPerson_Telephone
		,sec.ApprovedPerson_Email
		,sec.DelegatedPerson_FirstName
		,sec.DelegatedPerson_LastName
		,sec.DelegatedPerson_JobTitle
		,sec.DelegatedPerson_Email
		,sec.DelegatedPerson_Telephone
		,sec.DelegatedPersonEnrolment_RelationshipType
		,sec.DelegatedPersonEnrolment_OtherRelationshipDescription
		,sec.Enrolment_Id
		,sec.Enrolment_ExternalId
		,sec.Organisations_Id
		,sec.Persons_Id
		,sec.SelectedSchemes_IsDeleted
		,sec.OrganisationConnections_CreatedOn
		,Enrolment_CreatedOn_str=sec.Enrolment_CreatedOn 
		,ve.[Status]
		,ve.Regulator_Rejection_Comments
		,FORMAT(CONVERT(DATETIME, REPLACE(LEFT(ve.Decision_Date, 23), 'T', ' '), 121), 'dd/MM/yyyy HH:mm:ss') AS Decision_Date
		,ve.Regulator_User_Name
		

from cte_organisation_selected_scheme sec
Left Join dbo.v_Enrolmentstatus ve on ve.EnrolmentID=sec.Enrolment_Id
LEFT JOIN rpd.producerTypes ptf ON sec.Organisations_ProducerTypeId = ptf.id
left join rpd.nations n on n.id = sec.ComplianceSchemes_NationId
),


LtstCS as (
			Select Distinct
				 Organisations_Id AS Organisations_Id
				,FromOrganisation_ReferenceNumber AS FromOrganisation_ReferenceNumber_lcs
				,ComplianceSchemes_Name AS ComplianceSchemes_Name_lcs
				,SelectedSchemes_IsDeleted AS SelectedSchemes_IsDeleted_lcs
				,Persons_Id as Persons_Id_1
				,Case When 
					Row_Number () over(partition by [FromOrganisation_ReferenceNumber], Persons_Id Order By ISNULL(SelectedSchemes_IsDeleted, '0') asc, CONVERT(DATETIME,substring([OrganisationConnections_CreatedOn],1,23)) Desc) = 1
						--And Isnull(SelectedSchemes_IsDeleted,0) = 0 
					Then 1 
					Else 0 
				End Is_LatestCS
			From 
				cte_enrolment_before_breakdown
),

src as (
		Select 	 
			 eb.*
			
			,Case When Row_Number () over(partition by [FromOrganisation_ReferenceNumber],Persons_Id
				Order By isnull(SelectedSchemes_IsDeleted, '0') asc, isnull(Convert(DATETIME,substring(eb.[OrganisationConnections_CreatedOn],1,23)), getdate()) )=1  --, SecurityQuery
					And ISNULL(SelectedSchemes_IsDeleted,0) = 0 
						then 'Latest Enrolment' 
				Else 'Old Enrolment' 
			End IsLatestEnrolment
			
			,Case 
				when [Organisations_IsComplianceScheme] = 1 Then 'Operator'
				When ISNULL([ComplianceSchemes_Name],'') <> '' Then 'CS Member'	
			Else 'Direct Producer' End [CSorDP]
			,Enrolment_CreatedOn=CONVERT(DATETIME,substring(eb.[Enrolment_CreatedOn_str],1,23))
			,LtstCS.ComplianceSchemes_Name_lcs AS Latest_ComplianceScheme
		From 
			cte_enrolment_before_breakdown eb  
		inner Join LtstCS  on eb.FromOrganisation_ReferenceNumber=LtstCS.FromOrganisation_ReferenceNumber_lcs and LtstCS.Is_LatestCS=1 and LtstCS.Persons_Id_1 = eb.Persons_Id
)


select *
from src;