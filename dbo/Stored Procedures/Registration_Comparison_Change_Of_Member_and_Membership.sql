CREATE PROC [dbo].[Registration_Comparison_Change_Of_Member_and_Membership] @CompanyRegID_1 [VARCHAR](4000),@CompanyRegID_2 [VARCHAR](4000) AS
BEGIN
WITH file1 AS (
SELECT CompanyOrgId
      ,subsidiary_id
	  ,SubsidiaryOrganisation_ReferenceNumber
      ,organisation_name
      ,trading_name
      ,companies_house_number
      ,home_nation_code
      ,main_activity_sic
      ,organisation_type_code
      ,organisation_sub_type_code
      ,packaging_activity_so
      ,packaging_activity_pf
      ,packaging_activity_im
      ,packaging_activity_se
      ,packaging_activity_hl
      ,packaging_activity_om
      ,packaging_activity_sl
      ,registration_type_code
      ,turnover
      ,total_tonnage
      ,produce_blank_packaging_flag
      ,liable_for_disposal_costs_flag
      ,meet_reporting_requirements_flag
      ,registered_addr_line1
      ,registered_addr_line2
      ,registered_city
      ,registered_addr_county
      ,registered_addr_postcode
      ,registered_addr_country
      ,registered_addr_phone_number
      ,audit_addr_line1
      ,audit_addr_line2
      ,audit_addr_city
      ,audit_addr_county
      ,audit_addr_postcode
      ,audit_addr_country
      ,service_of_notice_addr_line1
      ,service_of_notice_addr_line2
      ,service_of_notice_addr_city
      ,service_of_notice_addr_county
      ,service_of_notice_addr_postcode
      ,service_of_notice_addr_country
      ,service_of_notice_addr_phone_number
      ,principal_addr_line1
      ,principal_addr_line2
      ,principal_addr_city
      ,principal_addr_county
      ,principal_addr_postcode
      ,principal_addr_country
      ,principal_addr_phone_number
      ,sole_trader_first_name
      ,sole_trader_last_name
      ,sole_trader_phone_number
      ,sole_trader_email
      ,approved_person_first_name
      ,approved_person_last_name
      ,approved_person_phone_number
      ,approved_person_email
      ,approved_person_job_title
      ,delegated_person_first_name
      ,delegated_person_last_name
      ,delegated_person_phone_number
      ,delegated_person_email
      ,delegated_person_job_title
      ,primary_contact_person_first_name
      ,primary_contact_person_last_name
      ,primary_contact_person_phone_number
      ,primary_contact_person_email
      ,primary_contact_person_job_title
      ,secondary_contact_person_first_name
      ,secondary_contact_person_last_name
      ,secondary_contact_person_phone_number
      ,secondary_contact_person_email
      ,secondary_contact_person_job_title
	  ,organisation_size
      ,CompanyFileName
      ,CompanyOriginalFileName
      ,CompanyFileType
      ,SubmissionDateTime
      ,CompanyRegID
      ,UserId
      ,ComplianceSchemeId
      ,TargetDirectoryName
      ,CSORPD
	  ,BrandOrgID
      ,BrandSubID
      ,BrandName
      ,BrandTypeCode
      ,BrandLoadTS
      ,BrandFileName
      ,BrandOriginalFileName
      ,BrandFileType
      ,BrandRegID
      ,PartnerOrgID
      ,PartnerSubID
      ,PartnerFirstName
      ,PartnerLastName
      ,PartnerPhoneNumber
      ,PartnerEmail
      ,PartnerFileName
      ,PartnerOriginalFileName
      ,PartnerFileType
      ,PartnerRegID
  FROM dbo.t_CompanyBrandPartnerFileUploadSet
  WHERE CompanyRegID = @CompanyRegID_1
  ),
  file2 AS (
  SELECT 
		CompanyOrgId
      ,subsidiary_id
	  ,SubsidiaryOrganisation_ReferenceNumber
      ,organisation_name
      ,trading_name
      ,companies_house_number
      ,home_nation_code
      ,main_activity_sic
      ,organisation_type_code
      ,organisation_sub_type_code
      ,packaging_activity_so
      ,packaging_activity_pf
      ,packaging_activity_im
      ,packaging_activity_se
      ,packaging_activity_hl
      ,packaging_activity_om
      ,packaging_activity_sl
      ,registration_type_code
      ,turnover
      ,total_tonnage
      ,produce_blank_packaging_flag
      ,liable_for_disposal_costs_flag
      ,meet_reporting_requirements_flag
      ,registered_addr_line1
      ,registered_addr_line2
      ,registered_city
      ,registered_addr_county
      ,registered_addr_postcode
      ,registered_addr_country
      ,registered_addr_phone_number
      ,audit_addr_line1
      ,audit_addr_line2
      ,audit_addr_city
      ,audit_addr_county
      ,audit_addr_postcode
      ,audit_addr_country
      ,service_of_notice_addr_line1
      ,service_of_notice_addr_line2
      ,service_of_notice_addr_city
      ,service_of_notice_addr_county
      ,service_of_notice_addr_postcode
      ,service_of_notice_addr_country
      ,service_of_notice_addr_phone_number
      ,principal_addr_line1
      ,principal_addr_line2
      ,principal_addr_city
      ,principal_addr_county
      ,principal_addr_postcode
      ,principal_addr_country
      ,principal_addr_phone_number
      ,sole_trader_first_name
      ,sole_trader_last_name
      ,sole_trader_phone_number
      ,sole_trader_email
      ,approved_person_first_name
      ,approved_person_last_name
      ,approved_person_phone_number
      ,approved_person_email
      ,approved_person_job_title
      ,delegated_person_first_name
      ,delegated_person_last_name
      ,delegated_person_phone_number
      ,delegated_person_email
      ,delegated_person_job_title
      ,primary_contact_person_first_name
      ,primary_contact_person_last_name
      ,primary_contact_person_phone_number
      ,primary_contact_person_email
      ,primary_contact_person_job_title
      ,secondary_contact_person_first_name
      ,secondary_contact_person_last_name
      ,secondary_contact_person_phone_number
      ,secondary_contact_person_email
      ,secondary_contact_person_job_title
	  ,organisation_size
      ,CompanyFileName
      ,CompanyOriginalFileName
      ,CompanyFileType
      ,SubmissionDateTime
      ,CompanyRegID
      ,UserId
      ,ComplianceSchemeId
      ,TargetDirectoryName
      ,CSORPD
	  ,BrandOrgID
      ,BrandSubID
      ,BrandName
      ,BrandTypeCode
      ,BrandLoadTS
      ,BrandFileName
      ,BrandOriginalFileName
      ,BrandFileType
      ,BrandRegID
      ,PartnerOrgID
      ,PartnerSubID
      ,PartnerFirstName
      ,PartnerLastName
      ,PartnerPhoneNumber
      ,PartnerEmail
      ,PartnerFileName
      ,PartnerOriginalFileName
      ,PartnerFileType
      ,PartnerRegID
  FROM dbo.t_CompanyBrandPartnerFileUploadSet
  WHERE CompanyRegID = @CompanyRegID_2
  ),

  resultfile AS (
  SELECT f1.CompanyOrgId AS CompanyOrgId_1 
  ,f2.CompanyOrgId AS CompanyOrgId_2 
  ,f1.subsidiary_id AS subsidiary_id_1
  ,f2.subsidiary_id AS subsidiary_id_2
  ,f1.organisation_name AS organisation_name_1
  ,f2.organisation_name AS organisation_name_2
  ,f1.SubsidiaryOrganisation_ReferenceNumber AS system_generated_subsidiary_id_1
  ,f2.SubsidiaryOrganisation_ReferenceNumber AS system_generated_subsidiary_id_2
  ,f1.companies_house_number AS companies_house_number_1
  ,f2.companies_house_number AS companies_house_number_2
  ,f1.main_activity_sic as main_activity_sic_1
  ,f2.main_activity_sic as main_activity_sic_2
  ,f1.subsidiary_id AS file1_subsidiary_id
  ,f2.subsidiary_id AS file2_subsidiary_id
  ,f1.CSORPD AS file1_CSORPD
  ,f2.CSORPD AS file2_CSORPD
  ,f1.organisation_size AS organisation_size_1
  ,f2.organisation_size AS organisation_size_2
		
	,CASE 
		WHEN ISNULL(f1.subsidiary_id, '') = ISNULL(f2.subsidiary_id, '') THEN 'No Change'
		WHEN f1.subsidiary_id IS NULL AND f2.subsidiary_id IS NOT NULL THEN 'Added'
		WHEN f1.subsidiary_id IS NOT NULL AND f2.subsidiary_id IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_subsidiary_id



	--,f1.SubsidiaryOrganisation_ReferenceNumber AS file1_SubsidiaryOrganisation_ReferenceNumber
	--,f2.SubsidiaryOrganisation_ReferenceNumber AS file2_SubsidiaryOrganisation_ReferenceNumber
	--,CASE 
	--	WHEN ISNULL(f1.SubsidiaryOrganisation_ReferenceNumber, '') = ISNULL(f2.SubsidiaryOrganisation_ReferenceNumber, '') THEN 'No Change'
	--	WHEN f1.SubsidiaryOrganisation_ReferenceNumber IS NULL AND f2.SubsidiaryOrganisation_ReferenceNumber IS NOT NULL THEN 'Added'
	--	WHEN f1.SubsidiaryOrganisation_ReferenceNumber IS NOT NULL AND f2.SubsidiaryOrganisation_ReferenceNumber IS NULL THEN 'Removed'
	--	ELSE 'Changed' 
	--END AS change_status_SubsidiaryOrganisation_ReferenceNumber

	,f1.organisation_name AS file1_organisation_name
	,f2.organisation_name AS file2_organisation_name
	,CASE 
		WHEN ISNULL(f1.organisation_name, '') = ISNULL(f2.organisation_name, '') THEN 'No Change'
		WHEN f1.organisation_name IS NULL AND f2.organisation_name IS NOT NULL  THEN 'Added'
		WHEN f1.organisation_name IS NOT NULL AND f2.organisation_name IS NULL  THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_organisation_name

	,f1.trading_name AS file1_trading_name
	,f2.trading_name AS file2_trading_name
	,CASE
		WHEN ISNULL(f1.trading_name, '')= ISNULL(f2.trading_name, '') THEN 'No Change'
		WHEN f1.trading_name IS NULL AND f2.trading_name IS NOT NULL  THEN 'Added'
		WHEN f1.trading_name IS NOT NULL AND  f2.trading_name IS NULL  THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_trading_name

	,f1.turnover AS file1_turnover
	,f2.turnover AS file2_turnover
	,CASE
		WHEN ISNULL(f1.turnover, '') = ISNULL(f2.turnover, '') THEN 'No Change'
		WHEN f1.turnover IS NULL AND f2.turnover IS NOT NULL THEN 'Added'
		WHEN f1.turnover IS NOT NULL AND f2.turnover IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_turnover

	,f1.total_tonnage AS file1_total_tonnage
	,f2.total_tonnage AS file2_total_tonnage
	,CASE
		WHEN ISNULL(f1.total_tonnage, '') = ISNULL(f2.total_tonnage, '') THEN 'No Change'
		WHEN f1.total_tonnage IS NULL AND f2.total_tonnage IS NOT NULL  THEN 'Added'
		WHEN f1.total_tonnage IS NOT NULL AND f2.total_tonnage IS NULL  THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_total_tonnage

	,f1.registered_addr_line1 AS file1_registered_addr_line1
	,f2.registered_addr_line1 AS file2_registered_addr_line1
	,CASE
		WHEN ISNULL(f1.registered_addr_line1, '') = ISNULL(f2.registered_addr_line1, '') THEN 'No Change'
		WHEN f1.registered_addr_line1 IS NULL AND f2.registered_addr_line1 IS NOT NULL THEN 'Added'
		WHEN f1.registered_addr_line1 IS NOT NULL AND f2.registered_addr_line1 IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_registered_addr_line1

	,f1.registered_addr_line2 AS file1_registered_addr_line2
	,f2.registered_addr_line2 AS file2_registered_addr_line2
	,CASE 
		WHEN ISNULL(f1.registered_addr_line2, '') = ISNULL(f2.registered_addr_line2, '') THEN 'No Change'
		WHEN f1.registered_addr_line2 IS NULL AND f2.registered_addr_line2 IS NOT NULL THEN 'Added'
		WHEN f1.registered_addr_line2 IS NOT NULL AND f2.registered_addr_line2 IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_registered_addr_line2

	,f1.registered_city AS file1_registered_city
	,f2.registered_city AS file2_registered_city
	,CASE
		WHEN ISNULL(f1.registered_city, '') = ISNULL(f2.registered_city, '') THEN 'No Change'
		WHEN f1.registered_city IS NULL AND f2.registered_city IS NOT NULL THEN 'Added'
		WHEN f1.registered_city IS NOT NULL AND f2.registered_city IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_registered_city

	,f1.registered_addr_county AS file1_registered_addr_county
	,f2.registered_addr_county AS file2_registered_addr_county
	,CASE
		WHEN ISNULL(f1.registered_addr_county, '') = ISNULL(f2.registered_addr_county, '') THEN 'No Change'
		WHEN f1.registered_addr_county IS NULL AND f2.registered_addr_county IS NOT NULL THEN 'Added'
		WHEN f1.registered_addr_county IS NOT NULL AND f2.registered_addr_county IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_registered_addr_county

	,f1.registered_addr_postcode AS file1_registered_addr_postcode
	,f2.registered_addr_postcode AS file2_registered_addr_postcode
	,CASE
		WHEN ISNULL(f1.registered_addr_postcode, '') = ISNULL(f2.registered_addr_postcode, '') THEN 'No Change'
		WHEN f1.registered_addr_postcode IS NULL AND f2.registered_addr_postcode IS NOT NULL THEN 'Added'
		WHEN f1.registered_addr_postcode IS NOT NULL AND f2.registered_addr_postcode IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_registered_addr_postcode

	,f1.registered_addr_country AS file1_registered_addr_country
	,f2.registered_addr_country AS file2_registered_addr_country
	,CASE
		WHEN ISNULL(f1.registered_addr_country, '') = ISNULL(f2.registered_addr_country, '') THEN 'No Change'
		WHEN f1.registered_addr_country IS NULL AND f2.registered_addr_country IS NOT NULL THEN 'Added'
		WHEN f1.registered_addr_country IS NOT NULL AND f2.registered_addr_country IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_registered_addr_country

	,f1.registered_addr_phone_number AS file1_registered_addr_phone_number
	,f2.registered_addr_phone_number AS file2_registered_addr_phone_number
	,CASE
		WHEN ISNULL(f1.registered_addr_phone_number, '') = ISNULL(f2.registered_addr_phone_number, '') THEN 'No Change'
		WHEN f1.registered_addr_phone_number IS NULL AND f2.registered_addr_phone_number IS NOT NULL THEN 'Added'
		WHEN f1.registered_addr_phone_number IS NOT NULL AND f2.registered_addr_phone_number IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_registered_addr_phone_number
	
	,f1.principal_addr_line1 AS file1_principal_addr_line1
	,f2.principal_addr_line1 AS file2_principal_addr_line1
	,CASE
		WHEN ISNULL(f1.principal_addr_line1, '') = ISNULL(f2.principal_addr_line1, '') THEN 'No Change'
		WHEN f1.principal_addr_line1 IS NULL AND f2.principal_addr_line1 IS NOT NULL THEN 'Added'
		WHEN f1.principal_addr_line1 IS NOT NULL AND f2.principal_addr_line1 IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_principal_addr_line1

	,f1.principal_addr_line2 AS file1_principal_addr_line2
	,f2.principal_addr_line2 AS file2_principal_addr_line2
	,CASE
		WHEN ISNULL(f1.principal_addr_line2, '') = ISNULL(f2.principal_addr_line2, '') THEN 'No Change'
		WHEN f1.principal_addr_line2 IS NULL AND f2.principal_addr_line2 IS NOT NULL THEN 'Added'
		WHEN f1.principal_addr_line2 IS NOT NULL AND f2.principal_addr_line2 IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_principal_addr_line2

	,f1.principal_addr_city AS file1_principal_addr_city
	,f2.principal_addr_city AS file2_principal_addr_city
	,CASE
		WHEN ISNULL(f1.principal_addr_city, '') = ISNULL(f2.principal_addr_city, '') THEN 'No Change'
		WHEN f1.principal_addr_city IS NULL AND f2.principal_addr_city IS NOT NULL THEN 'Added'
		WHEN f1.principal_addr_city IS NOT NULL AND f2.principal_addr_city IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_principal_addr_city

	,f1.principal_addr_county AS file1_principal_addr_county
	,f2.principal_addr_county AS file2_principal_addr_county
	,CASE
		WHEN ISNULL(f1.principal_addr_county, '') = ISNULL(f2.principal_addr_county, '') THEN 'No Change'
		WHEN f1.principal_addr_county IS NULL AND f2.principal_addr_county IS NOT NULL THEN 'Added'
		WHEN f1.principal_addr_county IS NOT NULL AND f2.principal_addr_county IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_principal_addr_county

	,f1.principal_addr_postcode AS file1_principal_addr_postcode
	,f2.principal_addr_postcode AS file2_principal_addr_postcode
	,CASE
		WHEN ISNULL(f1.principal_addr_postcode, '') = ISNULL(f2.principal_addr_postcode, '') THEN 'No Change'
		WHEN f1.principal_addr_postcode IS NULL AND f2.principal_addr_postcode IS NOT NULL THEN 'Added'
		WHEN f1.principal_addr_postcode IS NOT NULL AND f2.principal_addr_postcode IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_principal_addr_postcode

	,f1.principal_addr_country AS file1_principal_addr_country
	,f2.principal_addr_country AS file2_principal_addr_country
	,CASE
		WHEN ISNULL(f1.principal_addr_country, '') = ISNULL(f2.principal_addr_country, '') THEN 'No Change'
		WHEN f1.principal_addr_country IS NULL AND f2.principal_addr_country IS NOT NULL THEN 'Added'
		WHEN f1.principal_addr_country IS NOT NULL AND f2.principal_addr_country IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_principal_addr_country

	,f1.principal_addr_phone_number AS file1_principal_addr_phone_number
	,f2.principal_addr_phone_number AS file2_principal_addr_phone_number
	,CASE
		WHEN ISNULL(f1.principal_addr_phone_number, '') = ISNULL(f2.principal_addr_phone_number, '') THEN 'No Change'
		WHEN f1.principal_addr_phone_number IS NULL AND f2.principal_addr_phone_number IS NOT NULL THEN 'Added'
		WHEN f1.principal_addr_phone_number IS NOT NULL AND f2.principal_addr_phone_number IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_principal_addr_phone_number

	,f1.audit_addr_line1 AS file1_audit_addr_line1
	,f2.audit_addr_line1 AS file2_audit_addr_line1
	,CASE
		WHEN ISNULL(f1.audit_addr_line1, '') = ISNULL(f2.audit_addr_line1, '') THEN 'No Change'
		WHEN f1.audit_addr_line1 IS NULL AND f2.audit_addr_line1 IS NOT NULL THEN 'Added'
		WHEN f1.audit_addr_line1 IS NOT NULL AND f2.audit_addr_line1 IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_audit_addr_line1

	,f1.audit_addr_line2 AS file1_audit_addr_line2
	,f2.audit_addr_line2 AS file2_audit_addr_line2
	,CASE
		WHEN ISNULL(f1.audit_addr_line2, '') = ISNULL(f2.audit_addr_line2, '') THEN 'No Change'
		WHEN f1.audit_addr_line2 IS NULL AND f2.audit_addr_line2 IS NOT NULL THEN 'Added'
		WHEN f1.audit_addr_line2 IS NOT NULL AND f2.audit_addr_line2 IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_audit_addr_line2

	,f1.audit_addr_city AS file1_audit_addr_city
	,f2.audit_addr_city AS file2_audit_addr_city
	,CASE
		WHEN ISNULL(f1.audit_addr_city, '') = ISNULL(f2.audit_addr_city, '') THEN 'No Change'
		WHEN f1.audit_addr_city IS NULL AND f2.audit_addr_city IS NOT NULL THEN 'Added'
		WHEN f1.audit_addr_city IS NOT NULL AND f2.audit_addr_city IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_audit_addr_city

	,f1.audit_addr_county AS file1_audit_addr_county
	,f2.audit_addr_county AS file2_audit_addr_county
	,CASE
		WHEN ISNULL(f1.audit_addr_county, '') = ISNULL(f2.audit_addr_county, '') THEN 'No Change'
		WHEN f1.audit_addr_county IS NULL AND f2.audit_addr_county IS NOT NULL THEN 'Added'
		WHEN f1.audit_addr_county IS NOT NULL AND f2.audit_addr_county IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_audit_addr_county

	,f1.audit_addr_postcode AS file1_audit_addr_postcode
	,f2.audit_addr_postcode AS file2_audit_addr_postcode
	,CASE
		WHEN ISNULL(f1.audit_addr_postcode, '') = ISNULL(f2.audit_addr_postcode, '') THEN 'No Change'
		WHEN f1.audit_addr_postcode IS NULL AND f2.audit_addr_postcode IS NOT NULL THEN 'Added'
		WHEN f1.audit_addr_postcode IS NOT NULL AND f2.audit_addr_postcode IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_audit_addr_postcode

	,f1.audit_addr_country AS file1_audit_addr_country
	,f2.audit_addr_country AS file2_audit_addr_country
	,CASE
		WHEN ISNULL(f1.audit_addr_country, '') = ISNULL(f2.audit_addr_country, '') THEN 'No Change'
		WHEN f1.audit_addr_country IS NULL AND f2.audit_addr_country IS NOT NULL THEN 'Added'
		WHEN f1.audit_addr_country IS NOT NULL AND f2.audit_addr_country IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_audit_addr_country

	,f1.service_of_notice_addr_line1 AS file1_service_of_notice_addr_line1
	,f2.service_of_notice_addr_line1 AS file2_service_of_notice_addr_line1
	,CASE
		WHEN ISNULL(f1.service_of_notice_addr_line1, '') = ISNULL(f2.service_of_notice_addr_line1, '') THEN 'No Change'
		WHEN f1.service_of_notice_addr_line1 IS NULL AND f2.service_of_notice_addr_line1 IS NOT NULL THEN 'Added'
		WHEN f1.service_of_notice_addr_line1 IS NOT NULL AND f2.service_of_notice_addr_line1 IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_service_of_notice_addr_line1

	,f1.service_of_notice_addr_line2 AS file1_service_of_notice_addr_line2
	,f2.service_of_notice_addr_line2 AS file2_service_of_notice_addr_line2
	,CASE
		WHEN ISNULL(f1.service_of_notice_addr_line2, '') = ISNULL(f2.service_of_notice_addr_line2, '') THEN 'No Change'
		WHEN f1.service_of_notice_addr_line2 IS NULL AND f2.service_of_notice_addr_line2 IS NOT NULL THEN 'Added'
		WHEN f1.service_of_notice_addr_line2 IS NOT NULL AND f2.service_of_notice_addr_line2 IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_service_of_notice_addr_line2

	,f1.service_of_notice_addr_city AS file1_service_of_notice_addr_city
	,f2.service_of_notice_addr_city AS file2_service_of_notice_addr_city
	,CASE
		WHEN ISNULL(f1.service_of_notice_addr_city, '') = ISNULL(f2.service_of_notice_addr_city, '') THEN 'No Change'
		WHEN f1.service_of_notice_addr_city IS NULL AND f2.service_of_notice_addr_city IS NOT NULL THEN 'Added'
		WHEN f1.service_of_notice_addr_city IS NOT NULL AND f2.service_of_notice_addr_city IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_service_of_notice_addr_city

	,f1.service_of_notice_addr_county AS file1_service_of_notice_addr_county
	,f2.service_of_notice_addr_county AS file2_service_of_notice_addr_county
	,CASE
		WHEN ISNULL(f1.service_of_notice_addr_county, '') = ISNULL(f2.service_of_notice_addr_county, '') THEN 'No Change'
		WHEN f1.service_of_notice_addr_county IS NULL AND f2.service_of_notice_addr_county IS NOT NULL THEN 'Added'
		WHEN f1.service_of_notice_addr_county IS NOT NULL AND f2.service_of_notice_addr_county IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_service_of_notice_addr_county

	,f1.service_of_notice_addr_postcode AS file1_service_of_notice_addr_postcode
	,f2.service_of_notice_addr_postcode AS file2_service_of_notice_addr_postcode
	,CASE
		WHEN ISNULL(f1.service_of_notice_addr_postcode, '') = ISNULL(f2.service_of_notice_addr_postcode, '') THEN 'No Change'
		WHEN f1.service_of_notice_addr_postcode IS NULL AND f2.service_of_notice_addr_postcode IS NOT NULL THEN 'Added'
		WHEN f1.service_of_notice_addr_postcode IS NOT NULL AND f2.service_of_notice_addr_postcode IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_service_of_notice_addr_postcode

	,f1.service_of_notice_addr_country AS file1_service_of_notice_addr_country
	,f2.service_of_notice_addr_country AS file2_service_of_notice_addr_country
	,CASE
		WHEN ISNULL(f1.service_of_notice_addr_country, '') = ISNULL(f2.service_of_notice_addr_country, '') THEN 'No Change'
		WHEN f1.service_of_notice_addr_country IS NULL AND f2.service_of_notice_addr_country IS NOT NULL THEN 'Added'
		WHEN f1.service_of_notice_addr_country IS NOT NULL AND f2.service_of_notice_addr_country IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_service_of_notice_addr_country

	,f1.service_of_notice_addr_phone_number AS file1_service_of_notice_addr_phone_number
	,f2.service_of_notice_addr_phone_number AS file2_service_of_notice_addr_phone_number
	,CASE
		WHEN ISNULL(f1.service_of_notice_addr_phone_number, '') = ISNULL(f2.service_of_notice_addr_phone_number, '') THEN 'No Change'
		WHEN f1.service_of_notice_addr_phone_number IS NULL AND f2.service_of_notice_addr_phone_number IS NOT NULL THEN 'Added'
		WHEN f1.service_of_notice_addr_phone_number IS NOT NULL AND f2.service_of_notice_addr_phone_number IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_service_of_notice_addr_phone_number

	,f1.approved_person_first_name AS file1_approved_person_first_name
	,f2.approved_person_first_name AS file2_approved_person_first_name
	,CASE
		WHEN ISNULL(f1.approved_person_first_name, '') = ISNULL(f2.approved_person_first_name, '') THEN 'No Change'
		WHEN f1.approved_person_first_name IS NULL AND f2.approved_person_first_name IS NOT NULL THEN 'Added'
		WHEN f1.approved_person_first_name IS NOT NULL AND f2.approved_person_first_name IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_approved_person_first_name

	,f1.approved_person_last_name AS file1_approved_person_last_name
	,f2.approved_person_last_name AS file2_approved_person_last_name
	,CASE
		WHEN ISNULL(f1.approved_person_last_name, '') = ISNULL(f2.approved_person_last_name, '') THEN 'No Change'
		WHEN f1.approved_person_last_name IS NULL AND f2.approved_person_last_name IS NOT NULL THEN 'Added'
		WHEN f1.approved_person_last_name IS NOT NULL AND f2.approved_person_last_name IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_approved_person_last_name

	,f1.approved_person_phone_number AS file1_approved_person_phone_number
	,f2.approved_person_phone_number AS file2_approved_person_phone_number
	,CASE
		WHEN ISNULL(f1.approved_person_phone_number, '') = ISNULL(f2.approved_person_phone_number, '') THEN 'No Change'
		WHEN f1.approved_person_phone_number IS NULL AND f2.approved_person_phone_number IS NOT NULL THEN 'Added'
		WHEN f1.approved_person_phone_number IS NOT NULL AND f2.approved_person_phone_number IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_approved_person_phone_number

	,f1.approved_person_email AS file1_approved_person_email
	,f2.approved_person_email AS file2_approved_person_email
	,CASE
		WHEN ISNULL(f1.approved_person_email, '') = ISNULL(f2.approved_person_email, '') THEN 'No Change'
		WHEN f1.approved_person_email IS NULL AND f2.approved_person_email IS NOT NULL THEN 'Added'
		WHEN f1.approved_person_email IS NOT NULL AND f2.approved_person_email IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_approved_person_email

	,f1.approved_person_job_title AS file1_approved_person_job_title
	,f2.approved_person_job_title AS file2_approved_person_job_title
	,CASE
		WHEN ISNULL(f1.approved_person_job_title, '') = ISNULL(f2.approved_person_job_title, '') THEN 'No Change'
		WHEN f1.approved_person_job_title IS NULL AND f2.approved_person_job_title IS NOT NULL THEN 'Added'
		WHEN f1.approved_person_job_title IS NOT NULL AND f2.approved_person_job_title IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_approved_person_job_title

	,f1.delegated_person_first_name AS file1_delegated_person_first_name
	,f2.delegated_person_first_name AS file2_delegated_person_first_name
	,CASE
		WHEN ISNULL(f1.delegated_person_first_name, '') = ISNULL(f2.delegated_person_first_name, '') THEN 'No Change'
		WHEN f1.delegated_person_first_name IS NULL AND f2.delegated_person_first_name IS NOT NULL THEN 'Added'
		WHEN f1.delegated_person_first_name IS NOT NULL AND f2.delegated_person_first_name IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_delegated_person_first_name

	,f1.delegated_person_last_name AS file1_delegated_person_last_name
	,f2.delegated_person_last_name AS file2_delegated_person_last_name
	,CASE
		WHEN ISNULL(f1.delegated_person_last_name, '') = ISNULL(f2.delegated_person_last_name, '') THEN 'No Change'
		WHEN f1.delegated_person_last_name IS NULL AND f2.delegated_person_last_name IS NOT NULL THEN 'Added'
		WHEN f1.delegated_person_last_name IS NOT NULL AND f2.delegated_person_last_name IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_delegated_person_last_name

	,f1.delegated_person_phone_number AS file1_delegated_person_phone_number
	,f2.delegated_person_phone_number AS file2_delegated_person_phone_number
	,CASE
		WHEN ISNULL(f1.delegated_person_phone_number, '') = ISNULL(f2.delegated_person_phone_number, '') THEN 'No Change'
		WHEN f1.delegated_person_phone_number IS NULL AND f2.delegated_person_phone_number IS NOT NULL THEN 'Added'
		WHEN f1.delegated_person_phone_number IS NOT NULL AND f2.delegated_person_phone_number IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_delegated_person_phone_number

	,f1.delegated_person_email AS file1_delegated_person_email
	,f2.delegated_person_email AS file2_delegated_person_email
	,CASE
		WHEN ISNULL(f1.delegated_person_email, '') = ISNULL(f2.delegated_person_email, '') THEN 'No Change'
		WHEN f1.delegated_person_email IS NULL AND f2.delegated_person_email IS NOT NULL THEN 'Added'
		WHEN f1.delegated_person_email IS NOT NULL AND f2.delegated_person_email IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_delegated_person_email

	,f1.delegated_person_job_title AS file1_delegated_person_job_title
	,f2.delegated_person_job_title AS file2_delegated_person_job_title
	,CASE
		WHEN ISNULL(f1.delegated_person_job_title, '') = ISNULL(f2.delegated_person_job_title, '') THEN 'No Change'
		WHEN f1.delegated_person_job_title IS NULL AND f2.delegated_person_job_title IS NOT NULL THEN 'Added'
		WHEN f1.delegated_person_job_title IS NOT NULL AND f2.delegated_person_job_title IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_delegated_person_job_title

	,f1.primary_contact_person_first_name AS file1_primary_contact_person_first_name
	,f2.primary_contact_person_first_name AS file2_primary_contact_person_first_name
	,CASE
		WHEN ISNULL(f1.primary_contact_person_first_name, '') = ISNULL(f2.primary_contact_person_first_name, '') THEN 'No Change'
		WHEN f1.primary_contact_person_first_name IS NULL AND f2.primary_contact_person_first_name IS NOT NULL THEN 'Added'
		WHEN f1.primary_contact_person_first_name IS NOT NULL AND f2.primary_contact_person_first_name IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_primary_contact_person_first_name

	,f1.primary_contact_person_last_name AS file1_primary_contact_person_last_name
	,f2.primary_contact_person_last_name AS file2_primary_contact_person_last_name
	,CASE
		WHEN ISNULL(f1.primary_contact_person_last_name, '') = ISNULL(f2.primary_contact_person_last_name, '') THEN 'No Change'
		WHEN f1.primary_contact_person_last_name IS NULL AND f2.primary_contact_person_last_name IS NOT NULL THEN 'Added'
		WHEN f1.primary_contact_person_last_name IS NOT NULL AND f2.primary_contact_person_last_name IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_primary_contact_person_last_name

	,f1.primary_contact_person_phone_number AS file1_primary_contact_person_phone_number
	,f2.primary_contact_person_phone_number AS file2_primary_contact_person_phone_number
	,CASE
		WHEN ISNULL(f1.primary_contact_person_phone_number, '') = ISNULL(f2.primary_contact_person_phone_number, '') THEN 'No Change'
		WHEN f1.primary_contact_person_phone_number IS NULL AND f2.primary_contact_person_phone_number IS NOT NULL THEN 'Added'
		WHEN f1.primary_contact_person_phone_number IS NOT NULL AND f2.primary_contact_person_phone_number IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_primary_contact_person_phone_number

	,f1.primary_contact_person_email AS file1_primary_contact_person_email
	,f2.primary_contact_person_email AS file2_primary_contact_person_email
	,CASE
		WHEN ISNULL(f1.primary_contact_person_email, '') = ISNULL(f2.primary_contact_person_email, '') THEN 'No Change'
		WHEN f1.primary_contact_person_email IS NULL AND f2.primary_contact_person_email IS NOT NULL THEN 'Added'
		WHEN f1.primary_contact_person_email IS NOT NULL AND f2.primary_contact_person_email IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_primary_contact_person_email

	,f1.primary_contact_person_job_title AS file1_primary_contact_person_job_title
	,f2.primary_contact_person_job_title AS file2_primary_contact_person_job_title
	,CASE
		WHEN ISNULL(f1.primary_contact_person_job_title, '') = ISNULL(f2.primary_contact_person_job_title, '') THEN 'No Change'
		WHEN f1.primary_contact_person_job_title IS NULL AND f2.primary_contact_person_job_title IS NOT NULL THEN 'Added'
		WHEN f1.primary_contact_person_job_title IS NOT NULL AND f2.primary_contact_person_job_title IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_primary_contact_person_job_title

	,f1.secondary_contact_person_first_name AS file1_secondary_contact_person_first_name
	,f2.secondary_contact_person_first_name AS file2_secondary_contact_person_first_name
	,CASE
		WHEN ISNULL(f1.secondary_contact_person_first_name, '') = ISNULL(f2.secondary_contact_person_first_name, '') THEN 'No Change'
		WHEN f1.secondary_contact_person_first_name IS NULL AND f2.secondary_contact_person_first_name IS NOT NULL THEN 'Added'
		WHEN f1.secondary_contact_person_first_name IS NOT NULL AND f2.secondary_contact_person_first_name IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_secondary_contact_person_first_name

	,f1.secondary_contact_person_last_name AS file1_secondary_contact_person_last_name
	,f2.secondary_contact_person_last_name AS file2_secondary_contact_person_last_name
	,CASE
		WHEN ISNULL(f1.secondary_contact_person_last_name, '') = ISNULL(f2.secondary_contact_person_last_name, '') THEN 'No Change'
		WHEN f1.secondary_contact_person_last_name IS NULL AND f2.secondary_contact_person_last_name IS NOT NULL THEN 'Added'
		WHEN f1.secondary_contact_person_last_name IS NOT NULL AND f2.secondary_contact_person_last_name IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_secondary_contact_person_last_name

	,f1.secondary_contact_person_phone_number AS file1_secondary_contact_person_phone_number
	,f2.secondary_contact_person_phone_number AS file2_secondary_contact_person_phone_number
	,CASE
		WHEN ISNULL(f1.secondary_contact_person_phone_number, '') = ISNULL(f2.secondary_contact_person_phone_number, '') THEN 'No Change'
		WHEN f1.secondary_contact_person_phone_number IS NULL AND f2.secondary_contact_person_phone_number IS NOT NULL THEN 'Added'
		WHEN f1.secondary_contact_person_phone_number IS NOT NULL AND f2.secondary_contact_person_phone_number IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_secondary_contact_person_phone_number

	,f1.secondary_contact_person_email AS file1_secondary_contact_person_email
	,f2.secondary_contact_person_email AS file2_secondary_contact_person_email
	,CASE
		WHEN ISNULL(f1.secondary_contact_person_email, '') = ISNULL(f2.secondary_contact_person_email, '') THEN 'No Change'
		WHEN f1.secondary_contact_person_email IS NULL AND f2.secondary_contact_person_email IS NOT NULL THEN 'Added'
		WHEN f1.secondary_contact_person_email IS NOT NULL AND f2.secondary_contact_person_email IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_secondary_contact_person_email

	,f1.secondary_contact_person_job_title AS file1_secondary_contact_person_job_title
	,f2.secondary_contact_person_job_title AS file2_secondary_contact_person_job_title
	,CASE
		WHEN ISNULL(f1.secondary_contact_person_job_title, '') = ISNULL(f2.secondary_contact_person_job_title, '') THEN 'No Change'
		WHEN f1.secondary_contact_person_job_title IS NULL AND f2.secondary_contact_person_job_title IS NOT NULL THEN 'Added'
		WHEN f1.secondary_contact_person_job_title IS NOT NULL AND f2.secondary_contact_person_job_title IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_secondary_contact_person_job_title

	,f1.BrandName AS file1_BrandName
	,f2.BrandName AS file2_BrandName
	,CASE
		WHEN ISNULL(f1.BrandName, '') = ISNULL(f2.BrandName, '') THEN 'No Change'
		WHEN f1.BrandName IS NULL AND f2.BrandName IS NOT NULL THEN 'Added'
		WHEN f1.BrandName IS NOT NULL AND f2.BrandName IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_BrandName

	,f1.BrandTypeCode AS file1_BrandTypeCode
	,f2.BrandTypeCode AS file2_BrandTypeCode
	,CASE
		WHEN ISNULL(f1.BrandTypeCode, '') = ISNULL(f2.BrandTypeCode, '') THEN 'No Change'
		WHEN f1.BrandTypeCode IS NULL AND f2.BrandTypeCode IS NOT NULL THEN 'Added'
		WHEN f1.BrandTypeCode IS NOT NULL AND f2.BrandTypeCode IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_BrandTypeCode

	,f1.PartnerFirstName AS file1_PartnerFirstName
	,f2.PartnerFirstName AS file2_PartnerFirstName
	,CASE
		WHEN ISNULL(f1.PartnerFirstName, '') = ISNULL(f2.PartnerFirstName, '') THEN 'No Change'
		WHEN f1.PartnerFirstName IS NULL AND f2.PartnerFirstName IS NOT NULL THEN 'Added'
		WHEN f1.PartnerFirstName IS NOT NULL AND f2.PartnerFirstName IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_PartnerFirstName

	,f1.PartnerLastName AS file1_PartnerLastName
	,f2.PartnerLastName AS file2_PartnerLastName
	,CASE
		WHEN ISNULL(f1.PartnerLastName, '') = ISNULL(f2.PartnerLastName, '') THEN 'No Change'
		WHEN f1.PartnerLastName IS NULL AND f2.PartnerLastName IS NOT NULL THEN 'Added'
		WHEN f1.PartnerLastName IS NOT NULL AND f2.PartnerLastName IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_PartnerLastName

	,f1.PartnerPhoneNumber AS file1_PartnerPhoneNumber
	,f2.PartnerPhoneNumber AS file2_PartnerPhoneNumber
	,CASE
		WHEN ISNULL(f1.PartnerPhoneNumber, '') = ISNULL(f2.PartnerPhoneNumber, '') THEN 'No Change'
		WHEN f1.PartnerPhoneNumber IS NULL AND f2.PartnerPhoneNumber IS NOT NULL THEN 'Added'
		WHEN f1.PartnerPhoneNumber IS NOT NULL AND f2.PartnerPhoneNumber IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_PartnerPhoneNumber

	,f1.PartnerEmail AS file1_PartnerEmail
	,f2.PartnerEmail AS file2_PartnerEmail
	,CASE
		WHEN ISNULL(f1.PartnerEmail, '') = ISNULL(f2.PartnerEmail, '') THEN 'No Change'
		WHEN f1.PartnerEmail IS NULL AND f2.PartnerEmail IS NOT NULL THEN 'Added'
		WHEN f1.PartnerEmail IS NOT NULL AND f2.PartnerEmail IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_PartnerEmail

	,f1.home_nation_code AS file1_home_nation_code
	,f2.home_nation_code AS file2_home_nation_code
	,CASE
		WHEN ISNULL(f1.home_nation_code, '') = ISNULL(f2.home_nation_code, '') THEN 'No Change'
		WHEN f1.home_nation_code IS NULL AND f2.home_nation_code IS NOT NULL THEN 'Added'
		WHEN f1.home_nation_code IS NOT NULL AND f2.home_nation_code IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_home_nation_code

	,f1.main_activity_sic AS file1_main_activity_sic
	,f2.main_activity_sic AS file2_main_activity_sic
	,CASE
		WHEN ISNULL(f1.main_activity_sic, '') = ISNULL(f2.main_activity_sic, '') THEN 'No Change'
		WHEN f1.main_activity_sic IS NULL AND f2.main_activity_sic IS NOT NULL THEN 'Added'
		WHEN f1.main_activity_sic IS NOT NULL AND f2.main_activity_sic IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_main_activity_sic

	,f1.packaging_activity_so AS file1_packaging_activity_so
	,f2.packaging_activity_so AS file2_packaging_activity_so
	,CASE
		WHEN ISNULL(f1.packaging_activity_so, '') = ISNULL(f2.packaging_activity_so, '') THEN 'No Change'
		WHEN f1.packaging_activity_so IS NULL AND f2.packaging_activity_so IS NOT NULL THEN 'Added'
		WHEN f1.packaging_activity_so IS NOT NULL AND f2.packaging_activity_so IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_packaging_activity_so

	,f1.packaging_activity_pf AS file1_packaging_activity_pf
	,f2.packaging_activity_pf AS file2_packaging_activity_pf
	,CASE
		WHEN ISNULL(f1.packaging_activity_pf, '') = ISNULL(f2.packaging_activity_pf, '') THEN 'No Change'
		WHEN f1.packaging_activity_pf IS NULL AND f2.packaging_activity_pf IS NOT NULL THEN 'Added'
		WHEN f1.packaging_activity_pf IS NOT NULL AND f2.packaging_activity_pf IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_packaging_activity_pf

	,f1.packaging_activity_im AS file1_packaging_activity_im
	,f2.packaging_activity_im AS file2_packaging_activity_im
	,CASE
		WHEN ISNULL(f1.packaging_activity_im, '') = ISNULL(f2.packaging_activity_im, '') THEN 'No Change'
		WHEN f1.packaging_activity_im IS NULL AND f2.packaging_activity_im IS NOT NULL THEN 'Added'
		WHEN f1.packaging_activity_im IS NOT NULL AND f2.packaging_activity_im IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_packaging_activity_im

	,f1.packaging_activity_se AS file1_packaging_activity_se
	,f2.packaging_activity_se AS file2_packaging_activity_se
	,CASE
		WHEN ISNULL(f1.packaging_activity_se, '') = ISNULL(f2.packaging_activity_se, '') THEN 'No Change'
		WHEN f1.packaging_activity_se IS NULL AND f2.packaging_activity_se IS NOT NULL THEN 'Added'
		WHEN f1.packaging_activity_se IS NOT NULL AND f2.packaging_activity_se IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_packaging_activity_se

	,f1.packaging_activity_hl AS file1_packaging_activity_hl
	,f2.packaging_activity_hl AS file2_packaging_activity_hl
	,CASE
		WHEN ISNULL(f1.packaging_activity_hl, '') = ISNULL(f2.packaging_activity_hl, '') THEN 'No Change'
		WHEN f1.packaging_activity_hl IS NULL AND f2.packaging_activity_hl IS NOT NULL THEN 'Added'
		WHEN f1.packaging_activity_hl IS NOT NULL AND f2.packaging_activity_hl IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_packaging_activity_hl

	,f1.packaging_activity_om AS file1_packaging_activity_om
	,f2.packaging_activity_om AS file2_packaging_activity_om
	,CASE
		WHEN ISNULL(f1.packaging_activity_om, '') = ISNULL(f2.packaging_activity_om, '') THEN 'No Change'
		WHEN f1.packaging_activity_om IS NULL AND f2.packaging_activity_om IS NOT NULL THEN 'Added'
		WHEN f1.packaging_activity_om IS NOT NULL AND f2.packaging_activity_om IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_packaging_activity_om

	,f1.packaging_activity_sl AS file1_packaging_activity_sl
	,f2.packaging_activity_sl AS file2_packaging_activity_sl
	,CASE
		WHEN ISNULL(f1.packaging_activity_sl, '') = ISNULL(f2.packaging_activity_sl, '') THEN 'No Change'
		WHEN f1.packaging_activity_sl IS NULL AND f2.packaging_activity_sl IS NOT NULL THEN 'Added'
		WHEN f1.packaging_activity_sl IS NOT NULL AND f2.packaging_activity_sl IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_packaging_activity_sl

	,f1.registration_type_code AS file1_registration_type_code
	,f2.registration_type_code AS file2_registration_type_code
	,CASE
		WHEN ISNULL(f1.registration_type_code, '') = ISNULL(f2.registration_type_code, '') THEN 'No Change'
		WHEN f1.registration_type_code IS NULL AND f2.registration_type_code IS NOT NULL THEN 'Added'
		WHEN f1.registration_type_code IS NOT NULL AND f2.registration_type_code IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_registration_type_code

	,f1.produce_blank_packaging_flag AS file1_produce_blank_packaging_flag
	,f2.produce_blank_packaging_flag AS file2_produce_blank_packaging_flag
	,CASE
		WHEN ISNULL(f1.produce_blank_packaging_flag, '') = ISNULL(f2.produce_blank_packaging_flag, '') THEN 'No Change'
		WHEN f1.produce_blank_packaging_flag IS NULL AND f2.produce_blank_packaging_flag IS NOT NULL THEN 'Added'
		WHEN f1.produce_blank_packaging_flag IS NOT NULL AND f2.produce_blank_packaging_flag IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_produce_blank_packaging_flag

	,f1.liable_for_disposal_costs_flag AS file1_liable_for_disposal_costs_flag
	,f2.liable_for_disposal_costs_flag AS file2_liable_for_disposal_costs_flag
	,CASE
		WHEN ISNULL(f1.liable_for_disposal_costs_flag, '') = ISNULL(f2.liable_for_disposal_costs_flag, '') THEN 'No Change'
		WHEN f1.liable_for_disposal_costs_flag IS NULL AND f2.liable_for_disposal_costs_flag IS NOT NULL THEN 'Added'
		WHEN f1.liable_for_disposal_costs_flag IS NOT NULL AND f2.liable_for_disposal_costs_flag IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_liable_for_disposal_costs_flag

	,f1.meet_reporting_requirements_flag AS file1_meet_reporting_requirements_flag
	,f2.meet_reporting_requirements_flag AS file2_meet_reporting_requirements_flag
	,CASE
		WHEN ISNULL(f1.meet_reporting_requirements_flag, '') = ISNULL(f2.meet_reporting_requirements_flag, '') THEN 'No Change'
		WHEN f1.meet_reporting_requirements_flag IS NULL AND f2.meet_reporting_requirements_flag IS NOT NULL THEN 'Added'
		WHEN f1.meet_reporting_requirements_flag IS NOT NULL AND f2.meet_reporting_requirements_flag IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_meet_reporting_requirements_flag

	,f1.companies_house_number AS file1_companies_house_number
	,f2.companies_house_number AS file2_companies_house_number
	,CASE
		WHEN ISNULL(f1.companies_house_number, '') = ISNULL(f2.companies_house_number, '') THEN 'No Change'
		WHEN f1.companies_house_number IS NULL AND f2.companies_house_number IS NOT NULL THEN 'Added'
		WHEN f1.companies_house_number IS NOT NULL AND f2.companies_house_number IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_companies_house_number

	,f1.organisation_type_code AS file1_organisation_type_code
	,f2.organisation_type_code AS file2_organisation_type_code
	,CASE
		WHEN ISNULL(f1.organisation_type_code, '') = ISNULL(f2.organisation_type_code, '') THEN 'No Change'
		WHEN f1.organisation_type_code IS NULL AND f2.organisation_type_code IS NOT NULL THEN 'Added'
		WHEN f1.organisation_type_code IS NOT NULL AND f2.organisation_type_code IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_organisation_type_code

	,f1.organisation_sub_type_code AS file1_organisation_sub_type_code
	,f2.organisation_sub_type_code AS file2_organisation_sub_type_code
	,CASE
		WHEN ISNULL(f1.organisation_sub_type_code, '') = ISNULL(f2.organisation_sub_type_code, '') THEN 'No Change'
		WHEN f1.organisation_sub_type_code IS NULL AND f2.organisation_sub_type_code IS NOT NULL THEN 'Added'
		WHEN f1.organisation_sub_type_code IS NOT NULL AND f2.organisation_sub_type_code IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_organisation_sub_type_code

	,f1.CompanyOrgId AS file1_CompanyOrgId
	,f2.CompanyOrgId AS file2_CompanyOrgId
	,CASE
		WHEN ISNULL(f1.CompanyOrgId, '') = ISNULL(f2.CompanyOrgId, '') THEN 'No Change'
		WHEN f1.CompanyOrgId IS NULL AND f2.CompanyOrgId IS NOT NULL THEN 'Added'
		WHEN f1.CompanyOrgId IS NOT NULL AND f2.CompanyOrgId IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_CompanyOrgId

	,f1.organisation_size AS file1_organisation_size
	,f2.organisation_size AS file2_organisation_size
	,CASE
		WHEN ISNULL(f1.organisation_size, '') = ISNULL(f2.organisation_size, '') THEN 'No Change'
		--WHEN f1.organisation_size IS NULL AND f2.organisation_size IS NOT NULL THEN 'Added'
		--WHEN f1.organisation_size IS NOT NULL AND f2.organisation_size IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_organisation_size

	
	
	FROM file1 f1

	FULL OUTER JOIN file2  f2 ON f2.CompanyOrgId = f1.CompanyOrgId AND ISNULL(f1.subsidiary_id,'') = ISNULL(f2.subsidiary_id,'') AND ISNULL(f1.SubsidiaryOrganisation_ReferenceNumber,'') = ISNULL(f2.SubsidiaryOrganisation_ReferenceNumber,'')
	and  ISNULL(f1.companies_house_number,'') = ISNULL(f2.companies_house_number,'')
	)
	 
	 SELECT DISTINCT
		-- Organisation ID
		CASE 
			WHEN CompanyOrgId_1 IS NULL THEN CompanyOrgId_2
		ELSE CompanyOrgId_1 END CompanyOrgId,
		--CompanyOrgId_1,
		--CompanyOrgId_2,

		
		-- Subsidiary ID
		CASE 
			WHEN subsidiary_id_1 IS NULL THEN subsidiary_id_2
		ELSE subsidiary_id_1 END subsidiary_id,
		--subsidiary_id_1,
		--subsidiary_id_2,
		
		--system_generated_subsidiary_id_1,
		--system_generated_subsidiary_id_2,
		--Organisation Name
		--,f1.organisation_name AS organisation_name_1
		--,f2.organisation_name AS organisation_name_2

		CASE 
			WHEN organisation_name_1 IS NULL THEN organisation_name_2
		ELSE organisation_name_1 END organisation_name,


		-- System Generated Subsidiary ID
		CASE 
			WHEN system_generated_subsidiary_id_1 IS NULL THEN system_generated_subsidiary_id_2
		ELSE system_generated_subsidiary_id_1 END system_generated_subsidiary_id,

		 --Company House Number
		CASE 
			WHEN companies_house_number_1 IS NULL THEN companies_house_number_2
		ELSE companies_house_number_1 END companies_house_number,

		column_name, 
		file1_value,
		file2_value,
		change_status,
		CASE 
			WHEN main_activity_sic_1 IS NULL and main_activity_sic_2 is not null THEN main_activity_sic_1
			WHEN main_activity_sic_1 IS not NULL and main_activity_sic_2 is null THEN main_activity_sic_2
			when main_activity_sic_1 IS not NULL and main_activity_sic_2 is not null and change_status = 'No Change' THEN main_activity_sic_1
			 
		END SIC_Code,
	
		CASE 
			WHEN column_name IN (
								'registered_addr_line1'
								,'registered_addr_line2'
								,'registered_city'
								,'registered_addr_county'
								,'registered_addr_postcode'
								,'registered_addr_country'
								,'registered_addr_phone_number'
								,'principal_addr_line1'
								,'principal_addr_line2'
								,'principal_addr_city'
								,'principal_addr_county'
								,'principal_addr_postcode'
								,'principal_addr_country'
								,'principal_addr_phone_number'
								,'audit_addr_line1'
								,'audit_addr_line2'
								,'audit_addr_city'
								,'audit_addr_county'
								,'audit_addr_postcode'
								,'audit_addr_country'
								,'service_of_notice_addr_line1'
								,'service_of_notice_addr_line2'
								,'service_of_notice_addr_city'
								,'service_of_notice_addr_county'
								,'service_of_notice_addr_postcode'
								,'service_of_notice_addr_country'
								,'service_of_notice_addr_phone_number' ) THEN 'Address change'
	
			WHEN column_name IN (								
								'organisation_name'
								,'companies_house_number'
								,'organisation_type_code'
								,'organisation_size' )	THEN 'Organisation change'


			WHEN column_name IN (
								'approved_person_first_name'
								,'approved_person_last_name'
								,'approved_person_phone_number'
								,'approved_person_email'
								,'approved_person_job_title'
								,'delegated_person_first_name'
								,'delegated_person_last_name'
								,'delegated_person_phone_number'
								,'delegated_person_email'
								,'delegated_person_job_title'
								,'primary_contact_person_first_name'
								,'primary_contact_person_last_name'
								,'primary_contact_person_phone_number'
								,'primary_contact_person_email'
								,'primary_contact_person_job_title'
								,'secondary_contact_person_first_name'
								,'secondary_contact_person_last_name'
								,'secondary_contact_person_phone_number'
								,'secondary_contact_person_email'
								,'secondary_contact_person_job_title' ) THEN 'People change'
			WHEN column_name IN (
								'BrandName'
								,'BrandTypeCode' ) THEN 'Brand change'
			WHEN column_name IN (
								'PartnerFirstName'
								,'PartnerLastName'
								,'PartnerPhoneNumber'
								,'PartnerEmail')	THEN 'Partner change'
			WHEN column_name IN (
								'subsidiary_id'
								) THEN 
				CASE 
					WHEN  file1_VALUE is not null OR file2_VALUE is not null THEN 'Subsidiary change'
					
				ELSE 'Organisation change' END
			WHEN column_name IN ('CompanyOrgId') THEN 
				CASE 
					WHEN  file1_VALUE is not null OR file2_VALUE is not null  THEN 'Member change'
					ELSE 'Organisation change' END
		

		ELSE 'Other change' END Change_Category,

		CASE
			WHEN (file1_CSORPD = 'Compliance Scheme' or  file2_CSORPD = 'Compliance Scheme') and subsidiary_id_1 is null and subsidiary_id_2 is null THEN 'Member'
			WHEN file1_CSORPD = 'Producer' and subsidiary_id_1 is null and subsidiary_id_2 is null THEN 'Parent'
		Else 'Child' END Parent_or_Member_and_Child

		,file1_CSORPD
		,file2_CSORPD
		,organisation_size_1
		,organisation_size_2
					

		FROM (
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,
				'subsidiary_id' AS column_name, 
				file1_subsidiary_id AS file1_value,
				file2_subsidiary_id AS file2_value,
				change_status_subsidiary_id AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
				
			FROM resultfile
			UNION ALL
			--SELECT 
			--	CompanyOrgId_1,
			--	CompanyOrgId_2,
			--	subsidiary_id_1,
			--	subsidiary_id_2,
			--	organisation_name_1,
			--	organisation_name_2,
			--	system_generated_subsidiary_id_1,
			--	system_generated_subsidiary_id_2,
			--	companies_house_number_1,
			--	companies_house_number_2,
			--	'SubsidiaryOrganisation_ReferenceNumber' AS column_name, 
			--	--file1_SubsidiaryOrganisation_ReferenceNumber AS file1_value,
			--	--file2_SubsidiaryOrganisation_ReferenceNumber AS file2_value,
			--	change_status_subsidiary_id AS change_status,
			--	file1_CSORPD,
			--	file2_CSORPD,
			--	main_activity_sic_1,
			--	main_activity_sic_2, organisation_size_1, organisation_size_2
			--FROM resultfile
			--UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,
				'organisation_name' AS column_name, 
				CAST(file1_organisation_name AS VARCHAR) AS file1_value,
				CAST(file2_organisation_name AS VARCHAR) AS file2_value,
				change_status_organisation_name AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,
				'companies_house_number' AS column_name, 
				CAST(file1_companies_house_number AS VARCHAR (MAX)) AS file1_value,
				CAST(file2_companies_house_number AS VARCHAR (MAX)) AS file2_value,
				change_status_companies_house_number AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,				
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,
				'organisation_type_code' AS column_name, 
				CAST(file1_organisation_type_code AS VARCHAR (MAX)) AS file1_value,
				CAST(file2_organisation_type_code AS VARCHAR (MAX)) AS file2_value,
				change_status_organisation_type_code AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,				
				'organisation_sub_type_code' AS column_name, 
				CAST(file1_organisation_sub_type_code AS VARCHAR (MAX)) AS file1_value,
				CAST(file2_organisation_sub_type_code AS VARCHAR (MAX)) AS file2_value,
				change_status_organisation_sub_type_code AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,
				'registered_addr_line1' AS column_name, 
				file1_registered_addr_line1 AS file1_value,
				file2_registered_addr_line1 AS file2_value,
				change_status_registered_addr_line1 AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,
				'registered_addr_line2' AS column_name, 
				file1_registered_addr_line2 AS file1_value,
				file2_registered_addr_line2 AS file2_value,
				change_status_registered_addr_line2 AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,
				'registered_city' AS column_name, 
				file1_registered_city AS file1_value,
				file2_registered_city AS file2_value,
				change_status_registered_city AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,
				'registered_addr_county' AS column_name, 
				file1_registered_addr_county AS file1_value,
				file2_registered_addr_county AS file2_value,
				change_status_registered_addr_county AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,
				'registered_addr_postcode' AS column_name, 
				file1_registered_addr_postcode AS file1_value,
				file2_registered_addr_postcode AS file2_value,
				change_status_registered_addr_postcode AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,				
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,
				'registered_addr_country' AS column_name, 
				file1_registered_addr_country AS file1_value,
				file2_registered_addr_country AS file2_value,
				change_status_registered_addr_country AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,
				'registered_addr_phone_number' AS column_name, 
				file1_registered_addr_phone_number AS file1_value,
				file2_registered_addr_phone_number AS file2_value,
				change_status_registered_addr_phone_number AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,				
				'principal_addr_line1' AS column_name, 
				file1_principal_addr_line1 AS file1_value,
				file2_principal_addr_line1 AS file2_value,
				change_status_principal_addr_line1 AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,				
				'principal_addr_line2' AS column_name, 
				file1_principal_addr_line2 AS file1_value,
				file2_principal_addr_line2 AS file2_value,
				change_status_principal_addr_line2 AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
	
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,				
				'principal_addr_city' AS column_name, 
				file1_principal_addr_city AS file1_value,
				file2_principal_addr_city AS file2_value,
				change_status_principal_addr_city AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,
				'principal_addr_county' AS column_name, 
				file1_principal_addr_county AS file1_value,
				file2_principal_addr_county AS file2_value,
				change_status_principal_addr_county AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,				
				'principal_addr_postcode' AS column_name, 
				file1_principal_addr_postcode AS file1_value,
				file2_principal_addr_postcode AS file2_value,
				change_status_principal_addr_postcode AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,				
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,
				'principal_addr_country' AS column_name, 
				file1_principal_addr_country AS file1_value,
				file2_principal_addr_country AS file2_value,
				change_status_principal_addr_country AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,				
				'principal_addr_phone_number' AS column_name, 
				file1_principal_addr_phone_number AS file1_value,
				file2_principal_addr_phone_number AS file2_value,
				change_status_principal_addr_phone_number AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile	
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,
				'audit_addr_line1' AS column_name, 
				file1_audit_addr_line1 AS file1_value,
				file2_audit_addr_line1 AS file2_value,
				change_status_audit_addr_line1 AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,				
				'audit_addr_line2' AS column_name, 
				file1_audit_addr_line2 AS file1_value,
				file2_audit_addr_line2 AS file2_value,
				change_status_audit_addr_line2 AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,				
				'audit_addr_city' AS column_name, 
				file1_audit_addr_city AS file1_value,
				file2_audit_addr_city AS file2_value,
				change_status_audit_addr_city AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,				
				'audit_addr_county' AS column_name, 
				file1_audit_addr_county AS file1_value,
				file2_audit_addr_county AS file2_value,
				change_status_audit_addr_county AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,				
				'audit_addr_postcode' AS column_name, 
				file1_audit_addr_postcode AS file1_value,
				file2_audit_addr_postcode AS file2_value,
				change_status_audit_addr_postcode AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,				
				'audit_addr_country' AS column_name, 
				file1_audit_addr_country AS file1_value,
				file2_audit_addr_country AS file2_value,
				change_status_audit_addr_country AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,				
				'service_of_notice_addr_line1' AS column_name, 
				file1_service_of_notice_addr_line1 AS file1_value,
				file2_service_of_notice_addr_line1 AS file2_value,
				change_status_service_of_notice_addr_line1 AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,				
				'service_of_notice_addr_line2' AS column_name, 
				file1_service_of_notice_addr_line2 AS file1_value,
				file2_service_of_notice_addr_line2 AS file2_value,
				change_status_service_of_notice_addr_line2 AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,				
				'service_of_notice_addr_city' AS column_name, 
				file1_service_of_notice_addr_city AS file1_value,
				file2_service_of_notice_addr_city AS file2_value,
				change_status_service_of_notice_addr_city AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,				
				'service_of_notice_addr_county' AS column_name, 
				file1_service_of_notice_addr_county AS file1_value,
				file2_service_of_notice_addr_county AS file2_value,
				change_status_service_of_notice_addr_county AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,		
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,				
				'service_of_notice_addr_postcode' AS column_name, 
				file1_service_of_notice_addr_postcode AS file1_value,
				file2_service_of_notice_addr_postcode AS file2_value,
				change_status_service_of_notice_addr_postcode AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,			
				'service_of_notice_addr_country' AS column_name, 
				file1_service_of_notice_addr_country AS file1_value,
				file2_service_of_notice_addr_country AS file2_value,
				change_status_service_of_notice_addr_country AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,				
				'service_of_notice_addr_phone_number' AS column_name, 
				file1_service_of_notice_addr_phone_number AS file1_value,
				file2_service_of_notice_addr_phone_number AS file2_value,
				change_status_service_of_notice_addr_phone_number AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,				
				'approved_person_first_name' AS column_name, 
				file1_approved_person_first_name AS file1_value,
				file2_approved_person_first_name AS file2_value,
				change_status_approved_person_first_name AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,				
				'approved_person_last_name' AS column_name, 
				file1_approved_person_last_name AS file1_value,
				file2_approved_person_last_name AS file2_value,
				change_status_approved_person_last_name AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,				
				'approved_person_phone_number' AS column_name, 
				file1_approved_person_phone_number AS file1_value,
				file2_approved_person_phone_number AS file2_value,
				change_status_approved_person_phone_number AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,				
				'approved_person_email' AS column_name, 
				file1_approved_person_email AS file1_value,
				file2_approved_person_email AS file2_value,
				change_status_approved_person_email AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,				
				'approved_person_job_title' AS column_name, 
				file1_approved_person_job_title AS file1_value,
				file2_approved_person_job_title AS file2_value,
				change_status_approved_person_job_title AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,
				'delegated_person_first_name' AS column_name, 
				file1_delegated_person_first_name AS file1_value,
				file2_delegated_person_first_name AS file2_value,
				change_status_delegated_person_first_name AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,
				'delegated_person_last_name' AS column_name, 
				file1_delegated_person_last_name AS file1_value,
				file2_delegated_person_last_name AS file2_value,
				change_status_delegated_person_last_name AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,
				'delegated_person_phone_number' AS column_name, 
				file1_delegated_person_phone_number AS file1_value,
				file2_delegated_person_phone_number AS file2_value,
				change_status_delegated_person_phone_number AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,
				'delegated_person_email' AS column_name, 
				file1_delegated_person_email AS file1_value,
				file2_delegated_person_email AS file2_value,
				change_status_delegated_person_email AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,
				'delegated_person_job_title' AS column_name, 
				file1_delegated_person_job_title AS file1_value,
				file2_delegated_person_job_title AS file2_value,
				change_status_delegated_person_job_title AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,
				'primary_contact_person_first_name' AS column_name, 
				file1_primary_contact_person_first_name AS file1_value,
				file2_primary_contact_person_first_name AS file2_value,
				change_status_primary_contact_person_first_name AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,
				'primary_contact_person_last_name' AS column_name, 
				file1_primary_contact_person_last_name AS file1_value,
				file2_primary_contact_person_last_name AS file2_value,
				change_status_primary_contact_person_last_name AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,
				'primary_contact_person_phone_number' AS column_name, 
				file1_primary_contact_person_phone_number AS file1_value,
				file2_primary_contact_person_phone_number AS file2_value,
				change_status_primary_contact_person_phone_number AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
	
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,
				'primary_contact_person_email' AS column_name, 
				file1_primary_contact_person_email AS file1_value,
				file2_primary_contact_person_email AS file2_value,
				change_status_primary_contact_person_email AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,
				'primary_contact_person_job_title' AS column_name, 
				file1_primary_contact_person_job_title AS file1_value,
				file2_primary_contact_person_job_title AS file2_value,
				change_status_primary_contact_person_job_title AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,
				'secondary_contact_person_first_name' AS column_name, 
				file1_secondary_contact_person_first_name AS file1_value,
				file2_secondary_contact_person_first_name AS file2_value,
				change_status_secondary_contact_person_first_name AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,
				'secondary_contact_person_last_name' AS column_name, 
				file1_secondary_contact_person_last_name AS file1_value,
				file2_secondary_contact_person_last_name AS file2_value,
				change_status_secondary_contact_person_last_name AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,
				'secondary_contact_person_phone_number' AS column_name, 
				file1_secondary_contact_person_phone_number AS file1_value,
				file2_secondary_contact_person_phone_number AS file2_value,
				change_status_secondary_contact_person_phone_number AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,
				'secondary_contact_person_email' AS column_name, 
				file1_secondary_contact_person_email AS file1_value,
				file2_secondary_contact_person_email AS file2_value,
				change_status_secondary_contact_person_email AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,
				'secondary_contact_person_job_title' AS column_name, 
				file1_secondary_contact_person_job_title AS file1_value,
				file2_secondary_contact_person_job_title AS file2_value,
				change_status_secondary_contact_person_job_title AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,
				'BrandName' AS column_name, 
				file1_BrandName AS file1_value,
				file2_BrandName AS file2_value,
				change_status_BrandName AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,
				'BrandTypeCode' AS column_name, 
				file1_BrandTypeCode AS file1_value,
				file2_BrandTypeCode AS file2_value,
				change_status_BrandTypeCode AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
				
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,
				'PartnerFirstName' AS column_name, 
				file1_PartnerFirstName AS file1_value,
				file2_PartnerFirstName AS file2_value,
				change_status_PartnerFirstName AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,				
				'PartnerLastName' AS column_name, 
				file1_PartnerLastName AS file1_value,
				file2_PartnerLastName AS file2_value,
				change_status_PartnerLastName AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,
				'PartnerPhoneNumber' AS column_name, 
				file1_PartnerPhoneNumber AS file1_value,
				file2_PartnerPhoneNumber AS file2_value,
				change_status_PartnerPhoneNumber AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,
				'PartnerEmail' AS column_name, 
				file1_PartnerEmail AS file1_value,
				file2_PartnerEmail AS file2_value,
				change_status_PartnerEmail AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,
				'home_nation_code' AS column_name, 
				CAST(file1_home_nation_code AS VARCHAR(MAX)) AS file1_value,
				CAST(file2_home_nation_code AS VARCHAR(MAX)) AS file2_value,
				change_status_home_nation_code AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
	
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,
				'mainactivitysic' AS column_name, 
				file1_main_activity_sic AS file1_value,
				file2_main_activity_sic AS file2_value,
				change_status_main_activity_sic AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,
				'packaging_activity_so' AS column_name, 
				file1_packaging_activity_so AS file1_value,
				file2_packaging_activity_so AS file2_value,
				change_status_packaging_activity_so AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,
				'packaging_activity_pf' AS column_name, 
				file1_packaging_activity_pf AS file1_value,
				file2_packaging_activity_pf AS file2_value,
				change_status_packaging_activity_pf AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,
				'packaging_activity_im' AS column_name, 
				file1_packaging_activity_im AS file1_value,
				file2_packaging_activity_im AS file2_value,
				change_status_packaging_activity_im AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,
				'packaging_activity_se' AS column_name, 
				file1_packaging_activity_se AS file1_value,
				file2_packaging_activity_se AS file2_value,
				change_status_packaging_activity_se AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,
				'packaging_activity_hl' AS column_name, 
				file1_packaging_activity_hl AS file1_value,
				file2_packaging_activity_hl AS file2_value,
				change_status_packaging_activity_hl AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,
				'packaging_activity_om' AS column_name, 
				file1_packaging_activity_om AS file1_value,
				file2_packaging_activity_om AS file2_value,
				change_status_packaging_activity_om AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,
				'packaging_activity_sl' AS column_name, 
				file1_packaging_activity_sl AS file1_value,
				file2_packaging_activity_sl AS file2_value,
				change_status_packaging_activity_sl AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,
				'registration_type_code' AS column_name, 
				file1_registration_type_code AS file1_value,
				file2_registration_type_code AS file2_value,
				change_status_registration_type_code AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,
				'produce_blank_packaging_flag' AS column_name, 
				CAST(file1_produce_blank_packaging_flag AS VARCHAR (MAX)) AS file1_value,
				CAST(file2_produce_blank_packaging_flag AS VARCHAR (MAX)) AS file2_value,
				change_status_produce_blank_packaging_flag AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,
				'liable_for_disposal_costs_flag' AS column_name, 
				CAST(file1_liable_for_disposal_costs_flag AS VARCHAR (MAX)) AS file1_value,
				CAST(file2_liable_for_disposal_costs_flag AS VARCHAR (MAX)) AS file2_value,
				change_status_liable_for_disposal_costs_flag AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,
				'meet_reporting_requirements_flag' AS column_name, 
				CAST(file1_meet_reporting_requirements_flag AS VARCHAR (MAX)) AS file1_value,
				CAST(file2_meet_reporting_requirements_flag AS VARCHAR (MAX)) AS file2_value,
				change_status_meet_reporting_requirements_flag AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,
				'trading_name' AS column_name, 
				CAST(file1_trading_name AS VARCHAR) AS file1_value,
				CAST(file2_trading_name AS VARCHAR) AS file2_value,
				change_status_trading_name AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,
				'turnover' AS column_name, 
				cast(cast(file1_turnover as decimal) as varchar) AS file1_value,
				cast(cast(file2_turnover as decimal) as varchar) AS file2_value,
				change_status_turnover AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,
				'total_tonnage' AS column_name, 
				CAST(file1_total_tonnage AS VARCHAR) AS file1_value,
				CAST(file2_total_tonnage AS VARCHAR) AS file2_value,
				change_status_total_tonnage AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,
				'CompanyOrgId' AS column_name, 
				CAST(file1_CompanyOrgId AS VARCHAR) AS file1_value,
				CAST(file2_CompanyOrgId AS VARCHAR) AS file2_value,
				change_status_CompanyOrgId AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
                main_activity_sic_2,
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
			UNION ALL
			SELECT 
				CompanyOrgId_1,
				CompanyOrgId_2,
				subsidiary_id_1,
				subsidiary_id_2,
				organisation_name_1,
				organisation_name_2,
				system_generated_subsidiary_id_1,
				system_generated_subsidiary_id_2,
				companies_house_number_1,
				companies_house_number_2,
				'organisation_size' AS column_name, 
				file1_organisation_size AS file1_value,
				file2_organisation_size AS file2_value,
				change_status_organisation_size AS change_status,
				file1_CSORPD,
				file2_CSORPD,
				main_activity_sic_1,
				main_activity_sic_2, 
				organisation_size_1,
				organisation_size_2
				
			FROM resultfile
		

		) AS unpivoted_table

END