CREATE VIEW [dbo].[v_POM_Filters] AS select nation securityquery,'Producer' [PCS_Or_Direct_Producer],Org_Name+' '+ isnull([CH_Number],'') +' '+ CAST(organisation_id AS VARCHAR) Organisation, '2024' compliance_year, submission_period, submittedby + ' ' + submtteremail + ' ' +serviceroles_name  + ' '+ cast(submission_date as varchar(500)) + ' ' + originalfilename filecode, filename 
,organisation_id  ,'' [Compliance_Scheme], originalfilename,submittedby,submtteremail,serviceroles_name,submission_date
from dbo.t_POM_Submissions
where [PCS_Or_Direct_Producer] = 'Producer'
group by nation, Org_Name+' '+  isnull([CH_Number],'') +' '+CAST(organisation_id AS VARCHAR),  submission_period, submittedby + ' ' + submtteremail + ' ' +serviceroles_name   + ' '+ cast(submission_date as varchar(500)) + ' ' +  originalfilename,filename
,organisation_id, originalfilename,submittedby,submtteremail,serviceroles_name,submission_date
union all 
select nation securityquery,'Compliance Scheme' , [Compliance_Scheme] , '2024', submission_period, submittedby + ' ' + submtteremail + ' ' +serviceroles_name  + ' '+ cast(submission_date as varchar(500)) + ' ' + originalfilename filecode, filename 
,'', [Compliance_Scheme], originalfilename,submittedby,submtteremail,serviceroles_name,submission_date
from dbo.t_POM_Submissions
where [Compliance_Scheme] is not null
--and [PCS_Or_Direct_Producer] = 'Producer'
group by nation, [Compliance_Scheme],  submission_period, submittedby + ' ' + submtteremail + ' ' +serviceroles_name   + ' '+ cast(submission_date as varchar(500)) + ' ' +  originalfilename,filename
,organisation_id, originalfilename,submittedby,submtteremail,serviceroles_name,submission_date;