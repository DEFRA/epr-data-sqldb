CREATE VIEW [dbo].[v_POM_Submissions] AS SELECT distinct
/****************************************************************************************************************************
	History:
 
	Updated: 2024-11-15:	YM001:	Ticket - 460891:	Adding the new column [transitional_packaging_units]

******************************************************************************************************************************/
dsf.FromOrganisation_Name [Org_Name]
/*,Case 
    When dsf.[FromOrganisation_IsComplianceScheme] = 'True' then 'Compliance Scheme'
    else 'Producer'
End [PCS_Or_Direct_Producer] */
/*,case 
    when dsf.[ToOrganisation_IsComplianceScheme] = 'True' then dsf.[ToOrganisation_Name]
    when dsf.[FromOrganisation_IsComplianceScheme] = 'True' then dsf.[FromOrganisation_Name]
else NULL
end   [Compliance_Scheme]*/
,case when csname.name is not null then 'Compliance Scheme' else 'Producer'
end PCS_Or_Direct_Producer
--,dsf.[ComplianceSchemes_Name] Compliance_Scheme
,csname.name Compliance_Scheme
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
,meta.created  [Submission_Date]
,p.[submission_period]
,p.[organisation_id] 
,p.[subsidiary_id] 
,coalesce(dsf.FromOrganisation_CompaniesHouseNumber,dsf.ComplianceSchemes_CompaniesHouseNumber) [CH_Number] -- companies house number 
,dsf.FromOrganisation_NationName [Nation_Of_Enrolment]
,p.[packaging_activity]
,p.[packaging_type]
,p.[packaging_class]
,p.[packaging_material] 
,p.[packaging_sub_material] 
,p.[transitional_packaging_units] /**YM001 : Added new column transitional_packaging_units **/
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
,dsf.ServiceRoles_Role
--,meta.submittedBy
,meta.[SubmittedBy]
,meta.filetype
,dsf.Users_Email
,dsf.Persons_Email
,meta.filename metafile
,cast(p.organisation_id as nvarchar) +
p.filename JOINFIELD
,p.relative_move
--,transfers.NationName
,transfers.TransferNation
,meta.SubmtterEmail
,meta.Service_Name_History as ServiceRoles_Name
,meta.[OriginalFileName]
--,dsf.[from_nation] FromNation
--,dsf.[tonation] ToNation
 FROM [dbo].[t_Pom] p
   join [dbo].[t_rpd_data_SECURITY_FIX] dsf
 on p.[organisation_id]  = dsf.[FromOrganisation_ReferenceNumber] 
left join [dbo].[v_PersonOrganisationConnections] po_con
on po_con.Persons_Id = dsf.Persons_Id  
   join [dbo].[t_cosmos_file_metadata] meta
 on p.filename = meta.filename and (po_con.Users_UserId = meta.userid or meta.ComplianceSchemeId is not null)
left join [rpd].[CompanyDetails] reg on reg.[organisation_id] = p.[organisation_id]
left	join ( select cosmos.filename, cs.name, cs.companieshousenumber
  from [dbo].[t_cosmos_file_metadata] cosmos
  join  dbo.v_rpd_ComplianceSchemes_Active cs on cs.externalid = cosmos.[ComplianceSchemeId]
  group by  cosmos.filename, cs.name,cs.companieshousenumber) csname on csname.filename = p.filename

LEFT JOIN (
    SELECT o.ReferenceNumber AS Producer_ReferenceNumber
    ,n.Name AS TransferNation

    FROM dbo.v_rpd_Organisations_Active o

    JOIN rpd.Nations n
    ON o.TransferNationId = n.Id
) transfers
ON p.organisation_id = transfers.Producer_ReferenceNumber;