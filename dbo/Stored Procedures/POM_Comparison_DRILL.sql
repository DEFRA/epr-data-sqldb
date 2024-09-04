CREATE PROC [dbo].[POM_Comparison_DRILL] @filename1 [nvarchar](4000),@filename2 [nvarchar](4000),@ProducerCS [nvarchar](100),@organisation_id [int],@compliance_scheme [nvarchar](200),@securityquery [nvarchar](200),@BreakdownType [nvarchar](100),@packaging_type [nvarchar](100),@packaging_material [nvarchar](100),@packaging_class [nvarchar](100),@relative_move [nvarchar](100),@from_nation [nvarchar](100) AS
BEGIN
    --declare @organisation_id [int]
    --set @organisation_id = '100230'

    WITH file1 AS (
    SELECT organisation_id, subsidiary_id,[SecondOrganisation_ReferenceNumber] as SubsidiaryOrganisation_ReferenceNumber, organisation_size, submission_period, packaging_activity,
           packaging_type, packaging_class, packaging_material, packaging_sub_material, from_nation,
           to_nation, quantity_kg, quantity_unit, FileName, Quantity_kg_extrapolated,
           Quantity_units_extrapolated, relative_move, submission_date, org_sub_type, org_name,
           compliance_scheme, registration_type_code
    FROM dbo.t_POM_Submissions_POM_Comparison
	LEFT JOIN dbo.v_subsidiaryorganisations so 
	on so.FirstOrganisation_ReferenceNumber = [dbo].[t_POM_Submissions_POM_Comparison].organisation_id
		and ISNULL(trim(so.SubsidiaryId),'') = ISNULL(trim([dbo].[t_POM_Submissions_POM_Comparison].subsidiary_id),'')
			and so.RelationToDate is NULL -- added new sys gen subsidiary id
    WHERE nation = @securityquery
      AND FileName = @filename1
      AND ((@producerCS = 'Producer' AND organisation_id = @organisation_id)
           OR (@producerCS = 'Compliance Scheme' AND compliance_scheme = @compliance_scheme AND data_type = 'Member'))
),
file2 AS (
    SELECT organisation_id, subsidiary_id ,[SecondOrganisation_ReferenceNumber] as SubsidiaryOrganisation_ReferenceNumber, organisation_size, submission_period, packaging_activity,
           packaging_type, packaging_class, packaging_material, packaging_sub_material, from_nation,
           to_nation, quantity_kg, quantity_unit, FileName, Quantity_kg_extrapolated,
           Quantity_units_extrapolated, relative_move, submission_date, org_sub_type, org_name,
           compliance_scheme, registration_type_code
    FROM dbo.t_POM_Submissions_POM_Comparison
	LEFT JOIN dbo.v_subsidiaryorganisations so 
	on so.FirstOrganisation_ReferenceNumber = [dbo].[t_POM_Submissions_POM_Comparison].organisation_id
		and ISNULL(trim(so.SubsidiaryId),'') = ISNULL(trim([dbo].[t_POM_Submissions_POM_Comparison].subsidiary_id),'')
			and so.RelationToDate is NULL -- added new sys gen subsidiary id
    WHERE nation = @securityquery
      AND FileName = @filename2
      AND ((@producerCS = 'Producer' AND organisation_id = @organisation_id)
           OR (@producerCS = 'Compliance Scheme' AND compliance_scheme = @compliance_scheme AND data_type = 'Member'))
), 
file_joined_1 AS (
	SELECT COALESCE(a.organisation_id, b.organisation_id) AS OrganisationName,
	       COALESCE(a.subsidiary_id, b.subsidiary_id) AS subsidiary_id,
		   COALESCE(a.[SubsidiaryOrganisation_ReferenceNumber], b.[SubsidiaryOrganisation_ReferenceNumber]) AS [SubsidiaryOrganisation_ReferenceNumber],-- added new sys gen subsidiary id
	       COALESCE(a.packaging_material, b.packaging_material) AS packaging_material,
	       COALESCE(a.from_nation, b.from_nation) AS from_nation,
	       COALESCE(a.packaging_activity, b.packaging_activity) AS packaging_activity,
	       COALESCE(a.packaging_class, b.packaging_class) AS packaging_class,
	       COALESCE(a.packaging_sub_material, b.packaging_sub_material) AS packaging_sub_material,
	       COALESCE(a.to_nation, b.to_nation) AS to_nation,
	       COALESCE(a.relative_move, b.relative_move) AS relative_move,
	       COALESCE(a.packaging_type, b.packaging_type) AS packaging_type,
	       a.quantity_kg AS file1_quantity_kg,
	       b.quantity_kg AS file2_quantity_kg,
	       a.quantity_unit AS file1_quantity_unit,
	       b.quantity_unit AS file2_quantity_unit,
	       a.Quantity_kg_extrapolated AS file1_Quantity_kg_extrapolated,
	       b.Quantity_kg_extrapolated AS file2_Quantity_kg_extrapolated,
	       ISNULL(b.quantity_kg, '0') - ISNULL(a.quantity_kg, 0) AS quantity_kg_diff,
	       ISNULL(b.quantity_unit, '0') - ISNULL(a.quantity_unit, 0) AS quantity_unit_diff,
	       ISNULL(b.Quantity_kg_extrapolated, '0') - ISNULL(a.Quantity_kg_extrapolated, 0) AS Quantity_kg_extrapolated_diff,
	       ISNULL(b.Quantity_units_extrapolated, '0') - ISNULL(a.Quantity_units_extrapolated, 0) AS Quantity_units_extrapolated_diff,
	       a.FileName AS filename1,
	       b.FileName AS filename2,
	       a.submission_date AS file1_submission_date,
	       b.submission_date AS file2_submission_date,
	       COALESCE(a.org_sub_type, b.org_sub_type) AS org_sub_type,
	       COALESCE(a.org_name, b.org_name) AS org_name,
	       COALESCE(a.organisation_size, b.organisation_size) AS organisation_size,
	       COALESCE(a.compliance_scheme, b.compliance_scheme) AS compliance_scheme,
	       COALESCE(a.registration_type_code, b.registration_type_code) AS registration_type_code
	FROM file1 a
	FULL JOIN file2 b
	  ON a.organisation_id = b.organisation_id
	     AND a.subsidiary_id = b.subsidiary_id
		 AND a.SubsidiaryOrganisation_ReferenceNumber = b.SubsidiaryOrganisation_ReferenceNumber -- added new subsidiary column
	     AND a.packaging_activity = b.packaging_activity
	     AND a.packaging_type = b.packaging_type
	     AND a.packaging_class = b.packaging_class
	     AND a.packaging_material = b.packaging_material
	     AND a.packaging_sub_material = b.packaging_sub_material
	     AND a.from_nation = b.from_nation
	     AND a.to_nation = b.to_nation
	     AND a.organisation_size = b.organisation_size )


	
	SELECT *, 
	CASE WHEN packaging_type in ('Total Non-Household packaging','Total Household packaging','Public binned','Reusable packaging','Household drinks containers','Non-household drinks containers')
			THEN 'Total Packaging' 
		ELSE null END Total_Packaging
		into #file_joined
    from file_joined_1

IF @BreakdownType = 'relative_move'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber -- added new sys gen subsidiary id
		,packaging_material field2
		,relative_move field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND @relative_move = relative_move
		AND packaging_type = 'Self-managed consumer waste'

IF @BreakdownType = 'from_nation'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber -- added new sys gen subsidiary id 
		,packaging_material field2
		,from_nation field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND from_nation = @from_nation
		AND packaging_type = 'Self-managed consumer waste'
		AND isnull(relative_move, '') = ''

IF @BreakdownType = 'from_org'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,from_nation field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND from_nation = @from_nation
		AND packaging_type = 'Self-managed organisation waste'
		AND isnull(relative_move, '') = ''

IF @BreakdownType = 'relative_move_org'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,relative_move field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND @relative_move = relative_move
		AND packaging_type = 'Self-managed organisation waste'

-------
--ALL PACKAGING
-------
IF @BreakdownType = 'hp_all'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,packaging_class field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND @packaging_class = packaging_class
		AND packaging_type = 'Total Household Packaging'

IF @BreakdownType = 'nhp_all'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,packaging_class field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND @packaging_class = packaging_class
		AND packaging_type = 'Total Non-Household Packaging'

IF @BreakdownType = 'hdc_all'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,'' field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND packaging_type = 'Household drinks containers'

IF @BreakdownType = 'nhdc_all'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,'' field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND packaging_type = 'Non-Household drinks containers'

IF @BreakdownType = 'drinks_all'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,'' field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND packaging_type LIKE '%Household drinks containers'

IF @BreakdownType = 'rp_all'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,packaging_class field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND @packaging_class = packaging_class
		AND packaging_type = 'reusable packaging'

IF @BreakdownType = 'tp_all'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,'' field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND total_packaging = 'Total packaging'

IF @BreakdownType = 'hp_all_total'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,'' field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND packaging_type = ('Total Household Packaging')

IF @BreakdownType = 'nhp_all_total'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,'' field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND packaging_type = ('Total Non-Household Packaging')

IF @BreakdownType = 'rp_all_total'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,'' field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND packaging_type = 'reusable packaging'

---
--BRAND Owner
---
IF @BreakdownType = 'all_pm_hh_pa'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,packaging_class field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND @packaging_class = packaging_class
		AND packaging_activity = 'Brand Owner'
		AND packaging_type = 'Total Household Packaging'

--pubic binned
IF @BreakdownType = 'all_pm_pb_pa'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,packaging_class field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND @packaging_class = packaging_class
		AND packaging_activity = 'Brand Owner'
		AND packaging_type = 'Public Binned'

--non-household
IF @BreakdownType = 'all_pm_tnh_pa'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,packaging_class field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND @packaging_class = packaging_class
		AND packaging_activity = 'Brand Owner'
		AND packaging_type = 'Total non-Household Packaging'

--HH drinks
IF @BreakdownType = 'all_pm_pa_HH_drinks'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,'' field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND packaging_activity = 'Brand Owner'
		AND packaging_type = 'Household drinks containers'

--non HH drinks
IF @BreakdownType = 'all_pm_pa_nHH_drinks'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,'' field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND packaging_activity = 'Brand Owner'
		AND packaging_type = 'Non-household drinks containers'

--all drinks
IF @BreakdownType = 'all_pm_pa_all_drinks'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,'' field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND packaging_activity = 'Brand Owner'
		AND packaging_type LIKE '%Household drinks containers'

--reusable packclass
IF @BreakdownType = 'all_pm_pa_reusable'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,packaging_class field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND @packaging_class = packaging_class
		AND packaging_activity = 'Brand Owner'
		AND packaging_type = 'Reusable packaging'

--total packaging
IF @BreakdownType = 'all_pm_pa_tp'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,packaging_class field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND packaging_activity = 'Brand Owner'
		AND Total_Packaging = 'total packaging'

--hh
IF @BreakdownType = 'all_pm_pa_total_hh'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,packaging_class field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND packaging_activity = 'Brand Owner'
		AND packaging_type = 'Total Household packaging'

--nhh
IF @BreakdownType = 'all_pm_pa_total_nonhh'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,packaging_class field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND packaging_activity = 'Brand Owner'
		AND packaging_type = 'Total Non-Household packaging'

--reuse
IF @BreakdownType = 'all_pm_pa_total_reusable'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,packaging_class field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND packaging_activity = 'Brand Owner'
		AND packaging_type = 'Reusable packaging'

--PACKER FILLER
IF @BreakdownType = 'all_pm_hh_pa_pack'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,packaging_class field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND @packaging_class = packaging_class
		AND packaging_activity = 'Packer / Filler'
		AND packaging_type = 'Total Household packaging'

--pubic binned
IF @BreakdownType = 'all_pm_pb_pa_pack'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,packaging_class field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND @packaging_class = packaging_class
		AND packaging_activity = 'Packer / Filler'
		AND packaging_type = 'Public Binned'

--non-household
IF @BreakdownType = 'all_pm_tnh_pa_pack'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,packaging_class field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND @packaging_class = packaging_class
		AND packaging_activity = 'Packer / Filler'
		AND packaging_type = 'Total Non-Household packaging'

--HH drinks
IF @BreakdownType = 'all_pm_pa_HH_drinks_pack'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,'' field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND packaging_activity = 'Packer / Filler'
		AND packaging_type = 'Household drinks containers'

--non HH drinks
IF @BreakdownType = 'all_pm_pa_nHH_drinks_pack'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,'' field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND packaging_activity = 'Packer / Filler'
		AND packaging_type = 'Non-household drinks containers'

--all drinks
IF @BreakdownType = 'all_pm_pa_all_drinks_pack'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,'' field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND packaging_activity = 'Packer / Filler'
		AND packaging_type LIKE '%Household drinks containers'

--reusable packclass
IF @BreakdownType = 'all_pm_pa_reusable_pack'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,packaging_class field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND @packaging_class = packaging_class
		AND packaging_activity = 'Packer / Filler'
		AND packaging_type = 'Reusable packaging'

--total packaging
IF @BreakdownType = 'all_pm_pa_tp'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,packaging_class field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND packaging_activity = 'Packer / Filler'
		AND Total_Packaging = 'total packaging'

--hh
IF @BreakdownType = 'all_pm_pa_total_hh_pack'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,packaging_class field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND packaging_activity = 'Packer / Filler'
		AND packaging_type = 'Total Household packaging'

--nhh
IF @BreakdownType = 'all_pm_pa_total_nonhh_pack'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,packaging_class field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND packaging_activity = 'Packer / Filler'
		AND packaging_type = 'Total Non-Household packaging'

--reuse
IF @BreakdownType = 'all_pm_pa_total_reusable_pack'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,packaging_class field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND packaging_activity = 'Packer / Filler'
		AND packaging_type = 'Reusable packaging'

-----Imported
IF @BreakdownType = 'all_pm_hh_pa_Imported'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,packaging_class field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND @packaging_class = packaging_class
		AND packaging_activity = 'Imported'
		AND packaging_type = 'Total Household packaging'

--pubic binned
IF @BreakdownType = 'all_pm_pb_pa_Imported'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,packaging_class field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND @packaging_class = packaging_class
		AND packaging_activity = 'Imported'
		AND packaging_type = 'Public Binned'

--non-household
IF @BreakdownType = 'all_pm_tnh_pa_Imported'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,packaging_class field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND @packaging_class = packaging_class
		AND packaging_activity = 'Imported'
		AND packaging_type = 'Total Non-Household packaging'

--HH drinks
IF @BreakdownType = 'all_pm_pa_HH_drinks_Imported'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,'' field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND packaging_activity = 'Imported'
		AND packaging_type = 'Household drinks containers'

--non HH drinks
IF @BreakdownType = 'all_pm_pa_nHH_drinks_Imported'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,'' field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND packaging_activity = 'Imported'
		AND packaging_type = 'Non-household drinks containers'

--all drinks
IF @BreakdownType = 'all_pm_pa_all_drinks_Imported'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,'' field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND packaging_activity = 'Imported'
		AND packaging_type LIKE '%Household drinks containers'

--reusable packclass
IF @BreakdownType = 'all_pm_pa_reusable_Imported'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,packaging_class field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND @packaging_class = packaging_class
		AND packaging_activity = 'Imported'
		AND packaging_type = 'Reusable packaging'

--total packaging
IF @BreakdownType = 'all_pm_pa_tp_Imported'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,packaging_class field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND packaging_activity = 'Imported'
		AND Total_Packaging = 'total packaging'

--hh
IF @BreakdownType = 'all_pm_pa_total_hh_Imported'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,packaging_class field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND packaging_activity = 'Imported'
		AND packaging_type = 'Total Household packaging'

--nhh
IF @BreakdownType = 'all_pm_pa_total_nonhh_Imported'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,packaging_class field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND packaging_activity = 'Imported'
		AND packaging_type = 'Total Non-Household packaging'

--reuse
IF @BreakdownType = 'all_pm_pa_total_reusable_Imported'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,packaging_class field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND packaging_activity = 'Imported'
		AND packaging_type = 'Reusable packaging'

---Sold as empty
IF @BreakdownType = 'all_pm_hh_pa_sold'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,packaging_class field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND @packaging_class = packaging_class
		AND packaging_activity = 'Sold as empty'
		AND packaging_type = 'Total Household packaging'

--pubic binned
IF @BreakdownType = 'all_pm_pb_pa_sold'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,packaging_class field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND @packaging_class = packaging_class
		AND packaging_activity = 'Sold as empty'
		AND packaging_type = 'Public Binned'

--non-household
IF @BreakdownType = 'all_pm_tnh_pa_sold'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,packaging_class field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND @packaging_class = packaging_class
		AND packaging_activity = 'Sold as empty'
		AND packaging_type = 'Total Non-Household packaging'

--HH drinks
IF @BreakdownType = 'all_pm_pa_HH_drinks_sold'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,'' field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND packaging_activity = 'Sold as empty'
		AND packaging_type = 'Household drinks containers'

--non HH drinks
IF @BreakdownType = 'all_pm_pa_nHH_drinks_sold'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,'' field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND packaging_activity = 'Sold as empty'
		AND packaging_type = 'Non-household drinks containers'

--all drinks
IF @BreakdownType = 'all_pm_pa_all_drinks_sold'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,'' field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND packaging_activity = 'Sold as empty'
		AND packaging_type LIKE '%Household drinks containers'

--reusable packclass
IF @BreakdownType = 'all_pm_pa_reusable_sold'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,packaging_class field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND @packaging_class = packaging_class
		AND packaging_activity = 'Sold as empty'
		AND packaging_type = 'Reusable packaging'

--total packaging
IF @BreakdownType = 'all_pm_pa_tp_sold'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,packaging_class field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND packaging_activity = 'Sold as empty'
		AND Total_Packaging = 'total packaging'

--hh
IF @BreakdownType = 'all_pm_pa_total_hh_sold'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,packaging_class field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND packaging_activity = 'Sold as empty'
		AND packaging_type = 'Total Household packaging'

--nhh
IF @BreakdownType = 'all_pm_pa_total_nonhh_sold'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,packaging_class field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND packaging_activity = 'Sold as empty'
		AND packaging_type = 'Total Non-Household packaging'

--reuse
IF @BreakdownType = 'all_pm_pa_total_reusable_sold'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,packaging_class field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND packaging_activity = 'Sold as empty'
		AND packaging_type = 'Reusable packaging'

---Hired or loaned
IF @BreakdownType = 'all_pm_hh_pa_hired'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,packaging_class field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND @packaging_class = packaging_class
		AND packaging_activity = 'Hired or loaned'
		AND packaging_type = 'Total Household packaging'

--pubic binned
IF @BreakdownType = 'all_pm_pb_pa_Imported'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,packaging_class field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND @packaging_class = packaging_class
		AND packaging_activity = 'Hired or loaned'
		AND packaging_type = 'Public Binned'

--non-household
IF @BreakdownType = 'all_pm_tnh_pa_hired'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,packaging_class field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND @packaging_class = packaging_class
		AND packaging_activity = 'Hired or loaned'
		AND packaging_type = 'Total Non-Household packaging'

--HH drinks
IF @BreakdownType = 'all_pm_pa_HH_drinks_hired'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,'' field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND packaging_activity = 'Hired or loaned'
		AND packaging_type = 'Household drinks containers'

--non HH drinks
IF @BreakdownType = 'all_pm_pa_nHH_drinks_hired'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,'' field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND packaging_activity = 'Hired or loaned'
		AND packaging_type = 'Non-household drinks containers'

--all drinks
IF @BreakdownType = 'all_pm_pa_all_drinks_hired'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,'' field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND packaging_activity = 'Hired or loaned'
		AND packaging_type LIKE '%Household drinks containers'

--reusable packclass
IF @BreakdownType = 'all_pm_pa_reusable_hired'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,packaging_class field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND @packaging_class = packaging_class
		AND packaging_activity = 'Hired or loaned'
		AND packaging_type = 'Reusable packaging'

--total packaging
IF @BreakdownType = 'all_pm_pa_tp__hired'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,packaging_class field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND packaging_activity = 'Hired or loaned'
		AND Total_Packaging = 'total packaging'

--hh
IF @BreakdownType = 'all_pm_pa_total_hh_hired'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,packaging_class field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND packaging_activity = 'Hired or loaned'
		AND packaging_type = 'Total Household packaging'

--nhh
IF @BreakdownType = 'all_pm_pa_total_nonhh_hired'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,packaging_class field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND packaging_activity = 'Hired or loaned'
		AND packaging_type = 'Total Non-Household packaging'

--reuse
IF @BreakdownType = 'all_pm_pa_total_reusable_hired'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,packaging_class field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND packaging_activity = 'Hired or loaned'
		AND packaging_type = 'Reusable packaging'

---ONLINE
IF @BreakdownType = 'all_pm_online'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,packaging_class field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND @packaging_class = packaging_class
		AND packaging_type = 'Total Household Packaging'

--and packaging_activity = 'Online Marketplace'
IF @BreakdownType = 'all_pm_tnh_pa_online'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,packaging_class field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND @packaging_class = packaging_class
		AND packaging_type = 'Total Non-Household packaging'

--and packaging_activity = 'Online Marketplace'
--public binned all
IF @BreakdownType = 'all_public_binned'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,packaging_class field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND @packaging_class = packaging_class
		AND packaging_type = 'Public Binned'

--online non
IF @BreakdownType = 'all_pm_online_non'
	SELECT OrganisationName
		,subsidiary_id
		,SubsidiaryOrganisation_ReferenceNumber
		,packaging_material field2
		,packaging_class field3
		,file1_Quantity_kg_extrapolated
		,file2_Quantity_kg_extrapolated
		,quantity_kg_diff
		,file1_submission_date
		,file2_submission_date
		,Quantity_kg_extrapolated_diff
	FROM #file_joined
	WHERE @packaging_material = packaging_material
		AND @packaging_class = packaging_class
		AND packaging_type = 'Total non-Household Packaging'
		--and packaging_activity = 'Online Marketplace'
END;