CREATE VIEW [dbo].[v_POM_All_Submissions] AS With vPOM_AS As 
(

select A.*, d.Regulator_Status,	d.Regulator_User_Name,	d.Decision_Date ,	d.Regulator_Rejection_Comments
/***************************************************************************************************
History:

	Updated 2024-07-23: SN001: Display Org name with Org ID all the packaging reports.
							Ticket 412287 for Release 5.0
	
	Updated 2024-07-08: [Initials]001: [Update text here]

*****************************************************************************************************/
from
(
		SELECT [Org_Name]
		,MemberName		= [Org_Name]  /**  SN001: Added  **/
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
			   ,MemberName		=  [Producer_Org_Name] /**  SN001: Added  **/
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
			   ,MemberName		= [Producer_Org_Name]  /**  SN001: Added  **/
			  ,[PCS_Or_Direct_Producer]
			  ,[Compliance_Scheme]
			  ,[Org_Type]
			  ,[Org_Sub_Type]
			  ,[organisation_size]
			  ,[Submission_Date]
			  ,[submission_period]
			        ,[organisation_id]  /**  SN001: Uncommented  **/
			  --,[organisation_id_producer] /**  SN001: commented  **/
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
) A
left join dbo.v_submitted_pom_org_file_status d on d.Filename = A.FileName
)

Select 
	 v.*
	,IsLatest	=	Case When Dense_Rank() Over(Partition By v.submission_period, v.organisation_id Order By v.Submission_Date Desc) = 1 Then 1 Else 0 End
From 
	vPOM_AS v;