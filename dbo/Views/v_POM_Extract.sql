CREATE VIEW [dbo].[v_POM_Extract] AS SELECT distinct
dsf.FromOrganisation_Name [Org_Name]
/*,Case 
    When dsf.[FromOrganisation_IsComplianceScheme] = 'True' then 'Compliance Scheme'
    else 'Producer'
End [PCS_Or_Direct_Producer] 
*/
,case when csname.name is not null then  'Compliance Scheme'
else'Producer' end [PCS_Or_Direct_Producer]
 
/*,case 
    when dsf.[ToOrganisation_IsComplianceScheme] = 'True' then dsf.[ToOrganisation_Name]
    when dsf.[FromOrganisation_IsComplianceScheme] = 'True' then dsf.[FromOrganisation_Name]
else NULL
end   [Compliance_Scheme]*/
--,dsf.[ComplianceSchemes_Name] Compliance_Scheme
,case when csname.name is not null then csname.name else dsf.[ComplianceSchemes_Name] end Compliance_Scheme
,dsf.FromOrganisation_Type [Org_Type]
,case 
    when reg.[organisation_sub_type_code]  = 'LIC' then 'Licensor'
    when reg.[organisation_sub_type_code]  = 'POB' then 'Pub operating business '
    when reg.[organisation_sub_type_code]  = 'FRA' then 'Franchisor '
    when reg.[organisation_sub_type_code]  = 'NAO' then 'Non-associated organisation'
    when reg.[organisation_sub_type_code]  = 'HCY' then 'Holding company'
    when reg.[organisation_sub_type_code]  = 'SUB' then 'Subsidiary'
    when reg.[organisation_sub_type_code]  = 'LFR' then 'Licensee/Franchisee'
    when reg.[organisation_sub_type_code]  = 'TEN' then 'Tenant'
    when reg.[organisation_sub_type_code]  = 'OTH' then 'Others'
else NULL end [Org_Sub_Type] 
,p.[organisation_size]
,meta.created [Submission_Date]
,p.[submission_period]
,p.[organisation_id] 
,p.[subsidiary_id] 
,dsf.ComplianceSchemes_CompaniesHouseNumber [CH_Number] -- companies house number 
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
,case when csname.name is not null then  csname.name
else dsf.FromOrganisation_Name end submitter_org_name
 
,case when os.organisation_id is null then p.[organisation_id] 
else os.organisation_id end submitter_org_id
 
--,dsf.ServiceRoles_Role
--,dsf.[from_nation] FromNation
--,dsf.[tonation] ToNation
FROM [dbo].[v_Pom] p
   join [dbo].[v_rpd_data_SECURITY_FIX] dsf
on p.[organisation_id]  = dsf.[FromOrganisation_ReferenceNumber] 
   join [dbo].[v_cosmos_file_metadata] meta
on p.filename = meta.filename
--20231205
left join ( select cosmos.filename, cs.name
  from [dbo].[v_cosmos_file_metadata] cosmos
  join  rpd.complianceschemes cs on cs.externalid = cosmos.[ComplianceSchemeId]
  group by  cosmos.filename, cs.name) csname on csname.filename = p.filename
left join [rpd].[CompanyDetails] reg on reg.[organisation_id] = p.[organisation_id]
left join [v_POM_Operator_Submissions] os on os.filename = p.filename
where p.[submission_period] is not null;