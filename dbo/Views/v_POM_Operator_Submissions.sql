CREATE VIEW [dbo].[v_POM_Operator_Submissions] AS SELECT DISTINCT replacement.name AS [Org_Name],
 original.org_name AS [Producer_Org_Name]
    ,original.[PCS_Or_Direct_Producer]
 --   ,csname.name Compliance_Scheme
 ,original.Compliance_Scheme
    ,original.[Org_Type]
    ,original.[Org_Sub_Type]
    ,original.[organisation_size]
    ,original.[Submission_Date]
    ,original.[submission_period]
--   ,replacement.referenceNumber AS [organisation_id_operator]
	,original.[organisation_id] AS [organisation_id_producer]
	 ,replacement.referenceNumber AS organisation_id
    ,original.[subsidiary_id]
    ,original.[CH_Number]
    ,original.[Nation_Of_Enrolment]
    ,original.[packaging_activity]
    ,original.[packaging_type]
    ,original.[packaging_class]
    ,original.[packaging_material]
    ,original.[packaging_sub_material]
    ,original.[from_nation]
    ,original.[to_nation]
    ,original.[quantity_kg]
    ,original.[quantity_unit]
    ,original.[Quantity_kg_extrapolated]
    ,original.[Quantity_units_extrapolated]
    ,original.[ToOrganisation_NationName]
    ,original.[Nation]
    ,original.[FromOrganisation_NationName]
    ,original.[FileName]
    ,original.[ServiceRoles_Role]
    ,original.[SubmittedBy]
    ,original.[filetype]
    ,original.[Users_Email]
    ,original.[Persons_Email]
    ,original.[metafile]
    ,original.[JOINFIELD]
    ,original.[relative_move]
    ,original.TransferNation
    ,original.[SubmtterEmail]
    ,original.[ServiceRoles_Name]
    ,original.[OriginalFileName]
	--,original.trading_name
	--,original.registered_addr_line1
--,original.registered_addr_line2
--,original.registered_city
--,original.registered_addr_country
--,original.registered_addr_postcode
FROM [dbo].[t_POM_Submissions] original
	 join ( select cosmos.filename, cs.name, cs.companieshousenumber
  from [dbo].[v_cosmos_file_metadata] cosmos
  join  dbo.v_rpd_ComplianceSchemes_Active cs on cs.externalid = cosmos.[ComplianceSchemeId]
  group by  cosmos.filename, cs.name,cs.companieshousenumber) csname on csname.filename = original.filename
--     JOIN v_Producer_CS_Lookup replacement
--    ON original.organisation_id = replacement.Producer_Id;
join dbo.v_rpd_Organisations_Active replacement on replacement.companieshousenumber = csname.companieshousenumber;