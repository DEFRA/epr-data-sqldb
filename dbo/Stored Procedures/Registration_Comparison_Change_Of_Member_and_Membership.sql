CREATE PROC [dbo].[Registration_Comparison_Change_Of_Member_and_Membership] @CompanyRegID_1 [VARCHAR](4000),@CompanyRegID_2 [VARCHAR](4000) AS
BEGIN
WITH
/****************************************************************************************************************************
	History:
	Updated: 2025-07-15:	DK001:	Ticket - 576286: Subsidiary Retrofit column reference removal 
	Updated: 2025-07-24:	YM002:	Ticket - 582597 & 582613: Change of membership logic to be updated to include new Joiner and leaver codes
	Upated: 2025-09-12:		JP001: Ticket - 610935: Optimisation - added parameters CTE and CASE and cross join to get comparison fields into the output
******************************************************************************************************************************/
file1 AS (
SELECT CompanyOrgId
      ,subsidiary_id
	  --,SubsidiaryOrganisation_ReferenceNumber
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
	  ,leaver_code
	  ,leaver_date
	  ,organisation_change_reason
	  ,joiner_date
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
	  --,SubsidiaryOrganisation_ReferenceNumber
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
	  ,leaver_code
	  ,leaver_date
	  ,organisation_change_reason
	  ,joiner_date
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
  --,f1.SubsidiaryOrganisation_ReferenceNumber AS system_generated_subsidiary_id_1
  --,f2.SubsidiaryOrganisation_ReferenceNumber AS system_generated_subsidiary_id_2
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
  ,f1.leaver_code AS leaver_code_1
  ,f2.leaver_code AS leaver_code_2
  ,f1.joiner_date AS joiner_date_1
  ,f2.joiner_date AS joiner_date_2
  ,f1.leaver_date AS leaver_date_1
  ,f2.leaver_date AS leaver_date_2
  ,f1.organisation_change_reason AS organisation_change_reason_1
  ,f2.organisation_change_reason AS organisation_change_reason_2
	/*YM002*/		
	,CASE 
		WHEN 
		    ISNULL(f1.subsidiary_id, '') = ISNULL(f2.subsidiary_id, '') and ISNULL(f1.leaver_date, '') = ISNULL(f2.leaver_date, '') OR
		    (f1.subsidiary_id IS NOT NULL AND f1.leaver_date IS NOT NULL AND f2.subsidiary_id IS NULL) OR
			(f1.subsidiary_id IS NULL AND f2.leaver_date IS NOT NULL AND f2.subsidiary_id IS NOT NULL) -- Added Ticket 550897
		THEN 'No Change'

		WHEN 
		    (f1.subsidiary_id IS NULL AND f2.subsidiary_id IS NOT NULL AND f2.leaver_date IS NULL) OR -- 1 VS 1 
		    (f1.subsidiary_id IS NULL AND f2.subsidiary_id IS NOT NULL AND f2.joiner_date IS NOT NULL) OR -- 1 VS 2 
		    (f1.subsidiary_id IS NOT NULL AND f1.leaver_date IS NOT NULL AND f2.subsidiary_id IS NOT NULL AND f2.leaver_date IS NULL) OR -- 2 VS 1
			(f1.subsidiary_id IS NOT NULL AND f1.leaver_date IS NOT NULL AND f2.subsidiary_id IS NOT NULL AND f2.leaver_date IS NULL AND f2.joiner_date IS NOT NULL) -- 2 VS 2
		THEN 'Added'

		WHEN 
		    (f1.subsidiary_id IS NOT NULL AND f2.subsidiary_id IS NULL) OR -- 1 VS 1 and 2 VS 2
		    (f1.subsidiary_id IS NOT NULL AND f2.subsidiary_id IS NOT NULL AND f2.leaver_date IS NOT NULL) OR -- 1 VS 2
		    (f1.subsidiary_id IS NOT NULL AND f1.leaver_date IS NULL AND f2.subsidiary_id IS NULL) OR -- 2 VS 1
		    (f1.subsidiary_id IS NOT NULL AND f1.leaver_date IS NULL AND f2.subsidiary_id IS NOT NULL AND f2.leaver_date IS NOT NULL) OR -- 2 VS 2
			(f1.subsidiary_id IS NULL AND f1.leaver_date IS NULL AND f2.subsidiary_id IS NOT NULL AND f2.leaver_date IS NOT NULL)-- or -- 1 VS 2 new condition !!!!
		THEN 'Removed'
    
    ELSE 'Changed' 
END AS change_status_subsidiary_id
	
	/*,CASE 
		WHEN 
		    ISNULL(f1.subsidiary_id, '') = ISNULL(f2.subsidiary_id, '') and ISNULL(f1.leaver_code, '') = ISNULL(f2.leaver_code, '') OR
		    (f1.subsidiary_id IS NOT NULL AND f1.leaver_code IS NOT NULL AND f2.subsidiary_id IS NULL) OR
			(f1.subsidiary_id IS NULL AND f2.leaver_code IS NOT NULL AND f2.subsidiary_id IS NOT NULL) -- Added Ticket 550897
		THEN 'No Change'

		WHEN 
		    (f1.subsidiary_id IS NULL AND f2.subsidiary_id IS NOT NULL) OR -- 1 VS 1 
		    (f1.subsidiary_id IS NULL AND f2.subsidiary_id IS NOT NULL AND f2.joiner_date IS NOT NULL) OR -- 1 VS 2 
		    (f1.subsidiary_id IS NOT NULL AND f1.leaver_code IS NOT NULL AND f2.subsidiary_id IS NOT NULL AND f2.leaver_code IS NULL) OR -- 2 VS 1
			(f1.subsidiary_id IS NOT NULL AND f1.leaver_code IS NOT NULL AND f2.subsidiary_id IS NOT NULL AND f2.leaver_code IS NULL AND f2.joiner_date IS NOT NULL) -- 2 VS 2
		THEN 'Added'

		WHEN 
		    (f1.subsidiary_id IS NOT NULL AND f2.subsidiary_id IS NULL) OR -- 1 VS 1 and 2 VS 2
		    (f1.subsidiary_id IS NOT NULL AND f2.subsidiary_id IS NOT NULL AND f2.leaver_code IS NOT NULL) OR -- 1 VS 2
		    (f1.subsidiary_id IS NOT NULL AND f1.leaver_code IS NULL AND f2.subsidiary_id IS NULL) OR -- 2 VS 1
		    (f1.subsidiary_id IS NOT NULL AND f1.leaver_code IS NULL AND f2.subsidiary_id IS NOT NULL AND f2.leaver_code IS NOT NULL) OR -- 2 VS 2
			(f1.subsidiary_id IS NULL AND f1.leaver_code IS NULL AND f2.subsidiary_id IS NOT NULL AND f2.leaver_code IS NOT NULL)-- or -- 1 VS 2 new condition !!!!
		THEN 'Removed'
    
    ELSE 'Changed' 
END AS change_status_subsidiary_id */


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
	/*YM002*/
	,CASE 
		WHEN 
		    ISNULL(f1.CompanyOrgId, '') = ISNULL(f2.CompanyOrgId, '') and ISNULL(f1.leaver_date, '') = ISNULL(f2.leaver_date, '') OR
		    (f1.CompanyOrgId IS NOT NULL AND f1.leaver_date IS NOT NULL AND f2.CompanyOrgId IS NULL)
		THEN 'No Change'

		WHEN 
		    (f1.CompanyOrgId IS NULL AND f2.CompanyOrgId IS NOT NULL AND f2.leaver_date IS NULL) OR -- 1 VS 1 
		    (f1.CompanyOrgId IS NULL AND f2.CompanyOrgId IS NOT NULL AND f2.joiner_date IS NOT NULL) OR -- 1 VS 2 
		    (f1.CompanyOrgId IS NOT NULL AND f1.leaver_date IS NOT NULL AND f2.CompanyOrgId IS NOT NULL AND f2.leaver_date IS NULL) OR -- 2 VS 1
			(f1.CompanyOrgId IS NOT NULL AND f1.leaver_date IS NOT NULL AND f2.CompanyOrgId IS NOT NULL AND f2.leaver_date IS NULL AND f2.joiner_date IS NOT NULL) -- 2 VS 2
		THEN 'Added'

		WHEN 
		    (f1.CompanyOrgId IS NOT NULL AND f2.CompanyOrgId IS NULL) OR -- 1 VS 1 and 2 VS 2
		    (f1.CompanyOrgId IS NOT NULL AND f2.CompanyOrgId IS NOT NULL AND f2.leaver_date IS NOT NULL) OR -- 1 VS 2
		    (f1.CompanyOrgId IS NOT NULL AND f1.leaver_date IS NULL AND f2.CompanyOrgId IS NULL) OR -- 2 VS 1
		    (f1.CompanyOrgId IS NOT NULL AND f1.leaver_date IS NULL AND f2.CompanyOrgId IS NOT NULL AND f2.leaver_date IS NOT NULL) OR -- 2 VS 2
			(f1.CompanyOrgId IS NULL AND f1.leaver_date IS NULL AND f2.CompanyOrgId IS NOT NULL AND f2.leaver_date IS NOT NULL)-- or -- 1 VS 2 new condition !!!!
		THEN 'Removed'
    ELSE 'Changed' 
END AS change_status_CompanyOrgId
	/*,CASE 
		WHEN 
		    ISNULL(f1.CompanyOrgId, '') = ISNULL(f2.CompanyOrgId, '') and ISNULL(f1.leaver_code, '') = ISNULL(f2.leaver_code, '') OR
		    (f1.CompanyOrgId IS NOT NULL AND f1.leaver_code IS NOT NULL AND f2.CompanyOrgId IS NULL)
		THEN 'No Change'

		WHEN 
		    (f1.CompanyOrgId IS NULL AND f2.CompanyOrgId IS NOT NULL) OR -- 1 VS 1 
		    (f1.CompanyOrgId IS NULL AND f2.CompanyOrgId IS NOT NULL AND f2.joiner_date IS NOT NULL) OR -- 1 VS 2 
		    (f1.CompanyOrgId IS NOT NULL AND f1.leaver_code IS NOT NULL AND f2.CompanyOrgId IS NOT NULL AND f2.leaver_code IS NULL) OR -- 2 VS 1
			(f1.CompanyOrgId IS NOT NULL AND f1.leaver_code IS NOT NULL AND f2.CompanyOrgId IS NOT NULL AND f2.leaver_code IS NULL AND f2.joiner_date IS NOT NULL) -- 2 VS 2
		THEN 'Added'

		WHEN 
		    (f1.CompanyOrgId IS NOT NULL AND f2.CompanyOrgId IS NULL) OR -- 1 VS 1 and 2 VS 2
		    (f1.CompanyOrgId IS NOT NULL AND f2.CompanyOrgId IS NOT NULL AND f2.leaver_code IS NOT NULL) OR -- 1 VS 2
		    (f1.CompanyOrgId IS NOT NULL AND f1.leaver_code IS NULL AND f2.CompanyOrgId IS NULL) OR -- 2 VS 1
		    (f1.CompanyOrgId IS NOT NULL AND f1.leaver_code IS NULL AND f2.CompanyOrgId IS NOT NULL AND f2.leaver_code IS NOT NULL) OR -- 2 VS 2
			(f1.CompanyOrgId IS NULL AND f1.leaver_code IS NULL AND f2.CompanyOrgId IS NOT NULL AND f2.leaver_code IS NOT NULL)-- or -- 1 VS 2 new condition !!!!
		THEN 'Removed'
    
    ELSE 'Changed' 
END AS change_status_CompanyOrgId*/

	,f1.organisation_size AS file1_organisation_size
	,f2.organisation_size AS file2_organisation_size
	,CASE
		WHEN ISNULL(f1.organisation_size, '') = ISNULL(f2.organisation_size, '') THEN 'No Change'
		WHEN f1.organisation_size IS NULL AND f2.organisation_size IS NOT NULL THEN 'Added'
		WHEN f1.organisation_size IS NOT NULL AND f2.organisation_size IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_organisation_size

	,f1.leaver_code AS file1_leaver_code
	,f2.leaver_code AS file2_leaver_code
	,CASE
		WHEN ISNULL(f1.leaver_code, '') = ISNULL(f2.leaver_code, '') THEN 'No Change'
		WHEN f1.leaver_code IS NULL AND f2.leaver_code IS NOT NULL THEN 'Added'
		WHEN f1.leaver_code IS NOT NULL AND f2.leaver_code IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_leaver_code

	,f1.leaver_date AS file1_leaver_date
	,f2.leaver_date AS file2_leaver_date
	,CASE
		WHEN ISNULL(f1.leaver_date, '') = ISNULL(f2.leaver_date, '') THEN 'No Change'
		WHEN f1.leaver_date IS NULL AND f2.leaver_date IS NOT NULL THEN 'Added'
		WHEN f1.leaver_date IS NOT NULL AND f2.leaver_date IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_leaver_date

	,f1.joiner_date AS file1_joiner_date
	,f2.joiner_date AS file2_joiner_date
	,CASE
		WHEN ISNULL(f1.joiner_date, '') = ISNULL(f2.joiner_date, '') THEN 'No Change'
		WHEN f1.joiner_date IS NULL AND f2.joiner_date IS NOT NULL THEN 'Added'
		WHEN f1.joiner_date IS NOT NULL AND f2.joiner_date IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_joiner_date

	,f1.organisation_change_reason  AS file1_organisation_change_reason
	,f1.organisation_change_reason  AS file2_organisation_change_reason
	,CASE
		WHEN ISNULL(f1.organisation_change_reason, '') = ISNULL(f2.organisation_change_reason, '') THEN 'No Change'
		WHEN f1.organisation_change_reason IS NULL AND f2.organisation_change_reason IS NOT NULL THEN 'Added'
		WHEN f1.organisation_change_reason IS NOT NULL AND f2.organisation_change_reason IS NULL THEN 'Removed'
		ELSE 'Changed' 
	END AS change_status_organisation_change_reason
	FROM file1 f1

	FULL OUTER JOIN file2  f2 ON   f1.CompanyOrgId = f2.CompanyOrgId AND
    COALESCE(f1.subsidiary_id, '') = COALESCE(f2.subsidiary_id, '') AND 
    --COALESCE(f1.SubsidiaryOrganisation_ReferenceNumber, '') = COALESCE(f2.SubsidiaryOrganisation_ReferenceNumber, '') AND
    COALESCE(f1.companies_house_number, '') = COALESCE(f2.companies_house_number, '')
	),

/*JP001*/
change_parameters AS (
    SELECT 'subsidiary_id' AS column_name, 'file1_subsidiary_id' AS file1_col_name, 'file2_subsidiary_id' AS file2_col_name, 'change_status_subsidiary_id' AS change_status
    UNION ALL SELECT 'organisation_name', 'file1_organisation_name', 'file2_organisation_name', 'change_status_organisation_name'
    UNION ALL SELECT 'companies_house_number', 'file1_companies_house_number', 'file2_companies_house_number', 'change_status_companies_house_number'
    UNION ALL SELECT 'organisation_type_code', 'file1_organisation_type_code', 'file2_organisation_type_code', 'change_status_organisation_type_code'
    UNION ALL SELECT 'organisation_sub_type_code', 'file1_organisation_sub_type_code', 'file2_organisation_sub_type_code', 'change_status_organisation_sub_type_code'
    UNION ALL SELECT 'registered_addr_line1', 'file1_registered_addr_line1', 'file2_registered_addr_line1', 'change_status_registered_addr_line1'
    UNION ALL SELECT 'registered_addr_line2', 'file1_registered_addr_line2', 'file2_registered_addr_line2', 'change_status_registered_addr_line2'
    UNION ALL SELECT 'registered_city', 'file1_registered_city', 'file2_registered_city', 'change_status_registered_city'
    UNION ALL SELECT 'registered_addr_county', 'file1_registered_addr_county', 'file2_registered_addr_county', 'change_status_registered_addr_county'
    UNION ALL SELECT 'registered_addr_postcode', 'file1_registered_addr_postcode', 'file2_registered_addr_postcode', 'change_status_registered_addr_postcode'
    UNION ALL SELECT 'registered_addr_country', 'file1_registered_addr_country', 'file2_registered_addr_country', 'change_status_registered_addr_country'
    UNION ALL SELECT 'registered_addr_phone_number', 'file1_registered_addr_phone_number', 'file2_registered_addr_phone_number', 'change_status_registered_addr_phone_number'
    UNION ALL SELECT 'principal_addr_line1', 'file1_principal_addr_line1', 'file2_principal_addr_line1', 'change_status_principal_addr_line1'
    UNION ALL SELECT 'principal_addr_line2', 'file1_principal_addr_line2', 'file2_principal_addr_line2', 'change_status_principal_addr_line2'
    UNION ALL SELECT 'principal_addr_city', 'file1_principal_addr_city', 'file2_principal_addr_city', 'change_status_principal_addr_city'
    UNION ALL SELECT 'principal_addr_county', 'file1_principal_addr_county', 'file2_principal_addr_county', 'change_status_principal_addr_county'
    UNION ALL SELECT 'principal_addr_postcode', 'file1_principal_addr_postcode', 'file2_principal_addr_postcode', 'change_status_principal_addr_postcode'
    UNION ALL SELECT 'principal_addr_country', 'file1_principal_addr_country', 'file2_principal_addr_country', 'change_status_principal_addr_country'
    UNION ALL SELECT 'principal_addr_phone_number', 'file1_principal_addr_phone_number', 'file2_principal_addr_phone_number', 'change_status_principal_addr_phone_number'
    UNION ALL SELECT 'audit_addr_line1', 'file1_audit_addr_line1', 'file2_audit_addr_line1', 'change_status_audit_addr_line1'
    UNION ALL SELECT 'audit_addr_line2', 'file1_audit_addr_line2', 'file2_audit_addr_line2', 'change_status_audit_addr_line2'
    UNION ALL SELECT 'audit_addr_city', 'file1_audit_addr_city', 'file2_audit_addr_city', 'change_status_audit_addr_city'
    UNION ALL SELECT 'audit_addr_county', 'file1_audit_addr_county', 'file2_audit_addr_county', 'change_status_audit_addr_county'
    UNION ALL SELECT 'audit_addr_postcode', 'file1_audit_addr_postcode', 'file2_audit_addr_postcode', 'change_status_audit_addr_postcode'
    UNION ALL SELECT 'audit_addr_country', 'file1_audit_addr_country', 'file2_audit_addr_country', 'change_status_audit_addr_country'
    UNION ALL SELECT 'service_of_notice_addr_line1', 'file1_service_of_notice_addr_line1', 'file2_service_of_notice_addr_line1', 'change_status_service_of_notice_addr_line1'
    UNION ALL SELECT 'service_of_notice_addr_line2', 'file1_service_of_notice_addr_line2', 'file2_service_of_notice_addr_line2', 'change_status_service_of_notice_addr_line2'
    UNION ALL SELECT 'service_of_notice_addr_city', 'file1_service_of_notice_addr_city', 'file2_service_of_notice_addr_city', 'change_status_service_of_notice_addr_city'
    UNION ALL SELECT 'service_of_notice_addr_county', 'file1_service_of_notice_addr_county', 'file2_service_of_notice_addr_county', 'change_status_service_of_notice_addr_county'
    UNION ALL SELECT 'service_of_notice_addr_postcode', 'file1_service_of_notice_addr_postcode', 'file2_service_of_notice_addr_postcode', 'change_status_service_of_notice_addr_postcode'
    UNION ALL SELECT 'service_of_notice_addr_country', 'file1_service_of_notice_addr_country', 'file2_service_of_notice_addr_country', 'change_status_service_of_notice_addr_country'
    UNION ALL SELECT 'service_of_notice_addr_phone_number', 'file1_service_of_notice_addr_phone_number', 'file2_service_of_notice_addr_phone_number', 'change_status_service_of_notice_addr_phone_number'
    UNION ALL SELECT 'approved_person_first_name', 'file1_approved_person_first_name', 'file2_approved_person_first_name', 'change_status_approved_person_first_name'
    UNION ALL SELECT 'approved_person_last_name', 'file1_approved_person_last_name', 'file2_approved_person_last_name', 'change_status_approved_person_last_name'
    UNION ALL SELECT 'approved_person_phone_number', 'file1_approved_person_phone_number', 'file2_approved_person_phone_number', 'change_status_approved_person_phone_number'
    UNION ALL SELECT 'approved_person_email', 'file1_approved_person_email', 'file2_approved_person_email', 'change_status_approved_person_email'
    UNION ALL SELECT 'approved_person_job_title', 'file1_approved_person_job_title', 'file2_approved_person_job_title', 'change_status_approved_person_job_title'
    UNION ALL SELECT 'delegated_person_first_name', 'file1_delegated_person_first_name', 'file2_delegated_person_first_name', 'change_status_delegated_person_first_name'
    UNION ALL SELECT 'delegated_person_last_name', 'file1_delegated_person_last_name', 'file2_delegated_person_last_name', 'change_status_delegated_person_last_name'
    UNION ALL SELECT 'delegated_person_phone_number', 'file1_delegated_person_phone_number', 'file2_delegated_person_phone_number', 'change_status_delegated_person_phone_number'
    UNION ALL SELECT 'delegated_person_email', 'file1_delegated_person_email', 'file2_delegated_person_email', 'change_status_delegated_person_email'
    UNION ALL SELECT 'delegated_person_job_title', 'file1_delegated_person_job_title', 'file2_delegated_person_job_title', 'change_status_delegated_person_job_title'
    UNION ALL SELECT 'primary_contact_person_first_name', 'file1_primary_contact_person_first_name', 'file2_primary_contact_person_first_name', 'change_status_primary_contact_person_first_name'
    UNION ALL SELECT 'primary_contact_person_last_name', 'file1_primary_contact_person_last_name', 'file2_primary_contact_person_last_name', 'change_status_primary_contact_person_last_name'
    UNION ALL SELECT 'primary_contact_person_phone_number', 'file1_primary_contact_person_phone_number', 'file2_primary_contact_person_phone_number', 'change_status_primary_contact_person_phone_number'
    UNION ALL SELECT 'primary_contact_person_email', 'file1_primary_contact_person_email', 'file2_primary_contact_person_email', 'change_status_primary_contact_person_email'
    UNION ALL SELECT 'primary_contact_person_job_title', 'file1_primary_contact_person_job_title', 'file2_primary_contact_person_job_title', 'change_status_primary_contact_person_job_title'
    UNION ALL SELECT 'secondary_contact_person_first_name', 'file1_secondary_contact_person_first_name', 'file2_secondary_contact_person_first_name', 'change_status_secondary_contact_person_first_name'
    UNION ALL SELECT 'secondary_contact_person_last_name', 'file1_secondary_contact_person_last_name', 'file2_secondary_contact_person_last_name', 'change_status_secondary_contact_person_last_name'
    UNION ALL SELECT 'secondary_contact_person_phone_number', 'file1_secondary_contact_person_phone_number', 'file2_secondary_contact_person_phone_number', 'change_status_secondary_contact_person_phone_number'
    UNION ALL SELECT 'secondary_contact_person_email', 'file1_secondary_contact_person_email', 'file2_secondary_contact_person_email', 'change_status_secondary_contact_person_email'
    UNION ALL SELECT 'secondary_contact_person_job_title', 'file1_secondary_contact_person_job_title', 'file2_secondary_contact_person_job_title', 'change_status_secondary_contact_person_job_title'
    UNION ALL SELECT 'BrandName', 'file1_BrandName', 'file2_BrandName', 'change_status_BrandName'
    UNION ALL SELECT 'BrandTypeCode', 'file1_BrandTypeCode', 'file2_BrandTypeCode', 'change_status_BrandTypeCode'
    UNION ALL SELECT 'PartnerFirstName', 'file1_PartnerFirstName', 'file2_PartnerFirstName', 'change_status_PartnerFirstName'
    UNION ALL SELECT 'PartnerLastName', 'file1_PartnerLastName', 'file2_PartnerLastName', 'change_status_PartnerLastName'
    UNION ALL SELECT 'PartnerPhoneNumber', 'file1_PartnerPhoneNumber', 'file2_PartnerPhoneNumber', 'change_status_PartnerPhoneNumber'
    UNION ALL SELECT 'PartnerEmail', 'file1_PartnerEmail', 'file2_PartnerEmail', 'change_status_PartnerEmail'
    UNION ALL SELECT 'home_nation_code', 'file1_home_nation_code', 'file2_home_nation_code', 'change_status_home_nation_code'
    UNION ALL SELECT 'main_activity_sic', 'file1_main_activity_sic', 'file2_main_activity_sic', 'change_status_main_activity_sic'
    UNION ALL SELECT 'packaging_activity_so', 'file1_packaging_activity_so', 'file2_packaging_activity_so', 'change_status_packaging_activity_so'
    UNION ALL SELECT 'packaging_activity_pf', 'file1_packaging_activity_pf', 'file2_packaging_activity_pf', 'change_status_packaging_activity_pf'
    UNION ALL SELECT 'packaging_activity_im', 'file1_packaging_activity_im', 'file2_packaging_activity_im', 'change_status_packaging_activity_im'
    UNION ALL SELECT 'packaging_activity_se', 'file1_packaging_activity_se', 'file2_packaging_activity_se', 'change_status_packaging_activity_se'
    UNION ALL SELECT 'packaging_activity_hl', 'file1_packaging_activity_hl', 'file2_packaging_activity_hl', 'change_status_packaging_activity_hl'
    UNION ALL SELECT 'packaging_activity_om', 'file1_packaging_activity_om', 'file2_packaging_activity_om', 'change_status_packaging_activity_om'
    UNION ALL SELECT 'packaging_activity_sl', 'file1_packaging_activity_sl', 'file2_packaging_activity_sl', 'change_status_packaging_activity_sl'
    UNION ALL SELECT 'registration_type_code', 'file1_registration_type_code', 'file2_registration_type_code', 'change_status_registration_type_code'
    UNION ALL SELECT 'produce_blank_packaging_flag', 'file1_produce_blank_packaging_flag', 'file2_produce_blank_packaging_flag', 'change_status_produce_blank_packaging_flag'
    UNION ALL SELECT 'liable_for_disposal_costs_flag', 'file1_liable_for_disposal_costs_flag', 'file2_liable_for_disposal_costs_flag', 'change_status_liable_for_disposal_costs_flag'
    UNION ALL SELECT 'meet_reporting_requirements_flag', 'file1_meet_reporting_requirements_flag', 'file2_meet_reporting_requirements_flag', 'change_status_meet_reporting_requirements_flag'
    UNION ALL SELECT 'trading_name', 'file1_trading_name', 'file2_trading_name', 'change_status_trading_name'
    UNION ALL SELECT 'turnover', 'file1_turnover', 'file2_turnover', 'change_status_turnover'
    UNION ALL SELECT 'total_tonnage', 'file1_total_tonnage', 'file2_total_tonnage', 'change_status_total_tonnage'
    UNION ALL SELECT 'CompanyOrgId', 'file1_CompanyOrgId', 'file2_CompanyOrgId', 'change_status_CompanyOrgId'
    UNION ALL SELECT 'organisation_size', 'file1_organisation_size', 'file2_organisation_size', 'change_status_organisation_size'
    UNION ALL SELECT 'leaver_code', 'file1_leaver_code', 'file2_leaver_code', 'change_status_leaver_code'
    UNION ALL SELECT 'leaver_date', 'file1_leaver_date', 'file2_leaver_date', 'change_status_leaver_date'
    UNION ALL SELECT 'joiner_date', 'file1_joiner_date', 'file2_joiner_date', 'change_status_joiner_date'
    UNION ALL SELECT 'organisation_change_reason', 'file1_organisation_change_reason', 'file2_organisation_change_reason', 'change_status_organisation_change_reason'
),

pre_out as (SELECT DISTINCT
    -- Organisation ID
    CASE 
        WHEN CompanyOrgId_1 IS NULL THEN CompanyOrgId_2
        ELSE CompanyOrgId_1 
    END AS CompanyOrgId,
    
    -- Subsidiary ID
    CASE 
        WHEN subsidiary_id_1 IS NULL THEN subsidiary_id_2
        ELSE subsidiary_id_1 
    END AS subsidiary_id,
    
    -- Organisation Name
    CASE 
        WHEN organisation_name_1 IS NULL THEN organisation_name_2
        ELSE organisation_name_1 
    END AS organisation_name,
    
    -- System Generated Subsidiary ID
    --CASE 
    --    WHEN system_generated_subsidiary_id_1 IS NULL THEN system_generated_subsidiary_id_2
    --    ELSE system_generated_subsidiary_id_1 
    --END AS system_generated_subsidiary_id,
    
    -- Company House Number
    CASE 
        WHEN companies_house_number_1 IS NULL THEN companies_house_number_2
        ELSE companies_house_number_1 
    END AS companies_house_number,
    
    -- Dynamic columns from parameter table
    cp.column_name,
    
    -- Dynamic file1_value based on column_name
    CASE
        WHEN cp.column_name = 'subsidiary_id' THEN file1_subsidiary_id
        WHEN cp.column_name = 'organisation_name' THEN CAST(file1_organisation_name AS VARCHAR)
        WHEN cp.column_name = 'companies_house_number' THEN CAST(file1_companies_house_number AS VARCHAR (MAX))
        WHEN cp.column_name = 'organisation_type_code' THEN CAST(file1_organisation_type_code AS VARCHAR (MAX))
        WHEN cp.column_name = 'organisation_sub_type_code' THEN CAST(file1_organisation_sub_type_code AS VARCHAR (MAX))
        WHEN cp.column_name = 'registered_addr_line1' THEN file1_registered_addr_line1
        WHEN cp.column_name = 'registered_addr_line2' THEN file1_registered_addr_line2
        WHEN cp.column_name = 'registered_city' THEN file1_registered_city
        WHEN cp.column_name = 'registered_addr_county' THEN file1_registered_addr_county
        WHEN cp.column_name = 'registered_addr_postcode' THEN file1_registered_addr_postcode
        WHEN cp.column_name = 'registered_addr_country' THEN file1_registered_addr_country
        WHEN cp.column_name = 'registered_addr_phone_number' THEN file1_registered_addr_phone_number
        WHEN cp.column_name = 'principal_addr_line1' THEN file1_principal_addr_line1
        WHEN cp.column_name = 'principal_addr_line2' THEN file1_principal_addr_line2
        WHEN cp.column_name = 'principal_addr_city' THEN file1_principal_addr_city
        WHEN cp.column_name = 'principal_addr_county' THEN file1_principal_addr_county
        WHEN cp.column_name = 'principal_addr_postcode' THEN file1_principal_addr_postcode
        WHEN cp.column_name = 'principal_addr_country' THEN file1_principal_addr_country
        WHEN cp.column_name = 'principal_addr_phone_number' THEN file1_principal_addr_phone_number
        WHEN cp.column_name = 'audit_addr_line1' THEN file1_audit_addr_line1
        WHEN cp.column_name = 'audit_addr_line2' THEN file1_audit_addr_line2
        WHEN cp.column_name = 'audit_addr_city' THEN file1_audit_addr_city
        WHEN cp.column_name = 'audit_addr_county' THEN file1_audit_addr_county
        WHEN cp.column_name = 'audit_addr_postcode' THEN file1_audit_addr_postcode
        WHEN cp.column_name = 'audit_addr_country' THEN file1_audit_addr_country
        WHEN cp.column_name = 'service_of_notice_addr_line1' THEN file1_service_of_notice_addr_line1
        WHEN cp.column_name = 'service_of_notice_addr_line2' THEN file1_service_of_notice_addr_line2
        WHEN cp.column_name = 'service_of_notice_addr_city' THEN file1_service_of_notice_addr_city
        WHEN cp.column_name = 'service_of_notice_addr_county' THEN file1_service_of_notice_addr_county
        WHEN cp.column_name = 'service_of_notice_addr_postcode' THEN file1_service_of_notice_addr_postcode
        WHEN cp.column_name = 'service_of_notice_addr_country' THEN file1_service_of_notice_addr_country
        WHEN cp.column_name = 'service_of_notice_addr_phone_number' THEN file1_service_of_notice_addr_phone_number
        WHEN cp.column_name = 'approved_person_first_name' THEN file1_approved_person_first_name
        WHEN cp.column_name = 'approved_person_last_name' THEN file1_approved_person_last_name
        WHEN cp.column_name = 'approved_person_phone_number' THEN file1_approved_person_phone_number
        WHEN cp.column_name = 'approved_person_email' THEN file1_approved_person_email
        WHEN cp.column_name = 'approved_person_job_title' THEN file1_approved_person_job_title
        WHEN cp.column_name = 'delegated_person_first_name' THEN file1_delegated_person_first_name
        WHEN cp.column_name = 'delegated_person_last_name' THEN file1_delegated_person_last_name
        WHEN cp.column_name = 'delegated_person_phone_number' THEN file1_delegated_person_phone_number
        WHEN cp.column_name = 'delegated_person_email' THEN file1_delegated_person_email
        WHEN cp.column_name = 'delegated_person_job_title' THEN file1_delegated_person_job_title
        WHEN cp.column_name = 'primary_contact_person_first_name' THEN file1_primary_contact_person_first_name
        WHEN cp.column_name = 'primary_contact_person_last_name' THEN file1_primary_contact_person_last_name
        WHEN cp.column_name = 'primary_contact_person_phone_number' THEN file1_primary_contact_person_phone_number
        WHEN cp.column_name = 'primary_contact_person_email' THEN file1_primary_contact_person_email
        WHEN cp.column_name = 'primary_contact_person_job_title' THEN file1_primary_contact_person_job_title
        WHEN cp.column_name = 'secondary_contact_person_first_name' THEN file1_secondary_contact_person_first_name
        WHEN cp.column_name = 'secondary_contact_person_last_name' THEN file1_secondary_contact_person_last_name
        WHEN cp.column_name = 'secondary_contact_person_phone_number' THEN file1_secondary_contact_person_phone_number
        WHEN cp.column_name = 'secondary_contact_person_email' THEN file1_secondary_contact_person_email
        WHEN cp.column_name = 'secondary_contact_person_job_title' THEN file1_secondary_contact_person_job_title
        WHEN cp.column_name = 'BrandName' THEN file1_BrandName
        WHEN cp.column_name = 'BrandTypeCode' THEN file1_BrandTypeCode
        WHEN cp.column_name = 'PartnerFirstName' THEN file1_PartnerFirstName
        WHEN cp.column_name = 'PartnerLastName' THEN file1_PartnerLastName
        WHEN cp.column_name = 'PartnerPhoneNumber' THEN file1_PartnerPhoneNumber
        WHEN cp.column_name = 'PartnerEmail' THEN file1_PartnerEmail
        WHEN cp.column_name = 'home_nation_code' THEN CAST(file1_home_nation_code AS VARCHAR(MAX))
        WHEN cp.column_name = 'main_activity_sic' THEN file1_main_activity_sic
        WHEN cp.column_name = 'packaging_activity_so' THEN file1_packaging_activity_so
        WHEN cp.column_name = 'packaging_activity_pf' THEN file1_packaging_activity_pf
        WHEN cp.column_name = 'packaging_activity_im' THEN file1_packaging_activity_im
        WHEN cp.column_name = 'packaging_activity_se' THEN file1_packaging_activity_se
        WHEN cp.column_name = 'packaging_activity_hl' THEN file1_packaging_activity_hl
        WHEN cp.column_name = 'packaging_activity_om' THEN file1_packaging_activity_om
        WHEN cp.column_name = 'packaging_activity_sl' THEN file1_packaging_activity_sl
        WHEN cp.column_name = 'registration_type_code' THEN file1_registration_type_code
        WHEN cp.column_name = 'produce_blank_packaging_flag' THEN CAST(file1_produce_blank_packaging_flag AS VARCHAR (MAX))
        WHEN cp.column_name = 'liable_for_disposal_costs_flag' THEN CAST(file1_liable_for_disposal_costs_flag AS VARCHAR (MAX))
        WHEN cp.column_name = 'meet_reporting_requirements_flag' THEN CAST(file1_meet_reporting_requirements_flag AS VARCHAR (MAX))
        WHEN cp.column_name = 'trading_name' THEN CAST(file1_trading_name AS VARCHAR)
        WHEN cp.column_name = 'turnover' THEN cast(cast(file1_turnover as decimal) as varchar)
        WHEN cp.column_name = 'total_tonnage' THEN CAST(file1_total_tonnage AS VARCHAR)
        WHEN cp.column_name = 'CompanyOrgId' THEN CAST(file1_CompanyOrgId AS VARCHAR)
        WHEN cp.column_name = 'organisation_size' THEN file1_organisation_size
        WHEN cp.column_name = 'leaver_code' THEN file1_leaver_code
        WHEN cp.column_name = 'leaver_date' THEN file1_leaver_date
        WHEN cp.column_name = 'joiner_date' THEN file1_joiner_date
        WHEN cp.column_name = 'organisation_change_reason' THEN file1_organisation_change_reason
    END AS file1_value,
	-- Dynamic file2_value based on column_name
	CASE
		WHEN cp.column_name = 'subsidiary_id' THEN file2_subsidiary_id
        WHEN cp.column_name = 'organisation_name' THEN CAST(file2_organisation_name AS VARCHAR)
        WHEN cp.column_name = 'companies_house_number' THEN CAST(file2_companies_house_number AS VARCHAR (MAX))
        WHEN cp.column_name = 'organisation_type_code' THEN CAST(file2_organisation_type_code AS VARCHAR (MAX))
        WHEN cp.column_name = 'organisation_sub_type_code' THEN CAST(file2_organisation_sub_type_code AS VARCHAR (MAX))
        WHEN cp.column_name = 'registered_addr_line1' THEN file2_registered_addr_line1
        WHEN cp.column_name = 'registered_addr_line2' THEN file2_registered_addr_line2
        WHEN cp.column_name = 'registered_city' THEN file2_registered_city
        WHEN cp.column_name = 'registered_addr_county' THEN file2_registered_addr_county
        WHEN cp.column_name = 'registered_addr_postcode' THEN file2_registered_addr_postcode
        WHEN cp.column_name = 'registered_addr_country' THEN file2_registered_addr_country
        WHEN cp.column_name = 'registered_addr_phone_number' THEN file2_registered_addr_phone_number
        WHEN cp.column_name = 'principal_addr_line1' THEN file2_principal_addr_line1
        WHEN cp.column_name = 'principal_addr_line2' THEN file2_principal_addr_line2
        WHEN cp.column_name = 'principal_addr_city' THEN file2_principal_addr_city
        WHEN cp.column_name = 'principal_addr_county' THEN file2_principal_addr_county
        WHEN cp.column_name = 'principal_addr_postcode' THEN file2_principal_addr_postcode
        WHEN cp.column_name = 'principal_addr_country' THEN file2_principal_addr_country
        WHEN cp.column_name = 'principal_addr_phone_number' THEN file2_principal_addr_phone_number
        WHEN cp.column_name = 'audit_addr_line1' THEN file2_audit_addr_line1
        WHEN cp.column_name = 'audit_addr_line2' THEN file2_audit_addr_line2
        WHEN cp.column_name = 'audit_addr_city' THEN file2_audit_addr_city
        WHEN cp.column_name = 'audit_addr_county' THEN file2_audit_addr_county
        WHEN cp.column_name = 'audit_addr_postcode' THEN file2_audit_addr_postcode
        WHEN cp.column_name = 'audit_addr_country' THEN file2_audit_addr_country
        WHEN cp.column_name = 'service_of_notice_addr_line1' THEN file2_service_of_notice_addr_line1
        WHEN cp.column_name = 'service_of_notice_addr_line2' THEN file2_service_of_notice_addr_line2
        WHEN cp.column_name = 'service_of_notice_addr_city' THEN file2_service_of_notice_addr_city
        WHEN cp.column_name = 'service_of_notice_addr_county' THEN file2_service_of_notice_addr_county
        WHEN cp.column_name = 'service_of_notice_addr_postcode' THEN file2_service_of_notice_addr_postcode
        WHEN cp.column_name = 'service_of_notice_addr_country' THEN file2_service_of_notice_addr_country
        WHEN cp.column_name = 'service_of_notice_addr_phone_number' THEN file2_service_of_notice_addr_phone_number
        WHEN cp.column_name = 'approved_person_first_name' THEN file2_approved_person_first_name
        WHEN cp.column_name = 'approved_person_last_name' THEN file2_approved_person_last_name
        WHEN cp.column_name = 'approved_person_phone_number' THEN file2_approved_person_phone_number
        WHEN cp.column_name = 'approved_person_email' THEN file2_approved_person_email
        WHEN cp.column_name = 'approved_person_job_title' THEN file2_approved_person_job_title
        WHEN cp.column_name = 'delegated_person_first_name' THEN file2_delegated_person_first_name
        WHEN cp.column_name = 'delegated_person_last_name' THEN file2_delegated_person_last_name
        WHEN cp.column_name = 'delegated_person_phone_number' THEN file2_delegated_person_phone_number
        WHEN cp.column_name = 'delegated_person_email' THEN file2_delegated_person_email
        WHEN cp.column_name = 'delegated_person_job_title' THEN file2_delegated_person_job_title
        WHEN cp.column_name = 'primary_contact_person_first_name' THEN file2_primary_contact_person_first_name
        WHEN cp.column_name = 'primary_contact_person_last_name' THEN file2_primary_contact_person_last_name
        WHEN cp.column_name = 'primary_contact_person_phone_number' THEN file2_primary_contact_person_phone_number
        WHEN cp.column_name = 'primary_contact_person_email' THEN file2_primary_contact_person_email
        WHEN cp.column_name = 'primary_contact_person_job_title' THEN file2_primary_contact_person_job_title
        WHEN cp.column_name = 'secondary_contact_person_first_name' THEN file2_secondary_contact_person_first_name
        WHEN cp.column_name = 'secondary_contact_person_last_name' THEN file2_secondary_contact_person_last_name
        WHEN cp.column_name = 'secondary_contact_person_phone_number' THEN file2_secondary_contact_person_phone_number
        WHEN cp.column_name = 'secondary_contact_person_email' THEN file2_secondary_contact_person_email
        WHEN cp.column_name = 'secondary_contact_person_job_title' THEN file2_secondary_contact_person_job_title
        WHEN cp.column_name = 'BrandName' THEN file2_BrandName
        WHEN cp.column_name = 'BrandTypeCode' THEN file2_BrandTypeCode
        WHEN cp.column_name = 'PartnerFirstName' THEN file2_PartnerFirstName
        WHEN cp.column_name = 'PartnerLastName' THEN file2_PartnerLastName
        WHEN cp.column_name = 'PartnerPhoneNumber' THEN file2_PartnerPhoneNumber
        WHEN cp.column_name = 'PartnerEmail' THEN file2_PartnerEmail
        WHEN cp.column_name = 'home_nation_code' THEN CAST(file2_home_nation_code AS VARCHAR(MAX))
        WHEN cp.column_name = 'main_activity_sic' THEN file2_main_activity_sic
        WHEN cp.column_name = 'packaging_activity_so' THEN file2_packaging_activity_so
        WHEN cp.column_name = 'packaging_activity_pf' THEN file2_packaging_activity_pf
        WHEN cp.column_name = 'packaging_activity_im' THEN file2_packaging_activity_im
        WHEN cp.column_name = 'packaging_activity_se' THEN file2_packaging_activity_se
        WHEN cp.column_name = 'packaging_activity_hl' THEN file2_packaging_activity_hl
        WHEN cp.column_name = 'packaging_activity_om' THEN file2_packaging_activity_om
        WHEN cp.column_name = 'packaging_activity_sl' THEN file2_packaging_activity_sl
        WHEN cp.column_name = 'registration_type_code' THEN file2_registration_type_code
        WHEN cp.column_name = 'produce_blank_packaging_flag' THEN CAST(file2_produce_blank_packaging_flag AS VARCHAR (MAX))
        WHEN cp.column_name = 'liable_for_disposal_costs_flag' THEN CAST(file2_liable_for_disposal_costs_flag AS VARCHAR (MAX))
        WHEN cp.column_name = 'meet_reporting_requirements_flag' THEN CAST(file2_meet_reporting_requirements_flag AS VARCHAR (MAX))
        WHEN cp.column_name = 'trading_name' THEN CAST(file2_trading_name AS VARCHAR)
        WHEN cp.column_name = 'turnover' THEN cast(cast(file2_turnover as decimal) as varchar)
        WHEN cp.column_name = 'total_tonnage' THEN CAST(file2_total_tonnage AS VARCHAR)
        WHEN cp.column_name = 'CompanyOrgId' THEN CAST(file2_CompanyOrgId AS VARCHAR)
        WHEN cp.column_name = 'organisation_size' THEN file2_organisation_size
        WHEN cp.column_name = 'leaver_code' THEN file2_leaver_code
        WHEN cp.column_name = 'leaver_date' THEN file2_leaver_date
        WHEN cp.column_name = 'joiner_date' THEN file2_joiner_date
        WHEN cp.column_name = 'organisation_change_reason' THEN file2_organisation_change_reason
	END AS file2_value,
	-- Dynamic change_status based on column_name
	CASE 
		WHEN cp.column_name = 'subsidiary_id' THEN change_status_subsidiary_id
        WHEN cp.column_name = 'organisation_name' THEN change_status_organisation_name
        WHEN cp.column_name = 'companies_house_number' THEN change_status_companies_house_number
        WHEN cp.column_name = 'organisation_type_code' THEN change_status_organisation_type_code
        WHEN cp.column_name = 'organisation_sub_type_code' THEN change_status_organisation_sub_type_code
        WHEN cp.column_name = 'registered_addr_line1' THEN change_status_registered_addr_line1
        WHEN cp.column_name = 'registered_addr_line2' THEN change_status_registered_addr_line2
        WHEN cp.column_name = 'registered_city' THEN change_status_registered_city
        WHEN cp.column_name = 'registered_addr_county' THEN change_status_registered_addr_county
        WHEN cp.column_name = 'registered_addr_postcode' THEN change_status_registered_addr_postcode
        WHEN cp.column_name = 'registered_addr_country' THEN change_status_registered_addr_country
        WHEN cp.column_name = 'registered_addr_phone_number' THEN change_status_registered_addr_phone_number
        WHEN cp.column_name = 'principal_addr_line1' THEN change_status_principal_addr_line1
        WHEN cp.column_name = 'principal_addr_line2' THEN change_status_principal_addr_line2
        WHEN cp.column_name = 'principal_addr_city' THEN change_status_principal_addr_city
        WHEN cp.column_name = 'principal_addr_county' THEN change_status_principal_addr_county
        WHEN cp.column_name = 'principal_addr_postcode' THEN change_status_principal_addr_postcode
        WHEN cp.column_name = 'principal_addr_country' THEN change_status_principal_addr_country
        WHEN cp.column_name = 'principal_addr_phone_number' THEN change_status_principal_addr_phone_number
        WHEN cp.column_name = 'audit_addr_line1' THEN change_status_audit_addr_line1
        WHEN cp.column_name = 'audit_addr_line2' THEN change_status_audit_addr_line2
        WHEN cp.column_name = 'audit_addr_city' THEN change_status_audit_addr_city
        WHEN cp.column_name = 'audit_addr_county' THEN change_status_audit_addr_county
        WHEN cp.column_name = 'audit_addr_postcode' THEN change_status_audit_addr_postcode
        WHEN cp.column_name = 'audit_addr_country' THEN change_status_audit_addr_country
        WHEN cp.column_name = 'service_of_notice_addr_line1' THEN change_status_service_of_notice_addr_line1
        WHEN cp.column_name = 'service_of_notice_addr_line2' THEN change_status_service_of_notice_addr_line2
        WHEN cp.column_name = 'service_of_notice_addr_city' THEN change_status_service_of_notice_addr_city
        WHEN cp.column_name = 'service_of_notice_addr_county' THEN change_status_service_of_notice_addr_county
        WHEN cp.column_name = 'service_of_notice_addr_postcode' THEN change_status_service_of_notice_addr_postcode
        WHEN cp.column_name = 'service_of_notice_addr_country' THEN change_status_service_of_notice_addr_country
        WHEN cp.column_name = 'service_of_notice_addr_phone_number' THEN change_status_service_of_notice_addr_phone_number
        WHEN cp.column_name = 'approved_person_first_name' THEN change_status_approved_person_first_name
        WHEN cp.column_name = 'approved_person_last_name' THEN change_status_approved_person_last_name
        WHEN cp.column_name = 'approved_person_phone_number' THEN change_status_approved_person_phone_number
        WHEN cp.column_name = 'approved_person_email' THEN change_status_approved_person_email
        WHEN cp.column_name = 'approved_person_job_title' THEN change_status_approved_person_job_title
        WHEN cp.column_name = 'delegated_person_first_name' THEN change_status_delegated_person_first_name
        WHEN cp.column_name = 'delegated_person_last_name' THEN change_status_delegated_person_last_name
        WHEN cp.column_name = 'delegated_person_phone_number' THEN change_status_delegated_person_phone_number
        WHEN cp.column_name = 'delegated_person_email' THEN change_status_delegated_person_email
        WHEN cp.column_name = 'delegated_person_job_title' THEN change_status_delegated_person_job_title
        WHEN cp.column_name = 'primary_contact_person_first_name' THEN change_status_primary_contact_person_first_name
        WHEN cp.column_name = 'primary_contact_person_last_name' THEN change_status_primary_contact_person_last_name
        WHEN cp.column_name = 'primary_contact_person_phone_number' THEN change_status_primary_contact_person_phone_number
        WHEN cp.column_name = 'primary_contact_person_email' THEN change_status_primary_contact_person_email
        WHEN cp.column_name = 'primary_contact_person_job_title' THEN change_status_primary_contact_person_job_title
        WHEN cp.column_name = 'secondary_contact_person_first_name' THEN change_status_secondary_contact_person_first_name
        WHEN cp.column_name = 'secondary_contact_person_last_name' THEN change_status_secondary_contact_person_last_name
        WHEN cp.column_name = 'secondary_contact_person_phone_number' THEN change_status_secondary_contact_person_phone_number
        WHEN cp.column_name = 'secondary_contact_person_email' THEN change_status_secondary_contact_person_email
        WHEN cp.column_name = 'secondary_contact_person_job_title' THEN change_status_secondary_contact_person_job_title
        WHEN cp.column_name = 'BrandName' THEN change_status_BrandName
        WHEN cp.column_name = 'BrandTypeCode' THEN change_status_BrandTypeCode
        WHEN cp.column_name = 'PartnerFirstName' THEN change_status_PartnerFirstName
        WHEN cp.column_name = 'PartnerLastName' THEN change_status_PartnerLastName
        WHEN cp.column_name = 'PartnerPhoneNumber' THEN change_status_PartnerPhoneNumber
        WHEN cp.column_name = 'PartnerEmail' THEN change_status_PartnerEmail
        WHEN cp.column_name = 'home_nation_code' THEN change_status_home_nation_code
        WHEN cp.column_name = 'main_activity_sic' THEN change_status_main_activity_sic
        WHEN cp.column_name = 'packaging_activity_so' THEN change_status_packaging_activity_so
        WHEN cp.column_name = 'packaging_activity_pf' THEN change_status_packaging_activity_pf
        WHEN cp.column_name = 'packaging_activity_im' THEN change_status_packaging_activity_im
        WHEN cp.column_name = 'packaging_activity_se' THEN change_status_packaging_activity_se
        WHEN cp.column_name = 'packaging_activity_hl' THEN change_status_packaging_activity_hl
        WHEN cp.column_name = 'packaging_activity_om' THEN change_status_packaging_activity_om
        WHEN cp.column_name = 'packaging_activity_sl' THEN change_status_packaging_activity_sl
        WHEN cp.column_name = 'registration_type_code' THEN change_status_registration_type_code
        WHEN cp.column_name = 'produce_blank_packaging_flag' THEN change_status_produce_blank_packaging_flag
        WHEN cp.column_name = 'liable_for_disposal_costs_flag' THEN change_status_liable_for_disposal_costs_flag
        WHEN cp.column_name = 'meet_reporting_requirements_flag' THEN change_status_meet_reporting_requirements_flag
        WHEN cp.column_name = 'trading_name' THEN change_status_trading_name
        WHEN cp.column_name = 'turnover' THEN change_status_turnover
        WHEN cp.column_name = 'total_tonnage' THEN change_status_total_tonnage
        WHEN cp.column_name = 'CompanyOrgId' THEN change_status_CompanyOrgId
        WHEN cp.column_name = 'organisation_size' THEN change_status_organisation_size
        WHEN cp.column_name = 'leaver_code' THEN change_status_leaver_code
        WHEN cp.column_name = 'leaver_date' THEN change_status_leaver_date
        WHEN cp.column_name = 'joiner_date' THEN change_status_joiner_date
        WHEN cp.column_name = 'organisation_change_reason' THEN change_status_organisation_change_reason
	END AS change_status,

	CASE 
		WHEN main_activity_sic_1 IS NULL and main_activity_sic_2 is not null THEN main_activity_sic_1
		WHEN main_activity_sic_1 IS not NULL and main_activity_sic_2 is null THEN main_activity_sic_2
		WHEN main_activity_sic_1 IS not NULL and main_activity_sic_2 is not null THEN main_activity_sic_1
			 
	END AS SIC_Code,

    --CASE 
    --    WHEN cp.column_name IN (
    --        'registered_addr_line1', 'registered_addr_line2', 'registered_city',
    --        'registered_addr_county', 'registered_addr_postcode', 'registered_addr_country',
    --        'registered_addr_phone_number', 'principal_addr_line1', 'principal_addr_line2',
    --        'principal_addr_city', 'principal_addr_county', 'principal_addr_postcode',
    --        'principal_addr_country', 'principal_addr_phone_number', 'audit_addr_line1',
    --        'audit_addr_line2', 'audit_addr_city', 'audit_addr_county', 'audit_addr_postcode',
    --        'audit_addr_country', 'service_of_notice_addr_line1', 'service_of_notice_addr_line2',
    --        'service_of_notice_addr_city', 'service_of_notice_addr_county', 'service_of_notice_addr_postcode',
    --        'service_of_notice_addr_country', 'service_of_notice_addr_phone_number'
    --    ) THEN 'Address change'

    --    WHEN cp.column_name IN (
    --        'organisation_name', 'companies_house_number',
    --        'organisation_type_code', 'organisation_size'
    --    ) THEN 'Organisation change'

    --END AS Change_Category,
    

    CASE
        WHEN (file1_CSORPD = 'Compliance Scheme' OR file2_CSORPD = 'Compliance Scheme') 
             AND subsidiary_id_1 IS NULL AND subsidiary_id_2 IS NULL THEN 'Member'
        WHEN file1_CSORPD = 'Producer' AND subsidiary_id_1 IS NULL AND subsidiary_id_2 IS NULL THEN 'Parent'
        ELSE 'Child'
    END AS Parent_or_Member_and_Child,
    
    file1_CSORPD,
    file2_CSORPD,
    organisation_size_1,
    organisation_size_2,
    leaver_code_1,
    leaver_code_2,
    joiner_date_1,
    joiner_date_2,
    leaver_date_1,
    leaver_date_2,
    organisation_change_reason_1,
    organisation_change_reason_2
FROM resultfile
CROSS JOIN change_parameters cp
WHERE 1=1
)

select *,
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
								,'organisation_size' )		THEN 'Organisation change'


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
								,'leaver_code'
								,'leaver_date'
								,'joiner_date'
								,'organisation_change_reason'
								) THEN
				CASE 
					WHEN  file1_value is not null OR file2_value is not null THEN 'Subsidiary change'
					
					ELSE 'Organisation change' END
			WHEN column_name IN ('CompanyOrgId') THEN 
				CASE 
					WHEN  file1_value is not null OR file2_value is not null  THEN 'Member change'
					ELSE 'Organisation change' END
			
		ELSE 'Other change' END Change_Category
		FROM pre_out
END