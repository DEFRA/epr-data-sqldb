CREATE VIEW [dbo].[v_Enrolments] AS with cte_Enrolments as (
    SELECT EnrolmentsTable.Id as Enrolment_Id
    ,EnrolmentsTable.[ConnectionId] as Enrolment_ConnectionId
    ,EnrolmentsTable.[ServiceRoleId] as Enrolment_ServiceRoleId
    ,EnrolmentsTable.[ValidFrom] as Enrolment_ValidFrom
    ,EnrolmentsTable.[ValidTo] as Enrolment_ValidTo
    ,EnrolmentsTable.[ExternalId] as Enrolment_ExternalId
    ,EnrolmentsTable.[CreatedOn] as Enrolment_CreatedOn
    ,EnrolmentsTable.[LastUpdatedOn] as Enrolment_LastUpdatedOn
    ,EnrolmentsTable.[IsDeleted] as Enrolment_IsDeleted
    ,RegComments.[Id] as Enrolment_RegulatorCommentId
    ,EnrolmentStatusesTable.Name as EnrolmentStatuses_EnrolmentStatus
    ,ServicesAndRoles.ServiceRoles_Id
    ,ServicesAndRoles.ServiceRoles_ServiceId
    ,ServicesAndRoles.ServiceRoles_Key
    ,ServicesAndRoles.ServiceRoles_Role
    ,ServicesAndRoles.ServiceRoles_Description
    ,ServicesAndRoles.Services_Key
    ,ServicesAndRoles.Services_Service
    ,ServicesAndRoles.Services_Description

    FROM [dbo].[v_rpd_Enrolments_Active] EnrolmentsTable
    left join rpd.EnrolmentStatuses EnrolmentStatusesTable
    on EnrolmentsTable.EnrolmentStatusId = EnrolmentStatusesTable.Id

    left join (
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

    left join [dbo].[v_rpd_RegulatorComments_Active] RegComments
    on EnrolmentsTable.Id = RegComments.EnrolmentId
)

select * from cte_Enrolments;