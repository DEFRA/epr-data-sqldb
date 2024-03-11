CREATE VIEW [dbo].[v_POM_Extract]
AS SELECT DISTINCT
dsf.FromOrganisation_Name [Org_Name]
/*,Case 
    When dsf.[FromOrganisation_IsComplianceScheme] = 'True' then 'Compliance Scheme'
    else 'Producer'
End [PCS_Or_Direct_Producer] 
*/
,CASE
	WHEN csname.name is not null THEN  'Compliance Scheme'
	ELSE 'Producer' END [PCS_Or_Direct_Producer]
 
/*,case 
    when dsf.[ToOrganisation_IsComplianceScheme] = 'True' then dsf.[ToOrganisation_Name]
    when dsf.[FromOrganisation_IsComplianceScheme] = 'True' then dsf.[FromOrganisation_Name]
else NULL
end   [Compliance_Scheme]*/

--,dsf.[ComplianceSchemes_Name] Compliance_Scheme

--,case when csname.name is not null then csname.name else dsf.[ComplianceSchemes_Name] end Compliance_Scheme 278515
,csname.name as Compliance_Scheme
--,dsf.FromOrganisation_Type   as [Org_Type]

-- ********==========================================**********************
-- The below code included in the "v_registration_latest" ********
--,case 
--    when reglatest.[Org_Sub_Type]  = 'LIC' then 'Licensor'
--    when reglatest.[Org_Sub_Type]  = 'POB' then 'Pub operating business '
--    when reglatest.[Org_Sub_Type]  = 'FRA' then 'Franchisor '
--    when reglatest.[Org_Sub_Type]  = 'NAO' then 'Non-associated organisation'
--    when reglatest.[Org_Sub_Type]  = 'HCY' then 'Holding company'
--    when reglatest.[Org_Sub_Type]  = 'SUB' then 'Subsidiary'
--    when reglatest.[Org_Sub_Type]  = 'LFR' then 'Licensee/Franchisee'
--    when reglatest.[Org_Sub_Type]  = 'TEN' then 'Tenant'
--    when reglatest.[Org_Sub_Type]  = 'OTH' then 'Others'
--else NULL end [org_sub_type]
-- ********==========================================**********************

--- Below lines fetch Org Type from Orgtypecode form the Company Details table
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
ELSE dsf.FromOrganisation_Type END as [Org_Type] -- 278519

--,cd.[organisation_type_code]

,reglatest.[Org_Sub_Type] --New column for org_sub_type
,p.[organisation_size]
,meta.created [Submission_Date]
,p.[submission_period]
,p.[organisation_id] 
,p.[subsidiary_id] 
,dsf.FromOrganisation_CompaniesHouseNumber [CH_Number] -- companies house number 278675
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
,case when meta.[SubmittedBy] is null then 'No Name Available'
 
else meta.[SubmittedBy] end [SubmittedBy]

/*,Case 
    When dsf.[FromOrganisation_IsComplianceScheme] = 'True' then 'Compliance Scheme'
    else 'Producer'
End [PCS_Or_Direct_Producer_enrolled] 
*/
,CASE
	WHEN csname.name is not null THEN  csname.name
	ELSE dsf.FromOrganisation_Name END submitter_org_name
 
,CASE
	WHEN os.organisation_id is null THEN p.[organisation_id] 
	ELSE os.organisation_id END submitter_org_id
 
--,dsf.ServiceRoles_Role
--,dsf.[from_nation] FromNation
--,dsf.[tonation] ToNation

FROM [dbo].[v_Pom] p

	join [dbo].[v_rpd_data_SECURITY_FIX] dsf on p.[organisation_id]  = dsf.[FromOrganisation_ReferenceNumber]
	left join [v_POM_Operator_Submissions] os on os.filename = p.filename
	join [dbo].[v_cosmos_file_metadata] meta on p.filename = meta.filename

	left join ( select cosmos.filename, cs.name from [dbo].[v_cosmos_file_metadata] cosmos join  rpd.complianceschemes cs on cs.externalid = cosmos.[ComplianceSchemeId]
											group by  cosmos.filename, cs.name) csname on csname.filename = p.filename

	left join [dbo].[v_registration_latest] reglatest on  reglatest.[organisation_id] = p.[organisation_id] and reglatest.[subsidiary_id] =p.[subsidiary_id]

	left join (select distinct [organisation_id], [organisation_type_code] from  [rpd].[CompanyDetails] where [organisation_id] is not null ) cd on cd.[organisation_id] = p.[organisation_id]
WHERE p.[submission_period] is not null;