CREATE VIEW [dbo].[v_rpd_Partnerships_Active]
AS select * 
from rpd.Partnerships 
where IsDeleted = 0;