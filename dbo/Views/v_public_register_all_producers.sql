CREATE VIEW [dbo].[v_public_register_all_producers] AS with
all_org_with_status as
(
	select distinct cd.organisation_id
					, cd.filename
					, CAST(CONVERT(datetimeoffset, meta.created) as datetime) AS submitted_time
					, '20'+reverse(substring(reverse(trim(meta.SubmissionPeriod)),1,2)) as SubmissionYear
					, upper(trim(isnull(file_status.Regulator_Status,''))) as Regulator_Status
					, file_status.decision_date
					,file_status.SubmissionId
					,file_status.ApplicationReferenceNo
					,file_status.registrationreferencenumber
	from [rpd].[CompanyDetails] cd
	left join [dbo].[v_submitted_pom_org_file_status] file_status on (file_status.filetype = 'CompanyDetails' and file_status.FileName = cd.filename)
	left join [rpd].[cosmos_file_metadata] meta on meta.filename = cd.filename
),
all_latest_org_files as
(
	select * 
	from 
		(
		select *
			, row_number() over(partition by organisation_id, SubmissionYear order by submitted_time desc) as rn
		from all_org_with_status where Regulator_Status in ('ACCEPTED','CANCELLED','GRANTED') 
		and SubmissionYear>=2025
		) al
	WHERE al.rn = 1
),
accepted_status_for_apps as 
(
     select distinct SubmissionId,registrationreferencenumber,Decision
from(
Select
		 se.SubmissionId
		,se.ApplicationReferenceNumber
		,se.created 
		,se.[Type]
		,se.registrationreferencenumber
		,se.Decision
		,Row_Number() Over(Partition By se.SubmissionId Order By se.created Desc) as rownum
	From
		rpd.SubmissionEvents		se
	Where
		se.type ='RegulatorRegistrationDecision' and se.Decision='Accepted' and se.AppReferenceNumber is not null
		)a
where a.rownum = 1
)
,
cancelled_status_for_apps as 
(
      select  distinct SubmissionId,registrationreferencenumber,Decision
from(
Select
		 se.SubmissionId
		,se.ApplicationReferenceNumber
		,se.created 
		,se.[Type]
		,se.registrationreferencenumber
		,se.Decision
		,Row_Number() Over(Partition By se.SubmissionId Order By se.created Desc) as rownum
	From
		rpd.SubmissionEvents		se
	Where
		se.type ='RegulatorRegistrationDecision' and se.Decision='Cancelled' and se.AppReferenceNumber is not null
		)a
where a.rownum = 1
),
assign_accepted_to_cancelled as 
( 
       select ca.SubmissionId
	   ,aa.registrationreferencenumber as acc_registrationreferencenumber
	   ,ca.registrationreferencenumber as can_registrationreferencenumber
       from cancelled_status_for_apps ca 
       left join accepted_status_for_apps aa 
       on ca.SubmissionId=aa.SubmissionId 

),
org_result as
(
	SELECT DISTINCT
				cd.organisation_id AS 'Organisation_ID'
				,cds.organisation_size as 'Large/Small'
				,cds.liable_for_disposal_costs_flag as required_to_pay_disposal_fee
				,case when UPPER(ISNULL(cds.organisation_size, 'L')) ='L' and (meta.ComplianceSchemeId is null and cds.subsidiary_id is null) then 'Yes' else 'No' END as subject_to_recycling_and_certification_obligations
				, '' AS 'submission_period'
				, cs.Name AS 'Name_of_compliance_scheme'
				,trim(cds.companies_house_number) as 'Companies_House_number'
				,COALESCE(cds.subsidiary_id, '') AS 'Subsidiary_ID'
				,trim(cds.organisation_name) as 'Organisation_name'
				,trim(cds.Trading_Name) as 'Trading_name'
				,trim(cds.registered_addr_line1) as 'Address_line_1'									
				,trim(cds.registered_addr_line2) as 'Address_line_2'								
				, '' as 'Address_line_3'
				, '' as 'Address_line_4'
				,trim(cds.registered_city) as 'Town'
				,trim(cds.registered_addr_county) as 'County'
				,trim(cds.registered_addr_country) as 'Country'
				,trim(cds.registered_addr_postcode) as 'Postcode'
				, producernation.Name AS ProducerNation
				, producernation.Id AS ProducerNationId
				, csnation.Name AS ComplianceSchemeNation
				, csnation.Id AS ComplianceSchemeNationId
				, pr.ReferenceNumber AS ProducerId
				, (CASE producernation.Id
					WHEN 1 THEN 'Environment Agency (England)'
					WHEN 2 THEN 'Northern Ireland Environment Agency'
					WHEN 3 THEN 'Scottish Environment Protection Agency'
					WHEN 4 THEN 'Natural Resources Wales'
					END) As 'Environmental_regulator'
				, (CASE csnation.Id
					WHEN 1 THEN 'Environment Agency (England)'
					WHEN 2 THEN 'Northern Ireland Environment Agency'
					WHEN 3 THEN 'Scottish Environment Protection Agency'
					WHEN 4 THEN 'Natural Resources Wales'
					END) As 'Compliance_scheme_regulator'
				,cd.SubmissionYear as 'Reporting_year'
				, meta.created SubmittedDateTime
				, cd.regulator_status
				,case when cd.regulator_status in('GRANTED', 'ACCEPTED') then cd.decision_date end as registration_date
				,case when cd.regulator_status = 'CANCELLED' then cd.decision_date end as cancellation_date

				--,case when meta.ComplianceSchemeId is not null then concat(cd.registrationreferencenumber,cd.organisation_id,cds.subsidiary_id) else 
			--	concat(cd.registrationreferencenumber,cds.subsidiary_id) END as ProducerRegistrationNumber_old
				
	             ,case when meta.ComplianceSchemeId is not null and cd.regulator_status in ('GRANTED', 'ACCEPTED') 
	             			                then concat(cd.registrationreferencenumber,cd.organisation_id,cds.subsidiary_id)
	              when meta.ComplianceSchemeId is not null and cd.regulator_status = 'CANCELLED'
	             			                then concat(aac.acc_registrationreferencenumber,cd.organisation_id,cds.subsidiary_id)
	              when meta.ComplianceSchemeId is null and cd.regulator_status in ('GRANTED', 'ACCEPTED') 
	             							then concat(cd.registrationreferencenumber,cds.subsidiary_id)
	              when meta.ComplianceSchemeId is null and cd.regulator_status = 'CANCELLED'
	             							then concat(aac.acc_registrationreferencenumber,cds.subsidiary_id)							
	             else ''
	             			
                 END as Producer_Registration_Number
				 --,cds.leaver_date
				--,case when cd.regulator_status in ('GRANTED', 'ACCEPTED') then aac.acc_registrationreferencenumber else aac.can_registrationreferencenumber end as test
				--,aac.SubmissionId,cd.SubmissionId
			FROM all_latest_org_files cd
			inner join [rpd].[CompanyDetails] cds 
				on cds.Filename = cd.Filename
					and cds.organisation_id = cd.organisation_id
 			left join [dbo].[v_cosmos_file_metadata] meta
				on meta.FileName = cd.FileName
			LEFT JOIN dbo.v_rpd_ComplianceSchemes_Active cs
				ON meta.ComplianceSchemeId = cs.ExternalId
			left JOIN dbo.v_rpd_Organisations_Active pr
				ON cd.organisation_id = pr.ReferenceNumber
			LEFT JOIN rpd.Nations producernation 
				ON pr.NationId = producernation.Id
			LEFT JOIN rpd.Nations csnation
				ON cs.NationId = csnation.Id
			left JOIN [dbo].[v_registration_latest_by_Year] rl
				ON cd.organisation_id = rl.organisation_id
				and isnull(cds.subsidiary_id,'') = isnull(rl.subsidiary_id,'')
				and rl.Reporting_year = cd.SubmissionYear
			Left Join assign_accepted_to_cancelled aac on aac.SubmissionId=cd.SubmissionId
			left JOIN (SELECT FromOrganisation_ReferenceNumber, EnrolmentStatuses_EnrolmentStatus
					   FROM dbo.t_rpd_data_SECURITY_FIX
					   GROUP BY FromOrganisation_ReferenceNumber, EnrolmentStatuses_EnrolmentStatus) e_status
				 ON e_status.FromOrganisation_ReferenceNumber = cd.organisation_id
			WHERE cds.leaver_date is null
			    AND (cs.IsDeleted = 0 OR cs.IsDeleted IS NULL)
				AND (pr.isdeleted = 0 OR pr.isdeleted IS NULL)
				AND e_status.EnrolmentStatuses_EnrolmentStatus <> 'Rejected'
				AND (pr.IsComplianceScheme = 0 OR pr.IsComplianceScheme IS NULL)
	)
		select 
				Organisation_ID,[Large/Small],Required_to_pay_disposal_fee,Subject_to_recycling_and_certification_obligations,
				Producer_Registration_Number,submission_period,Name_of_compliance_scheme,		
				Companies_House_number,		Subsidiary_ID,		Organisation_name,
				Trading_name,		Address_line_1,		Address_line_2,		Address_line_3,		Address_line_4,		Town,		County,		Country,
				Postcode,		ProducerNation,		ProducerNationId,		ComplianceSchemeNation,	ComplianceSchemeNationId,		ProducerId,
				Environmental_regulator,		Compliance_scheme_regulator, Reporting_year,regulator_status	,Registration_date,Cancellation_date
		from org_result;