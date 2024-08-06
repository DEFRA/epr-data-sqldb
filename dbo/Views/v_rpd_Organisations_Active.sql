CREATE VIEW [dbo].[v_rpd_Organisations_Active]
AS select * 
from rpd.Organisations 
where IsDeleted = 0;