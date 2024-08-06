CREATE VIEW [dbo].[v_Organisations_PreJoin] AS with cte_Enrolments as (
    -- Enrolments Table - 230 records
    SELECT EnrolmentsTable.Id as Enrolment_Id
    ,EnrolmentsTable.[ConnectionId] as Enrolment_ConnectionId
    ,EnrolmentsTable.[ServiceRoleId] as Enrolment_ServiceRoleId
    ,EnrolmentsTable.[ValidFrom] as Enrolment_ValidFrom
    ,EnrolmentsTable.[ValidTo] as Enrolment_ValidTo
    ,EnrolmentsTable.[ExternalId] as Enrolment_ExternalId
    ,EnrolmentsTable.[CreatedOn] as Enrolment_CreatedOn
    ,EnrolmentsTable.[LastUpdatedOn] as Enrolment_LastUpdatedOn
    ,EnrolmentsTable.[IsDeleted] as Enrolment_IsDeleted
    -- ,EnrolmentsTable.[RegulatorCommentId] as Enrolment_RegulatorCommentId
    ,EnrolmentStatusesTable.Name as EnrolmentStatuses_EnrolmentStatus
    ,ServicesAndRoles.ServiceRoles_Id
    ,ServicesAndRoles.ServiceRoles_ServiceId
    ,ServicesAndRoles.ServiceRoles_Key
    ,ServicesAndRoles.ServiceRoles_Role
    ,ServicesAndRoles.ServiceRoles_Description
    ,ServicesAndRoles.Services_Key
    ,ServicesAndRoles.Services_Service
    ,ServicesAndRoles.Services_Description

    FROM dbo.v_rpd_Enrolments_Active EnrolmentsTable
    left join rpd.EnrolmentStatuses EnrolmentStatusesTable
    on EnrolmentsTable.EnrolmentStatusId = EnrolmentStatusesTable.Id

    left join (
        -- ServiceRoles Table - 3 records
        select ServiceRolesTable.Id as ServiceRoles_Id
        ,ServiceRolesTable.ServiceId as ServiceRoles_ServiceId
        ,ServiceRolesTable.[Key] as ServiceRoles_Key
        ,ServiceRolesTable.Name as ServiceRoles_Role
        ,ServiceRolesTable.Description as ServiceRoles_Description
        ,ServicesTable.[Key] as Services_Key
        ,ServicesTable.Name as Services_Service
        ,ServicesTable.Description as Services_Description
        from rpd.ServiceRoles ServiceRolesTable
        join rpd.Services ServicesTable
        on ServiceRolesTable.ServiceId = ServicesTable.Id
    ) ServicesAndRoles
    on EnrolmentsTable.ServiceRoleId = ServicesAndRoles.ServiceRoles_Id
),

cte_Enrolments_And_DP as (
    SELECT a.[Enrolment_Id]
    ,a.[Enrolment_ConnectionId]
    ,a.[Enrolment_ServiceRoleId]
    ,a.[Enrolment_ValidFrom]
    ,a.[Enrolment_ValidTo]
    ,a.[Enrolment_ExternalId]
    ,a.[Enrolment_CreatedOn]
    ,a.[Enrolment_LastUpdatedOn]
    ,a.[Enrolment_IsDeleted]
    -- ,a.[Enrolment_RegulatorCommentId]
    ,a.[EnrolmentStatuses_EnrolmentStatus]
    ,a.[ServiceRoles_Id]
    ,a.[ServiceRoles_ServiceId]
    ,a.[ServiceRoles_Key]
    ,a.[ServiceRoles_Role]
    ,a.[ServiceRoles_Description]
    ,a.[Services_Key]
    ,a.[Services_Service]
    ,a.[Services_Description]

    ,b.[RelationshipType] as DelegatedPersonEnrolment_RelationshipType
    ,b.[ConsultancyName] as DelegatedPersonEnrolment_ConsultancyName
    ,b.[ComplianceSchemeName] as DelegatedPersonEnrolment_ComplianceSchemeName
    ,b.[OtherOrganisationName] as DelegatedPersonEnrolment_OtherOrganisationNation
    ,b.[OtherRelationshipDescription] as DelegatedPersonEnrolment_OtherRelationshipDescription
    ,b.[NominatorDeclaration] as DelegatedPersonEnrolment_NominatorDeclaration
    ,b.[NominatorDeclarationTime] as DelegatedPersonEnrolment_NominatorDeclarationTime
    ,b.[NomineeDeclaration] as DelegatedPersonEnrolment_NomineeDeclaration
    ,b.[NomineeDeclarationTime] as DelegatedPersonEnrolment_NomineeDeclarationTime
    ,b.[CreatedOn] as DelegatedPersonEnrolment_CreatedOn
    ,b.[LastUpdatedOn] as DelegatedPersonEnrolment_LastUpdatedOn
    ,b.[IsDeleted] as DelegatedPersonEnrolment_IsDeleted

    ,c.[RelationshipType] as NominatedDelegatedPersonEnrolment_RelationshipType
    ,c.[ConsultancyName] as NominatedDelegatedPersonEnrolment_ConsultancyName
    ,c.[ComplianceSchemeName] as NominatedDelegatedPersonEnrolment_ComplianceSchemeName
    ,c.[OtherOrganisationName] as NominatedDelegatedPersonEnrolment_OtherOrganisationNation
    ,c.[OtherRelationshipDescription] as NominatedDelegatedPersonEnrolment_OtherRelationshipDescription
    ,c.[NominatorDeclaration] as NominatedDelegatedPersonEnrolment_NominatorDeclaration
    ,c.[NominatorDeclarationTime] as NominatedDelegatedPersonEnrolment_NominatorDeclarationTime
    ,c.[NomineeDeclaration] as NominatedDelegatedPersonEnrolment_NomineeDeclaration
    ,c.[NomineeDeclarationTime] as NominatedDelegatedPersonEnrolment_NomineeDeclarationTime
    ,c.[CreatedOn] as NominatedDelegatedPersonEnrolment_CreatedOn
    ,c.[LastUpdatedOn] as NominatedDelegatedPersonEnrolment_LastUpdatedOn
    ,c.[IsDeleted] as NominatedDelegatedPersonEnrolment_IsDeleted

    FROM [dbo].[v_Enrolments] a

    left join dbo.v_rpd_DelegatedPersonEnrolments_Active b

    on a.Enrolment_Id = b.EnrolmentId

    left join dbo.v_rpd_DelegatedPersonEnrolments_Active c

    on a.Enrolment_Id = c.NominatorEnrolmentId
),

cte_PersonOrganisationConnections as (
    -- PersonOrganisationConnectionsTable - 235 records
    select POCTable.Id as PersonOrganisationConnections_Id
    ,POCTable.OrganisationId as PersonOrganisationConnections_OrganisationId
    ,POCTable.JobTitle as PersonOrganisationConnections_JobTitle
    ,POCTable.ExternalId as PersonOrganisationConnections_ExternalId
    ,POCTable.CreatedOn as PersonOrganisationConnections_CreatedOn
    ,POCTable.LastUpdatedOn as PersonOrganisationConnections_LastUpdatedOn
    ,POCTable.IsDeleted as PersonOrganisationConnections_IsDeleted
    ,OrgToPersonRolesTable.Name as OrganisationToPersonRoles_Role
    ,PIOrgRolesTable.Name as PersonInOrganisationRoles_Role
    ,PersonsAndUsers.Persons_Id
    ,PersonsAndUsers.Persons_FirstName
    ,PersonsAndUsers.Persons_LastName
    ,PersonsAndUsers.Persons_Email
    ,PersonsAndUsers.Persons_Telephone
    ,PersonsAndUsers.Persons_CreatedOn
    ,PersonsAndUsers.Persons_LastUpdatedOn
    ,PersonsAndUsers.Persons_IsDeleted
    -- ,PersonsAndUsers.Persons_RegulatorCommentId
    ,PersonsAndUsers.Users_Email
    ,PersonsAndUsers.Users_IsDeleted
    ,PersonsAndUsers.Users_InviteToken
    ,PersonsAndUsers.Users_InvitedBy

    from dbo.v_rpd_PersonOrganisationConnections_Active POCTable
    left join rpd.OrganisationToPersonRoles OrgToPersonRolesTable
    on POCTable.OrganisationRoleId = OrgToPersonRolesTable.Id

    left join rpd.PersonInOrganisationRoles PIOrgRolesTable
    on POCTable.PersonRoleId = PIOrgRolesTable.Id

    left join (
        select PersonsTable.Id as Persons_Id
        ,PersonsTable.FirstName as Persons_FirstName
        ,PersonsTable.LastName as Persons_LastName
        ,PersonsTable.Email as Persons_Email
        ,PersonsTable.Telephone as Persons_Telephone
        ,PersonsTable.CreatedOn as Persons_CreatedOn
        ,PersonsTable.LastUpdatedOn as Persons_LastUpdatedOn
        ,PersonsTable.IsDeleted as Persons_IsDeleted
        -- ,PersonsTable.RegulatorCommentId as Persons_RegulatorCommentId
        ,UsersTable.Email as Users_Email
        ,UsersTable.IsDeleted as Users_IsDeleted
        ,UsersTable.InviteToken as Users_InviteToken
        ,UsersTable.InvitedBy as Users_InvitedBy
        from dbo.v_rpd_Persons_Active PersonsTable
        left join dbo.v_rpd_Users_Active UsersTable
        on PersonsTable.UserId = UsersTable.Id
    ) PersonsAndUsers
    on POCTable.PersonId = PersonsAndUsers.Persons_Id
),

cte_PersonOrgConnectionsAndEnrolments as (
    select PersonOrgConnections.*
    ,Enrolments.*
    from cte_PersonOrganisationConnections PersonOrgConnections
    left join cte_Enrolments_And_DP Enrolments
    on PersonOrgConnections.PersonOrganisationConnections_Id = Enrolments.Enrolment_ConnectionId
), -- 238 records

-- LEFT SIDE OF MAP END

-- RIGHT SIDE OF MAP START
-- From and To columns are 1:1
-- Need to join up roles, then two joins on to main data on the main id 
-- No need for union join

cte_ComplianceSchemes as (
    select SelectedSchemesTable.Id as SelectedSchemes_Id
    ,SelectedSchemesTable.OrganisationConnectionId as SelectedSchemes_OrganisationConnectionId
    ,SelectedSchemesTable.ComplianceSchemeId as SelectedSchemes_ComplianceSchemeId
    ,SelectedSchemesTable.CreatedOn as SelectedSchemes_CreatedOn
    ,SelectedSchemesTable.LastUpdatedOn as SelectedSchemes_LastUpdatedOn
    ,SelectedSchemesTable.IsDeleted as SelectedSchemes_IsDeleted

    ,ComplianceSchemesTable.Id as ComplianceSchemes_Id
    ,ComplianceSchemesTable.Name as ComplianceSchemes_Name
    ,ComplianceSchemesTable.CreatedOn as ComplianceSchemes_CreatedOn
    ,ComplianceSchemesTable.LastUpdatedOn as ComplianceSchemes_LastUpdatedOn
    ,ComplianceSchemesTable.IsDeleted as ComplianceSchemes_IsDeleted
    ,ComplianceSchemesTable.CompaniesHouseNumber as ComplianceSchemes_CompaniesHouseNumber

    from dbo.v_rpd_SelectedSchemes_Active SelectedSchemesTable

    left join dbo.v_rpd_ComplianceSchemes_Active ComplianceSchemesTable

    on SelectedSchemesTable.ComplianceSchemeId = ComplianceSchemesTable.Id
),

cte_OrganisationConnections as (
    SELECT [Id] as OrganisationConnections_Id
    ,[FromOrganisationId] as OrganisationConnections_FromOrganisationId
    ,[FromOrganisationRoleId] as OrganisationConnections_FromOrganisationRoleId
    ,[ToOrganisationId] as OrganisationConnections_ToOrganisationId
    ,[ToOrganisationRoleId] as OrganisationConnections_ToOrganisationRoleId
    ,[CreatedOn] as OrganisationConnections_CreatedOn
    ,[LastUpdatedOn] as OrganisationConnections_LastUpdatedOn
    ,[IsDeleted] as OrganisationConnections_IsDeleted
    FROM dbo.v_rpd_OrganisationsConnections_Active
),

cte_OrganisationConnectionsAndComplianceSchemes as (
    select a.*
    ,b.*
    from cte_OrganisationConnections a
    left join cte_ComplianceSchemes b
    on a.OrganisationConnections_Id = b.SelectedSchemes_OrganisationConnectionId
),

-- cte_FromOrganisationConnectionsAndComplianceSchemesAndRoles as (
--     select a.OrganisationConnections_Id
--     ,a.OrganisationConnections_FromOrganisationId
--     ,a.OrganisationConnections_FromOrganisationRoleId
--     ,a.OrganisationConnections_ToOrganisationId
--     ,a.OrganisationConnections_ToOrganisationRoleId
--     ,a.OrganisationConnections_CreatedOn
--     ,a.OrganisationConnections_LastUpdatedOn
--     ,a.OrganisationConnections_IsDeleted
--     ,a.SelectedSchemes_Id
--     ,a.SelectedSchemes_OrganisationConnectionId
--     ,a.SelectedSchemes_ComplianceSchemeId
--     ,a.SelectedSchemes_CreatedOn
--     ,a.SelectedSchemes_LastUpdatedOn
--     ,a.SelectedSchemes_IsDeleted
--     ,a.ComplianceSchemes_Id
--     ,a.ComplianceSchemes_Name
--     ,a.ComplianceSchemes_CreatedOn
--     ,a.ComplianceSchemes_LastUpdatedOn
--     ,a.ComplianceSchemes_IsDeleted
--     ,a.ComplianceSchemes_CompaniesHouseNumber
--     ,b.Name as InterOrganisationRoles_Role

--     from cte_OrganisationConnectionsAndComplianceSchemes a
    
--     join rpd.InterOrganisationRoles b
--     on a.OrganisationConnections_FromOrganisationRoleId = b.Id
-- ),

-- cte_ToOrganisationConnectionsAndComplianceSchemesAndRoles as (
--     select a.*
--     ,b.Name as InterOrganisationRoles_Role

--     from cte_OrganisationConnectionsAndComplianceSchemes a
    
--     join rpd.InterOrganisationRoles b
--     on a.OrganisationConnections_ToOrganisationRoleId = b.Id
-- ),

cte_OrganisationConnectionsAndComplianceSchemesAndRoles as (
    select a.*
    ,b.Name as InterOrganisationRoles_FromOrganisationRole
    ,c.Name as InterOrganisationRoles_ToOrganisationRole

    from cte_OrganisationConnectionsAndComplianceSchemes a
    
    left join rpd.InterOrganisationRoles b
    on a.OrganisationConnections_FromOrganisationRoleId = b.Id

    left join rpd.InterOrganisationRoles c
    on a.OrganisationConnections_ToOrganisationRoleId = c.Id
),

-- select * from cte_ToOrganisationConnectionsAndComplianceSchemesAndRoles

-- cte_OrganisationConnectionsAndComplianceSchemesAndRoles as (
--     select * from cte_FromOrganisationConnectionsAndComplianceSchemesAndRoles
--     union
--     select * from cte_ToOrganisationConnectionsAndComplianceSchemesAndRoles
-- ),

-- RIGHT SIDE OF MAP END 

-- CENTRE OF MAP START 

cte_Organisations_PreJoin as (
    -- Organisations Table - 173 rows

    SELECT OrganisationsTable.[Id] as Organisations_Id
    ,OrganisationsTable.[OrganisationTypeId] as Organisations_OrganisationTypeId
    ,OrganisationsTable.[CompaniesHouseNumber] as Organisations_CompaniesHouseNumber
    ,OrganisationsTable.[Name] as Organisations_Name
    ,OrganisationsTable.[TradingName] as Organisations_TradingName
    ,OrganisationsTable.[ReferenceNumber] as Organisations_ReferenceNumber
    ,OrganisationsTable.[SubBuildingName] as Organisations_SubBuildingName
    ,OrganisationsTable.[BuildingName] as Organisations_BuildingName
    ,OrganisationsTable.[BuildingNumber] as Organisations_BuildingNumber
    ,OrganisationsTable.[Street] as Organisations_Street
    ,OrganisationsTable.[Locality] Organisations_Locality
    ,OrganisationsTable.[DependentLocality] as Organisations_DependentLocality
    ,OrganisationsTable.[Town] as Organisations_Town
    ,OrganisationsTable.[County] Organisations_County
    ,OrganisationsTable.[Country] as Organisations_Country
    ,OrganisationsTable.[Postcode] as Organisations_Postcode
    ,OrganisationsTable.[ValidatedWithCompaniesHouse] as Organisations_ValidatedWithCompaniesHouse
    ,OrganisationsTable.[IsComplianceScheme] as Organisations_IsComplianceScheme
    ,OrganisationsTable.[NationId] as Organisations_NationId
    ,OrganisationsTable.[CreatedOn] as Organisations_CreatedOn
    ,OrganisationsTable.[LastUpdatedOn] as Organisations_LastUpdatedOn
    ,OrganisationsTable.[IsDeleted] as Organisations_IsDeleted
    ,OrganisationsTable.[ProducerTypeId] as Organisations_ProducerTypeId
    ,OrganisationsTable.[TransferNationId] as Organisations_TransferNationId

    ,OrganisationTypesTable.Name as OrganisationTypes_OrganisationType

    -- ,NationsTable.Name as Nations_Nation

    -- Query for security, to be updated when Compliance Scheme Nation is added
    -- ,NationsTable.Name as SecurityQuery

    FROM dbo.v_rpd_Organisations_Active OrganisationsTable

    left join rpd.OrganisationTypes OrganisationTypesTable
    on OrganisationsTable.OrganisationTypeId = OrganisationTypesTable.Id

    -- left join rpd.Nations NationsTable
    -- on OrganisationsTable.NationId = NationsTable.Id
)--,

select * from cte_Organisations_PreJoin;