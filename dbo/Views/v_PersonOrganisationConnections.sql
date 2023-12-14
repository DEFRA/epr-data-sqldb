CREATE VIEW [dbo].[v_PersonOrganisationConnections] AS with cte_Enrolments as (
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
)--, -- 238 records

select * from cte_PersonOrgConnectionsAndEnrolments;