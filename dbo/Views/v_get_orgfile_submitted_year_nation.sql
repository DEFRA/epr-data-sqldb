CREATE VIEW [dbo].[v_get_orgfile_submitted_year_nation] AS SELECT DISTINCT Relevant_Year, Organisation_Nation_Name, CS_Nation_name, Link_Column

FROM
	(
	
	SELECT 
	CASE
		WHEN '20' + Reverse(Substring(Reverse(Trim(SubmissionPeriod)), 1, 2)) = 2023 then 2023+1
		WHEN '20' + Reverse(Substring(Reverse(Trim(SubmissionPeriod)), 1, 2)) = 2024 then 2024+1
		ELSE '20' + Reverse(Substring(Reverse(Trim(SubmissionPeriod)), 1, 2)) END AS Relevant_Year,
					  Organisation_Nation_Name,
					  CS_Nation_name,
					  'Link Column' as Link_Column
	FROM   [dbo].[v_latest_pending_or_accepted_orgfile_by_year]
	UNION ALL
	SELECT  CASE
				WHEN '20' + Reverse(Substring(Reverse(Trim(SubmissionPeriod)), 1, 2)) = 2023 then 2023+1
				WHEN '20' + Reverse(Substring(Reverse(Trim(SubmissionPeriod)), 1, 2)) = 2024 then 2024+1
				ELSE '20' + Reverse(Substring(Reverse(Trim(SubmissionPeriod)), 1, 2)) END AS Relevant_Year,
					Organisation_Nation_Name,
					CS_Nation_name,
					'Link Column' as Link_Column
	FROM   [dbo].[v_latest_accepted_orgfile_by_year]
	) A;