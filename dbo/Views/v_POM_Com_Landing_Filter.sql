CREATE VIEW [dbo].[v_POM_Com_Landing_Filter] AS SELECT DISTINCT *
FROM (
SELECT
	nation securityquery,
	'Producer' PCS_Or_Direct_Producer,
	Org_Name+' '+ isnull([CH_Number],'') +' '+ CAST(organisation_id AS VARCHAR) Organisation,
	'2024' compliance_year,
	submission_period,
	CONVERT(varchar, Submission_Date, 112) + ' ' + CONVERT(varchar, Submission_Date, 108) + ' ' + submittedby + ' ' + submtteremail + ' ' +serviceroles_name  + ' '+ ' ' + originalfilename filecode,
	filename,
	organisation_id,
	'' Compliance_Scheme,
	originalfilename,
	submittedby,
	submtteremail,
	serviceroles_name,
	submission_date
FROM dbo.t_POM_Submissions_POM_Comparison
WHERE PCS_Or_Direct_Producer = 'Producer'

UNION ALL

SELECT
	nation securityquery,
	'Compliance Scheme',
	Compliance_Scheme,
	'2024',
	submission_period,
	CONVERT(varchar, Submission_Date, 112) + ' ' + CONVERT(varchar, Submission_Date, 108) + ' ' + submittedby + ' ' + submtteremail + ' ' +serviceroles_name  + ' '+ ' ' + originalfilename filecode,
	filename,
	'',
	Compliance_Scheme,
	originalfilename,
	submittedby,
	submtteremail,
	serviceroles_name,
	submission_date
FROM dbo.t_POM_Submissions_POM_Comparison
WHERE Compliance_Scheme IS NOT NULL
) X;