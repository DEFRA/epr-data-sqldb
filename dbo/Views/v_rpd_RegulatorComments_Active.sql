CREATE VIEW [dbo].[v_rpd_RegulatorComments_Active]
AS select * 
from rpd.RegulatorComments 
where IsDeleted = 0;