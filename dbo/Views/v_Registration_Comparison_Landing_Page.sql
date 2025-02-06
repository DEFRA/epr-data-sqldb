CREATE VIEW [dbo].[v_Registration_Comparison_Landing_Page] AS SELECT 
     cset.[CompanyOrgId]
	,trim(cset.[organisation_name]) +' '+ ISNULL(RIGHT(REPLICATE('0', 8) + trim(replace(cset.[companies_house_number],'''','')), 8),'') +' '+ CAST(cset.[CompanyOrgId] AS VARCHAR) AS Organisation --TS_001
	,cset.[CompanyOriginalFileName]
	,c.[SubmissionPeriod]
	,c.[IsSubmitted]
	,CAST (CONCAT_WS('-', DATEPART(YYYY, c.[created] ), DATEPART(MM, c.[created] ), DATEPART(DD, c.[created] )) AS VARCHAR) + ' ' + CAST (CONCAT_WS(':', DATEPART(HH, c.[created] ), DATEPART(N, c.[created] ), DATEPART(SS, c.[created] )) AS VARCHAR)+'.'+CAST (DATEPART(MS, c.[created] ) AS VARCHAR)
	+ ' ' + cset.[CompanyOriginalFileName] + ' ' + 
		      CAST(ISNULL(c.[SubmittedBy],'') AS VARCHAR) + ' ' +CAST(ISNULL(c.[SubmtterEmail],'') AS VARCHAR) + ' ' + CAST(ISNULL(c.[ServiceRoles_Name],'') AS VARCHAR)  AS FileCode
	,cset.[Regulator_Status]
	,c.[FileName]
	,cset.[CompanyFileType]
	,c.[SubmittedBy]
	,c.[SubmtterEmail]  SubmitterEmail
	,c.[ServiceRoles_Name] As ServiceRoleType
	,c.[created] AS SubmissionDateTime
	,'2024' AS Compliance_Year
	,cs.[Name] AS [ComplianceSchemeName]
	,CASE 
		WHEN cset.[ComplianceSchemeId] IS NOT NULL THEN 'Compliance Scheme'
		ELSE 'Producer' END [CSORPD]
	,'' AS Nation
	,cset.[CompanyRegID]
  FROM [dbo].[t_CompanyBrandPartnerFileUploadSet] cset
  JOIN [dbo].[v_cosmos_file_metadata] c ON cset.[CompanyFileName] = c.[FileName]
  LEFT JOIN [rpd].[ComplianceSchemes] cs ON cs.[ExternalId] = cset.ComplianceSchemeId
  GROUP BY  cset.[CompanyOrgId]
			,trim(cset.[organisation_name]) +' '+ ISNULL(RIGHT(REPLICATE('0', 8) + trim(replace(cset.[companies_house_number],'''','')), 8),'') +' '+ CAST(cset.[CompanyOrgId] AS VARCHAR) --TS_001
			,cset.[CompanyOriginalFileName]
			,c.[SubmissionPeriod]
			,c.[IsSubmitted]
			,CAST (CONCAT_WS('-', DATEPART(YYYY, c.[created] ), DATEPART(MM, c.[created] ), DATEPART(DD, c.[created] )) AS VARCHAR) + ' ' + CAST (CONCAT_WS(':', DATEPART(HH, c.[created] ), DATEPART(N, c.[created] ), DATEPART(SS, c.[created] )) AS VARCHAR)+'.'+CAST (DATEPART(MS, c.[created] ) AS VARCHAR)
			+ ' ' + cset.[CompanyOriginalFileName] + ' ' + 
		      CAST(ISNULL(c.[SubmittedBy],'') AS VARCHAR) + ' ' +CAST(ISNULL(c.[SubmtterEmail],'') AS VARCHAR)	+ ' ' + CAST(ISNULL(c.[ServiceRoles_Name],'') AS VARCHAR)
			,cset.[Regulator_Status]
			,c.[FileName]
			,cset.[CompanyFileType]
			,c.[SubmittedBy]
			,c.[SubmtterEmail]
			,c.[ServiceRoles_Name]
			,c.[created]
			,cs.[Name]
			,CASE 
				WHEN cset.[ComplianceSchemeId] IS NOT NULL THEN 'Compliance Scheme'
				ELSE 'Producer' END
			,cset.[CompanyRegID];