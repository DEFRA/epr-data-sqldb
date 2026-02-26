CREATE VIEW [dbo].[v_POM_Submissions_POM_Comparison] AS SELECT distinct
/****************************************************************************************************************************
	History:
 
	Updated: 2025-10-27:	JP001:  Ticket - 608994:	Adding ram_rag_rating column and plastic subtypes to packaging material column for modulation

******************************************************************************************************************************/
		[Org_Name]
      ,[PCS_Or_Direct_Producer]
      ,[Compliance_Scheme]
      ,[Org_Type]
      ,'' [Org_Sub_Type]
      ,[organisation_size]
      ,[Submission_Date]
      ,[submission_period]
      --,[organisation_id] -- Change for the SPs 27/09/20024 to OrganisationID
	  ,OrganisationID
      ,[subsidiary_id]
      ,[CH_Number]
      ,[Nation_Of_Enrolment]
      ,[packaging_activity]
      ,[packaging_type]
      ,[packaging_class]
      --,[packaging_material]
	  ,CASE WHEN [packaging_material] = 'Plastic' and [packaging_sub_material] = 'Flexible' THEN 'Plastic - Flexible'
			WHEN [packaging_material] = 'Plastic' and [packaging_sub_material] = 'Rigid' THEN 'Plastic - Rigid'
			ELSE [packaging_material] 
		END as [packaging_material] --JP001
      ,[packaging_sub_material]
      ,[from_nation]
      ,[to_nation]
      ,[quantity_kg]
      ,[quantity_unit]
      ,[Quantity_kg_extrapolated]
      ,[Quantity_units_extrapolated]
	  ,[ram_rag_rating] --JP001
      ,[ToOrganisation_NationName]
      ,[Nation]
      ,[FromOrganisation_NationName]
      ,[FileName]
      ,' ' [ServiceRoles_Role]
      ,[SubmittedBy]
      ,[filetype]
      ,'' [Users_Email]
      ,'' [Persons_Email]
      ,[metafile]
      ,[JOINFIELD]
      ,[relative_move]
      ,[SubmtterEmail]
      ,[ServiceRoles_Name]
      ,[OriginalFileName]
      , data_type
	  ,''registration_type_code
	  ,[Regulator_Status]
FROM dbo.[t_POM_All_Submissions];