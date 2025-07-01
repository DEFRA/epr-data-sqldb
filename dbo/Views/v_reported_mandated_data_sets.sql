CREATE VIEW [dbo].[v_reported_mandated_data_sets] AS select bs.[Org_ID] , sub_c.ReportingYear ,
case when sub_c.cnt = 4 then 'Y' else 'N' end as Reported_mandated_data_sets
from dbo.t_extract_recent_pom_org_data bs
left join dbo.t_submission_count sub_c on sub_c.[Org ID] = bs.[Org_ID] and sub_c.ReportingYear = bs.Reporting_Year;