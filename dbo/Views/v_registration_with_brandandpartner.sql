CREATE VIEW [dbo].[v_registration_with_brandandpartner] AS WITH 

CompanyDetails_with_regid AS
(
select 
	c_meta.RegistrationSetId,c.* 
from [rpd].[CompanyDetails] c
	join [rpd].[cosmos_file_metadata] c_meta 
		on c_meta.filename = c.filename
),
Brands_with_regid AS
(
select 
	b_meta.RegistrationSetId,b.* 
From [rpd].[Brands] b
	join [rpd].[cosmos_file_metadata] b_meta 
		on b_meta.filename = b.filename
),
Partnerships_with_regid AS
(
select 
	p_meta.RegistrationSetId,p.* 
From [rpd].[Partnerships] p
	join [rpd].[cosmos_file_metadata] p_meta 
		on p_meta.filename = p.filename
)



SELECT distinct 

/****************************************************************************************************************************

	History:

	Updated: 2024-11-18:	BL001:	Ticket - 460892:	Adding the new column [organisation_size]

******************************************************************************************************************************/

 


rbp.*
,so.SecondOrganisation_ReferenceNumber as SubsidiaryOrganisation_ReferenceNumber
,b.[Organisations_Id]
,b.[FromOrganisation_TypeId]
,b.[FromOrganisation_Type]
,b.[FromOrganisation_CompaniesHouseNumber]
,b.[FromOrganisation_Name]
,b.[FromOrganisation_TradingName]
,b.[FromOrganisation_ReferenceNumber]
,b.[FromOrganisation_SubBuildingName]
,b.[FromOrganisation_BuildingName]
,b.[FromOrganisation_BuildingNumber]
,b.[FromOrganisation_Street]
,b.[FromOrganisation_Locality]
,b.[FromOrganisation_DependentLocality]
,b.[FromOrganisation_Town]
,b.[FromOrganisation_County]
,b.[FromOrganisation_Country]
,b.[FromOrganisation_Postcode]
,b.[FromOrganisation_ValidatedWithCompaniesHouse]
,b.[FromOrganisation_IsComplianceScheme]
,b.[FromOrganisation_NationId]
,b.[Organisations_CreatedOn]
,b.[FromOrganisation_IsDeleted]
,b.[FromOrganisation_ProducerTypeId]
,b.[FromOrganisation_TransferNationId]
,b.[ToOrganisation_TypeId]
,b.[ToOrganisation_Type]
,b.[ToOrganisation_CompaniesHouseNumber]
,b.[ToOrganisation_Name]
,b.[ToOrganisation_TradingName]
,b.[ToOrganisation_ReferenceNumber]
,b.[ToOrganisation_SubBuildingName]
,b.[ToOrganisation_BuildingName]
,b.[ToOrganisation_BuildingNumber]
,b.[ToOrganisation_Street]
,b.[ToOrganisation_Locality]
,b.[ToOrganisation_DependentLocality]
,b.[ToOrganisation_Town]
,b.[ToOrganisation_County]
,b.[ToOrganisation_Country]
,b.[ToOrganisation_Postcode]
,b.[ToOrganisation_ValidatedWithCompaniesHouse]
,b.[ToOrganisation_IsComplianceScheme]
,b.[ToOrganisation_NationId]
,b.[ToOrganisation_IsDeleted]
,b.[ToOrganisation_ProducerTypeId]
,b.[ToOrganisation_TransferNationId]
,b.[OrganisationConnections_Id]
,b.[OrganisationConnections_FromOrganisationId]
,b.[OrganisationConnections_FromOrganisationRoleId]
,b.[OrganisationConnections_ToOrganisationId]
,b.[OrganisationConnections_ToOrganisationRoleId]
,b.[OrganisationConnections_CreatedOn]
,b.[OrganisationConnections_LastUpdatedOn]
,b.[OrganisationConnections_IsDeleted]
,b.[SelectedSchemes_Id]
,b.[SelectedSchemes_OrganisationConnectionId]
,b.[SelectedSchemes_ComplianceSchemeId]
,b.[SelectedSchemes_CreatedOn]
,b.[SelectedSchemes_LastUpdatedOn]
,b.[SelectedSchemes_IsDeleted]
,d.[id] as ComplianceSchemes_Id
,d.[name] as ComplianceSchemes_Name
,b.[ComplianceSchemes_CreatedOn]
,b.[ComplianceSchemes_LastUpdatedOn]
,b.[ComplianceSchemes_IsDeleted]
,b.[ComplianceSchemes_CompaniesHouseNumber]
,b.[InterOrganisationRoles_FromOrganisationRole]
,b.[InterOrganisationRoles_ToOrganisationRole]
,b.[PersonOrganisationConnections_Id]
,b.[PersonOrganisationConnections_OrganisationId]
,b.[PersonOrganisationConnections_JobTitle]
,b.[PersonOrganisationConnections_ExternalId]
,b.[PersonOrganisationConnections_CreatedOn]
,b.[PersonOrganisationConnections_LastUpdatedOn]
,b.[PersonOrganisationConnections_IsDeleted]
,b.[OrganisationToPersonRoles_Role]
,b.[PersonInOrganisationRoles_Role]
,b.[Persons_Id]
,b.[Persons_FirstName]
,b.[Persons_LastName]
,b.[Persons_Email]
,b.[Persons_Telephone]
,b.[Persons_CreatedOn]
,b.[Persons_LastUpdatedOn]
,b.[Persons_IsDeleted]
,b.[Users_Email]
,b.[Users_IsDeleted]
,b.[Users_InviteToken]
,b.[Users_InvitedBy]
,b.[Enrolment_Id]
,b.[Enrolment_ConnectionId]
,b.[Enrolment_ServiceRoleId]
,b.[Enrolment_ValidFrom]
,b.[Enrolment_ValidTo]
,b.[Enrolment_ExternalId]
,b.[Enrolment_CreatedOn]
,b.[Enrolment_LastUpdatedOn]
,b.[Enrolment_IsDeleted]
,b.[Enrolment_RegulatorCommentId]
,b.[EnrolmentStatuses_EnrolmentStatus]
,b.[ServiceRoles_Id]
,b.[ServiceRoles_ServiceId]
,b.[ServiceRoles_Key]
,b.[ServiceRoles_Role]
,b.[ServiceRoles_Description]
,b.[Services_Key]
,b.[Services_Service]
,b.[Services_Description]
,b.[DelegatedPersonEnrolment_RelationshipType]
,b.[DelegatedPersonEnrolment_ConsultancyName]
,b.[DelegatedPersonEnrolment_ComplianceSchemeName]
,b.[DelegatedPersonEnrolment_OtherOrganisationNation]
,b.[DelegatedPersonEnrolment_OtherRelationshipDescription]
,b.[DelegatedPersonEnrolment_NominatorDeclaration]
,b.[DelegatedPersonEnrolment_NominatorDeclarationTime]
,b.[DelegatedPersonEnrolment_NomineeDeclaration]
,b.[DelegatedPersonEnrolment_NomineeDeclarationTime]
,b.[DelegatedPersonEnrolment_CreatedOn]
,b.[DelegatedPersonEnrolment_LastUpdatedOn]
,b.[DelegatedPersonEnrolment_IsDeleted]
,b.[NominatedDelegatedPersonEnrolment_RelationshipType]
,b.[NominatedDelegatedPersonEnrolment_ConsultancyName]
,b.[NominatedDelegatedPersonEnrolment_ComplianceSchemeName]
,b.[NominatedDelegatedPersonEnrolment_OtherOrganisationNation]
,b.[NominatedDelegatedPersonEnrolment_OtherRelationshipDescription]
,b.[NominatedDelegatedPersonEnrolment_NominatorDeclaration]
,b.[NominatedDelegatedPersonEnrolment_NominatorDeclarationTime]
,b.[NominatedDelegatedPersonEnrolment_NomineeDeclaration]
,b.[NominatedDelegatedPersonEnrolment_NomineeDeclarationTime]
,b.[NominatedDelegatedPersonEnrolment_CreatedOn]
,b.[NominatedDelegatedPersonEnrolment_LastUpdatedOn]
,b.[NominatedDelegatedPersonEnrolment_IsDeleted]
,b.[FromOrganisation_NationName]
,b.[ToOrganisation_NationName]
,b.[Security_Id]
,b.[SecurityQuery]
,b.[SecurityQuery_OrganisationOrigin]
,b.[ApprovedPerson_Id]
,b.[ApprovedPerson_FirstName]
,b.[ApprovedPerson_LastName]
,b.[ApprovedPerson_Email]
,b.[ApprovedPerson_Telephone]
,b.[ApprovedPerson_CreatedOn]
,b.[ApprovedPerson_LastUpdatedOn]
,b.[ApprovedPerson_IsDeleted]
,b.[ApprovedPerson_JobTitle]
,b.[DelegatedPerson_Id]
,b.[DelegatedPerson_FirstName]
,b.[DelegatedPerson_LastName]
,b.[DelegatedPerson_Email]
,b.[DelegatedPerson_Telephone]
,b.[DelegatedPerson_CreatedOn]
,b.[DelegatedPerson_LastUpdatedOn]
,b.[DelegatedPerson_IsDeleted]
,b.[DelegatedPerson_JobTitle]

,c.[SubmissionId]
,c.[FileId]
,c.[UserId]
--,c.[SubmittedBy]
,c.[SubmittedBy]
,c.[BlobName]
,c.[BlobContainerName]
,c.[FileType]
,c.[Created]
,c.[OriginalFileName]
,c.[OrganisationId]
,c.[DataSourceType]
,c.[SubmissionPeriod]
,c.[IsSubmitted]
,c.[SubmissionType]
,c.[TargetDirectoryName]
,c.[TargetContainerName]
,c.[SourceContainerName]
,c.[FileName] as cosmos_file_name
,c.[load_ts] as cosmos_load_ts
,c.SubmtterEmail
,c.ServiceRoles_Name
,pos.Decision_Date
,pos.[Regulator_Status]
,pos.[Regulator_User_Name]
,pos.[Regulator_Rejection_Comments]

FROM
--1 Brand mapping
(
SELECT 
a.[organisation_id]
,a.[subsidiary_id]
,a.[organisation_name]
,a.[trading_name]
,a.[companies_house_number]
,a.[home_nation_code]
,a.[main_activity_sic]
,a.[organisation_type_code]
,a.[organisation_sub_type_code]
,a.[packaging_activity_so]
,a.[packaging_activity_pf]
,a.[packaging_activity_im]
,a.[packaging_activity_se]
,a.[packaging_activity_hl]
,a.[packaging_activity_om]
,a.[packaging_activity_sl]
,a.[registration_type_code]
,a.[turnover]
,a.[total_tonnage]
,a.[produce_blank_packaging_flag]
,a.[liable_for_disposal_costs_flag]
,a.[meet_reporting_requirements_flag]
,a.[registered_addr_line1]
,a.[registered_addr_line2]
,a.[registered_city]
,a.[registered_addr_county]
,a.[registered_addr_postcode]
,a.[registered_addr_country]
,a.[registered_addr_phone_number]
,a.[audit_addr_line1]
,a.[audit_addr_line2]
,a.[audit_addr_city]
,a.[audit_addr_county]
,a.[audit_addr_postcode]
,a.[audit_addr_country]
,a.[service_of_notice_addr_line1]
,a.[service_of_notice_addr_line2]
,a.[service_of_notice_addr_city]
,a.[service_of_notice_addr_county]
,a.[service_of_notice_addr_postcode]
,a.[service_of_notice_addr_country]
,a.[service_of_notice_addr_phone_number]
,a.[principal_addr_line1]
,a.[principal_addr_line2]
,a.[principal_addr_city]
,a.[principal_addr_county]
,a.[principal_addr_postcode]
,a.[principal_addr_country]
,a.[principal_addr_phone_number]
,a.[sole_trader_first_name]
,a.[sole_trader_last_name]
,a.[sole_trader_phone_number]
,a.[sole_trader_email]
,a.[approved_person_first_name]
,a.[approved_person_last_name]
,a.[approved_person_phone_number]
,a.[approved_person_email]
,a.[approved_person_job_title]
,a.[delegated_person_first_name]
,a.[delegated_person_last_name]
,a.[delegated_person_phone_number]
,a.[delegated_person_email]
,a.[delegated_person_job_title]
,a.[primary_contact_person_first_name]
,a.[primary_contact_person_last_name]
,a.[primary_contact_person_phone_number]
,a.[primary_contact_person_email]
,a.[primary_contact_person_job_title]
,a.[secondary_contact_person_first_name]
,a.[secondary_contact_person_last_name]
,a.[secondary_contact_person_phone_number]
,a.[secondary_contact_person_email]
,a.[secondary_contact_person_job_title]
,a.[load_ts]
,a.[FileName]
,a.[organisation_size]     /** BL001 new column added **/  

--,br.[organisation_id]
--,br.[subsidiary_id]
,br.[brand_name]
,br.[brand_type_code]
--,br.[load_ts]
--,br.[FileName]

--,null as [partner organisation_id]
--,null as [partner subsidiary_id]
,null as [partner_first_name]
,null as [partner_last_name]
,null as [partner_phone_number]
,null as [partner_email]
--,null as [partner load_ts]
--,null as [partner FileName]

FROM CompanyDetails_with_regid a -- Registration
join Brands_with_regid br on br.organisation_id = a.organisation_id
and ISNULL(a.[subsidiary_id],'') = ISNULL(br.[subsidiary_id],'')
and a.RegistrationSetId = br.RegistrationSetId

union all
--2 Partnerships mapping
SELECT 
a.[organisation_id]
,a.[subsidiary_id]
,a.[organisation_name]
,a.[trading_name]
,a.[companies_house_number]
,a.[home_nation_code]
,a.[main_activity_sic]
,a.[organisation_type_code]
,a.[organisation_sub_type_code]
,a.[packaging_activity_so]
,a.[packaging_activity_pf]
,a.[packaging_activity_im]
,a.[packaging_activity_se]
,a.[packaging_activity_hl]
,a.[packaging_activity_om]
,a.[packaging_activity_sl]
,a.[registration_type_code]
,a.[turnover]
,a.[total_tonnage]
,a.[produce_blank_packaging_flag]
,a.[liable_for_disposal_costs_flag]
,a.[meet_reporting_requirements_flag]
,a.[registered_addr_line1]
,a.[registered_addr_line2]
,a.[registered_city]
,a.[registered_addr_county]
,a.[registered_addr_postcode]
,a.[registered_addr_country]
,a.[registered_addr_phone_number]
,a.[audit_addr_line1]
,a.[audit_addr_line2]
,a.[audit_addr_city]
,a.[audit_addr_county]
,a.[audit_addr_postcode]
,a.[audit_addr_country]
,a.[service_of_notice_addr_line1]
,a.[service_of_notice_addr_line2]
,a.[service_of_notice_addr_city]
,a.[service_of_notice_addr_county]
,a.[service_of_notice_addr_postcode]
,a.[service_of_notice_addr_country]
,a.[service_of_notice_addr_phone_number]
,a.[principal_addr_line1]
,a.[principal_addr_line2]
,a.[principal_addr_city]
,a.[principal_addr_county]
,a.[principal_addr_postcode]
,a.[principal_addr_country]
,a.[principal_addr_phone_number]
,a.[sole_trader_first_name]
,a.[sole_trader_last_name]
,a.[sole_trader_phone_number]
,a.[sole_trader_email]
,a.[approved_person_first_name]
,a.[approved_person_last_name]
,a.[approved_person_phone_number]
,a.[approved_person_email]
,a.[approved_person_job_title]
,a.[delegated_person_first_name]
,a.[delegated_person_last_name]
,a.[delegated_person_phone_number]
,a.[delegated_person_email]
,a.[delegated_person_job_title]
,a.[primary_contact_person_first_name]
,a.[primary_contact_person_last_name]
,a.[primary_contact_person_phone_number]
,a.[primary_contact_person_email]
,a.[primary_contact_person_job_title]
,a.[secondary_contact_person_first_name]
,a.[secondary_contact_person_last_name]
,a.[secondary_contact_person_phone_number]
,a.[secondary_contact_person_email]
,a.[secondary_contact_person_job_title]
,a.[load_ts]
,a.[FileName]
,a.[organisation_size]   /** BL001 new column added **/  


--,null as [brand organisation_id]
--,null as [brand subsidiary_id]
,null as [brand_name]
,null as [brand brand_type_code]
--,null as [brand load_ts]
--,null as [brand FileName]

--,p.[organisation_id]
--,p.[subsidiary_id]
,p.[partner_first_name]
,p.[partner_last_name]
,p.[partner_phone_number]
,p.[partner_email]
--,p.[load_ts]
--,p.[FileName]

FROM CompanyDetails_with_regid a -- Registration
join Partnerships_with_regid p on p.organisation_id = a.organisation_id
and ISNULL(a.[subsidiary_id],'') = ISNULL(p.[subsidiary_id],'')
and a.RegistrationSetId = p.RegistrationSetId

union all

--3 Org does not match with Brand and Partnership
SELECT 
a.[organisation_id]
,a.[subsidiary_id]
,a.[organisation_name]
,a.[trading_name]
,a.[companies_house_number]
,a.[home_nation_code]
,a.[main_activity_sic]
,a.[organisation_type_code]
,a.[organisation_sub_type_code]
,a.[packaging_activity_so]
,a.[packaging_activity_pf]
,a.[packaging_activity_im]
,a.[packaging_activity_se]
,a.[packaging_activity_hl]
,a.[packaging_activity_om]
,a.[packaging_activity_sl]
,a.[registration_type_code]
,a.[turnover]
,a.[total_tonnage]
,a.[produce_blank_packaging_flag]
,a.[liable_for_disposal_costs_flag]
,a.[meet_reporting_requirements_flag]
,a.[registered_addr_line1]
,a.[registered_addr_line2]
,a.[registered_city]
,a.[registered_addr_county]
,a.[registered_addr_postcode]
,a.[registered_addr_country]
,a.[registered_addr_phone_number]
,a.[audit_addr_line1]
,a.[audit_addr_line2]
,a.[audit_addr_city]
,a.[audit_addr_county]
,a.[audit_addr_postcode]
,a.[audit_addr_country]
,a.[service_of_notice_addr_line1]
,a.[service_of_notice_addr_line2]
,a.[service_of_notice_addr_city]
,a.[service_of_notice_addr_county]
,a.[service_of_notice_addr_postcode]
,a.[service_of_notice_addr_country]
,a.[service_of_notice_addr_phone_number]
,a.[principal_addr_line1]
,a.[principal_addr_line2]
,a.[principal_addr_city]
,a.[principal_addr_county]
,a.[principal_addr_postcode]
,a.[principal_addr_country]
,a.[principal_addr_phone_number]
,a.[sole_trader_first_name]
,a.[sole_trader_last_name]
,a.[sole_trader_phone_number]
,a.[sole_trader_email]
,a.[approved_person_first_name]
,a.[approved_person_last_name]
,a.[approved_person_phone_number]
,a.[approved_person_email]
,a.[approved_person_job_title]
,a.[delegated_person_first_name]
,a.[delegated_person_last_name]
,a.[delegated_person_phone_number]
,a.[delegated_person_email]
,a.[delegated_person_job_title]
,a.[primary_contact_person_first_name]
,a.[primary_contact_person_last_name]
,a.[primary_contact_person_phone_number]
,a.[primary_contact_person_email]
,a.[primary_contact_person_job_title]
,a.[secondary_contact_person_first_name]
,a.[secondary_contact_person_last_name]
,a.[secondary_contact_person_phone_number]
,a.[secondary_contact_person_email]
,a.[secondary_contact_person_job_title]
,a.[load_ts]
,a.[FileName]
,a.[organisation_size]    /** BL001 new column added **/  

--,br.[organisation_id]
--,br.[subsidiary_id]
,br.[brand_name]
,br.[brand_type_code]
--,br.[load_ts]
--,br.[FileName]

--,p.[organisation_id]  
--,p.[subsidiary_id]
,p.[partner_first_name]
,p.[partner_last_name]
,p.[partner_phone_number]
,p.[partner_email]
--,p.[load_ts]
--,p.[FileName]



FROM CompanyDetails_with_regid a -- Registration

left join Brands_with_regid br 
	on br.organisation_id = a.organisation_id
		and ISNULL(a.[subsidiary_id],'') = ISNULL(br.[subsidiary_id],'') 
			and a.RegistrationSetId = br.RegistrationSetId

left join Partnerships_with_regid p 
	on p.organisation_id = a.organisation_id
		and ISNULL(a.[subsidiary_id],'') = ISNULL(p.[subsidiary_id],'') 
			and a.RegistrationSetId = p.RegistrationSetId


where br.[brand_name] is null and  br.[subsidiary_id] is null 
and  p.[partner_first_name] is null and  p.[subsidiary_id] is null 

) as rbp

JOIN [v_rpd_data_SECURITY_FIX] b ON rbp.organisation_id = b.FromOrganisation_ReferenceNumber --Enrolment
JOIN [dbo].[v_cosmos_file_metadata] c ON rbp.FileName = c.FileName
LEFT JOIN dbo.v_rpd_ComplianceSchemes_Active	 d ON c.ComplianceSchemeId = d.externalid
LEFT JOIN [dbo].[v_submitted_pom_org_file_status] pos on pos.filename = rbp.filename
LEFT JOIN dbo.v_subsidiaryorganisations so 
	on so.FirstOrganisation_ReferenceNumber = rbp.organisation_id
		and ISNULL(trim(so.SubsidiaryId),'') = ISNULL(trim(rbp.subsidiary_id),'') and ISNULL(TRIM(so.[SecondOrganisation_CompaniesHouseNumber]), '') = ISNULL(TRIM(rbp.[companies_house_number]), '')
			and so.RelationToDate is NULL;