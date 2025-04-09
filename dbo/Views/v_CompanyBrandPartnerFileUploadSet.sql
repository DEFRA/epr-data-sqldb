CREATE VIEW [dbo].[v_CompanyBrandPartnerFileUploadSet] AS SELECT  distinct *

from 

( SELECT cd.[organisation_id] CompanyOrgId
      ,cd.[subsidiary_id]
	  ,so.[SecondOrganisation_ReferenceNumber] As SubsidiaryOrganisation_ReferenceNumber
      ,cd.[organisation_name]
      ,cd.[trading_name]
      ,cd.[companies_house_number]
      ,cd.[home_nation_code]
      ,cd.[main_activity_sic]
      ,cd.[organisation_type_code]
      ,cd.[organisation_sub_type_code]
      ,cd.[packaging_activity_so]
      ,cd.[packaging_activity_pf]
      ,cd.[packaging_activity_im]
      ,cd.[packaging_activity_se]
      ,cd.[packaging_activity_hl]
      ,cd.[packaging_activity_om]
      ,cd.[packaging_activity_sl]
      ,cd.[registration_type_code]
      ,cd.[turnover]
      ,cd.[total_tonnage]
      ,cd.[produce_blank_packaging_flag]
      ,cd.[liable_for_disposal_costs_flag]
      ,cd.[meet_reporting_requirements_flag]
      ,cd.[registered_addr_line1]
      ,cd.[registered_addr_line2]
      ,cd.[registered_city]
      ,cd.[registered_addr_county]
      ,cd.[registered_addr_postcode]
      ,cd.[registered_addr_country]
      ,cd.[registered_addr_phone_number]
      ,cd.[audit_addr_line1]
      ,cd.[audit_addr_line2]
      ,cd.[audit_addr_city]
      ,cd.[audit_addr_county]
      ,cd.[audit_addr_postcode]
      ,cd.[audit_addr_country]
      ,cd.[service_of_notice_addr_line1]
      ,cd.[service_of_notice_addr_line2]
      ,cd.[service_of_notice_addr_city]
      ,cd.[service_of_notice_addr_county]
      ,cd.[service_of_notice_addr_postcode]
      ,cd.[service_of_notice_addr_country]
      ,cd.[service_of_notice_addr_phone_number]
      ,cd.[principal_addr_line1]
      ,cd.[principal_addr_line2]
      ,cd.[principal_addr_city]
      ,cd.[principal_addr_county]
      ,cd.[principal_addr_postcode]
      ,cd.[principal_addr_country]
      ,cd.[principal_addr_phone_number]
      ,cd.[sole_trader_first_name]
      ,cd.[sole_trader_last_name]
      ,cd.[sole_trader_phone_number]
      ,cd.[sole_trader_email]
      ,cd.[approved_person_first_name]
      ,cd.[approved_person_last_name]
      ,cd.[approved_person_phone_number]
      ,cd.[approved_person_email]
      ,cd.[approved_person_job_title]
      ,cd.[delegated_person_first_name]
      ,cd.[delegated_person_last_name]
      ,cd.[delegated_person_phone_number]
      ,cd.[delegated_person_email]
      ,cd.[delegated_person_job_title]
      ,cd.[primary_contact_person_first_name]
      ,cd.[primary_contact_person_last_name]
      ,cd.[primary_contact_person_phone_number]
      ,cd.[primary_contact_person_email]
      ,cd.[primary_contact_person_job_title]
      ,cd.[secondary_contact_person_first_name]
      ,cd.[secondary_contact_person_last_name]
      ,cd.[secondary_contact_person_phone_number]
      ,cd.[secondary_contact_person_email]
      ,cd.[secondary_contact_person_job_title]
      ,cd.[load_ts]
      ,cd.[FileName] CompanyFileName
	  ,cd.[organisation_size]
	  ,cd.[leaver_code] -- MYC
	  ,cd.[leaver_date] -- MYC
	  ,cd.[organisation_change_reason] -- MYC
	  ,cd.[joiner_date] --MYC
	  ,c.OriginalFileName CompanyOriginalFileName
	  ,c.FileType CompanyFileType
	  ,c.Created As SubmissionDateTime
	  ,c.RegistrationSetId CompanyRegID
	  ,c.UserId
	  ,c.ComplianceSchemeId
	  ,c.[TargetDirectoryName]
	  ,CASE 
		WHEN c.[ComplianceSchemeId] is not null then 'Compliance Scheme'
		Else 'Producer' End [CSORPD]
		,pos.[Regulator_Status]

  FROM [rpd].[CompanyDetails] cd 
  join [rpd].[cosmos_file_metadata] c on c.[FileName] = cd.[FileName]
  LEFT JOIN [dbo].[v_submitted_pom_org_file_status] pos on pos.filename = cd.filename
  LEFT JOIN dbo.v_subsidiaryorganisations so 
	on so.FirstOrganisation_ReferenceNumber = cd.[organisation_id]
		and ISNULL(trim(so.SubsidiaryId),'') = ISNULL(trim(cd.subsidiary_id),'') and ISNULL(TRIM(so.[SecondOrganisation_CompaniesHouseNumber]), '') = ISNULL(TRIM(cd.[companies_house_number]), '')
			and so.RelationToDate is NULL
  ) a 
	
left join 

(SELECT br.[organisation_id] BrandOrgID
      ,br.[subsidiary_id] BrandSubID
      ,[brand_name] BrandName
      ,[brand_type_code] BrandTypeCode
      ,br.[load_ts] BrandLoadTS
      ,br.[FileName] BrandFileName
	  ,c.OriginalFileName BrandOriginalFileName
	  ,c.FileType BrandFileType
	  ,c.RegistrationSetId BrandRegID

  FROM [rpd].[Brands] br
  left join [rpd].[cosmos_file_metadata] c on c.[FileName] =br.[FileName]
  ) b on b. BrandRegID = a.CompanyRegID and isnull(a.CompanyOrgId,'') = isnull(b.BrandOrgID,'') and isnull(a.[subsidiary_id],'') = isnull(b.BrandSubID,'') 

left join 
  ( 
  SELECT p.[organisation_id] PartnerOrgID
		,p.[subsidiary_id] PartnerSubID
		,[partner_first_name] PartnerFirstName
		,[partner_last_name] PartnerLastName
		,[partner_phone_number] PartnerPhoneNumber
		,[partner_email] PartnerEmail
		,p.[FileName] PartnerFileName
		,c.OriginalFileName PartnerOriginalFileName
		,c.FileType PartnerFileType
		,c.RegistrationSetId PartnerRegID

  FROM [rpd].[Partnerships] p
  left join [rpd].[cosmos_file_metadata] c on c.[FileName] = p.[FileName]
  ) c on c.PartnerRegID = a.CompanyRegID and isnull(a.CompanyOrgId,'') = isnull(c.PartnerOrgID,'') and isnull(a.[subsidiary_id],'') = isnull(c.PartnerSubID,'')
  


where a.CompanyOrgId is not null;