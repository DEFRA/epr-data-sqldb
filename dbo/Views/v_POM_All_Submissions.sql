CREATE VIEW [dbo].[v_POM_All_Submissions] AS With vPOM_AS As 
(
SELECT [Org_Name]
      ,[PCS_Or_Direct_Producer]
      ,[Compliance_Scheme]
      ,[Org_Type]
      ,[Org_Sub_Type]
      ,[organisation_size]
      ,[Submission_Date]
      ,[submission_period]
      ,[organisation_id]
      ,[subsidiary_id]
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
      ,[TransferNation]
      ,[SubmtterEmail]
      ,[ServiceRoles_Name]
      ,[OriginalFileName]
      ,'Direct' data_type
FROM t_POM_Submissions direct
WHERE direct.FileName NOT IN ( SELECT DISTINCT operators.FileName 
								FROM v_POM_Operator_Submissions operators )
 
UNION
--add in operator
SELECT 
       [Org_Name]
      ,[PCS_Or_Direct_Producer]
      ,[Compliance_Scheme]
      ,[Org_Type]
      ,[Org_Sub_Type]
      ,[organisation_size]
      ,[Submission_Date]
      ,[submission_period]
      ,[organisation_id]
      ,[subsidiary_id]
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
      ,[TransferNation]
      ,[SubmtterEmail]
      ,[ServiceRoles_Name]
      ,[OriginalFileName], 
	  'Operator'
FROM v_POM_Operator_Submissions
 
UNION 

SELECT
       [Org_Name]
      ,[PCS_Or_Direct_Producer]
      ,[Compliance_Scheme]
      ,[Org_Type]
      ,[Org_Sub_Type]
      ,[organisation_size]
      ,[Submission_Date]
      ,[submission_period]
	 --       ,[organisation_id]
      ,[organisation_id_producer]
      ,[subsidiary_id]
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
      ,[OriginalFileName] ,
	  'Member'
	  from v_POM_Operator_Submissions 
where	[organisation_id_producer] <>   [organisation_id]
		AND compliance_scheme IS NOT NULL
		)

		Select 
	 v.*
/** BL/SN:  Added IsLatest based on v_POM.Is_Latest  **/
	,IsLatest	=	Case When Dense_Rank() Over(Partition By v.submission_period, v.organisation_id Order By v.Submission_Date Desc) = 1 Then 1 Else 0 End
From 
	vPOM_AS v;