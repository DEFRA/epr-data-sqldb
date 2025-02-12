CREATE VIEW [dbo].[v_enrolment_report] AS With enrolmentBase as (

Select 
	 ApprovedPerson_Email
	,ApprovedPerson_FirstName
	,ApprovedPerson_LastName
	,ApprovedPerson_LastUpdatedOn	
	,ApprovedPerson_JobTitle
	,ApprovedPerson_Telephone
	,ComplianceSchemes_Name
	,DelegatedPerson_Email
	,DelegatedPerson_FirstName
	,DelegatedPerson_JobTitle
	,DelegatedPerson_LastName
	,DelegatedPerson_Telephone	
	,DelegatedPersonEnrolment_RelationshipType
	,DelegatedPersonEnrolment_OtherRelationshipDescription
	,Enrolment_CreatedOn_str=Enrolment_CreatedOn 
	,Enrolment_ExternalId
	,Enrolment_Id
	,EnrolmentStatuses_EnrolmentStatus
	,FromOrganisation_CompaniesHouseNumber
	,FromOrganisation_IsComplianceScheme
	,FromOrganisation_Name
	,FromOrganisation_NationName
	,FromOrganisation_ReferenceNumber	
	,FromOrganisation_Type
	,CONVERT(int,Organisations_Id) AS Organisations_Id
	,ServiceRoles_Role	
	,ToOrganisation_IsComplianceScheme
	,ToOrganisation_Name
	,[Status]
	,SelectedSchemes_IsDeleted
	,Regulator_Rejection_Comments
	,CONVERT(DATETIME,substring(Decision_Date,1,23)) AS Decision_Date
	,Regulator_User_Name
	,Case When[FromOrganisation_IsComplianceScheme]=1 Then 'Compliance Scheme' Else 'Producer' End [PCS_or_DP]
	,[Security_Id]
    ,[SecurityQuery]
	,ComplianceSchemes_Id
	,[OrganisationConnections_CreatedOn]
	--,OrganisationConnections_IsDeleted
	,Persons_Id
	

From
	[dbo].[v_rpd_data_SECURITY_FIX_for_enrolment] 

),



/** SN001: Added to get latest Compliance Scheme Name **/
LtstCS as (
			Select Distinct
				 Organisations_Id AS Organisations_Id
				,FromOrganisation_ReferenceNumber AS FromOrganisation_ReferenceNumber_lcs
				,ComplianceSchemes_Name AS ComplianceSchemes_Name_lcs
				,SelectedSchemes_IsDeleted AS SelectedSchemes_IsDeleted_lcs
				,Persons_Id as Persons_Id_1
				,Case When 
					Row_Number () over(partition by [FromOrganisation_ReferenceNumber], Persons_Id Order By ISNULL(SelectedSchemes_IsDeleted, '0') asc, CONVERT(DATETIME,substring([OrganisationConnections_CreatedOn],1,23)) Desc) = 1
						--And Isnull(SelectedSchemes_IsDeleted,0) = 0 
					Then 1 
					Else 0 
				End Is_LatestCS
			From 
				enrolmentBase
),

src as (
		Select 	 
			 eb.*
			
			,Case When Row_Number () over(partition by [FromOrganisation_ReferenceNumber],Persons_Id, SecurityQuery
				Order By isnull(SelectedSchemes_IsDeleted, '0') asc, isnull(Convert(DATETIME,substring(eb.[OrganisationConnections_CreatedOn],1,23)), getdate()) )=1 
					And ISNULL(SelectedSchemes_IsDeleted,0) = 0 
						then 'Latest Enrolment' 
				Else 'Old Enrolment' 
			End IsLatestEnrolment
			
			,Case 
				When ISNULL([ComplianceSchemes_Name],'') <> '' Then 'CS Member'			
			Else 'Direct Producer' End [CSorDP]
			,Enrolment_CreatedOn=CONVERT(DATETIME,substring(eb.[Enrolment_CreatedOn_str],1,23))
			,LtstCS.ComplianceSchemes_Name_lcs AS Latest_ComplianceScheme		/** SN001: Added **/
		From 
			enrolmentBase eb  
		inner Join LtstCS  on eb.FromOrganisation_ReferenceNumber=LtstCS.FromOrganisation_ReferenceNumber_lcs and LtstCS.Is_LatestCS=1 and LtstCS.Persons_Id_1 = eb.Persons_Id
		
)


select * from src;