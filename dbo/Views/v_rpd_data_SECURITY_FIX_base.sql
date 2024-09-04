CREATE VIEW [dbo].[v_rpd_data_SECURITY_FIX_base] AS WITH 
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
	cs.NationId AS ComplianceSchemes_NationId
FROM dbo.v_rpd_SelectedSchemes_Active AS ss
LEFT JOIN dbo.v_rpd_ComplianceSchemes_Active AS cs ON ss.ComplianceSchemeId = cs.Id
),

cte_OrganisationConnectionsANDComplianceSchemes AS (
SELECT 
    oc.Id AS OrganisationConnections_Id,
    oc.FromOrganisationId AS OrganisationConnections_FromOrganisationId,
    oc.FromOrganisationRoleId AS OrganisationConnections_FromOrganisationRoleId,
    oc.ToOrganisationId AS OrganisationConnections_ToOrganisationId,
    oc.ToOrganisationRoleId AS OrganisationConnections_ToOrganisationRoleId,
    oc.CreatedOn AS OrganisationConnections_Createdon,
    oc.LastUpdatedOn AS OrganisationConnections_LastUpdatedon,
    oc.IsDeleted AS OrganisationConnections_IsDeleted,
    cs.*
FROM dbo.v_rpd_OrganisationsConnections_Active oc
LEFT JOIN cte_ComplianceSchemes cs ON oc.Id = cs.SelectedSchemes_OrganisationConnectionId
WHERE oc.IsDeleted = 0
),

cte_OrganisationConnectionsANDComplianceSchemesANDRoles AS (
SELECT 
    oc.*,
    FromRole.Name AS InterOrganisationRoles_FromOrganisationRole,
    toRole.Name AS InterOrganisationRoles_ToOrganisationRole
FROM cte_OrganisationConnectionsANDComplianceSchemes AS oc
LEFT JOIN rpd.InterOrganisationRoles AS FromRole ON oc.OrganisationConnections_FromOrganisationRoleId = FromRole.Id
LEFT JOIN rpd.InterOrganisationRoles AS toRole ON oc.OrganisationConnections_ToOrganisationRoleId = toRole.Id
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
    org.CreatedOn AS Organisations_Createdon,
    org.LastUpdatedOn AS Organisations_LastUpdatedon,
    org.IsDeleted AS Organisations_IsDeleted,
    org.ProducerTypeId AS Organisations_ProducerTypeId,
    org.TransferNationId AS Organisations_TransferNationId,
    orgType.Name AS OrganisationTypes_OrganisationType
FROM dbo.v_rpd_Organisations_Active AS org
LEFT JOIN rpd.OrganisationTypes AS orgType ON org.OrganisationTypeId = orgType.Id
),

cte_OrganisationsANDRoles AS (
SELECT 
	csr.OrganisationConnections_Id,
    csr.OrganisationConnections_FromOrganisationId,
    csr.OrganisationConnections_FromOrganisationRoleId,
    csr.OrganisationConnections_ToOrganisationId,
    csr.OrganisationConnections_ToOrganisationRoleId,
    csr.OrganisationConnections_Createdon,
    csr.OrganisationConnections_LAStUpdatedon,
    csr.OrganisationConnections_IsDeleted,
    csr.SelectedSchemes_Id,
    csr.SelectedSchemes_OrganisationConnectionId,
    csr.SelectedSchemes_ComplianceSchemeId,
    csr.SelectedSchemes_Createdon,
    csr.SelectedSchemes_LAStUpdatedon,
    csr.SelectedSchemes_IsDeleted,
    csr.ComplianceSchemes_Id,
    csr.ComplianceSchemes_Name,
    csr.ComplianceSchemes_Createdon,
    csr.ComplianceSchemes_LAStUpdatedon,
    csr.ComplianceSchemes_IsDeleted,
    csr.ComplianceSchemes_CompaniesHouseNumber,
    csr.InterOrganisationRoles_FromOrganisationRole,
    csr.InterOrganisationRoles_ToOrganisationRole,
    oFrom.Organisations_Id,
	oTO.Organisations_Id ToOrganisations_Id,
    oFrom.Organisations_OrganisationTypeId AS FromOrganisation_TypeId,
		CASE 
			WHEN oFrom.OrganisationTypes_OrganisationType = 'Companies House Company' 
				THEN oFrom.OrganisationTypes_OrganisationType 
			ELSE ptf.Name
		END
    AS FromOrganisation_Type,
    oFrom.Organisations_CompaniesHouseNumber AS FromOrganisation_CompaniesHouseNumber,
    oFrom.Organisations_Name AS FromOrganisation_Name,
    oFrom.Organisations_TradingName AS FromOrganisation_TradingName,
    oFrom.Organisations_ReferenceNumber AS FromOrganisation_ReferenceNumber,
    oFrom.Organisations_SubBuildingName AS FromOrganisation_SubBuildingName,
    oFrom.Organisations_BuildingName AS FromOrganisation_BuildingName,
    oFrom.Organisations_BuildingNumber AS FromOrganisation_BuildingNumber,
    oFrom.Organisations_Street AS FromOrganisation_Street,
    oFrom.Organisations_Locality AS FromOrganisation_Locality,
    oFrom.Organisations_DepENDentLocality AS FromOrganisation_DepENDentLocality,
    oFrom.Organisations_Town AS FromOrganisation_Town,
    oFrom.Organisations_County AS FromOrganisation_County,
    oFrom.Organisations_Country AS FromOrganisation_Country,
    oFrom.Organisations_Postcode AS FromOrganisation_Postcode,
    oFrom.Organisations_ValidatedWithCompaniesHouse AS FromOrganisation_ValidatedWithCompaniesHouse,
    oFrom.Organisations_IsComplianceScheme AS FromOrganisation_IsComplianceScheme,
    oFrom.Organisations_NationId AS FromOrganisation_NationId,
    oFrom.Organisations_Createdon,
    oFrom.Organisations_IsDeleted AS FromOrganisation_IsDeleted,
    oFrom.Organisations_ProducerTypeId AS FromOrganisation_ProducerTypeId,
    oFrom.Organisations_TransferNationId AS FromOrganisation_TransferNationId,
    oto.Organisations_OrganisationTypeId AS ToOrganisation_TypeId,
		CASE 
			WHEN oto.OrganisationTypes_OrganisationType = 'Companies House Company' 
				THEN oto.OrganisationTypes_OrganisationType 
			ELSE ptt.Name 
		END
	AS ToOrganisation_Type,
    oto.Organisations_CompaniesHouseNumber AS ToOrganisation_CompaniesHouseNumber,
    oto.Organisations_Name AS ToOrganisation_Name,
    oto.Organisations_TradingName AS ToOrganisation_TradingName,
    oto.Organisations_ReferenceNumber AS ToOrganisation_ReferenceNumber,
    oto.Organisations_SubBuildingName AS ToOrganisation_SubBuildingName,
    oto.Organisations_BuildingName AS ToOrganisation_BuildingName,
    oto.Organisations_BuildingNumber AS ToOrganisation_BuildingNumber,
    oto.Organisations_Street AS ToOrganisation_Street,
    oto.Organisations_Locality AS ToOrganisation_Locality,
    oto.Organisations_DepENDentLocality AS ToOrganisation_DepENDentLocality,
    oto.Organisations_Town AS ToOrganisation_Town,
    oto.Organisations_County AS ToOrganisation_County,
    oto.Organisations_Country AS ToOrganisation_Country,
    oto.Organisations_Postcode AS ToOrganisation_Postcode,
    oto.Organisations_ValidatedWithCompaniesHouse AS ToOrganisation_ValidatedWithCompaniesHouse,
    oto.Organisations_IsComplianceScheme AS ToOrganisation_IsComplianceScheme,    
	--ISNULL(NULLIF(csr.ComplianceSchemes_NationId, 0), oTO.Organisations_NationId) AS ToOrganisation_NationId,
	oto.Organisations_NationId AS ToOrganisation_NationId,
    oto.Organisations_IsDeleted AS ToOrganisation_IsDeleted,
    oto.Organisations_ProducerTypeId AS ToOrganisation_ProducerTypeId,
    oto.Organisations_TransferNationId AS ToOrganisation_TransferNationId
FROM cte_OrganisationConnectionsANDComplianceSchemesANDRoles csr
FULL OUTER JOIN cte_Organisations_PreJoin oFROM ON csr.OrganisationConnections_FromOrganisationId = oFrom.Organisations_Id
FULL OUTER JOIN cte_Organisations_PreJoin oTO ON csr.OrganisationConnections_ToOrganisationId = oto.Organisations_Id
--LK for cs companies house number where record not the org connections
        --OR csr.ComplianceSchemes_CompaniesHouseNumber = oto.Organisations_CompaniesHouseNumber)
LEFT JOIN rpd.producerTypes ptf ON oFrom.Organisations_ProducerTypeId = ptf.id
LEFT JOIN rpd.producerTypes ptt ON oto.Organisations_ProducerTypeId = ptt.id
),

cte_OrganisationsANDRolesANDPersons AS (
SELECT 
	argR.*,
	ep.*
FROM cte_OrganisationsANDRoles argR
LEFT JOIN cte_PersonOrgConnectionsANDEnrolments ep ON argR.Organisations_Id = ep.PersonOrganisationConnections_OrganisationId
),

cte_OrganisationsANDRolesANDPersonsANDNations AS (
SELECT 
	orp.*,
	fn.Name AS FromOrganisation_NationName,
	tn.Name AS ToOrganisation_NationName,
	ROW_NUMBER() OVER (ORDER BY orp.Organisations_Id) AS Security_Id
FROM cte_OrganisationsANDRolesANDPersons orp
LEFT JOIN rpd.Nations fn ON orp.FromOrganisation_NationId = fn.Id
LEFT JOIN rpd.Nations tn ON orp.ToOrganisation_NationId = tn.Id
),

cte_OrganisationsANDSecurity AS (
    SELECT *
    FROM cte_OrganisationsANDRolesANDPersonsANDNations
    unpivot (
        SecurityQuery
        for SecurityQuery_OrganisationOrigin in (FromOrganisation_NationName, ToOrganisation_NationName)
    ) up
),

cte_RejoinNations AS (
SELECT 
	os.*,
	fn.Name AS FromOrganisation_NationName,
	tn.Name AS ToOrganisation_NationName
FROM cte_OrganisationsANDSecurity os
LEFT JOIN rpd.Nations fn ON os.FromOrganisation_NationId = fn.Id
LEFT JOIN rpd.Nations tn ON os.ToOrganisation_NationId = tn.Id
),

cte_rpd_data AS (
SELECT 
	cast(Organisations_Id AS varchar(20)) AS Organisations_Id,
	ToOrganisations_Id,
    FromOrganisation_TypeId,
    FromOrganisation_Type,
    FromOrganisation_CompaniesHouseNumber,
    FromOrganisation_Name,
    FromOrganisation_TradingName,
    FromOrganisation_ReferenceNumber,
    FromOrganisation_SubBuildingName,
    FromOrganisation_BuildingName,
    FromOrganisation_BuildingNumber,
    FromOrganisation_Street,
    FromOrganisation_Locality,
    FromOrganisation_DepENDentLocality,
    FromOrganisation_Town,
    FromOrganisation_County,
    FromOrganisation_Country,
    FromOrganisation_Postcode,
    FromOrganisation_ValidatedWithCompaniesHouse,
    FromOrganisation_IsComplianceScheme,
    FromOrganisation_NationId,
    Organisations_Createdon,
    FromOrganisation_IsDeleted,
    FromOrganisation_ProducerTypeId,
    FromOrganisation_TransferNationId,
    ToOrganisation_TypeId,
    ToOrganisation_Type,
    ToOrganisation_CompaniesHouseNumber,
    ToOrganisation_Name,
    ToOrganisation_TradingName,
    ToOrganisation_ReferenceNumber,
    ToOrganisation_SubBuildingName,
    ToOrganisation_BuildingName,
    ToOrganisation_BuildingNumber,
    ToOrganisation_Street,
    ToOrganisation_Locality,
    ToOrganisation_DepENDentLocality,
    ToOrganisation_Town,
    ToOrganisation_County,
    ToOrganisation_Country,
    ToOrganisation_Postcode,
    ToOrganisation_ValidatedWithCompaniesHouse,
    ToOrganisation_IsComplianceScheme,
    ToOrganisation_NationId,
    ToOrganisation_IsDeleted,
    ToOrganisation_ProducerTypeId,
    ToOrganisation_TransferNationId,
    OrganisationConnections_Id,
    OrganisationConnections_FromOrganisationId,
    OrganisationConnections_FromOrganisationRoleId,
    OrganisationConnections_ToOrganisationId,
    OrganisationConnections_ToOrganisationRoleId,
    OrganisationConnections_Createdon,
    OrganisationConnections_LastUpdatedon,
    OrganisationConnections_IsDeleted,
    SelectedSchemes_Id,
    SelectedSchemes_OrganisationConnectionId,
    SelectedSchemes_ComplianceSchemeId,
    SelectedSchemes_Createdon,
    SelectedSchemes_LastUpdatedon,
    SelectedSchemes_IsDeleted,
    ComplianceSchemes_Id,
    ComplianceSchemes_Name,
    ComplianceSchemes_Createdon,
    ComplianceSchemes_LastUpdatedon,
    ComplianceSchemes_IsDeleted,
    ComplianceSchemes_CompaniesHouseNumber,
    InterOrganisationRoles_FromOrganisationRole,
    InterOrganisationRoles_ToOrganisationRole,
    PersonOrganisationConnections_Id,
    PersonOrganisationConnections_OrganisationId,
    PersonOrganisationConnections_JobTitle,
    PersonOrganisationConnections_ExternalId,
    PersonOrganisationConnections_Createdon,
    PersonOrganisationConnections_LastUpdatedon,
    PersonOrganisationConnections_IsDeleted,
    OrganisationToPersonRoles_Role,
    PersonInOrganisationRoles_Role,
    Persons_Id,
    Persons_FirstName,
    Persons_LastName,
    Persons_Email,
    Persons_Telephone,
    Persons_Createdon,
    Persons_LastUpdatedon,
    Persons_IsDeleted,
    Users_Email,
    Users_IsDeleted,
    Users_InviteToken,
    Users_InvitedBy,
    Enrolment_Id,
    Enrolment_ConnectionId,
    Enrolment_ServiceRoleId,
    Enrolment_ValidFrom,
    Enrolment_ValidTo,
    Enrolment_ExternalId,
    Enrolment_CreatedOn,
    Enrolment_LastUpdatedon,
    Enrolment_IsDeleted,
    Enrolment_RegulatorCommentId,
    EnrolmentStatuses_EnrolmentStatus,
    ServiceRoles_Id,
    ServiceRoles_ServiceId,
    ServiceRoles_Key,
    ServiceRoles_Role,
    ServiceRoles_Description,
    Services_Key,
    Services_Service,
    Services_Description,
    DelegatedPersonEnrolment_RelationshipType,
    DelegatedPersonEnrolment_ConsultancyName,
    DelegatedPersonEnrolment_ComplianceSchemeName,
    DelegatedPersonEnrolment_OtherOrganisationNation,
    DelegatedPersonEnrolment_OtherRelationshipDescription,
    DelegatedPersonEnrolment_NominatorDeclaration,
    DelegatedPersonEnrolment_NominatorDeclarationTime,
    DelegatedPersonEnrolment_NomineeDeclaration,
    DelegatedPersonEnrolment_NomineeDeclarationTime,
    DelegatedPersonEnrolment_CreatedOn,
    DelegatedPersonEnrolment_LastUpdatedon,
    DelegatedPersonEnrolment_IsDeleted,
    NominatedDelegatedPersonEnrolment_RelationshipType,
    NominatedDelegatedPersonEnrolment_ConsultancyName,
    NominatedDelegatedPersonEnrolment_ComplianceSchemeName,
    NominatedDelegatedPersonEnrolment_OtherOrganisationNation,
    NominatedDelegatedPersonEnrolment_OtherRelationshipDescription,
    NominatedDelegatedPersonEnrolment_NominatorDeclaration,
    NominatedDelegatedPersonEnrolment_NominatorDeclarationTime,
    NominatedDelegatedPersonEnrolment_NomineeDeclaration,
    NominatedDelegatedPersonEnrolment_NomineeDeclarationTime,
    NominatedDelegatedPersonEnrolment_CreatedOn,
    NominatedDelegatedPersonEnrolment_LastUpdatedon,
    NominatedDelegatedPersonEnrolment_IsDeleted,
    FromOrganisation_NationName,
    ToOrganisation_NationName,
    Security_Id,
    SecurityQuery,
    SecurityQuery_OrganisationOrigin,
    ApprovedPerson_Id = CASE
        WHEN ServiceRoles_Role = 'Approved Person'
        THEN Persons_Id
        ELSE ''
        END,
    ApprovedPerson_FirstName = CASE
        WHEN ServiceRoles_Role = 'Approved Person'
        THEN Persons_FirstName
        ELSE ''
        END,
    ApprovedPerson_LastName = CASE
        WHEN ServiceRoles_Role = 'Approved Person'
        THEN Persons_LastName
        ELSE ''
        END,
    ApprovedPerson_Email = CASE
        WHEN ServiceRoles_Role = 'Approved Person'
        THEN Persons_Email
        ELSE ''
        END,
    ApprovedPerson_Telephone = CASE
        WHEN ServiceRoles_Role = 'Approved Person'
        THEN Persons_Telephone
        ELSE ''
        END,
    ApprovedPerson_CreatedOn = CASE
        WHEN ServiceRoles_Role = 'Approved Person'
        THEN Persons_Createdon
        ELSE ''
        END,
    ApprovedPerson_LastUpdatedOn = CASE
        WHEN ServiceRoles_Role = 'Approved Person'
        THEN Persons_LastUpdatedon
        ELSE ''
        END,
    ApprovedPerson_IsDeleted = CASE
        WHEN ServiceRoles_Role = 'Approved Person'
        THEN Persons_IsDeleted
        ELSE ''
        END,
    ApprovedPerson_JobTitle = CASE
        WHEN ServiceRoles_Role = 'Approved Person'
        THEN PersonOrganisationConnections_JobTitle
        ELSE ''
        END,
    DelegatedPerson_Id = CASE
        WHEN ServiceRoles_Role = 'Delegated Person'
        THEN Persons_Id
        ELSE ''
        END,
    DelegatedPerson_FirstName = CASE
        WHEN ServiceRoles_Role = 'Delegated Person'
        THEN Persons_FirstName
        ELSE ''
        END,
    DelegatedPerson_LastName = CASE
        WHEN ServiceRoles_Role = 'Delegated Person'
        THEN Persons_LastName
        ELSE ''
        END,
    DelegatedPerson_Email = CASE
        WHEN ServiceRoles_Role = 'Delegated Person'
        THEN Persons_Email
        ELSE ''
        END,
    DelegatedPerson_Telephone = CASE
        WHEN ServiceRoles_Role = 'Delegated Person'
        THEN Persons_Telephone
        ELSE ''
        END,
    DelegatedPerson_CreatedOn = CASE
        WHEN ServiceRoles_Role = 'Delegated Person'
        THEN Persons_Createdon
        ELSE ''
        END,
    DelegatedPerson_LastUpdatedOn = CASE
        WHEN ServiceRoles_Role = 'Delegated Person'
        THEN Persons_LastUpdatedon
        ELSE ''
        END,
    DelegatedPerson_IsDeleted = CASE
        WHEN ServiceRoles_Role = 'Delegated Person'
        THEN Persons_IsDeleted
        ELSE ''
        END,
    DelegatedPerson_JobTitle = CASE
        WHEN ServiceRoles_Role = 'Delegated Person'
        THEN PersonOrganisationConnections_JobTitle
        ELSE ''
        END
FROM cte_RejoinNations
),
cte_cs_nation AS
(
SELECT
	o.id Organisations_Id,
	ISNULL(NULLIF(cs.NationId, 0), o.NationId) NationId,
	NULLIF(oc.[FromOrganisationId], 0) [FromOrganisationId],
	cs.Name ComplianceSchemes_Name,
	cs.CreatedOn ComplianceSchemes_CreatedOn,
	cs.LastUpdatedOn ComplianceSchemes_LastUpdatedOn,
	cs.IsDeleted ComplianceSchemes_IsDeleted,
	cs.CompaniesHouseNumber ComplianceSchemes_CompaniesHouseNumber,
	cs.ID ComplianceSchemes_Id,
	ss.IsDeleted as SelectedSchemes_IsDeleted_new
FROM dbo.v_rpd_OrganisationsConnections_Active oc
LEFT JOIN dbo.v_rpd_Organisations_Active o ON o.id = toOrganisationId
LEFT JOIN dbo.v_rpd_SelectedSchemes_Active ss ON ss.OrganisationConnectionId = oc.id
LEFT JOIN dbo.v_rpd_ComplianceSchemes_Active cs ON cs.id = ss.ComplianceSchemeId
UNION
SELECT
	o.id Organisations_Id,
	ISNULL(NULLIF(cs.NationId, 0), o.NationId) NationId,
	0 FromOrganisationId,
	cs.Name ComplianceSchemes_Name,
	cs.CreatedOn ComplianceSchemes_CreatedOn,
	cs.LastUpdatedOn ComplianceSchemes_LastUpdatedOn,
	cs.IsDeleted ComplianceSchemes_IsDeleted,
	cs.CompaniesHouseNumber ComplianceSchemes_CompaniesHouseNumber,
	cs.ID ComplianceSchemes_Id,
	NULL as SelectedSchemes_IsDeleted_new
FROM dbo.v_rpd_Organisations_Active o
LEFT JOIN dbo.v_rpd_ComplianceSchemes_Active cs ON cs.CompaniesHouseNumber = o.CompaniesHouseNumber
),

cte_rpd_data_all AS
(
SELECT 
	d.Organisations_Id,
	d.FromOrganisation_TypeId,
	d.FromOrganisation_Type,
	d.FromOrganisation_CompaniesHouseNumber,
	d.FromOrganisation_Name,
	d.FromOrganisation_TradingName,
	d.FromOrganisation_ReferenceNumber,
	d.FromOrganisation_SubBuildingName,
	d.FromOrganisation_BuildingName,
	d.FromOrganisation_BuildingNumber,
	d.FromOrganisation_Street,
	d.FromOrganisation_Locality,
	d.FromOrganisation_DependentLocality,
	d.FromOrganisation_Town,
	d.FromOrganisation_County,
	d.FromOrganisation_Country,
	d.FromOrganisation_Postcode,
	d.FromOrganisation_ValidatedWithCompaniesHouse,
	d.FromOrganisation_IsComplianceScheme,
	d.FromOrganisation_NationId,
	d.Organisations_CreatedOn,
	d.FromOrganisation_IsDeleted,
	d.FromOrganisation_ProducerTypeId,
	d.FromOrganisation_TransferNationId,
	d.ToOrganisation_TypeId,
	d.ToOrganisation_Type,
	d.ToOrganisation_CompaniesHouseNumber,
	d.ToOrganisation_Name,
	d.ToOrganisation_TradingName,
	d.ToOrganisation_ReferenceNumber,
	d.ToOrganisation_SubBuildingName,
	d.ToOrganisation_BuildingName,
	d.ToOrganisation_BuildingNumber,
	d.ToOrganisation_Street,
	d.ToOrganisation_Locality,
	d.ToOrganisation_DependentLocality,
	d.ToOrganisation_Town,
	d.ToOrganisation_County,
	d.ToOrganisation_Country,
	d.ToOrganisation_Postcode,
	d.ToOrganisation_ValidatedWithCompaniesHouse,
	d.ToOrganisation_IsComplianceScheme,
	d.ToOrganisation_NationId,
	d.ToOrganisation_IsDeleted,
	d.ToOrganisation_ProducerTypeId,
	d.ToOrganisation_TransferNationId,
	d.OrganisationConnections_Id,
	d.OrganisationConnections_FromOrganisationId,
	d.OrganisationConnections_FromOrganisationRoleId,
	d.OrganisationConnections_ToOrganisationId,
	d.OrganisationConnections_ToOrganisationRoleId,
	d.OrganisationConnections_CreatedOn,
	d.OrganisationConnections_LastUpdatedOn,
	d.OrganisationConnections_IsDeleted,
	d.SelectedSchemes_Id,
	d.SelectedSchemes_OrganisationConnectionId,
	d.SelectedSchemes_ComplianceSchemeId,
	d.SelectedSchemes_CreatedOn,
	d.SelectedSchemes_LastUpdatedOn,
	--d.SelectedSchemes_IsDeleted,
	cst.SelectedSchemes_IsDeleted_new as SelectedSchemes_IsDeleted,
	ISNULL(cst.ComplianceSchemes_Id, csf.ComplianceSchemes_Id) ComplianceSchemes_Id,
	ISNULL(cst.ComplianceSchemes_Name, csf.ComplianceSchemes_Name) ComplianceSchemes_Name,
	ISNULL(cst.ComplianceSchemes_CreatedOn, csf.ComplianceSchemes_CreatedOn) ComplianceSchemes_CreatedOn,
	ISNULL(cst.ComplianceSchemes_LastUpdatedOn, csf.ComplianceSchemes_LastUpdatedOn) ComplianceSchemes_LastUpdatedOn,
	ISNULL(cst.ComplianceSchemes_IsDeleted, csf.ComplianceSchemes_IsDeleted) ComplianceSchemes_IsDeleted,
	ISNULL(cst.ComplianceSchemes_CompaniesHouseNumber, csf.ComplianceSchemes_CompaniesHouseNumber) ComplianceSchemes_CompaniesHouseNumber,
	d.InterOrganisationRoles_FromOrganisationRole,
	d.InterOrganisationRoles_ToOrganisationRole,
	d.PersonOrganisationConnections_Id,
	d.PersonOrganisationConnections_OrganisationId,
	d.PersonOrganisationConnections_JobTitle,
	d.PersonOrganisationConnections_ExternalId,
	d.PersonOrganisationConnections_CreatedOn,
	d.PersonOrganisationConnections_LastUpdatedOn,
	d.PersonOrganisationConnections_IsDeleted,
	d.OrganisationToPersonRoles_Role,
	d.PersonInOrganisationRoles_Role,
	d.Persons_Id,
	d.Persons_FirstName,
	d.Persons_LastName,
	d.Persons_Email,
	d.Persons_Telephone,
	d.Persons_CreatedOn,
	d.Persons_LastUpdatedOn,
	d.Persons_IsDeleted,
	d.Users_Email,
	d.Users_IsDeleted,
	d.Users_InviteToken,
	d.Users_InvitedBy,
	d.Enrolment_Id,
	d.Enrolment_ConnectionId,
	d.Enrolment_ServiceRoleId,
	d.Enrolment_ValidFrom,
	d.Enrolment_ValidTo,
	d.Enrolment_ExternalId,
	d.Enrolment_CreatedOn,
	d.Enrolment_LastUpdatedOn,
	d.Enrolment_IsDeleted,
	d.Enrolment_RegulatorCommentId,
	d.EnrolmentStatuses_EnrolmentStatus,
	d.ServiceRoles_Id,
	d.ServiceRoles_ServiceId,
	d.ServiceRoles_Key,
	d.ServiceRoles_Role,
	d.ServiceRoles_Description,
	d.Services_Key,
	d.Services_Service,
	d.Services_Description,
	d.DelegatedPersonEnrolment_RelationshipType,
	d.DelegatedPersonEnrolment_ConsultancyName,
	d.DelegatedPersonEnrolment_ComplianceSchemeName,
	d.DelegatedPersonEnrolment_OtherOrganisationNation,
	d.DelegatedPersonEnrolment_OtherRelationshipDescription,
	d.DelegatedPersonEnrolment_NominatorDeclaration,
	d.DelegatedPersonEnrolment_NominatorDeclarationTime,
	d.DelegatedPersonEnrolment_NomineeDeclaration,
	d.DelegatedPersonEnrolment_NomineeDeclarationTime,
	d.DelegatedPersonEnrolment_CreatedOn,
	d.DelegatedPersonEnrolment_LastUpdatedOn,
	d.DelegatedPersonEnrolment_IsDeleted,
	d.NominatedDelegatedPersonEnrolment_RelationshipType,
	d.NominatedDelegatedPersonEnrolment_ConsultancyName,
	d.NominatedDelegatedPersonEnrolment_ComplianceSchemeName,
	d.NominatedDelegatedPersonEnrolment_OtherOrganisationNation,
	d.NominatedDelegatedPersonEnrolment_OtherRelationshipDescription,
	d.NominatedDelegatedPersonEnrolment_NominatorDeclaration,
	d.NominatedDelegatedPersonEnrolment_NominatorDeclarationTime,
	d.NominatedDelegatedPersonEnrolment_NomineeDeclaration,
	d.NominatedDelegatedPersonEnrolment_NomineeDeclarationTime,
	d.NominatedDelegatedPersonEnrolment_CreatedOn,
	d.NominatedDelegatedPersonEnrolment_LastUpdatedOn,
	d.NominatedDelegatedPersonEnrolment_IsDeleted,
	case 
	  WHEN d.FromOrganisation_IsComplianceScheme = 1 THEN fn.name
	  WHEN d.ToOrganisation_IsComplianceScheme = 1 THEN d.FromOrganisation_NationName
	  ELSE NULL
	end FromOrganisation_NationName,
	case 
	  WHEN d.FromOrganisation_IsComplianceScheme = 1 THEN d.ToOrganisation_NationName
	  WHEN d.ToOrganisation_IsComplianceScheme = 1 THEN tn.name
	  ELSE NULL
	end ToOrganisation_NationName,
	d.Security_Id,
	case 
	  WHEN d.FromOrganisation_IsComplianceScheme = 1 THEN fn.name
	   WHEN d.ToOrganisation_IsComplianceScheme = 1 and d.SecurityQuery_OrganisationOrigin = 'FromOrganisation_NationName' THEN FromOrganisation_NationName
	  WHEN d.ToOrganisation_IsComplianceScheme = 1 THEN tn.name
	  ELSE NULL
	end SecurityQuery,
	d.SecurityQuery_OrganisationOrigin,
	d.ApprovedPerson_Id,
	d.ApprovedPerson_FirstName,
	d.ApprovedPerson_LastName,
	d.ApprovedPerson_Email,
	d.ApprovedPerson_Telephone,
	d.ApprovedPerson_CreatedOn,
	d.ApprovedPerson_LastUpdatedOn,
	d.ApprovedPerson_IsDeleted,
	d.ApprovedPerson_JobTitle,
	d.DelegatedPerson_Id,
	d.DelegatedPerson_FirstName,
	d.DelegatedPerson_LastName,
	d.DelegatedPerson_Email,
	d.DelegatedPerson_Telephone,
	d.DelegatedPerson_CreatedOn,
	d.DelegatedPerson_LastUpdatedOn,
	d.DelegatedPerson_IsDeleted,
	d.DelegatedPerson_JobTitle
FROM   cte_rpd_data d
LEFT JOIN cte_cs_nation cst
       ON --d.ToOrganisation_CompaniesHouseNumber = cst.CompaniesHouseNumber
	      d.ToOrganisations_Id = cst.Organisations_Id
		  AND cst.FromOrganisationId = ISNULL(d.Organisations_Id, 0)
          AND cst.NationId IS NOT NULL
          AND d.ToOrganisation_CompaniesHouseNumber IS NOT NULL
          AND cst.ComplianceSchemes_IsDeleted != 1
LEFT JOIN rpd.nations tn
       ON tn.id = cst.NationId
          AND d.ToOrganisation_IsComplianceScheme = 1
LEFT JOIN cte_cs_nation csf
       ON --d.FromOrganisation_CompaniesHouseNumber = csf.CompaniesHouseNumber
	      d.Organisations_Id = csf.Organisations_Id
          AND csf.NationId IS NOT NULL
          AND csf.ComplianceSchemes_IsDeleted != 1
LEFT JOIN rpd.nations fn
       ON fn.id = csf.NationId
          AND d.FromOrganisation_IsComplianceScheme = 1
WHERE  d.ToOrganisation_IsComplianceScheme = 1
          OR d.FromOrganisation_IsComplianceScheme = 1
UNION

--Add in rest of data excluding not set for variations above
SELECT
	d.Organisations_Id,
	d.FromOrganisation_TypeId,
	d.FromOrganisation_Type,
	d.FromOrganisation_CompaniesHouseNumber,
	d.FromOrganisation_Name,
	d.FromOrganisation_TradingName,
	d.FromOrganisation_ReferenceNumber,
	d.FromOrganisation_SubBuildingName,
	d.FromOrganisation_BuildingName,
	d.FromOrganisation_BuildingNumber,
	d.FromOrganisation_Street,
	d.FromOrganisation_Locality,
	d.FromOrganisation_DependentLocality,
	d.FromOrganisation_Town,
	d.FromOrganisation_County,
	d.FromOrganisation_Country,
	d.FromOrganisation_Postcode,
	d.FromOrganisation_ValidatedWithCompaniesHouse,
	d.FromOrganisation_IsComplianceScheme,
	d.FromOrganisation_NationId,
	d.Organisations_CreatedOn,
	d.FromOrganisation_IsDeleted,
	d.FromOrganisation_ProducerTypeId,
	d.FromOrganisation_TransferNationId,
	d.ToOrganisation_TypeId,
	d.ToOrganisation_Type,
	d.ToOrganisation_CompaniesHouseNumber,
	d.ToOrganisation_Name,
	d.ToOrganisation_TradingName,
	d.ToOrganisation_ReferenceNumber,
	d.ToOrganisation_SubBuildingName,
	d.ToOrganisation_BuildingName,
	d.ToOrganisation_BuildingNumber,
	d.ToOrganisation_Street,
	d.ToOrganisation_Locality,
	d.ToOrganisation_DependentLocality,
	d.ToOrganisation_Town,
	d.ToOrganisation_County,
	d.ToOrganisation_Country,
	d.ToOrganisation_Postcode,
	d.ToOrganisation_ValidatedWithCompaniesHouse,
	d.ToOrganisation_IsComplianceScheme,
	d.ToOrganisation_NationId,
	d.ToOrganisation_IsDeleted,
	d.ToOrganisation_ProducerTypeId,
	d.ToOrganisation_TransferNationId,
	d.OrganisationConnections_Id,
	d.OrganisationConnections_FromOrganisationId,
	d.OrganisationConnections_FromOrganisationRoleId,
	d.OrganisationConnections_ToOrganisationId,
	d.OrganisationConnections_ToOrganisationRoleId,
	d.OrganisationConnections_CreatedOn,
	d.OrganisationConnections_LastUpdatedOn,
	d.OrganisationConnections_IsDeleted,
	d.SelectedSchemes_Id,
	d.SelectedSchemes_OrganisationConnectionId,
	d.SelectedSchemes_ComplianceSchemeId,
	d.SelectedSchemes_CreatedOn,
	d.SelectedSchemes_LastUpdatedOn,
	d.SelectedSchemes_IsDeleted,
	d.ComplianceSchemes_Id,
	d.ComplianceSchemes_Name,
	d.ComplianceSchemes_CreatedOn,
	d.ComplianceSchemes_LastUpdatedOn,
	d.ComplianceSchemes_IsDeleted,
	d.ComplianceSchemes_CompaniesHouseNumber,
	d.InterOrganisationRoles_FromOrganisationRole,
	d.InterOrganisationRoles_ToOrganisationRole,
	d.PersonOrganisationConnections_Id,
	d.PersonOrganisationConnections_OrganisationId,
	d.PersonOrganisationConnections_JobTitle,
	d.PersonOrganisationConnections_ExternalId,
	d.PersonOrganisationConnections_CreatedOn,
	d.PersonOrganisationConnections_LastUpdatedOn,
	d.PersonOrganisationConnections_IsDeleted,
	d.OrganisationToPersonRoles_Role,
	d.PersonInOrganisationRoles_Role,
	d.Persons_Id,
	d.Persons_FirstName,
	d.Persons_LastName,
	d.Persons_Email,
	d.Persons_Telephone,
	d.Persons_CreatedOn,
	d.Persons_LastUpdatedOn,
	d.Persons_IsDeleted,
	d.Users_Email,
	d.Users_IsDeleted,
	d.Users_InviteToken,
	d.Users_InvitedBy,
	d.Enrolment_Id,
	d.Enrolment_ConnectionId,
	d.Enrolment_ServiceRoleId,
	d.Enrolment_ValidFrom,
	d.Enrolment_ValidTo,
	d.Enrolment_ExternalId,
	d.Enrolment_CreatedOn,
	d.Enrolment_LastUpdatedOn,
	d.Enrolment_IsDeleted,
	d.Enrolment_RegulatorCommentId,
	d.EnrolmentStatuses_EnrolmentStatus,
	d.ServiceRoles_Id,
	d.ServiceRoles_ServiceId,
	d.ServiceRoles_Key,
	d.ServiceRoles_Role,
	d.ServiceRoles_Description,
	d.Services_Key,
	d.Services_Service,
	d.Services_Description,
	d.DelegatedPersonEnrolment_RelationshipType,
	d.DelegatedPersonEnrolment_ConsultancyName,
	d.DelegatedPersonEnrolment_ComplianceSchemeName,
	d.DelegatedPersonEnrolment_OtherOrganisationNation,
	d.DelegatedPersonEnrolment_OtherRelationshipDescription,
	d.DelegatedPersonEnrolment_NominatorDeclaration,
	d.DelegatedPersonEnrolment_NominatorDeclarationTime,
	d.DelegatedPersonEnrolment_NomineeDeclaration,
	d.DelegatedPersonEnrolment_NomineeDeclarationTime,
	d.DelegatedPersonEnrolment_CreatedOn,
	d.DelegatedPersonEnrolment_LastUpdatedOn,
	d.DelegatedPersonEnrolment_IsDeleted,
	d.NominatedDelegatedPersonEnrolment_RelationshipType,
	d.NominatedDelegatedPersonEnrolment_ConsultancyName,
	d.NominatedDelegatedPersonEnrolment_ComplianceSchemeName,
	d.NominatedDelegatedPersonEnrolment_OtherOrganisationNation,
	d.NominatedDelegatedPersonEnrolment_OtherRelationshipDescription,
	d.NominatedDelegatedPersonEnrolment_NominatorDeclaration,
	d.NominatedDelegatedPersonEnrolment_NominatorDeclarationTime,
	d.NominatedDelegatedPersonEnrolment_NomineeDeclaration,
	d.NominatedDelegatedPersonEnrolment_NomineeDeclarationTime,
	d.NominatedDelegatedPersonEnrolment_CreatedOn,
	d.NominatedDelegatedPersonEnrolment_LastUpdatedOn,
	d.NominatedDelegatedPersonEnrolment_IsDeleted,
	d.FromOrganisation_NationName,
	d.ToOrganisation_NationName,
	d.Security_Id,
	d.SecurityQuery,
	d.SecurityQuery_OrganisationOrigin,
	d.ApprovedPerson_Id,
	d.ApprovedPerson_FirstName,
	d.ApprovedPerson_LastName,
	d.ApprovedPerson_Email,
	d.ApprovedPerson_Telephone,
	d.ApprovedPerson_CreatedOn,
	d.ApprovedPerson_LastUpdatedOn,
	d.ApprovedPerson_IsDeleted,
	d.ApprovedPerson_JobTitle,
	d.DelegatedPerson_Id,
	d.DelegatedPerson_FirstName,
	d.DelegatedPerson_LastName,
	d.DelegatedPerson_Email,
	d.DelegatedPerson_Telephone,
	d.DelegatedPerson_CreatedOn,
	d.DelegatedPerson_LastUpdatedOn,
	d.DelegatedPerson_IsDeleted,
	d.DelegatedPerson_JobTitle
FROM   cte_rpd_data d
WHERE  ISNULL(ToOrganisation_IsComplianceScheme, 0) = 0
       AND ISNULL(FromOrganisation_IsComplianceScheme, 0) = 0
)

SELECT DISTINCT * 
FROM cte_rpd_data_all;