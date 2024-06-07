CREATE VIEW [dbo].[v_rpd_ComplianceSchemes_Active]
AS select * 
from rpd.ComplianceSchemes
where IsDeleted = 0;