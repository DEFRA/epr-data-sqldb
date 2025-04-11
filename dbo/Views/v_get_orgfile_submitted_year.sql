CREATE VIEW [dbo].[v_get_orgfile_submitted_year] AS SELECT DISTINCT '20'
                  + Reverse(Substring(Reverse(Trim(submissionperiod)), 1, 2)) AS ReportingYear
  FROM   rpd.cosmos_file_metadata
  WHERE  Upper(filetype) = 'COMPANYDETAILS';