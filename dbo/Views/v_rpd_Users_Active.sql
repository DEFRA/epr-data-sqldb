CREATE VIEW [dbo].[v_rpd_Users_Active]
AS select * 
from rpd.Users
where IsDeleted = 0;