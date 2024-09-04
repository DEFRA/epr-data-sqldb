CREATE VIEW [dbo].[v_rpd_PersonOrganisationConnections_Active] AS select * 
from rpd.PersonOrganisationConnections 
where IsDeleted = 0 

/*------------------------------------------------------------------------------------
 * US 429684: Rejected enrolment of an approved person should show in enrolment report
 *
 * Don't treat IsDeleted = 1 as Soft deleted  
 *   when Role was 'Approved Person'.
 * ----------------------------------------------------------------------------------*/

UNION

SELECT * 
FROM rpd.PersonOrganisationConnections 
WHERE IsDeleted = 1  AND PersonRoleId = 1;