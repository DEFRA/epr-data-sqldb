CREATE VIEW [dbo].[v_OrganisationsAndRoles] AS with cte_Enrolments as (
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

    FROM [rpd].[Enrolments] EnrolmentsTable
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

    from rpd.PersonOrganisationConnections POCTable
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
        from rpd.Persons PersonsTable
        left join rpd.Users UsersTable
        on PersonsTable.UserId = UsersTable.Id
    ) PersonsAndUsers
    on POCTable.PersonId = PersonsAndUsers.Persons_Id
),

cte_PersonOrgConnectionsAndEnrolments as (
    select PersonOrgConnections.*
    ,Enrolments.*
    from cte_PersonOrganisationConnections PersonOrgConnections
    left join cte_Enrolments Enrolments
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

    from rpd.SelectedSchemes SelectedSchemesTable

    left join rpd.ComplianceSchemes ComplianceSchemesTable

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
    FROM [rpd].[OrganisationsConnections]
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

    FROM [rpd].[Organisations] OrganisationsTable

    left join rpd.OrganisationTypes OrganisationTypesTable
    on OrganisationsTable.OrganisationTypeId = OrganisationTypesTable.Id

    -- left join rpd.Nations NationsTable
    -- on OrganisationsTable.NationId = NationsTable.Id
),



-- cte_OrganisationsAndPersonsAndRoles as (
--     select a.*
--     ,b.*
--     from cte_Organisations_PreJoin a

--     left join cte_PersonOrgConnectionsAndEnrolments b
--     on a.Organisations_Id = b.PersonOrganisationConnections_OrganisationId

--     left join cte_OrganisationConnectionsAndComplianceSchemesAndRoles c
--     on a.Organisations_Id = c.OrganisationConnections_FromOrganisationId

--     left join cte_OrganisationConnectionsAndComplianceSchemesAndRoles d
--     on a.Organisations_Id = d.OrganisationConnections_ToOrganisationId
-- )

cte_OrganisationsAndRoles as (
    select a.OrganisationConnections_Id
    ,a.OrganisationConnections_FromOrganisationId
    ,a.OrganisationConnections_FromOrganisationRoleId
    ,a.OrganisationConnections_ToOrganisationId
    ,a.OrganisationConnections_ToOrganisationRoleId
    ,a.OrganisationConnections_CreatedOn
    ,a.OrganisationConnections_LastUpdatedOn
    ,a.OrganisationConnections_IsDeleted
    ,a.SelectedSchemes_Id
    ,a.SelectedSchemes_OrganisationConnectionId
    ,a.SelectedSchemes_ComplianceSchemeId
    ,a.SelectedSchemes_CreatedOn
    ,a.SelectedSchemes_LastUpdatedOn
    ,a.SelectedSchemes_IsDeleted
    ,a.ComplianceSchemes_Id
    ,a.ComplianceSchemes_Name
    ,a.ComplianceSchemes_CreatedOn
    ,a.ComplianceSchemes_LastUpdatedOn
    ,a.ComplianceSchemes_IsDeleted
    ,a.ComplianceSchemes_CompaniesHouseNumber
    ,a.InterOrganisationRoles_FromOrganisationRole
    ,a.InterOrganisationRoles_ToOrganisationRole

    ,b.Organisations_Id
    ,b.Organisations_OrganisationTypeId as FromOrganisation_TypeId
    ,b.OrganisationTypes_OrganisationType as FromOrganisation_Type -- xxxhere
    ,b.Organisations_CompaniesHouseNumber as FromOrganisation_CompaniesHouseNumber
    ,b.Organisations_Name as FromOrganisation_Name
    ,b.Organisations_TradingName as FromOrganisation_TradingName
    ,b.Organisations_ReferenceNumber as FromOrganisation_ReferenceNumber
    ,b.Organisations_SubBuildingName as FromOrganisation_SubBuildingName
    ,b.Organisations_BuildingName as FromOrganisation_BuildingName
    ,b.Organisations_BuildingNumber as FromOrganisation_BuildingNumber
    ,b.Organisations_Street as FromOrganisation_Street
    ,b.Organisations_Locality as FromOrganisation_Locality
    ,b.Organisations_DependentLocality as FromOrganisation_DependentLocality
    ,b.Organisations_Town as FromOrganisation_Town
    ,b.Organisations_County as FromOrganisation_County
    ,b.Organisations_Country as FromOrganisation_Country
    ,b.Organisations_Postcode as FromOrganisation_Postcode
    ,b.Organisations_ValidatedWithCompaniesHouse as FromOrganisation_ValidatedWithCompaniesHouse
    ,b.Organisations_IsComplianceScheme as FromOrganisation_IsComplianceScheme
    ,b.Organisations_NationId as FromOrganisation_NationId
    ,b.Organisations_CreatedOn
    -- ,b.Organisations_LastUpdated
    ,b.Organisations_IsDeleted as FromOrganisation_IsDeleted
    ,b.Organisations_ProducerTypeId as FromOrganisation_ProducerTypeId
    ,b.Organisations_TransferNationId as FromOrganisation_TransferNationId

    ,c.Organisations_OrganisationTypeId as ToOrganisation_TypeId
    ,c.OrganisationTypes_OrganisationType as ToOrganisation_Type -- xxxhere
    ,c.Organisations_CompaniesHouseNumber as ToOrganisation_CompaniesHouseNumber
    ,c.Organisations_Name as ToOrganisation_Name
    ,c.Organisations_TradingName as ToOrganisation_TradingName
    ,c.Organisations_ReferenceNumber as ToOrganisation_ReferenceNumber
    ,c.Organisations_SubBuildingName as ToOrganisation_SubBuildingName
    ,c.Organisations_BuildingName as ToOrganisation_BuildingName
    ,c.Organisations_BuildingNumber as ToOrganisation_BuildingNumber
    ,c.Organisations_Street as ToOrganisation_Street
    ,c.Organisations_Locality as ToOrganisation_Locality
    ,c.Organisations_DependentLocality as ToOrganisation_DependentLocality
    ,c.Organisations_Town as ToOrganisation_Town
    ,c.Organisations_County as ToOrganisation_County
    ,c.Organisations_Country as ToOrganisation_Country
    ,c.Organisations_Postcode as ToOrganisation_Postcode
    ,c.Organisations_ValidatedWithCompaniesHouse as ToOrganisation_ValidatedWithCompaniesHouse
    ,c.Organisations_IsComplianceScheme as ToOrganisation_IsComplianceScheme
    ,c.Organisations_NationId as ToOrganisation_NationId
    ,c.Organisations_IsDeleted as ToOrganisation_IsDeleted
    ,c.Organisations_ProducerTypeId as ToOrganisation_ProducerTypeId
    ,c.Organisations_TransferNationId as ToOrganisation_TransferNationId

    from cte_OrganisationConnectionsAndComplianceSchemesAndRoles a

    left join cte_Organisations_PreJoin b
    on a.OrganisationConnections_FromOrganisationId = b.Organisations_Id

    left join cte_Organisations_PreJoin c
    on a.OrganisationConnections_ToOrganisationId = c.Organisations_Id
)

select * from cte_OrganisationsAndRoles;