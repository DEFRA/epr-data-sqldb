CREATE VIEW [dbo].[v_POM_All_Submissions] AS With vPOM_AS 
As 
(

	select A.*, d.Regulator_Status,	d.Regulator_User_Name,	d.Decision_Date ,	d.Regulator_Rejection_Comments
	,so.SecondOrganisation_ReferenceNumber as SubsidiaryOrganisation_ReferenceNumber
	/***************************************************************************************************
	History:

		Updated 2024-07-23: SN001: Display Org name with Org ID all the packaging reports.
								Ticket 412287 for Release 5.0
	
		Updated 2024-07-08: [Initials]001: [Update text here]

		Updated 2024-11-18: JP001: changed by JP; changed organisation_id to OrgansiationID - ticket 462085

	*****************************************************************************************************/
	from
	(
			SELECT [Org_Name]
			,[Org_Name]  as OrganisationName   /**  SN001: Added  **/
				  ,[PCS_Or_Direct_Producer]
				  ,[Compliance_Scheme]
				  ,[Org_Type]
				  ,[Org_Sub_Type]
				  ,[organisation_size]
				  ,[Submission_Date]
				  ,[submission_period]
				  ,[organisation_id] AS SubmitterID
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
				  ,[organisation_id] OrganisationID -- added TS 12/09/2024
			FROM t_POM_Submissions direct  
			WHERE direct.FileName NOT IN ( SELECT DISTINCT operators.FileName 
											FROM v_POM_Operator_Submissions operators )
 
			UNION
			--add in operator
			SELECT 
				   [Org_Name]
				   ,[Producer_Org_Name] As OrganisationName    /**  SN001: Added  **/
				  ,[PCS_Or_Direct_Producer]
				  ,[Compliance_Scheme]
				  ,[Org_Type]
				  ,[Org_Sub_Type]
				  ,[organisation_size]
				  ,[Submission_Date]
				  ,[submission_period]
				  ,[organisation_id] AS SubmitterID
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
				  ,'' OrganisationID -- added TS 12/09/2024
			FROM v_POM_Operator_Submissions
 
			UNION 

			SELECT
				   [Org_Name]
				   ,[Producer_Org_Name] as OrganisationName    /**  SN001: Added  **/
				  ,[PCS_Or_Direct_Producer]
				  ,[Compliance_Scheme]
				  ,[Org_Type]
				  ,[Org_Sub_Type]
				  ,[organisation_size]
				  ,[Submission_Date]
				  ,[submission_period]
				  ,[organisation_id] AS SubmitterID  /**  SN001: Uncommented  **/
				  ,[organisation_id]
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
				  ,[OriginalFileName]
				  ,'Member'
				  ,[organisation_id_producer] as OrganisationID -- added TS 12/09/2024
				  from v_POM_Operator_Submissions 
			where	[organisation_id_producer] <>   [organisation_id]
					AND compliance_scheme IS NOT NULL
	) A
left join dbo.v_submitted_pom_org_file_status d on d.Filename = A.FileName
LEFT JOIN dbo.v_subsidiaryorganisations so 
	on so.FirstOrganisation_ReferenceNumber = A.OrganisationID
		and ISNULL(trim(so.SubsidiaryId),'') = ISNULL(trim(A.subsidiary_id),'') and ISNULL(trim(so.[SecondOrganisation_CompaniesHouseNumber]), '') = ISNULL(TRIM(A.[CH_Number]), '') -- Added CHN Mapping for the ticket 440955

			and so.RelationToDate is NULL
)
 -- JP001
Select 
	 v.*
	,IsLatest	=	Case When Dense_Rank() Over(Partition By v.submission_period, v.[OrganisationID] Order By v.Submission_Date Desc) = 1 Then 1 Else 0 End
From 
	vPOM_AS v;