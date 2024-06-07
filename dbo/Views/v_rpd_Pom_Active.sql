CREATE VIEW [dbo].[v_rpd_Pom_Active]
AS select * 
from rpd.Pom 
where IsDeleted = 0;