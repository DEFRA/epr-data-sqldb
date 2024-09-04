CREATE VIEW [dbo].[v_rpd_Enrolments_Active]
AS SELECT * 
FROM [rpd].[Enrolments] 
WHERE ISdeleted = 0

UNION

/*------------------------------------------------------------------------------------
 * US 429684: Rejected enrolment of an approved person should show in enrolment report
 *
 * Don't treat ISdeleted = 1 as Soft deleted Enrolments 
 *   when ServiceRole was 'Approved Person' and EnrolmentStatus was 'Rejected'
 * ----------------------------------------------------------------------------------*/

SELECT * 
FROM [rpd].[Enrolments]
WHERE ISdeleted = 1 AND ServiceRoleId = 1 AND EnrolmentStatusId = 4;