CREATE PROC [dbo].[sp_compare_org_file] @Year1 [INT],@Year2 [INT] AS
BEGIN

	
	set @Year1 = case when @Year1 < 2026 then @Year1 - 1 else @Year1 end;
	set @Year2 = case when @Year1 < 2026 then @Year2 - 1 else @Year2 end;

	

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
		SELECT 
			y1.file_submitted_organisation_reference as y1_file_submitted_organisation_reference,
			y1.meta_filename as y1_meta_filename,
			y1.SubmissionPeriod as y1_SubmissionPeriod,
			y1.CS_id AS y1_CS_id,
			y1.organisation_id AS y1_organisation_id,
			y1.subsidiary_id AS y1_subsidiary_id,
			y1.subsidiary_id_sys_gen AS y1_subsidiary_id_sys_gen,
			y1.ReportingYear AS y1_ReportingYear,
			y1.ComplianceSchemeName AS y1_ComplianceSchemeName,
			y1.organisation_name AS y1_organisation_name,
			y1.companies_house_number AS y1_companies_house_number,
			y1.organisation_size AS y1_organisation_size,
			y1.Submission_time AS y1_Submission_time,
			y1.Regulator_Status AS y1_Regulator_Status,
			y1.registered_addr_line1 AS y1_registered_addr_line1,
			y1.registered_addr_line2 AS y1_registered_addr_line2,
			y1.registered_city AS y1_registered_city,
			y1.registered_addr_county AS y1_registered_addr_county,
			y1.registered_addr_postcode AS y1_registered_addr_postcode,
			y1.registered_addr_country AS y1_registered_addr_country,
			y1.registered_addr_phone_number AS y1_registered_addr_phone_number,
			y1.approved_person_first_name as y1_approved_person_first_name,
			y1.approved_person_last_name as y1_approved_person_last_name,
			y1.approved_person_email as y1_approved_person_email,
			y1.approved_person_phone_number as y1_approved_person_phone_number,
			y1.delegated_person_first_name as y1_delegated_person_first_name,
			y1.delegated_person_last_name as y1_delegated_person_last_name,
			y1.delegated_person_email as y1_delegated_person_email,
			y1.delegated_person_phone_number as y1_delegated_person_phone_number,
			y1.primary_contact_person_first_name as y1_primary_contact_person_first_name,
			y1.primary_contact_person_last_name as y1_primary_contact_person_last_name,
			y1.primary_contact_person_email as y1_primary_contact_person_email,
			y1.primary_contact_person_phone_number as y1_primary_contact_person_phone_number
			--y1.joiner_date as y1_joiner_date,
			--y1.leaver_code as y1_leaver_code,
			--y1.leaver_date as y1_leaver_date,
			--y1.Organisation_change_reason as y1_Organisation_change_reason
		FROM dbo.t_latest_accepted_orgfile_by_year y1
		WHERE y1.ReportingYear = @Year1
		and y1.Subsidiary_RelationToDate is null
		--and y1.leaver_code is null
		),
	year2
	AS (
		SELECT 
			y2.file_submitted_organisation_reference as y2_file_submitted_organisation_reference,
			y2.meta_filename as y2_meta_filename,
			y2.SubmissionPeriod as y2_SubmissionPeriod,
			y2.CS_id AS y2_CS_id,
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
			y2.approved_person_first_name as y2_approved_person_first_name,
			y2.approved_person_last_name as y2_approved_person_last_name,
			y2.approved_person_email as y2_approved_person_email,
			y2.approved_person_phone_number as y2_approved_person_phone_number,
			y2.delegated_person_first_name as y2_delegated_person_first_name,
			y2.delegated_person_last_name as y2_delegated_person_last_name,
			y2.delegated_person_email as y2_delegated_person_email,
			y2.delegated_person_phone_number as y2_delegated_person_phone_number,
			y2.primary_contact_person_first_name as y2_primary_contact_person_first_name,
			y2.primary_contact_person_last_name as y2_primary_contact_person_last_name,
			y2.primary_contact_person_email as y2_primary_contact_person_email,
			y2.primary_contact_person_phone_number as y2_primary_contact_person_phone_number
			--y2.joiner_date as y2_joiner_date,
			--y2.leaver_code as y2_leaver_code,
			--y2.leaver_date as y2_leaver_date,
			--y2.Organisation_change_reason as y2_Organisation_change_reason
		FROM dbo.t_latest_pending_or_accepted_orgfile_by_year y2
		WHERE y2.ReportingYear = @Year2
		and y2.Subsidiary_RelationToDate is null
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
		SELECT 
			cr.y1_file_submitted_organisation_reference,
			cr.y1_meta_filename,
			cr.y1_SubmissionPeriod,
			cr.y2_file_submitted_organisation_reference,
			cr.y2_meta_filename,
			cr.y2_SubmissionPeriod,
			cr.y1_ComplianceSchemeName, cr.y2_ComplianceSchemeName,
			cr.y1_organisation_id, cr.y2_organisation_id,
			cr.y1_organisation_name, cr.y2_organisation_name,
			cr.y1_subsidiary_id, cr.y2_subsidiary_id,
			cr.y1_subsidiary_id_sys_gen, cr.y2_subsidiary_id_sys_gen,
			cr.y1_companies_house_number, cr.y2_companies_house_number,
			cr.y1_organisation_size, cr.y2_organisation_size,
			/*
			coalesce(cr.y1_ComplianceSchemeName, cr.y2_ComplianceSchemeName, 'Direct Producer') AS CS_Name_or_DP,
			coalesce(cr.y1_organisation_id, cr.y2_organisation_id) AS org_id,
			coalesce(cr.y1_organisation_name, cr.y2_organisation_name) AS org_name,
			coalesce(cr.y1_subsidiary_id, cr.y2_subsidiary_id) AS sub_id,
			coalesce(cr.y1_subsidiary_id_sys_gen, cr.y2_subsidiary_id_sys_gen) AS subsidiary_id_sys_gen,
			coalesce(cr.y1_companies_house_number, cr.y2_companies_house_number) AS ch_number,
			coalesce(cr.y1_organisation_size, cr.y2_organisation_size) AS org_size,
			*/
			cr.y1_Submission_time,
			cr.y1_Regulator_Status,
			cr.y2_Submission_time,
			cr.y2_Regulator_Status,
			cr.y1_registered_addr_line1,
			cr.y1_registered_addr_line2,
			cr.y1_registered_city,
			cr.y1_registered_addr_county,
			cr.y1_registered_addr_postcode,
			cr.y1_registered_addr_country,
			cr.y1_registered_addr_phone_number,

			cr.y1_approved_person_first_name,
			cr.y1_approved_person_last_name,
			cr.y1_approved_person_email,
			cr.y1_approved_person_phone_number,
			cr.y2_approved_person_first_name,
			cr.y2_approved_person_last_name,
			cr.y2_approved_person_email,
			cr.y2_approved_person_phone_number,

			cr.y1_delegated_person_first_name,
			cr.y1_delegated_person_last_name,
			cr.y1_delegated_person_email,
			cr.y1_delegated_person_phone_number,
			cr.y2_delegated_person_first_name,
			cr.y2_delegated_person_last_name,
			cr.y2_delegated_person_email,
			cr.y2_delegated_person_phone_number,

			cr.y1_primary_contact_person_first_name,
			cr.y1_primary_contact_person_last_name,
			cr.y1_primary_contact_person_email,
			cr.y1_primary_contact_person_phone_number,
			cr.y2_primary_contact_person_first_name,
			cr.y2_primary_contact_person_last_name,
			cr.y2_primary_contact_person_email,
			cr.y2_primary_contact_person_phone_number,

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
		),
		comparison_result_selected_columns_redefined_based_fields as
		(
		select 
			*,
			case when JL = 'Leaver' then coalesce(cr.y1_ComplianceSchemeName, 'Direct Producer')  when JL = 'Joiner' then coalesce(cr.y2_ComplianceSchemeName, 'Direct Producer')  else coalesce(cr.y1_ComplianceSchemeName, cr.y2_ComplianceSchemeName, 'Direct Producer') end AS CS_Name_or_DP,
			case when JL = 'Leaver' then cr.y1_organisation_id when JL = 'Joiner' then cr.y2_organisation_id else coalesce(cr.y1_organisation_id, cr.y2_organisation_id) end as org_id,
			case when JL = 'Leaver' then cr.y1_organisation_name when JL = 'Joiner' then cr.y2_organisation_name else coalesce(cr.y1_organisation_name, cr.y2_organisation_name) end as org_name,
			case when JL = 'Leaver' then cr.y1_subsidiary_id when JL = 'Joiner' then cr.y2_subsidiary_id else coalesce(cr.y1_subsidiary_id, cr.y2_subsidiary_id) end as sub_id,
			case when JL = 'Leaver' then cr.y1_subsidiary_id_sys_gen when JL = 'Joiner' then cr.y2_subsidiary_id_sys_gen else coalesce(cr.y1_subsidiary_id_sys_gen, cr.y2_subsidiary_id_sys_gen) end as subsidiary_id_sys_gen,
			case when JL = 'Leaver' then cr.y1_companies_house_number when JL = 'Joiner' then cr.y2_companies_house_number else coalesce(cr.y1_companies_house_number, cr.y2_companies_house_number) end as ch_number,
			case when JL = 'Leaver' then cr.y1_organisation_size when JL = 'Joiner' then cr.y2_organisation_size else coalesce(cr.y1_organisation_size, cr.y2_organisation_size) end as org_size
		from comparison_result_selected_columns cr
		)


	SELECT @Year1 as y1, @Year2 as y2,
		cr_sc.y1_file_submitted_organisation_reference,
		cr_sc.y1_meta_filename,
		cr_sc.y1_SubmissionPeriod,
		cr_sc.y2_file_submitted_organisation_reference,
		cr_sc.y2_meta_filename,
		cr_sc.y2_SubmissionPeriod,
		
		cr_sc.CS_Name_or_DP,
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
		case when l_y2.y2_organisation_id is not null then l_y2.y2_registered_addr_line1 else cr_sc.y1_registered_addr_line1 end as registered_addr_line1,
		case when l_y2.y2_organisation_id is not null then l_y2.y2_registered_addr_line2 else cr_sc.y1_registered_addr_line2 end as registered_addr_line2,
		case when l_y2.y2_organisation_id is not null then l_y2.y2_registered_city else cr_sc.y1_registered_city end as registered_city,
		case when l_y2.y2_organisation_id is not null then l_y2.y2_registered_addr_county else cr_sc.y1_registered_addr_county end as registered_addr_county,
		case when l_y2.y2_organisation_id is not null then l_y2.y2_registered_addr_postcode else cr_sc.y1_registered_addr_postcode end as registered_addr_postcode,
		case when l_y2.y2_organisation_id is not null then l_y2.y2_registered_addr_country else cr_sc.y1_registered_addr_country end as registered_addr_country,
		case when l_y2.y2_organisation_id is not null then l_y2.y2_registered_addr_phone_number else cr_sc.y1_registered_addr_phone_number end as registered_addr_phone_number,

		case when l_y2.y2_organisation_id is not null then l_y2.y2_approved_person_first_name else cr_sc.y1_approved_person_first_name end as approved_person_first_name,
		case when l_y2.y2_organisation_id is not null then l_y2.y2_approved_person_last_name else cr_sc.y1_approved_person_last_name end as approved_person_last_name,
		case when l_y2.y2_organisation_id is not null then l_y2.y2_approved_person_email else cr_sc.y1_approved_person_email end as approved_person_email,
		case when l_y2.y2_organisation_id is not null then l_y2.y2_approved_person_phone_number else cr_sc.y1_approved_person_phone_number end as approved_person_phone_number,

		case when l_y2.y2_organisation_id is not null then l_y2.y2_delegated_person_first_name else cr_sc.y1_delegated_person_first_name end as delegated_person_first_name,
		case when l_y2.y2_organisation_id is not null then l_y2.y2_delegated_person_last_name else cr_sc.y1_delegated_person_last_name end as delegated_person_last_name,
		case when l_y2.y2_organisation_id is not null then l_y2.y2_delegated_person_email else cr_sc.y1_delegated_person_email end as delegated_person_email,
		case when l_y2.y2_organisation_id is not null then l_y2.y2_delegated_person_phone_number else cr_sc.y1_delegated_person_phone_number end as delegated_person_phone_number,

		case when l_y2.y2_organisation_id is not null then l_y2.y2_primary_contact_person_first_name else cr_sc.y1_primary_contact_person_first_name end as primary_contact_person_first_name,
		case when l_y2.y2_organisation_id is not null then l_y2.y2_primary_contact_person_last_name else cr_sc.y1_primary_contact_person_last_name end as primary_contact_person_last_name,
		case when l_y2.y2_organisation_id is not null then l_y2.y2_primary_contact_person_email else cr_sc.y1_primary_contact_person_email end as primary_contact_person_email,
		case when l_y2.y2_organisation_id is not null then l_y2.y2_primary_contact_person_phone_number else cr_sc.y1_primary_contact_person_phone_number end as primary_contact_person_phone_number 
	FROM comparison_result_selected_columns_redefined_based_fields cr_sc
	LEFT JOIN latest_in_year2 l_y2
		ON cr_sc.org_id = l_y2.y2_organisation_id AND ISNULL(cr_sc.sub_id, '') = ISNULL(l_y2.y2_subsidiary_id, '') AND l_y2.rn = 1
	LEFT JOIN enrol e
		ON e.ReferenceNumber = cr_sc.org_id

END
	/*

exec dbo.sp_compare_org_file 2024, 2025

*/