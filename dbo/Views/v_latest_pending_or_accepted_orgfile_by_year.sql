CREATE VIEW [dbo].[v_latest_pending_or_accepted_orgfile_by_year] AS WITH base_data
AS (
	SELECT m.OrganisationId AS meta_OrganisationId,
		m.SubmissionPeriod,
		case when m.SubmissionPeriod = 'January to December 2025'
				then 2024
			else
				'20' + Reverse(Substring(Reverse(TRIM(m.SubmissionPeriod)), 1, 2)) 
			end AS ReportingYear,
		CONVERT(DATETIME, substring(m.Created, 1, 23)) AS Submission_time,
		m.FileType,
		m.filename AS meta_filename,
		UPPER(TRIM(ISNULL(st.Regulator_Status, 'PENDING'))) AS Regulator_Status,
		m.[RegistrationSetId],
		m.[ComplianceSchemeId],
		cs.Name AS ComplianceSchemeName,
		cs.Id AS CS_id,
		n.name as CS_Nation_name	--  TS_514441
	FROM rpd.cosmos_file_metadata m
	INNER JOIN dbo.v_submitted_pom_org_file_status st
		ON m.filename = st.FileName
	LEFT JOIN rpd.ComplianceSchemes cs
		ON cs.ExternalId = m.ComplianceSchemeId
	LEFT JOIN [rpd].[Nations] n 
		ON n.id = cs.Nationid   --  TS_514441
	WHERE UPPER(TRIM(ISNULL(Regulator_Status, 'PENDING'))) IN (	'ACCEPTED', 'PENDING', 'GRANTED', 'QUERIED')
	),

latest_CompanyDetails
AS (
	SELECT *
	FROM (
		SELECT *,
			Row_number() OVER (
				PARTITION BY coalesce(ComplianceSchemeId, meta_OrganisationId),
				ReportingYear ORDER BY Submission_time DESC
				) AS cd_rn
		FROM base_data
		WHERE UPPER(FileType) = 'COMPANYDETAILS'
		) A
	WHERE cd_rn = 1
	),

cd_org_combined
AS (
	SELECT o.ReferenceNumber AS file_submitted_organisation_reference,
		o.IsComplianceScheme AS file_submitted_organisation_IsComplianceScheme,
		cd.CS_Nation_name,--TS_514441
		cd.meta_OrganisationId,
		cd.SubmissionPeriod,
		cd.ReportingYear,
		cd.Submission_time,
		cd.FileType,
		cd.meta_filename,
		cd.Regulator_Status,
		cd.ComplianceSchemeName,
		cd.CS_id
	FROM latest_CompanyDetails cd
	LEFT JOIN rpd.organisations o
		ON cd.meta_OrganisationId = o.ExternalId
	),

res
AS (
	SELECT com.*,
		cd.organisation_id,
		cd.subsidiary_id,
		ISNULL(sub.SecondOrganisation_ReferenceNumber, o.ReferenceNumber) subsidiary_id_sys_gen,
		cd.organisation_name,
		cd.companies_house_number,
		cd.organisation_size,
		cd.registered_addr_line1,
		cd.registered_addr_line2,
		cd.registered_city,
		cd.registered_addr_county,
		cd.registered_addr_postcode,
		cd.registered_addr_country,
		cd.registered_addr_phone_number,
		cd.approved_person_first_name,
		cd.approved_person_last_name,
		cd.approved_person_email,
		cd.approved_person_phone_number,
		cd.delegated_person_first_name,
		cd.delegated_person_last_name,
		cd.delegated_person_email,
		cd.delegated_person_phone_number,
		cd.primary_contact_person_first_name,
		cd.primary_contact_person_last_name,
		cd.primary_contact_person_email,
		cd.primary_contact_person_phone_number,
		sub.RelationFromDate as Subsidiary_RelationFromDate,
		sub.RelationToDate as Subsidiary_RelationToDate,
		n.name AS Organisation_Nation_Name, --TS_514441
		org.[NationId] AS Organisation_Nation_Id --TS_514441
		--cd.joiner_date,
		--cd.leaver_code,
		--cd.leaver_date,
		--'' as Organisation_change_reason
	FROM cd_org_combined com
	LEFT JOIN rpd.CompanyDetails cd
		ON com.meta_filename = cd.filename
	LEFT JOIN dbo.v_subsidiaryorganisations sub
		ON sub.FirstOrganisation_ReferenceNumber = cd.organisation_id
			AND (sub.SubsidiaryId = cd.subsidiary_id
					or sub.SecondOrganisation_ReferenceNumber = cd.subsidiary_id)
	LEFT JOIN rpd.Organisations o
		ON o.ReferenceNumber = cd.subsidiary_id
	LEFT JOIN rpd.Organisations org  -- TS_514441
		ON org.ReferenceNumber = cd.organisation_id 
	LEFT JOIN [rpd].[Nations] n  --TS_514441
		ON n.id = org.Nationid 
			--where file_submitted_organisation_IsComplianceScheme = 1 
	)
SELECT *
FROM res;