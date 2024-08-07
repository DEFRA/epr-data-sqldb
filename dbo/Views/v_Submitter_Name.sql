﻿CREATE VIEW [dbo].[v_Submitter_Name] AS with cte_enrolments as (
    select enrolments.Id as Enrolments_Id
    ,enrolments.ConnectionId as Enrolments_ConnectionId
    ,enrolments.CreatedOn as Enrolments_CreatedOn
    ,enrolments.IsDeleted as Enrolments_IsDeleted
    ,serviceroles.Name as ServiceRoles_Name
    ,enrolments.LastUpdatedOn as Enrolments_LastUpdatedOn
    ,ROW_NUMBER() OVER (PARTITION BY enrolments.ConnectionId ORDER BY enrolments.LastUpdatedOn DESC) AS RowNum

    from dbo.v_rpd_Enrolments_Active enrolments

    left join rpd.ServiceRoles serviceroles
    on enrolments.ServiceRoleId = serviceroles.Id
),

cte_persons as (
    select 
        p.ExternalId as Submitter_Id
        ,concat(p.FirstName, ' ', p.LastName) as Submitter_Name
        ,p.Email as Submitter_Email
        ,poc.Id as POC_Id
        ,u.UserId 
    from dbo.v_rpd_Persons_Active p
    join dbo.v_rpd_PersonOrganisationConnections_Active poc
        on p.Id = poc.PersonId
    join dbo.v_rpd_Users_Active u 
        on u.id = p.UserId
)

select enrolments.*
,persons.*
from cte_enrolments enrolments
left join cte_persons persons
on enrolments.Enrolments_ConnectionId = persons.POC_Id
where enrolments.RowNum = 1;