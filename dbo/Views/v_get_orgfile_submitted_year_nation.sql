/****** Object:  View [dbo].[v_get_orgfile_submitted_year_nation]    Script Date: 14/05/2026 10:36:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[v_get_orgfile_submitted_year_nation] AS

SELECT DISTINCT 
    CASE
--  WHEN CAST('20' + RIGHT(TRIM(SubmissionPeriod), 2) AS INT) >= 2023 -- removed year reliance
    WHEN CAST('20' + RIGHT(TRIM(SubmissionPeriod), 2) AS INT) >= YEAR(GETDATE())
                    THEN CAST('20' + RIGHT(TRIM(SubmissionPeriod), 2) AS INT) + 1
        ELSE CAST('20' + RIGHT(TRIM(SubmissionPeriod), 2) AS INT)     
    END AS Relevant_Year,
      Organisation_Nation_Name,
    CS_Nation_name,
    'Link Column' AS Link_Column

FROM [dbo].[v_latest_pending_or_accepted_orgfile_by_year]

UNION ALL

SELECT  
    CASE
--        WHEN CAST('20' + RIGHT(TRIM(SubmissionPeriod), 2) AS INT) >= 2023 -- removed year reliance
          WHEN CAST('20' + RIGHT(TRIM(SubmissionPeriod), 2) AS INT) >= YEAR(GETDATE())
            THEN CAST('20' + RIGHT(TRIM(SubmissionPeriod), 2) AS INT) + 1
        ELSE CAST('20' + RIGHT(TRIM(SubmissionPeriod), 2) AS INT)
    END AS Relevant_Year,
        Organisation_Nation_Name,
    CS_Nation_name,
    'Link Column' AS Link_Column
 
FROM [dbo].[v_latest_accepted_orgfile_by_year];
GO