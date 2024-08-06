CREATE VIEW [dbo].[v_rpd_Persons_Active]
AS select * 
from rpd.Persons
where IsDeleted = 0;