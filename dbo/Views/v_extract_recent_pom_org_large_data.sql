CREATE VIEW [dbo].[v_extract_recent_pom_org_large_data] AS select *
from dbo.t_extract_recent_pom_org_data a
where not exists 
(
	select 1
	from dbo.v_extract_recent_pom_org_small_data b
	where a.org_id = b.org_id
	and a.Reporting_Year=b.Reporting_Year
);