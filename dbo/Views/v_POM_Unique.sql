CREATE VIEW [dbo].[v_POM_Unique] AS with cte_a as (
SELECT 
cast(organisation_id as nvarchar) +
filename JOINFIELD
from dbo.v_POM_Submissions
group by 
cast(organisation_id as nvarchar)+
filename 
) 

select *
from cte_a;