﻿CREATE VIEW [dbo].[v_POM] AS SELECT 
/****************************************************************************************************************************
	History:
 
	Updated: 2024-11-15:	YM001:	Ticket - 460891:	Adding the new column [transitional_packaging_units]
	Updated: 2024-12-02:	SN002:	Ticket - 460891:	Adding the new column PkgOrgJoinColumn 		
	
******************************************************************************************************************************/
	p.organisation_id,
	p.subsidiary_id, 
	so.SecondOrganisation_ReferenceNumber as SubsidiaryOrganisation_ReferenceNumber,
	p.organisation_size,
	'' as organisation_sub_type_code,
	sp.Text submission_period,
	p.submission_period as submission_period_tile,
	pa.Text packaging_activity,
	pt.Text packaging_type,
	pc.Text packaging_class,
	pm.Text packaging_material,
	p.packaging_material_subtype as packaging_sub_material, --alias added
	fn.Text from_nation,
	tn.Text to_nation,
	p.packaging_material_weight as quantity_kg, --alias added,
	p.packaging_material_units as quantity_unit, --alias added,
	p.load_ts,
	p.FileName,
	p.transitional_packaging_units, /**YM001 : Added new column transitional_packaging_units **/
	CASE
		WHEN p.submission_period =  '2023-P2' THEN CAST(p.packaging_material_weight * 1.50  AS DECIMAL(16,2))
		WHEN p.submission_period =  '2024-P2' THEN CAST(p.packaging_material_weight * 2 AS DECIMAL(16,2)) 
		WHEN p.submission_period =  '2024-P3' THEN CAST(p.packaging_material_weight * 3 AS DECIMAL(16,2))   
		ELSE p.packaging_material_weight 
	END Quantity_kg_extrapolated,

	CASE
		WHEN p.submission_period =  '2023-P2' THEN CAST(p.packaging_material_units * 1.5 AS DECIMAL(16,2))
		WHEN p.submission_period =  '2024-P2' THEN CAST(p.packaging_material_units * 2 AS DECIMAL(16,2))
		WHEN p.submission_period =  '2024-P3' THEN CAST(p.packaging_material_units * 3 AS DECIMAL(16,2))
		ELSE p.packaging_material_units
	END	Quantity_units_extrapolated,

	CASE
		WHEN p.to_country IS NOT NULL AND p.from_country IS NOT NULL THEN CONCAT(fn.Text, ' to ', tn.Text)
		ELSE NULL
	END relative_move
	,CONVERT(DATETIME,substring(meta.created,1,23)) File_submitted_time

,case when dense_rank() over(partition by sp.Text, p.organisation_id order by CONVERT(DATETIME,substring(meta.created,1,23)) desc) = 1 then 1 else 0 end as IsLatest
,PkgOrgJoinColumn = Concat(p.packaging_type,'-',organisation_size)	/**SN002:	Ticket - 460891:	Adding the new column PkgOrgJoinColumn**/

FROm rpd.POM p
--FROM dbo.v_rpd_Pom_Active p
LEFT JOIN dbo.t_PoM_Codes sp ON sp.Code = p.submission_period 
								AND sp.Type = 'submission_period'
LEFT JOIN dbo.t_PoM_Codes pa ON pa.Code = p.packaging_activity 
								AND pa.Type = 'packaging_activity'
LEFT JOIN dbo.t_PoM_Codes pt on pt.code = p.packaging_type 
								AND pt.Type = 'packaging_type'
LEFT JOIN dbo.t_PoM_Codes pc on pc.code = p.packaging_class 
								AND pc.Type = 'packaging_class'
LEFT JOIN dbo.t_PoM_Codes pm on pm.code = p.packaging_material 
								AND pm.Type = 'packaging_material'
LEFT JOIN dbo.t_PoM_Codes tn ON tn.Code = p.to_country 
								AND tn.Type = 'nation'
LEFT JOIN dbo.t_PoM_Codes fn ON fn.Code = p.from_country 
								AND fn.Type = 'nation'
LEFT JOIN [rpd].[cosmos_file_metadata] meta ON meta.FileName = p.FileName
LEFT JOIN dbo.v_subsidiaryorganisations so 
	on so.FirstOrganisation_ReferenceNumber = p.organisation_id
		and ISNULL(trim(so.SubsidiaryId),'') = ISNULL(trim(p.subsidiary_id),'')
			and so.RelationToDate is NULL;