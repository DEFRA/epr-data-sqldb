CREATE VIEW [dbo].[v_rpd_Persons_Active] AS select * 
from rpd.Persons
where IsDeleted = 0

UNION

/*------------------------------------------------------------------------------------
 * US 429684: Rejected enrolment of an approved person should show in enrolment report
 *
 * Don't treat IsDeleted = 1 as Soft deleted
 *   when Role was 'Approved Person'
 * ----------------------------------------------------------------------------------*/

SELECT p.* 
FROM [rpd].[Persons] p 
JOIN [rpd].[PersonOrganisationConnections] poc ON poc.[PersonId] = p.[Id]
WHERE poc.[PersonRoleId] = 1 AND p.[IsDeleted]=1;