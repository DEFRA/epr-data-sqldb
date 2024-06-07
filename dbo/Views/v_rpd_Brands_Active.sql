CREATE VIEW [dbo].[v_rpd_Brands_Active]
AS select * 
from rpd.Brands 
where IsDeleted = 0;