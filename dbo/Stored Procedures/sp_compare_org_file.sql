CREATE PROC [dbo].[sp_compare_org_file] @Year1 [INT],@Year2 [INT] AS
BEGIN
	WITH enrol
	AS (
		SELECT o.ReferenceNumber,
			min(e.CreatedOn) AS date_of_enrolment
		FROM rpd.enrolments e
		INNER JOIN rpd.PersonOrganisationConnections c
			ON e.ConnectionId = c.Id
		INNER JOIN rpd.organisations o
			ON o.Id = c.OrganisationId
		WHERE e.IsDeleted = 0 AND c.IsDeleted = 0 AND o.IsDeleted = 0
		GROUP BY o.ReferenceNumber
		),
	year1
	AS (
		SELECT y1.CS_id AS y1_CS_id,
			y1.organisation_id AS y1_organisation_id,
			y1.subsidiary_id AS y1_subsidiary_id,
			y1.subsidiary_id_sys_gen AS y1_subsidiary_id_sys_gen,
			y1.ReportingYear AS y1_ReportingYear,
			y1.ComplianceSchemeName AS y1_ComplianceSchemeName,
			y1.organisation_name AS y1_organisation_name,
			y1.companies_house_number AS y1_companies_house_number,
			y1.organisation_size AS y1_organisation_size,
			y1.Submission_time AS y1_Submission_time,
			y1.Regulator_Status AS y1_Regulator_Status
		FROM dbo.t_latest_accepted_orgfile_by_year y1
		WHERE y1.ReportingYear = 2023
		),
	year2
	AS (
		SELECT y2.CS_id AS y2_CS_id,
			y2.organisation_id AS y2_organisation_id,
			y2.subsidiary_id AS y2_subsidiary_id,
			y2.subsidiary_id_sys_gen AS y2_subsidiary_id_sys_gen,
			y2.ReportingYear AS y2_ReportingYear,
			y2.ComplianceSchemeName AS y2_ComplianceSchemeName,
			y2.organisation_name AS y2_organisation_name,
			y2.companies_house_number AS y2_companies_house_number,
			y2.organisation_size AS y2_organisation_size,
			y2.Submission_time AS y2_Submission_time,
			y2.Regulator_Status AS y2_Regulator_Status,
			y2.registered_addr_line1 AS y2_registered_addr_line1,
			y2.registered_addr_line2 AS y2_registered_addr_line2,
			y2.registered_city AS y2_registered_city,
			y2.registered_addr_county AS y2_registered_addr_county,
			y2.registered_addr_postcode AS y2_registered_addr_postcode,
			y2.registered_addr_country AS y2_registered_addr_country,
			y2.registered_addr_phone_number AS y2_registered_addr_phone_number,
			y2.approved_person_email AS y2_approved_person_email,
			y2.delegated_person_email AS y2_delegated_person_email
		FROM dbo.t_latest_pending_or_accepted_orgfile_by_year y2
		WHERE y2.ReportingYear = 2024
		),
	latest_in_year2
	AS (
		SELECT *,
			row_number() OVER (
				PARTITION BY y2_organisation_id,
				y2_subsidiary_id ORDER BY y2_Submission_time DESC
				) AS rn
		FROM year2
		),
	comparison_result
	AS (
		SELECT *
		FROM year1 y1
		FULL OUTER JOIN year2 y2
			ON ISNULL(y1_CS_id, '') = ISNULL(y2_CS_id, '') AND y1_organisation_id = y2_organisation_id AND ISNULL(y1_subsidiary_id, '') = ISNULL(y2_subsidiary_id, '')
		),
	comparison_result_selected_columns
	AS (
		SELECT coalesce(cr.y1_ComplianceSchemeName, cr.y2_ComplianceSchemeName, 'Direct Producer') AS CS_Name_or_DP,
			coalesce(cr.y1_organisation_id, cr.y2_organisation_id) AS org_id,
			coalesce(cr.y1_organisation_name, cr.y2_organisation_name) AS org_name,
			coalesce(cr.y1_subsidiary_id, cr.y2_subsidiary_id) AS sub_id,
			coalesce(cr.y1_subsidiary_id_sys_gen, cr.y2_subsidiary_id_sys_gen) AS subsidiary_id_sys_gen,
			coalesce(cr.y1_companies_house_number, cr.y2_companies_house_number) AS ch_number,
			coalesce(cr.y1_organisation_size, cr.y2_organisation_size) AS org_size,
			cr.y1_Submission_time,
			cr.y1_Regulator_Status,
			cr.y2_Submission_time,
			cr.y2_Regulator_Status,
			CASE 
				WHEN (cr.y1_CS_id IS NULL AND cr.y2_CS_id IS NOT NULL) OR (cr.y1_organisation_id IS NULL AND cr.y2_organisation_id IS NOT NULL)
					-- if not direct producer
					THEN 'Joiner'
				WHEN (cr.y1_CS_id IS NOT NULL AND cr.y2_CS_id IS NULL) OR (cr.y1_organisation_id IS NOT NULL AND cr.y2_organisation_id IS NULL)
					--if not direct producer
					THEN 'Leaver'
				WHEN ISNULL(cr.y1_CS_id, '') = ISNULL(cr.y2_CS_id, '') AND (cr.y1_organisation_id = cr.y2_organisation_id)
					THEN 'No change'
				END AS JL
		FROM comparison_result cr
		)
	SELECT cr_sc.CS_Name_or_DP,
		cr_sc.org_id,
		cr_sc.org_name,
		cr_sc.sub_id,
		cr_sc.subsidiary_id_sys_gen,
		cr_sc.ch_number,
		cr_sc.org_size,
		e.date_of_enrolment,
		cr_sc.y1_Submission_time,
		cr_sc.y1_Regulator_Status,
		cr_sc.y2_Submission_time,
		cr_sc.y2_Regulator_Status,
		cr_sc.JL,
		CASE 
			WHEN l_y2.y2_CS_id IS NOT NULL
				THEN 'Compliance scheme'
			WHEN l_y2.y2_organisation_id IS NOT NULL
				THEN 'Direct producer'
			END AS dp_or_cs,
		CASE 
			WHEN l_y2.y2_CS_id IS NOT NULL
				THEN l_y2.y2_ComplianceSchemeName
			WHEN l_y2.y2_organisation_id IS NOT NULL
				THEN l_y2.y2_organisation_name
			END AS new_cs,
		l_y2.y2_registered_addr_line1,
		l_y2.y2_registered_addr_line2,
		l_y2.y2_registered_city,
		l_y2.y2_registered_addr_county,
		l_y2.y2_registered_addr_postcode,
		l_y2.y2_registered_addr_country,
		l_y2.y2_registered_addr_phone_number,
		l_y2.y2_approved_person_email,
		l_y2.y2_delegated_person_email
	FROM comparison_result_selected_columns cr_sc
	LEFT JOIN latest_in_year2 l_y2
		ON cr_sc.org_id = l_y2.y2_organisation_id AND ISNULL(cr_sc.sub_id, '') = ISNULL(l_y2.y2_subsidiary_id, '') AND l_y2.rn = 1
	LEFT JOIN enrol e
		ON e.ReferenceNumber = cr_sc.org_id

END
	/*

exec dbo.sp_compare_org_file 2023, 2024

*/