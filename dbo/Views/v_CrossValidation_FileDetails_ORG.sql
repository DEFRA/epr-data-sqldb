CREATE VIEW [dbo].[v_CrossValidation_FileDetails_ORG] AS With Filestatus as (Select 
cm.[Filename],
		 se.Decision as Registration_Status
	From 
		[rpd].[cosmos_file_metadata] cm
		left join rpd.SubmissionEvents se on cm.Fileid=se.Fileid
		where
		se.[type] ='RegulatorRegistrationDecision'
), SchemeName as 
(select cs.[name] , cm.[Filename] from [rpd].[cosmos_file_metadata] cm left join rpd.complianceschemes cs on cs.externalid = cm.ComplianceSchemeId )
select 
       [organisation_id]
      ,[subsidiary_id]
      ,[organisation_name]
	  ,SchemeName.[name] as Scheme_Name
	  ,case 
		when [organisation_sub_type_code]  = 'LIC' then 'Licensor'
		when [organisation_sub_type_code]  = 'POB' then 'Pub operating business '
		when [organisation_sub_type_code]  = 'FRA' then 'Franchisor '
		when [organisation_sub_type_code]  = 'NAO' then 'Non-associated organisation'
		when [organisation_sub_type_code]  = 'HCY' then 'Holding company'
		when [organisation_sub_type_code]  = 'SUB' then 'Subsidiary'
		when [organisation_sub_type_code]  = 'LFR' then 'Licensee/Franchisee'
		when [organisation_sub_type_code]  = 'TEN' then 'Tenant'
		when [organisation_sub_type_code]  = 'OTH' then 'Others'
	else NULL end [Org_Sub_Type]
		  ,case 
	  when [subsidiary_id] is null then 'Single'
	  else 'Group'
	  end as Single_or_Group
	  ,cfm.SubmissionPeriod as Registration_Submission_Period
	  ,isnull(Filestatus.Registration_Status, 'Pending')as Registration_Status
	  ,convert(date,cfm.created) as Registration_Submission_date
	  ,[packaging_activity_so] as Brand_owner
      ,[packaging_activity_pf] as Packer_filler
      ,[packaging_activity_im] as Importer
      ,[packaging_activity_se] as Distributor
      ,[packaging_activity_hl] as Service_provider
      ,[packaging_activity_om] as Online_market_place
      ,[packaging_activity_sl] as Seller
      ,[meet_reporting_requirements_flag]
	  ,[liable_for_disposal_costs_flag]
	  ,a.[FileName]
	  ,cfm.FileId
from rpd.CompanyDetails a
Left join Filestatus on a.[filename]=Filestatus.[filename]
left join  [rpd].[cosmos_file_metadata] cfm on a.[filename]=cfm.[filename]
left join SchemeName on cfm.[Filename]=SchemeName.[Filename];