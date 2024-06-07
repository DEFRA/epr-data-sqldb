CREATE VIEW [dbo].[v_rpd_CompanyDetails_Active]
AS select * 
from rpd.CompanyDetails 
where IsDeleted = 0;