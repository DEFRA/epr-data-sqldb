CREATE VIEW [dbo].[v_rpd_Organisations_Active_Pom]
AS select * 
from rpd.Organisations 
where IsDeleted = 0;