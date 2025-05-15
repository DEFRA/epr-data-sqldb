CREATE VIEW [dbo].[v_BrndPrtnr_Org_Submissions] AS With 
/****************************************************************************************************************************
	History:

	Created: 2025-03-17:	SN001:	Ticket - 520218:	Organisation Submissions with Brand and Partner.  Added Relevant Year Column
														Reduced columns to ones only used in PBI

	Updated: 2025-04-14:	YM002:	Ticket - 537082:	Organisation Details report to include the 4 new columns added in the Org file for DP and CS
	Updated: 2025-05-14:	PM004	Ticket - 552117: Rel 9/10 - Resubmission date -  Taking uplodded date not submitted date
******************************************************************************************************************************/
CompanyDetails_with_regid	As
(
	Select	c_meta.RegistrationSetId,c.* 
	From	[rpd].[CompanyDetails]			c
	Join	[rpd].[cosmos_file_metadata]	c_meta	on c_meta.[Filename] = c.[Filename]
),
Brands_with_regid			As
(
	Select 	b_meta.RegistrationSetId,b.* 
	From	[rpd].[Brands]					b
	Join	[rpd].[cosmos_file_metadata]	b_meta	on b_meta.[Filename] = b.[Filename]
),
Partner_with_regid			As
(
	Select	p_meta.RegistrationSetId,p.* 
	From	[rpd].[Partnerships]			p
	Join	[rpd].[cosmos_file_metadata]	p_meta	on p_meta.[Filename] = p.[Filename]
),
BrPaUn						As 
(
	Select
		 cd.organisation_id
		,cd.subsidiary_id
		,cd.RegistrationSetId
		,br.brand_name
		,br.brand_type_code
		,partner_first_name		= Null
		,partner_last_name		= Null
		,partner_phone_number	= Null
		,partner_email			= Null
	From
		CompanyDetails_with_regid	cd
	Join 
		Brands_with_regid			br			
			on cd.organisation_id = br.organisation_id
				And ISNULL(cd.subsidiary_id,'') = ISNULL(br.subsidiary_id,'') 
					And cd.RegistrationSetId = br.RegistrationSetId
	Union --All

	Select
		 cd.organisation_id
		,cd.subsidiary_id
		,cd.RegistrationSetId
		,brand_name				= Null
		,brand_type_code		= Null
		,ps.partner_first_name		
		,ps.partner_last_name
		,ps.partner_phone_number
		,ps.partner_email
	From
		CompanyDetails_with_regid	cd
	Join 
		Partner_with_regid			ps	
			on cd.organisation_id = ps.organisation_id
				And ISNULL(cd.subsidiary_id,'') = ISNULL(ps.subsidiary_id,'') 
					And cd.RegistrationSetId = ps.RegistrationSetId
	Union --All
	Select
		 cd.organisation_id
		,cd.subsidiary_id
		,cd.RegistrationSetId
		,brOJ.brand_name
		,brOJ.brand_type_code
		,psOJ.partner_first_name		
		,psOJ.partner_last_name
		,psOJ.partner_phone_number
		,psOJ.partner_email
	From
		CompanyDetails_with_regid	cd
	Left Join 
		Partner_with_regid			psOJ	
			on cd.organisation_id = psOJ.organisation_id
				And ISNULL(cd.subsidiary_id,'') = ISNULL(psOJ.subsidiary_id,'') 
					And cd.RegistrationSetId = psOJ.RegistrationSetId

	Left Join 
		Brands_with_regid			brOJ			
			on cd.organisation_id = brOJ.organisation_id
				And ISNULL(cd.subsidiary_id,'') = ISNULL(brOJ.subsidiary_id,'') 
					And cd.RegistrationSetId = brOJ.RegistrationSetId
	Where
		brOJ.brand_name Is Null And brOJ.brand_type_code IS Null
			And psOJ.partner_first_name Is Null And psOJ.subsidiary_id Is Null
)
Select Distinct
	 cd.approved_person_email
	,cd.approved_person_first_name
	,cd.approved_person_job_title
	,cd.approved_person_last_name
	,cd.approved_person_phone_number
	,cd.audit_addr_city
	,cd.audit_addr_country
	,cd.audit_addr_county
	,cd.audit_addr_line1
	,cd.audit_addr_line2
	,cd.audit_addr_postcode
	,cd.companies_house_number
	,cd.delegated_person_email
	,cd.delegated_person_first_name
	,cd.delegated_person_job_title
	,cd.delegated_person_last_name
	,cd.delegated_person_phone_number
	,cd.home_nation_code
	,cd.liable_for_disposal_costs_flag
	,cd.main_activity_sic
	,cd.meet_reporting_requirements_flag
	,cd.organisation_id
	,cd.organisation_name
	,cd.organisation_size
	,cd.organisation_sub_type_code
	,cd.organisation_type_code
	,cd.packaging_activity_hl
	,cd.packaging_activity_im
	,cd.packaging_activity_om
	,cd.packaging_activity_pf
	,cd.packaging_activity_se
	,cd.packaging_activity_sl
	,cd.packaging_activity_so
	,cd.primary_contact_person_email
	,cd.primary_contact_person_first_name
	,cd.primary_contact_person_job_title
	,cd.primary_contact_person_last_name
	,cd.primary_contact_person_phone_number
	,cd.principal_addr_city
	,cd.principal_addr_country
	,cd.principal_addr_county
	,cd.principal_addr_line1
	,cd.principal_addr_line2
	,cd.principal_addr_phone_number
	,cd.principal_addr_postcode
	,cd.produce_blank_packaging_flag
	,cd.registered_addr_country
	,cd.registered_addr_county
	,cd.registered_addr_line1
	,cd.registered_addr_line2
	,cd.registered_addr_phone_number
	,cd.registered_addr_postcode
	,cd.registered_city
	,cd.registration_type_code
	,cd.secondary_contact_person_email
	,cd.secondary_contact_person_first_name
	,cd.secondary_contact_person_job_title
	,cd.secondary_contact_person_last_name
	,cd.secondary_contact_person_phone_number
	,cd.service_of_notice_addr_city
	,cd.service_of_notice_addr_country
	,cd.service_of_notice_addr_county
	,cd.service_of_notice_addr_line1
	,cd.service_of_notice_addr_line2
	,cd.service_of_notice_addr_phone_number
	,cd.service_of_notice_addr_postcode
	,cd.sole_trader_email
	,cd.sole_trader_first_name
	,cd.sole_trader_last_name
	,cd.sole_trader_phone_number
	,cd.subsidiary_id							-- Subsidiary ID (User Generated)
	,cd.total_tonnage
	,cd.trading_name
	,cd.turnover
	/**YM002: below four new columns added**/
	,cd.leaver_code					--YM002
    ,cd.leaver_date					--YM002
    ,cd.organisation_change_reason  --YM002
    ,cd.joiner_date					--YM002
	
	--Brand
	,bp.brand_name
	,bp.brand_type_code
	
	--Partner
	,bp.partner_first_name
	,bp.partner_last_name
	,bp.partner_phone_number
	,bp.partner_email

	--SubmissionFileStatus
	,pos.Regulator_Rejection_Comments
	,pos.Regulator_User_Name
	,pos.Decision_Date
	,pos.ApplicationReferenceNo
	,RegistrationType					= IsNull(pos.RegistrationType,1)
	,Regulator_Status					= Case	When pos.Regulator_Status Is Null Then 'Pending' Else pos.Regulator_Status End
	
	--v_subsidiaryorganisations
	,SubsidiaryOrganisation_ReferenceNumber		= so.SecondOrganisation_ReferenceNumber

	--t_cosmos_file_metadata
	,cfm.FileType
	,cfm.[Filename]
	,cfm.OriginalFileName
	,cfm.SubmittedBy
	,cfm.SubmissionId
	,cfm.SubmissionPeriod
	--,Created							= isnull(convert(datetime2,pos.Created,127) , cfm.Created)
	, coalesce(convert(datetime2,pos.Application_submitted_ts,127),convert(datetime2,pos.Created,127), cfm.Created) as Created
	--t_rpd_data_SECURITY_FIX
	,sc.FromOrganisation_Type
	,sc.Organisations_Id
	,sc.ServiceRoles_Role
	,sc.FromOrganisation_ReferenceNumber
	,sc.FromOrganisation_IsComplianceScheme
	,sc.FromOrganisation_Name

	--v_rpd_ComplianceSchemes_Active
	,ComplianceSchemes_Id			= csa.[Id]
	,ComplianceSchemes_Name			= csa.[Name]

	--New Column Removed from PowerBI
	,RelevantYear = Right(dbo.udf_DQ_SubmissionPeriod(cfm.SubmissionPeriod),4)+1
From
	CompanyDetails_with_regid				cd
Join
	BrPaUn									bp		
		on cd.organisation_id = bp.organisation_id
			And ISNULL(cd.subsidiary_id,'') = ISNULL(bp.subsidiary_id,'') 
				And cd.RegistrationSetId = bp.RegistrationSetId
Join
	dbo.t_rpd_data_SECURITY_FIX				sc
		On cd.organisation_id = sc.FromOrganisation_ReferenceNumber
Join
	dbo.t_cosmos_file_metadata				cfm
		On cd.[FileName] = cfm.[FileName]

Left Join
	dbo.v_rpd_ComplianceSchemes_Active		csa 
		On cfm.ComplianceSchemeId = csa.externalid
Left Join
	dbo.v_submitted_pom_org_file_status		pos
		On cd.[Filename] = pos.[Filename]
			And pos.RegistrationType = 1 
Left Join
	dbo.v_subsidiaryorganisations			so
		On cd.organisation_id = so.FirstOrganisation_ReferenceNumber
			And IsNull(Trim(cd.subsidiary_id),'') = IsNull(Trim(so.SubsidiaryId),'')
				And IsNull(Trim(cd.companies_house_number),'') = IsNull(Trim(so.SecondOrganisation_CompaniesHouseNumber),'')
					And so.RelationToDate Is Null		
Where 
	Right(dbo.udf_DQ_SubmissionPeriod(cfm.SubmissionPeriod),4) < 2025;