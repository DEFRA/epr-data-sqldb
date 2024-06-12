CREATE VIEW [dbo].[v_POM_Extract_Fix]
AS SELECT DISTINCT

dsf.FromOrganisation_Name [Org_Name]

,CASE
	WHEN csname.name is not null THEN  'Compliance Scheme'
	ELSE 'Producer' END [PCS_Or_Direct_Producer]

,csname.name Compliance_Scheme

,CASE
	WHEN cd.[organisation_type_code] = 'SOL'	THEN	'Sole trader'
	WHEN cd.[organisation_type_code] = 'PAR'	THEN	'Partnership'
	WHEN cd.[organisation_type_code] = 'REG'	THEN	'Regulator'
	WHEN cd.[organisation_type_code] = 'PLC'	THEN	'Public limited company'
	WHEN cd.[organisation_type_code] = 'LLP'	THEN	'Limited Liability partnership'
	WHEN cd.[organisation_type_code] = 'LTD'	THEN	'Limited Liability company'
	WHEN cd.[organisation_type_code] = 'LPA'	THEN	'Limited partnership'
	WHEN cd.[organisation_type_code] = 'COP'	THEN	'Co-operative'
	WHEN cd.[organisation_type_code] = 'CIC'	THEN	'Community interest Company'
	WHEN cd.[organisation_type_code] = 'OUT'	THEN	'Outside UK'
	WHEN cd.[organisation_type_code] = 'OTH'	THEN	'Others'
ELSE dsf.FromOrganisation_Type END as [Org_Type]

,reglatest.[Org_Sub_Type] 
,p.[organisation_size]
,meta.created  [Submission_Date]
,p.[submission_period]
,p.[organisation_id] 
,p.[subsidiary_id]
,dsf.FromOrganisation_CompaniesHouseNumber [CH_Number]
--,coalesce(dsf.FromOrganisation_CompaniesHouseNumber,dsf.ComplianceSchemes_CompaniesHouseNumber) [CH_Number] -- companies house number 
,dsf.FromOrganisation_NationName [Nation_Of_Enrolment]
,p.[packaging_activity]
,p.[packaging_type]
,p.[packaging_class]
,p.[packaging_material] 
,p.[packaging_sub_material] 
,p.[from_nation]
,p.[to_nation]
,p.[quantity_kg]
,p.[quantity_unit]
,p.[Quantity_kg_extrapolated]
,p.[Quantity_units_extrapolated]
,dsf.[ToOrganisation_NationName]
,dsf.SecurityQuery Nation
,dsf.[FromOrganisation_NationName]
,p.FileName

,CASE
	WHEN meta.[SubmittedBy] is null THEN 'No Name Available'
	ELSE meta.[SubmittedBy] end [SubmittedBy]

,CASE
	WHEN csname.name is not null THEN  csname.name
	ELSE dsf.FromOrganisation_Name END submitter_org_name
,CASE
	WHEN replacement.referenceNumber is null THEN p.[organisation_id] 
	ELSE replacement.referenceNumber END submitter_org_id


FROM [dbo].[v_Pom] p
  
JOIN [dbo].[v_rpd_data_SECURITY_FIX] dsf on p.[organisation_id]  = dsf.[FromOrganisation_ReferenceNumber] 

LEFT JOIN ( select cosmos.filename, cs.name, cs.companieshousenumber
				from [dbo].[v_cosmos_file_metadata] cosmos
				join  rpd.complianceschemes cs on cs.externalid = cosmos.[ComplianceSchemeId]
				group by  cosmos.filename, cs.name,cs.companieshousenumber) csname on csname.filename = p.filename
				
LEFT JOIN rpd.organisations replacement on replacement.companieshousenumber = csname.companieshousenumber

JOIN [dbo].[v_cosmos_file_metadata] meta  on p.filename = meta.filename

LEFT JOIN  [dbo].[v_registration_latest] reglatest on  reglatest.[organisation_id] = p.[organisation_id] and isnull(reglatest.[subsidiary_id], '') =isnull(p.[subsidiary_id], '')
  
LEFT JOIN  (select distinct [organisation_id], [organisation_type_code] from  [rpd].[CompanyDetails] where [organisation_id] is not null ) cd on cd.[organisation_id] = p.[organisation_id];