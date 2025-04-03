CREATE VIEW [dbo].[v_PayCal_Org] AS WITH producer_accepted_record AS (
/*****************************************************************************************************************
	History:
	Created 2024-10-04: VK001:425541: Created initial version of the view based on the logic we had in pyspark notebook
	Updated 2024-10-24: ST002: 457711: Added submission_period_desc column
	Updated 2024-07-23: ST002: 510600: 	Added in additional null validation to OrganisationId and OrganisationName to ensure no null value records passed to PayCal
    Updated 2025-03-26: HA001: 522656: Added the field "trading_name" from CompanyDetails as per PayCal new requirements.


 *****************************************************************************************************************/
SELECT cm.filename,
                  cm.originalfilename,
                  cm.organisationid,
                  cm.submissionperiod as submission_period_desc,
                  cm.[created],
                  Row_number()
                    OVER(
                      partition BY cm.organisationid, cm.submissionperiod
                      ORDER BY CONVERT(DATETIME, Substring(cm.created, 1, 23))
                    DESC) AS
                     org_rownumber
           FROM   [rpd].[cosmos_file_metadata] cm
                  INNER JOIN [rpd].[submissionevents] se
                          ON Trim(se.fileid) = Trim(cm.fileid)
                             AND se.[type] = 'RegulatorRegistrationDecision'
                             AND se.decision = 'Accepted'
           WHERE  Trim(cm.filetype) = 'CompanyDetails'),
       latest_producer_accepted_record
       AS (SELECT filename,
                  originalfilename,
                  organisationid,
                  submission_period_desc,
                  created
           FROM   producer_accepted_record
           WHERE  org_rownumber = 1)
  SELECT cd.organisation_id,
         cd.subsidiary_id,
         cd.organisation_name,
         cd.trading_name,
		 cm.submission_period_desc
  FROM   [rpd].[companydetails] cd
         INNER JOIN latest_producer_accepted_record cm ON Trim(cm.[filename]) = Trim(cd.[filename])
		 WHERE 
		 cd.organisation_id IS NOT NULL
         AND cd.organisation_name IS NOT NULL;