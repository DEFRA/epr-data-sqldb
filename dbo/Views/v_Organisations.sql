CREATE VIEW [dbo].[v_Organisations] AS with CTE_InterOrganisationRoles as (
    select Id as InterOrganisationRolesId
    ,Name as OrganisationRole
    from rpd.InterOrganisationRoles
),

CTE_OrganisationsConnections as (
    SELECT [Id] as OrganisationConnectionId
    ,[FromOrganisationId]
    ,[FromOrganisationRoleId]
    ,[ToOrganisationId]
    ,[ToOrganisationRoleId]
    ,[ExternalId]
    ,[CreatedOn]
    ,[LastUpdatedOn]
    ,[IsDeleted]
    ,[load_ts]
    FROM [dbo].[v_rpd_OrganisationsConnections_Active]
),

CTE_FromOrganisationRoles as (
    select a.OrganisationConnectionId
    ,a.FromOrganisationId
    ,b.OrganisationRole as FromOrganisationRole
    from CTE_OrganisationsConnections a
    join CTE_InterOrganisationRoles b
    on a.FromOrganisationRoleId = b.InterOrganisationRolesId
),

CTE_ToOrganisationRoles as (
    select a.OrganisationConnectionId
    ,a.ToOrganisationId
    ,b.OrganisationRole as ToOrganisationRole
    from CTE_OrganisationsConnections a
    join CTE_InterOrganisationRoles b
    on a.ToOrganisationRoleId = b.InterOrganisationRolesId
),

CTE_SelectedSchemes as (
    select OrganisationConnectionId
    ,ComplianceSchemeId
    from [dbo].[v_rpd_SelectedSchemes_Active]
),

CTE_ComplianceSchemes as (
    select Id as ComplianceSchemeId
    ,Name as ComplianceSchemeName
    ,CompaniesHouseNumber as ComplianceSchemeCompaniesHouseNumber
    from [dbo].[v_rpd_ComplianceSchemes_Active]
),

CTE_SelectedSchemes_ComplianceSchemes as (
    select a.OrganisationConnectionId
    ,b.ComplianceSchemeName
    ,b.ComplianceSchemeCompaniesHouseNumber
    from CTE_SelectedSchemes a
    join CTE_ComplianceSchemes b
    on a.ComplianceSchemeId = b.ComplianceSchemeId
),

CTE_FromOrganisationRoles_CS as (
    select a.*
    ,b.ComplianceSchemeName
    ,b.ComplianceSchemeCompaniesHouseNumber
    from CTE_FromOrganisationRoles a
    join CTE_SelectedSchemes_ComplianceSchemes b
    on a.OrganisationConnectionId = b.OrganisationConnectionId
),

CTE_ToOrganisationRoles_CS as (
    select a.*
    ,b.ComplianceSchemeName
    ,b.ComplianceSchemeCompaniesHouseNumber
    from CTE_ToOrganisationRoles a
    join CTE_SelectedSchemes_ComplianceSchemes b
    on a.OrganisationConnectionId = b.OrganisationConnectionId
),

CTE_Main_Organisations as (
    SELECT [Id] as OrganisationId
    ,[OrganisationTypeId]
    ,[CompaniesHouseNumber]
    ,[Name]
    ,[TradingName]
    ,[ReferenceNumber]
    ,[SubBuildingName]
    ,[BuildingName]
    ,[BuildingNumber]
    ,[Street]
    ,[Locality]
    ,[DependentLocality]
    ,[Town]
    ,[County]
    ,[Country]
    ,[Postcode]
    ,[ValidatedWithCompaniesHouse]
    ,[IsComplianceScheme]
    ,[NationId]
    ,[ExternalId]
    ,[CreatedOn]
    ,[LastUpdatedOn]
    ,[IsDeleted]
    ,[ProducerTypeId]
    ,[TransferNationId]
    FROM [dbo].[v_rpd_Organisations_Active]
),

CTE_Main_FromOrganisations as (
    select a.*, 'From' as Direction from CTE_Main_Organisations a
    join CTE_FromOrganisationRoles_CS b
    on a.OrganisationId = b.FromOrganisationId
),

CTE_Main_ToOrganisations as (
    select a.*, 'To' as Direction from CTE_Main_Organisations a
    join CTE_ToOrganisationRoles_CS b
    on a.OrganisationId = b.ToOrganisationId
),

CTE_Organisations as (
    select * from CTE_Main_FromOrganisations
    union
    select * from CTE_Main_ToOrganisations
),

CTE_OrganisationTypes as (
    select Name as OrganisationType
    ,Id as XOrganisationTypeId
    from rpd.OrganisationTypes
),

CTE_Organisations_OrganisationTypes as (
    select * from CTE_Organisations a
    left join CTE_OrganisationTypes b
    on a.[OrganisationTypeId] = b.XOrganisationTypeId
),

CTE_ServiceRoles as (
    select a.Name as ServiceRoleName
    ,a.Id as ServiceRoleId
    ,b.[Key] as ServiceKey
    ,b.Description as ServiceDescription
    ,b.Name as ServiceName
    from rpd.ServiceRoles a
    join rpd.Services b
    on a.ServiceId = b.Id
),

CTE_Enrolments as (
    select a.ConnectionId
    ,a.EnrolmentStatusId
    ,a.ValidFrom
    ,a.ValidTo
    ,a.ExternalId as EnrolmentExternalId
    ,b.Name as EnrolmentStatus
    ,c.ServiceRoleName
    ,c.ServiceRoleId
    ,c.ServiceKey
    ,c.ServiceDescription
    ,c.ServiceName
    from [dbo].[v_rpd_Enrolments_Active] a
    join rpd.EnrolmentStatuses b
    on a.EnrolmentStatusId = b.Id
    join CTE_ServiceRoles c
    on a.ServiceRoleId = c.ServiceRoleId
	-- where a.IsDeleted = 'False'
),

CTE_Persons as (
    select a.FirstName
    ,a.LastName
    ,a.Email
    ,a.Telephone
    ,a.Id as PersonsId
    ,b.Email as ExternalEmail
    ,b.InvitedBy
    from [dbo].[v_rpd_Persons_Active] a
    left join rpd.Users b
    on a.UserId = b.Id
	-- where a.IsDeleted = 'False'
),

CTE_PersonOrganisationConnections as (
    select a.JobTitle
    ,a.OrganisationId as Connector
    ,b.Name as OrganisationToPersonRole
    ,c.Name as PersonInOrganisationRole
    ,d.*
    ,e.*
    from [dbo].[v_rpd_PersonOrganisationConnections_Active] a
    left join rpd.OrganisationToPersonRoles b
    on a.OrganisationRoleId = b.Id
    left join rpd.PersonInOrganisationRoles c
    on a.PersonRoleId = c.Id
    left join CTE_Enrolments d
    on a.Id = d.ConnectionId
    left join CTE_Persons e
    on a.PersonId = e.PersonsId
	-- where a.IsDeleted = 'False'
),

CTE_MainBody as (
    select a.*
    ,b.*
    ,c.Name as OrganisationNation
    ,c.Name as SecurityQuery -- make sure to update this when CS have nations too
    from CTE_Organisations_OrganisationTypes a
    left join CTE_PersonOrganisationConnections b
    on a.OrganisationId = b.Connector
    join rpd.Nations c
    on a.NationId = c.Id
)

select * from CTE_MainBody;