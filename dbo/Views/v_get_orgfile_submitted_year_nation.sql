CREATE VIEW [dbo].[v_get_orgfile_submitted_year_nation] AS SELECT DISTINCT Relevant_Year, Organisation_Nation_Name, CS_Nation_name, Link_Column

FROM
	(
	
	SELECT  '20' + Reverse(Substring(Reverse(Trim(SubmissionPeriod)), 1, 2))+1 AS Relevant_Year,
					  Organisation_Nation_Name,
					  CS_Nation_name,
					  'Link Column' as Link_Column
	FROM   [dbo].[v_latest_pending_or_accepted_orgfile_by_year]
	UNION ALL
	SELECT  '20'
	                + Reverse(Substring(Reverse(Trim(SubmissionPeriod)), 1, 2))+1 AS Relevant_Year,
					Organisation_Nation_Name,
					CS_Nation_name,
					'Link Column' as Link_Column
	FROM   [dbo].[v_latest_accepted_orgfile_by_year]
	) A;