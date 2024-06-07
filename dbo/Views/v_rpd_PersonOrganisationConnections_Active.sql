CREATE VIEW [dbo].[v_rpd_PersonOrganisationConnections_Active]
AS select * 
from rpd.PersonOrganisationConnections 
where IsDeleted = 0;