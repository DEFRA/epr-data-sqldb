CREATE VIEW [dbo].[v_POM_Submissions_POM_Comparison] AS SELECT distinct
[Org_Name]
      ,[PCS_Or_Direct_Producer]
      ,[Compliance_Scheme]
      ,[Org_Type]
      ,''[Org_Sub_Type]
      ,[organisation_size]
      ,[Submission_Date]
      ,[submission_period]
      --,a.[organisation_id] -- Change for the SPs 27/09/20024 to OrganisationID
	  ,a.OrganisationID
      ,a.[subsidiary_id]
      ,[CH_Number]
      ,[Nation_Of_Enrolment]
      ,[packaging_activity]
      ,[packaging_type]
      ,[packaging_class]
      ,[packaging_material]
      ,[packaging_sub_material]
      ,[from_nation]
      ,[to_nation]
      ,[quantity_kg]
      ,[quantity_unit]
      ,[Quantity_kg_extrapolated]
      ,[Quantity_units_extrapolated]
      ,a.[ToOrganisation_NationName]
      ,[Nation]
      ,a.[FromOrganisation_NationName]
      ,a.[FileName]

      ,' '[ServiceRoles_Role]
      ,a.[SubmittedBy]
      ,a.[filetype]
      ,''[Users_Email]
      ,''[Persons_Email]
      ,[metafile]
      ,[JOINFIELD]
      ,[relative_move]
      ,a.[SubmtterEmail]
      ,a.[ServiceRoles_Name]
      ,a.[OriginalFileName]
      , data_type
--,case when r.registration_type_code = 'GR' then 'Group'
 --   when r.registration_type_code = 'IN' then 'Single'
  --  else '' end 
  ,''registration_type_code
FROM dbo.[t_POM_All_Submissions] a;