CREATE VIEW [dbo].[v_rpd_SelectedSchemes_Active]
AS select * 
from rpd.SelectedSchemes
where IsDeleted = 0;