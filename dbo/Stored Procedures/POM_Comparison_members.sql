CREATE PROC [dbo].[POM_Comparison_members] @filename1 [nvarchar](4000),@filename2 [nvarchar](4000),@ProducerCS [nvarchar](100),@OrganisationID [int],@compliance_scheme [nvarchar](200),@securityquery [nvarchar](200) AS
BEGIN
	SET NOCOUNT ON;
/****************************************************************************************************************************
	History:

	Updated: 2024-08-23:	ST001:	Ticket - 421766:Update org_name from fj.org_name to r.org_name if final select statement.
													this is to ensure correct org_name displayed based on selection of latest,
													accepted, or latest value(s)

	Actions TBC:			
			YYYY-MM-DD:		NN001:	OrganisationName actually contains OrgId.  Assess impact, Rename to OrganisationId 
									to reflect content correctly.
	Updated: 27/09/2024		TS: Ticket Bug No: 449230
							1-The [organisation_id] column changed to OrganisationID 
							which has been changed in the v_POM_All_Submission to fetch the correct Organisation and its subsidiaries
							2- Action has been taken for the NN001 Organisationname has changed to org_id.

 ******************************************************************************************************************************/
	
--this script now only needed for member comparison. 
WITH file1
AS (
	SELECT OrganisationID
		,[subsidiary_id]
		,[SecondOrganisation_ReferenceNumber] as SubsidiaryOrganisation_ReferenceNumber -- added new sys gen subsidiary id
		,[organisation_size]
		,[submission_period]
		,[packaging_activity]
		,[packaging_type]
		,[packaging_class]
		,[packaging_material]
		,[packaging_sub_material]
		,[from_nation]
		,[to_nation]
		,[quantity_kg]
		,[quantity_unit]
		,[FileName]
		,[Quantity_kg_extrapolated]
		,[Quantity_units_extrapolated]
		,[relative_move]
		,submission_date
		,org_sub_type
		,org_name
		,compliance_scheme
		,registration_type_code
		, nation
		,data_type
		--,so.[SecondOrganisation_CompaniesHouseNumber]
	FROM [dbo].[t_POM_Submissions_POM_Comparison]
	LEFT JOIN dbo.v_subsidiaryorganisations so 
	on so.FirstOrganisation_ReferenceNumber = [dbo].[t_POM_Submissions_POM_Comparison].OrganisationID
		and ISNULL(trim(so.SubsidiaryId),'') = ISNULL(trim([dbo].[t_POM_Submissions_POM_Comparison].subsidiary_id),'')
		--and ISNULL(trim(so.[SecondOrganisation_CompaniesHouseNumber]),'') = ISNULL(trim([dbo].[t_POM_Submissions_POM_Comparison].[CH_Number]),'')
			and so.RelationToDate is NULL -- added new sys gen subsidiary id 
			

	WHERE nation = @securityquery
		AND FileName = @filename1
		AND (
			(
				@producerCS = 'Producer'
				AND OrganisationID = @OrganisationID
				)
			OR (
				@producerCS = 'Compliance Scheme'
				AND compliance_scheme = @compliance_scheme
				AND data_type = 'Member'
				)
			)
	),

file2 AS (
	SELECT OrganisationID
		,[subsidiary_id]
		,[SecondOrganisation_ReferenceNumber] as SubsidiaryOrganisation_ReferenceNumber -- added new sys gen subsidiary id
		,[organisation_size]
		,[submission_period]
		,[packaging_activity]
		,[packaging_type]
		,[packaging_class]
		,[packaging_material]
		,[packaging_sub_material]
		,[from_nation]
		,[to_nation]
		,[quantity_kg]
		,[quantity_unit]
		,[FileName]
		,[Quantity_kg_extrapolated]
		,[Quantity_units_extrapolated]
		,[relative_move]
		,submission_date
		,org_sub_type
		,org_name
		,compliance_scheme
		,registration_type_code
		--,so.[SecondOrganisation_CompaniesHouseNumber]
		
	FROM [dbo].[t_POM_Submissions_POM_Comparison]
	LEFT JOIN dbo.v_subsidiaryorganisations so 
	on so.FirstOrganisation_ReferenceNumber = [dbo].[t_POM_Submissions_POM_Comparison].OrganisationID
		and ISNULL(trim(so.SubsidiaryId),'') = ISNULL(trim([dbo].[t_POM_Submissions_POM_Comparison].subsidiary_id),'')
		--and ISNULL(trim(so.[SecondOrganisation_CompaniesHouseNumber]),'') = ISNULL(trim([dbo].[t_POM_Submissions_POM_Comparison].[CH_Number]),'')
			and so.RelationToDate is NULL -- added new subsidiary column
	WHERE nation = @securityquery
		AND FileName = @filename2
		AND (
			(
				@producerCS = 'Producer'
				AND OrganisationID = @OrganisationID
				)
			OR (
				@producerCS = 'Compliance Scheme'
				AND compliance_scheme = @compliance_scheme
				AND data_type = 'Member'
				)
			)
	)
SELECT coalesce(a.OrganisationID, b.OrganisationID) org_id  /** NN001: **/
	,coalesce(a.[subsidiary_id], b.[subsidiary_id]) [subsidiary_id]
	,coalesce(a.SubsidiaryOrganisation_ReferenceNumber, b.SubsidiaryOrganisation_ReferenceNumber) SubsidiaryOrganisation_ReferenceNumber -- added new sys gen subsidiary id
	--,coalesce(a.[SecondOrganisation_CompaniesHouseNumber], b.[SecondOrganisation_CompaniesHouseNumber]) -- added new sys gen subsidiary id
	,coalesce(a.packaging_material, b.packaging_material) packaging_material
	,coalesce(a.[from_nation], b.[from_nation]) [from_nation]
	,coalesce(a.packaging_activity, b.packaging_activity) packaging_activity
	,coalesce(a.packaging_class, b.packaging_class) packaging_class
	,coalesce(a.packaging_sub_material, b.packaging_sub_material) packaging_sub_material
	,coalesce(a.to_nation, b.to_nation) to_nation
	,coalesce(a.relative_move, b.relative_move) relative_move
	,coalesce(a.packaging_type, b.packaging_type) packaging_type
	,a.quantity_kg file1_quantity_kg
	,b.quantity_kg file2_quantity_kg
	,a.quantity_unit file1_quantity_unit
	,b.quantity_unit file2_quantity_unit
	,a.Quantity_kg_extrapolated file1_Quantity_kg_extrapolated
	,b.Quantity_kg_extrapolated file2_Quantity_kg_extrapolated
	,isnull(b.quantity_kg, '0') - isnull(a.quantity_kg, '0') AS quantity_kg_diff
	,isnull(b.quantity_unit, '0') - isnull(a.quantity_unit, '0') AS quantity_unit_diff
	,isnull(b.Quantity_kg_extrapolated, '0') - isnull(a.Quantity_kg_extrapolated, '0') AS Quantity_kg_extrapolated_diff
	,isnull(b.Quantity_units_extrapolated, '0') - isnull(a.Quantity_units_extrapolated, '0') AS Quantity_units_extrapolated_diff
	,a.filename filename1
	,b.filename filename2
	,a.submission_date file1_submission_date
	,b.submission_date file2_submission_date
	,coalesce(a.org_sub_type, b.org_sub_type) org_sub_type
	,coalesce(a.org_name, b.org_name) org_name
	,coalesce(a.organisation_size, b.organisation_size) organisation_size
	,coalesce(a.compliance_scheme, b.compliance_scheme) compliance_scheme
	,coalesce(a.registration_type_code, b.registration_type_code) registration_type_code

INTO #file_joined
FROM file1 a
FULL JOIN file2 b
	ON isnull(a.OrganisationID, '') = isnull(b.OrganisationID, '')
		AND isnull(a.[subsidiary_id], '') = isnull(b.[subsidiary_id], '')
		AND isnull(a.SubsidiaryOrganisation_ReferenceNumber, '') = isnull(b.SubsidiaryOrganisation_ReferenceNumber, '') -- added new subsidiary column
		--AND ISNULL(trim(a.[SecondOrganisation_CompaniesHouseNumber]),'') = ISNULL(trim(b.[SecondOrganisation_CompaniesHouseNumber]),'') -- added new subsidiary column
		AND isnull(a.[packaging_activity], '') = isnull(b.packaging_activity, '')
		AND isnull(a.[packaging_type], '') = isnull(b.packaging_type, '')
		AND isnull(a.[packaging_class], '') = isnull(b.packaging_class, '')
		AND isnull(a.[packaging_material], '') = isnull(b.packaging_material, '')
		AND isnull(a.[packaging_sub_material], '') = isnull(b.packaging_sub_material, '')
		AND isnull(a.[from_nation], '') = isnull(b.from_nation, '')
		AND isnull(a.[to_nation], '') = isnull(b.to_nation, '')
		AND isnull(a.[organisation_size], '') = isnull(b.organisation_size, '')


--remove Self-managed organisation waste where to_nation is not null
DELETE
FROM #file_joined
WHERE packaging_type = 'Self-managed organisation waste'
	AND to_nation IS NOT NULL

DELETE
FROM #file_joined
WHERE packaging_type = 'Self-managed consumer waste'
	AND to_nation IS NOT NULL

SELECT DISTINCT fj.org_id
	,fj.subsidiary_id
	,fj.SubsidiaryOrganisation_ReferenceNumber --- added new subsidiary column
	,fj.organisation_size
	,fj.compliance_scheme
	,fj.packaging_type
	,fj.packaging_material
	,file1_Quantity_kg_extrapolated
	,file2_Quantity_kg_extrapolated
	,fj.from_nation
	,fj.relative_move
	,fj.packaging_activity
	,fj.packaging_class
	,fj.packaging_sub_material
	,fj.to_nation
	,r.[organisation_name] as org_name  /** ST001: **/ --- changed by TS set the org name
	,fj.Quantity_kg_extrapolated_diff
	,CASE 
		WHEN fj.packaging_type IN (
				'Total Non-Household packaging'
				,'Total Household packaging'
				,'Public binned'
				,'Reusable packaging'
				,'Household drinks containers'
				,'Non-household drinks containers'
				)
			THEN 'Total Packaging'
		ELSE NULL
		END Total_Packaging
	,r.[org_sub_type] org_sub_type2
	,CASE 
		WHEN r.registration_type_code = 'GR'
			THEN 'Group'
		WHEN r.registration_type_code = 'IN'
			THEN 'Single'
		ELSE ''
		END [registration_type_code2]
FROM #file_joined fj
LEFT JOIN dbo.t_registration_latest r
	ON r.organisation_id = fj.org_id
		AND r.subsidiary_id = fj.subsidiary_id


END;