CREATE VIEW [dbo].[v_POM_Operator_Submissions] AS WITH original AS (SELECT
	org_name AS [Producer_Org_Name]
    ,[PCS_Or_Direct_Producer]
	,Compliance_Scheme
    ,[Org_Type]
    ,[Org_Sub_Type]
    ,[organisation_size]
    ,[Submission_Date]
    ,[submission_period]
	,[organisation_id] AS [organisation_id_producer]
	 --ement.referenceNumber AS organisation_id
    ,[subsidiary_id]
    ,[CH_Number]
    ,[Nation_Of_Enrolment]
    ,[packaging_activity]
    ,[packaging_type]
    ,[packaging_class]
    ,[packaging_material]
    ,[packaging_sub_material]
	,[transitional_packaging_units] /**YM001 : Added new column transitional_packaging_units **/
    ,[from_nation]
    ,[to_nation]
    ,[quantity_kg]
    ,[quantity_unit]
    ,[Quantity_kg_extrapolated]
    ,[Quantity_units_extrapolated]
    ,[ToOrganisation_NationName]
    ,[Nation]
    ,[FromOrganisation_NationName]
    ,[FileName]
    ,[ServiceRoles_Role]
    ,[SubmittedBy]
    ,[filetype]
    ,[Users_Email]
    ,[Persons_Email]
    ,[metafile]
    ,[JOINFIELD]
    ,[relative_move]
    ,TransferNation
    ,[SubmtterEmail]
    ,[ServiceRoles_Name]
    ,[OriginalFileName]
	
FROM [dbo].[t_POM_Submissions]
),

csname as (
select cosmos.filename, cs.name, cs.companieshousenumber
  from [dbo].[t_cosmos_file_metadata] cosmos
  join  dbo.v_rpd_ComplianceSchemes_Active cs on cs.externalid = cosmos.[ComplianceSchemeId]
  group by  cosmos.filename, cs.name,cs.companieshousenumber
 )

select original.*, 
replacement.referenceNumber AS organisation_id,
replacement.name AS [Org_Name]
FROM original 
JOIN csname on csname.filename = original.filename
JOIN dbo.v_rpd_Organisations_Active replacement on replacement.companieshousenumber = csname.companieshousenumber;