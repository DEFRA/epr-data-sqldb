CREATE VIEW [dbo].[v_rpd_Enrolments_Active]
AS select * 
from rpd.Enrolments 
where IsDeleted = 0;