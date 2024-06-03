CREATE VIEW [dbo].[v_POM] AS SELECT 
	p.organisation_id,
	p.subsidiary_id, 
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
	CASE
		WHEN p.submission_period =  '2023-P2' THEN CAST(p.packaging_material_weight * (181.00 / 121.00) AS DECIMAL(16,2))
		WHEN p.submission_period =  '2024-P2' THEN CAST(p.packaging_material_weight * (182.00 / 91.00) AS DECIMAL(16,2)) 
		WHEN p.submission_period =  '2024-P3' THEN CAST(p.packaging_material_weight * (182.00 / 61.00) AS DECIMAL(16,2))   
		ELSE p.packaging_material_weight 
	END Quantity_kg_extrapolated,

	CASE
		WHEN p.submission_period =  '2023-P2' THEN CAST(p.packaging_material_units * (181.00 / 121.00) AS DECIMAL(16,2))
		WHEN p.submission_period =  '2024-P2' THEN CAST(p.packaging_material_units * (182.00 / 91.00) AS DECIMAL(16,2))
		WHEN p.submission_period =  '2024-P3' THEN CAST(p.packaging_material_units * (182.00 / 61.00) AS DECIMAL(16,2))
		ELSE p.packaging_material_units
	END	Quantity_units_extrapolated,

	CASE
		WHEN p.to_country IS NOT NULL AND p.from_country IS NOT NULL THEN CONCAT(fn.Text, ' to ', tn.Text)
		ELSE NULL
	END relative_move,

	CONVERT(DATETIME,substring(meta.created,1,23)) File_submitted_time,
	dense_rank() over(partition by trim(sp.Text), p.organisation_id order by CONVERT(DATETIME,substring(meta.created,1,23)) desc) as Rank_over_time,
	case when dense_rank() over(partition by trim(sp.Text), p.organisation_id order by CONVERT(DATETIME,substring(meta.created,1,23)) desc) = 1 then 1 else 0 end as IsLatest

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
LEFT JOIN [rpd].[cosmos_file_metadata] meta ON meta.FileName = p.FileName;