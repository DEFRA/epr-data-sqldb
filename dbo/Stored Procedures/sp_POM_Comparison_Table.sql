CREATE PROC [dbo].[sp_POM_Comparison_Table] AS
BEGIN

--select top 10 * from POM_Filters
 
 IF OBJECT_ID('dbo.POM_Filters_Insert', 'U') IS NOT NULL
BEGIN
    -- Drop the table if it exists
    DROP TABLE dbo.POM_Filters_Insert;
END

select distinct
nation securityquery
,'Producer' [PCS_Or_Direct_Producer]
,Org_Name+' '+ isnull([CH_Number],'') +' '+ CAST(organisation_id AS VARCHAR) Organisation
,'2024' compliance_year
,submission_period
--,RIGHT('00000000' + CAST(ROW_NUMBER() OVER (ORDER BY Submission_Date DESC) AS VARCHAR(10)), 8) + ' ' + submittedby + ' ' + submtteremail + ' ' +serviceroles_name  + ' '+ cast(submission_date as varchar(500)) + ' ' + originalfilename filecode
,CONVERT(varchar, Submission_Date, 112) + ' ' + CONVERT(varchar, Submission_Date, 108) + ' ' + submittedby + ' ' + submtteremail + ' ' +serviceroles_name  + ' '+ ' ' + originalfilename filecode
,filename 
,organisation_id
,'' [Compliance_Scheme]
,originalfilename
,submittedby
,submtteremail
,serviceroles_name
,submission_date

into dbo.POM_Filters_Insert
from dbo.[t_POM_Submissions_POM_Comparison]
where [PCS_Or_Direct_Producer] = 'Producer'
group by 
nation
,Org_Name+' '+  isnull([CH_Number],'') +' '+CAST(organisation_id AS VARCHAR)
,submission_period
,submittedby + ' ' + submtteremail + ' ' +serviceroles_name  + ' '+ cast(submission_date as varchar(500)) + ' ' + originalfilename
,filename
,organisation_id
,originalfilename
,submittedby
,submtteremail
,serviceroles_name
,submission_date
union all 

select distinct  nation securityquery
,'Compliance Scheme'
,[Compliance_Scheme] 
,'2024'
,submission_period
--,RIGHT('00000000' + CAST(ROW_NUMBER() OVER (ORDER BY Submission_Date DESC) AS VARCHAR(10)), 8) + ' ' + submittedby + ' ' + submtteremail + ' ' +serviceroles_name  + ' '+ cast(submission_date as varchar(500)) + ' ' + originalfilename filecode
,CONVERT(varchar, Submission_Date, 112) + ' ' + CONVERT(varchar, Submission_Date, 108) + ' ' + submittedby + ' ' + submtteremail + ' ' +serviceroles_name  + ' '+ ' ' + originalfilename filecode
,filename 
,''
,[Compliance_Scheme]
,originalfilename
,submittedby
,submtteremail
,serviceroles_name
,submission_date

from dbo.[t_POM_Submissions_POM_Comparison]
where [Compliance_Scheme] is not null
--and [PCS_Or_Direct_Producer] = 'Producer'
group by 
nation
,[Compliance_Scheme]
,submission_period
,submittedby + ' ' + submtteremail + ' ' +serviceroles_name  + ' '+ cast(submission_date as varchar(500)) + ' ' + originalfilename
,filename
--,organisation_id
,originalfilename
,submittedby
,submtteremail
,serviceroles_name
,submission_date

RENAME OBJECT dbo.POM_Filters TO POM_Filters_Drop; -- existing table renamed to table to drop
RENAME OBJECT dbo.POM_Filters_Insert TO POM_Filters; -- newly created table renamed table used by report

--drop old table, no longer needed
 IF OBJECT_ID('dbo.POM_Filters_Drop', 'U') IS NOT NULL
BEGIN
    -- Drop the table if it exists
    DROP TABLE dbo.POM_Filters_Drop;
END

end


--select * from POM_Filters