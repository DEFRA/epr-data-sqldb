CREATE VIEW [dbo].[v_rpd_OrganisationsConnections_Active]
AS select * 
from rpd.OrganisationsConnections
where IsDeleted = 0;