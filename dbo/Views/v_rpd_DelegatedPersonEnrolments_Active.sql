CREATE VIEW [dbo].[v_rpd_DelegatedPersonEnrolments_Active]
AS select * 
from rpd.DelegatedPersonEnrolments
where IsDeleted = 0;