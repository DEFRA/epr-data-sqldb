CREATE VIEW [dbo].[v_enrolment_report] AS With enrolmentBase As (
Select 
	 ApprovedPerson_Email
	,ApprovedPerson_FirstName
	,ApprovedPerson_LastName
	,ApprovedPerson_LastUpdatedOn	
	,ApprovedPerson_JobTitle
	,ApprovedPerson_Telephone
	,ComplianceSchemes_LastUpdatedOn
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
	,Organisations_Id=convert(int,Organisations_Id)
	,ServiceRoles_Role	
	,ToOrganisation_IsComplianceScheme
	,ToOrganisation_Name
	,[Status]
	,Regulator_Rejection_Comments
	,Decision_Date=CONVERT(DATETIME,substring(Decision_Date,1,23))
	,Regulator_User_Name
	,[PCS_or_DP]	= Case When[FromOrganisation_IsComplianceScheme]=1 Then 'Compliance Scheme' Else 'Producer' End
From
	[dbo].[t_rpd_data_SECURITY_FIX]
)
Select 	 
	 eb.*
	,IsLatestCS		= Case When Dense_Rank() over(partition by [FromOrganisation_ReferenceNumber] Order By Convert(Date,CONVERT(DATETIME,substring([Enrolment_CreatedOn_str],1,23))) Desc)=1 then 'Latest Enrolemnt' Else 'Old Enrolemnt' End
	,[CSorDP]		= Case When ISNULL([ComplianceSchemes_Name],'') <> '' Then 'CS Member' Else 'Direct Producer' End 
	,Enrolment_CreatedOn=CONVERT(DATETIME,substring([Enrolment_CreatedOn_str],1,23))
From 
	enrolmentBase eb;