CREATE VIEW [dbo].[v_latest_pending_or_accepted_orgfile_by_year] AS WITH base_data
AS (
	SELECT m.OrganisationId AS meta_OrganisationId,
		m.SubmissionPeriod,
		'20' + reverse(substring(reverse(trim(m.SubmissionPeriod)), 1, 2)) AS ReportingYear,
		CONVERT(DATETIME, substring(m.Created, 1, 23)) AS Submission_time,
		m.FileType,
		m.filename AS meta_filename,
		UPPER(TRIM(ISNULL(st.Regulator_Status, 'PENDING'))) AS Regulator_Status,
		m.[RegistrationSetId],
		m.[ComplianceSchemeId],
		cs.Name AS ComplianceSchemeName,
		cs.Id AS CS_id
	FROM rpd.cosmos_file_metadata m
	INNER JOIN dbo.v_submitted_pom_org_file_status st
		ON m.filename = st.FileName
	LEFT JOIN rpd.ComplianceSchemes cs
		ON cs.ExternalId = m.ComplianceSchemeId
	WHERE UPPER(TRIM(ISNULL(Regulator_Status, 'PENDING'))) IN (	'ACCEPTED', 'PENDING')
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
		cd.approved_person_email,
		cd.delegated_person_email,
		sub.RelationFromDate as Subsidiary_RelationFromDate,
		sub.RelationToDate as Subsidiary_RelationToDate
	FROM cd_org_combined com
	LEFT JOIN rpd.CompanyDetails cd
		ON com.meta_filename = cd.filename
	LEFT JOIN dbo.v_subsidiaryorganisations sub
		ON sub.FirstOrganisation_ReferenceNumber = cd.organisation_id
			AND (sub.SubsidiaryId = cd.subsidiary_id
					or sub.SecondOrganisation_ReferenceNumber = cd.subsidiary_id)
	LEFT JOIN rpd.Organisations o
		ON o.ReferenceNumber = cd.subsidiary_id
			--where file_submitted_organisation_IsComplianceScheme = 1 
	)
SELECT *
FROM res;