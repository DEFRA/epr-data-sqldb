CREATE VIEW [dbo].[v_rpd_Organisations_Active] AS select * 
from rpd.Organisations 
where IsDeleted = 0


/*------------------------------------------------------------------------------------
 * US 429684: Rejected enrolment of an approved person should show in enrolment report
 *
 * Don't treat IsDeleted = 1 as Soft deleted Organisations 
 *   when Role was 'Approved Person' and Status was 'Rejected'
 * ----------------------------------------------------------------------------------*/

UNION 

SELECT o.* 
FROM rpd.Organisations o
JOIN [rpd].[PersonOrganisationConnections] poc ON poc.[OrganisationId] = o.[Id]
WHERE poc.[PersonRoleId] = 1 AND poc.[IsDeleted] = 1 AND o.[IsDeleted] = 1;