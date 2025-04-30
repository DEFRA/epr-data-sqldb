CREATE PROC [dbo].[sp_CrossValidation_pom_org_files] @RYear [INT],@CS_or_DP [varchar](100),@CS_Name [nvarchar](4000),@OrgFileName [nvarchar](4000),@PomFileName1 [nvarchar](4000),@PomFileName2 [nvarchar](4000) AS
begin

		if @CS_or_DP = 'Compliance Scheme'
		begin
				WITH Org_Data AS 
				(
					SELECT 
					   [organisation_id] as org_organisation_id
					  ,[subsidiary_id] as org_subsidiary_id
					  ,[organisation_name]
					  ,[organisation_size] aS org_organisation_size
					  ,CASE 
							WHEN [organisation_sub_type_code]  = 'LIC' THEN 'Licensor'
							WHEN [organisation_sub_type_code]  = 'POB' THEN 'Pub operating business '
							WHEN [organisation_sub_type_code]  = 'FRA' THEN 'Franchisor '
							WHEN [organisation_sub_type_code]  = 'NAO' THEN 'Non-associated organisation'
							WHEN [organisation_sub_type_code]  = 'HCY' THEN 'Holding company'
							WHEN [organisation_sub_type_code]  = 'SUB' THEN 'Subsidiary'
							WHEN [organisation_sub_type_code]  = 'LFR' THEN 'Licensee/Franchisee'
							WHEN [organisation_sub_type_code]  = 'TEN' THEN 'Tenant'
							WHEN [organisation_sub_type_code]  = 'OTH' THEN 'Others'
						ELSE NULL END [Org_Sub_Type]
					,CASE 
						WHEN [subsidiary_id] is null THEN 'single'
					  ELSE 'group' END AS single_or_group


					  ,[packaging_activity_so] as Brand_Owner_Org
					  ,[packaging_activity_pf] as Packer_Filler_Org
					  ,[packaging_activity_im] as Importer_Org
					  ,[packaging_activity_se] as Distributor_Org
					  ,[packaging_activity_hl] as Service_Provider_Org
					  ,[packaging_activity_om] as Online_Market_Place_Org
					  ,[packaging_activity_sl] as Seller_Org
					  ,[liable_for_disposal_costs_flag] AS Liable_to_Pay_Disposal_Cost
					  ,[total_tonnage]
					  ,[FileName] as org_filename
					  ,[joiner_date]
					  ,[leaver_date]
					  ,[leaver_code]
					FROM [rpd].[CompanyDetails]
					where FileName = @OrgFileName
				),

						pom_data AS (
							SELECT
								pvt.organisation_id AS pom_organisation_id,
								pvt.subsidiary_Id AS pom_subsidiary_id,
								pvt.organisation_size AS pom_organisation_size,
								pvt.fileName AS pom_filename,
								[SO] AS Brand_Owner_Pom,
								[IM] AS Importer_Pom,
								[PF] AS Packer_Filler_Pom,
								[HL] AS Service_Provider_Pom,
								[SE] AS Distributor_Pom,
								[OM] AS Online_Market_Place_Pom,
								pvt.total_packaging_material_weight,  -- Add total weight column
								-- Compliance Check: Ensure check is done at org_name + FileName level
								CASE 
									WHEN EXISTS (
										SELECT 1 
										FROM rpd.POM p_inner
										JOIN Org_Data od_inner 
											ON p_inner.Organisation_Id = od_inner.org_organisation_id
											AND ISNULL(p_inner.subsidiary_Id, '') = ISNULL(od_inner.org_subsidiary_id, '') 
										WHERE 
										--od_inner.organisation_name = od.organisation_name  -- Ensure org_name is matched
										p_inner.organisation_id = pvt.organisation_id
										AND ISNULL(p_inner.subsidiary_Id, '') = ISNULL(pvt.subsidiary_Id, '')
										AND p_inner.FileName = pvt.fileName
										AND p_inner.packaging_type IN ('HH', 'PB')  
									) THEN 1 ELSE 0
								END AS has_HH_PB
							FROM (
								-- Aggregate before pivoting
								SELECT 
									Organisation_Id,
									subsidiary_Id,
									organisation_size,
									FileName,
									submission_period,
									ISNULL(Packaging_activity, 'No-activity') AS Packaging_activity,
									SUM(Packaging_material_weight) AS Packaging_material_weight,
									SUM(SUM(Packaging_material_weight)) OVER (PARTITION BY Organisation_Id, subsidiary_Id, FileName) 
										AS total_packaging_material_weight  -- Compute total weight
								FROM rpd.POM
								WHERE FileName IN (@PomFileName1, @PomFileName2)
								GROUP BY Organisation_Id, subsidiary_Id, organisation_size, FileName, submission_period, Packaging_activity
							) sub
							PIVOT(
								SUM(packaging_material_weight) FOR Packaging_Activity 
								IN ([SO], [IM], [PF], [HL], [SE], [OM])
							) AS pvt
							JOIN Org_Data od 
								ON pvt.organisation_id = od.org_organisation_id 
								AND ISNULL(pvt.subsidiary_Id, '') = ISNULL(od.org_subsidiary_id, '')
						),


				org_pom_data AS (
					SELECT 
						cd.*,
						p.*
					FROM Org_Data cd 
					FULL OUTER JOIN pom_data p 
						ON cd.org_organisation_id = p.pom_organisation_id 
						AND ISNULL(p.pom_subsidiary_id, '') = ISNULL(cd.org_subsidiary_id, '')
				),


				Org_Pom_submitted_files AS 
				(
					SELECT [file_submitted_organisation]
					  ,[file_submitted_organisation_IsComplianceScheme]
					  ,[SubmissionPeriod] AS Org_SubmissionPeriod
					  ,[cd_Submission_time] AS Org_Submission_Date
					  ,Org_Regulator_Status
					  ,[cd_filename] AS landing_cd_filename
					  ,[pom_Submission_time] AS Pom_Submission_Date
					  ,Pom_Regulator_Status
					  ,[pom_filename] AS landing_pom_filename
					  ,[pom_SubmissionPeriod] AS Pom_SubmissionPeriod
					  ,[RelevantYear]
					  ,[CS_or_DP]
					  ,[CS_Name]
					  ,[CS_nation]
					  ,[DisplayFilenameCD]
					  ,[DisplayFilenamePOM]
					  ,ProducerName
					  ,[ProducerNationId]
					  ,ProducerNationName
				  FROM [dbo].[v_CrossValidation_Landing_Page]
				  WHERE [CS_or_DP] = 'Compliance Scheme'
				  and RelevantYear = @RYear
				  and CS_Name = @CS_Name
				  and cd_filename = @OrgFileName 
				  and pom_filename in ( @PomFileName1, @PomFileName2)
		  
				)

				SELECT lp.*, 
					   op.*, 
						CASE 
						   WHEN op.Liable_to_Pay_Disposal_Cost = 'Yes' AND op.has_HH_PB = 0 
								THEN 'Non Compliant'
						   WHEN op.Liable_to_Pay_Disposal_Cost = 'No' AND op.has_HH_PB = 1
								THEN 'Non Compliant'
						   When  op.Liable_to_Pay_Disposal_Cost = 'Yes' AND  op.org_organisation_size = 'S' 
								THEN 'Non Compliant'
						   when (
									(op.Liable_to_Pay_Disposal_Cost = 'Yes' and op.has_HH_PB = 1 and op.org_organisation_size <> 'S') 
										or 
									(op.Liable_to_Pay_Disposal_Cost = 'No' and op.has_HH_PB = 0)
								)
								THEN 'Compliant'
						   ELSE 'Non Compliant' 
					   END AS Highlighted_liability_cost_flag,

					   CASE
						   WHEN op.total_packaging_material_weight > 50000 AND op.org_organisation_size = 'S' THEN 'Non Compliant'
						   WHEN op.total_packaging_material_weight <= 50000 AND op.org_organisation_size = 'S' THEN 'Compliant'
						   ELSE 'N/A'
					   END AS Small_producer_total_tonnage
				FROM Org_Pom_submitted_files lp
				LEFT JOIN Org_Pom_Data op
				ON lp.landing_cd_filename = op.org_filename 
				AND lp.landing_pom_filename = op.pom_filename
				WHERE 
				UPPER(TRIM(ISNULL(lp.Org_Regulator_Status, ''))) IN ('PENDING', 'ACCEPTED', 'QUERIED', 'GRANTED', 'Rejected', 'Cancelled', 'Refused')
				AND UPPER(TRIM(ISNULL(lp.Pom_Regulator_Status, ''))) IN ('PENDING', 'ACCEPTED', 'QUERIED', 'GRANTED', 'Rejected', 'Cancelled', 'Refused');

		end;

				IF @CS_or_DP = 'All producers'
				BEGIN

					WITH Org_Data AS 
					(
						SELECT 
							[organisation_id] AS org_organisation_id,
							[subsidiary_id] AS org_subsidiary_id,
							[organisation_name],
							[organisation_size] AS org_organisation_size,
							CASE 
								WHEN [organisation_sub_type_code] = 'LIC' THEN 'Licensor'
								WHEN [organisation_sub_type_code] = 'POB' THEN 'Pub operating business '
								WHEN [organisation_sub_type_code] = 'FRA' THEN 'Franchisor '
								WHEN [organisation_sub_type_code] = 'NAO' THEN 'Non-associated organisation'
								WHEN [organisation_sub_type_code] = 'HCY' THEN 'Holding company'
								WHEN [organisation_sub_type_code] = 'SUB' THEN 'Subsidiary'
								WHEN [organisation_sub_type_code] = 'LFR' THEN 'Licensee/Franchisee'
								WHEN [organisation_sub_type_code] = 'TEN' THEN 'Tenant'
								WHEN [organisation_sub_type_code] = 'OTH' THEN 'Others'
								ELSE NULL 
							END AS [Org_Sub_Type],
							CASE 
								WHEN [subsidiary_id] IS NULL THEN 'single'
								ELSE 'group' 
							END AS single_or_group,
							[packaging_activity_so] AS Brand_Owner_Org,
							[packaging_activity_pf] AS Packer_Filler_Org,
							[packaging_activity_im] AS Importer_Org,
							[packaging_activity_se] AS Distributor_Org,
							[packaging_activity_hl] AS Service_Provider_Org,
							[packaging_activity_om] AS Online_Market_Place_Org,
							[packaging_activity_sl] AS Seller_Org,
							[liable_for_disposal_costs_flag] AS Liable_to_Pay_Disposal_Cost,
					        [total_tonnage],
							[FileName] AS org_filename,
							[joiner_date],
					        [leaver_date],
					        [leaver_code]
						FROM [rpd].[CompanyDetails]
					),

					pom_data AS (
						SELECT
							pvt.organisation_id AS pom_organisation_id,
							pvt.subsidiary_Id AS pom_subsidiary_id,
							pvt.organisation_size AS pom_organisation_size,
							pvt.fileName AS pom_filename,
							[SO] AS Brand_Owner_Pom,
							[IM] AS Importer_Pom,
							[PF] AS Packer_Filler_Pom,
							[HL] AS Service_Provider_Pom,
							[SE] AS Distributor_Pom,
							[OM] AS Online_Market_Place_Pom,
							-- Calculate the total packaging material weight across all activities
							COALESCE([SO], 0) + COALESCE([IM], 0) + COALESCE([PF], 0) + 
							COALESCE([HL], 0) + COALESCE([SE], 0) + COALESCE([OM], 0) AS total_packaging_material_weight,
							-- Compliance Check: Ensure check is done at org_name + FileName level
							CASE 
								WHEN EXISTS (
									SELECT 1 
									FROM rpd.POM p_inner
									JOIN Org_Data od_inner 
										ON p_inner.Organisation_Id = od_inner.org_organisation_id
										AND ISNULL(p_inner.subsidiary_Id, '') = ISNULL(od_inner.org_subsidiary_id, '')
									WHERE 
									--od_inner.organisation_name = od_inner.organisation_name  -- Ensure org_name is matched
									p_inner.organisation_id = pvt.organisation_id
									AND ISNULL(p_inner.subsidiary_Id, '') = ISNULL(pvt.subsidiary_Id, '') 
									AND p_inner.FileName = pvt.fileName
									AND p_inner.packaging_type IN ('HH', 'PB')  
								) THEN 1 ELSE 0
							END AS has_HH_PB
						FROM (
							SELECT 
								Organisation_Id,
								subsidiary_Id,
								organisation_size,
								FileName,
								submission_period,
								Packaging_activity,
								SUM(Packaging_material_weight) AS Packaging_material_weight
							FROM rpd.POM
							GROUP BY Organisation_Id, subsidiary_Id, organisation_size, FileName, submission_period, Packaging_activity
						) sub
						PIVOT(
							SUM(packaging_material_weight) FOR Packaging_Activity 
							IN ([SO], [IM], [PF], [HL], [SE], [OM])
						) AS pvt
					),


					org_pom_data AS (
						SELECT 
							cd.*, 
							p.*
						FROM Org_Data cd 
						LEFT JOIN pom_data p 
							ON cd.org_organisation_id = p.pom_organisation_id 
							AND ISNULL(p.pom_subsidiary_id, '') = ISNULL(cd.org_subsidiary_id, '')
					),



					Org_Pom_submitted_files AS (
						SELECT 
							[file_submitted_organisation],
							[file_submitted_organisation_IsComplianceScheme],
							[SubmissionPeriod] AS Org_SubmissionPeriod,
							[cd_Submission_time] AS Org_Submission_Date,
							Org_Regulator_Status,
							[cd_filename] AS landing_cd_filename,
							[pom_Submission_time] AS Pom_Submission_Date,
							Pom_Regulator_Status,
							[pom_filename] AS landing_pom_filename,
							[pom_SubmissionPeriod] AS Pom_SubmissionPeriod,
							[RelevantYear],
							[CS_or_DP],
							[CS_Name],
							[CS_nation],
							[DisplayFilenameCD],
							[DisplayFilenamePOM],
							ProducerName,
							[ProducerNationId],
							ProducerNationName,
							ROW_NUMBER() OVER (
								PARTITION BY file_submitted_organisation 
								ORDER BY pom_Submission_time DESC
							) AS pom_submission_rank
						FROM [dbo].[v_CrossValidation_Landing_Page]
						WHERE RelevantYear = @RYear
					)

					SELECT  
						lp.*,  
						op.*,  
						CASE 
						   WHEN op.Liable_to_Pay_Disposal_Cost = 'Yes' AND op.has_HH_PB = 0 
								THEN 'Non Compliant'
						   WHEN op.Liable_to_Pay_Disposal_Cost = 'No' AND op.has_HH_PB = 1
								THEN 'Non Compliant'
						   When  op.Liable_to_Pay_Disposal_Cost = 'Yes' AND  op.org_organisation_size = 'S' 
								THEN 'Non Compliant'
						   when (
									(op.Liable_to_Pay_Disposal_Cost = 'Yes' and op.has_HH_PB = 1 and op.org_organisation_size <> 'S') 
										or 
									(op.Liable_to_Pay_Disposal_Cost = 'No' and op.has_HH_PB = 0)
								)
								THEN 'Compliant'
						   ELSE 'Non Compliant' 
					   END AS Highlighted_liability_cost_flag,

						CASE
						   WHEN op.total_packaging_material_weight > 50000 AND op.org_organisation_size = 'S' THEN 'Non Compliant'
						   WHEN op.total_packaging_material_weight <= 50000 AND op.org_organisation_size = 'S' THEN 'Compliant'
						   ELSE 'N/A'
						END AS Small_producer_total_tonnage
					FROM Org_Pom_submitted_files lp
					LEFT JOIN Org_Pom_Data op
						ON lp.landing_cd_filename = op.org_filename 
						AND lp.landing_pom_filename = op.pom_filename
					WHERE 
					    pom_submission_rank = 1
					    AND UPPER(TRIM(ISNULL(Org_Regulator_Status, ''))) IN ('PENDING', 'ACCEPTED', 'QUERIED', 'GRANTED')
                        AND UPPER(TRIM(ISNULL(Pom_Regulator_Status, ''))) IN ('PENDING', 'ACCEPTED', 'QUERIED', 'GRANTED')
					ORDER BY 
						lp.Org_Submission_Date DESC, 
						lp.pom_submission_rank ASC;


	end;

		
END;