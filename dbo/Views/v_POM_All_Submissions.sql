CREATE VIEW [dbo].[v_POM_All_Submissions] AS With vPOM_AS 
/***************************************************************************************************
History:

	Updated 2024-07-23: SN001: Display Org name with Org ID all the packaging reports.
							Ticket 412287 for Release 5.0

	Updated: 2024-11-18: YM001:	Ticket - 460891:Adding the new column [transitional_packaging_units]
	Updated 2024-11-18: JP001: changed by JP; changed organisation_id to OrgansiationID - ticket 462085
	Updated 2025-01-22: JP002: ticket 475754; added left join on companydetails to get subsidiary name, added new column
	Updated 2025-07-04: SV003: ticket 576281; Removed subsid retrofit solution
	Updated 2025-08-05: JP003: ticket 596389; reverted submission_date to be file submission date, renamed new col to applicaton submission date
*****************************************************************************************************/
	
As 
(

	select 
			A.Org_Name
			,A.OrganisationName
			,A.PCS_Or_Direct_Producer
			,A.Compliance_Scheme
			,A.Org_Type
			,A.Org_Sub_Type
			,A.organisation_size
			,A.Submission_Date --JP003
			,coalesce(convert(datetime2,d.Application_submitted_ts,127),convert(datetime2,d.Created,127), A.Submission_Date) as Application_Submission_Date --JP003
			,A.submission_period
			,A.SubmitterID
			,A.organisation_id
			,A.subsidiary_id
			,A.CH_Number
			,A.Nation_Of_Enrolment
			,A.packaging_activity
			,A.packaging_type
			,A.packaging_class
			,A.packaging_material
			,A.packaging_sub_material
			,A.transitional_packaging_units
			,A.from_nation
			,A.to_nation
			,A.quantity_kg
			,A.quantity_unit
			,A.Quantity_kg_extrapolated
			,A.Quantity_units_extrapolated
			,A.ToOrganisation_NationName
			,A.Nation
			,A.FromOrganisation_NationName
			,A.FileName
			,A.ServiceRoles_Role
			,A.SubmittedBy
			,A.filetype
			,A.Users_Email
			,A.Persons_Email
			,A.metafile
			,A.JOINFIELD
			,A.relative_move
			,A.TransferNation
			,A.SubmtterEmail
			,A.ServiceRoles_Name
			,A.OriginalFileName
			,A.data_type
			,A.OrganisationID
		, d.Regulator_Status,	d.Regulator_User_Name,	d.Decision_Date ,	d.Regulator_Rejection_Comments
	-- SV001 -,so.SecondOrganisation_ReferenceNumber as SubsidiaryOrganisation_ReferenceNumber
	,Null as subsidiary_name
	
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
				  ,[TransferNation]
				  ,[SubmtterEmail]
				  ,[ServiceRoles_Name]
				  ,[OriginalFileName]
				  ,'Direct' data_type
				  ,[organisation_id] OrganisationID -- added TS 12/09/2024
			FROM dbo.t_POM_Submissions direct  
			WHERE direct.FileName NOT IN ( SELECT DISTINCT operators.FileName 
							FROM dbo.t_POM_Operator_Submissions operators )
 
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
				  ,[TransferNation]
				  ,[SubmtterEmail]
				  ,[ServiceRoles_Name]
				  ,[OriginalFileName], 
				  'Operator'
				  ,CAST(NULL AS INT) AS OrganisationID -- added TS 12/09/2024
			FROM dbo.t_POM_Operator_Submissions
 
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
				  ,'Member'
				  ,[organisation_id_producer] as OrganisationID -- added TS 12/09/2024
				  from dbo.t_POM_Operator_Submissions 
			where	[organisation_id_producer] <>   [organisation_id]
					AND compliance_scheme IS NOT NULL
	) A
left join dbo.v_submitted_pom_org_file_status d on d.Filename = A.FileName
--SV001- LEFT JOIN dbo.v_subsidiaryorganisations so 
--	on so.FirstOrganisation_ReferenceNumber = A.OrganisationID
--		and ISNULL(trim(so.SubsidiaryId),'') = ISNULL(trim(A.subsidiary_id),'') and ISNULL(trim(so.[SecondOrganisation_CompaniesHouseNumber]), '') = ISNULL(TRIM(A.[CH_Number]), '') -- Added CHN Mapping for the ticket 440955

--			and so.RelationToDate is NULL
/** JP002 added join on company details table to get subsidiary name **/
--left join rpd.CompanyDetails cd on cd.organisation_id = A.OrganisationID
--and ISNULL((cd.subsidiary_id),'') = ISNULL((A.subsidiary_id),'')
)
 -- JP001
Select 
	 v.*
	,IsLatest	=	Case When Dense_Rank() Over(Partition By v.submission_period, v.[OrganisationID] Order By v.Submission_Date Desc) = 1 Then 1 Else 0 End
From 
	vPOM_AS v;