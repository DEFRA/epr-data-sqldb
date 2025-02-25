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
					  ,[organisation_size] AS org_organisation_size
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
					FROM [rpd].[CompanyDetails]
					where FileName = @OrgFileName
				),

				pom_data AS (


				SELECT		pvt.organisation_id AS pom_organisation_id,
							pvt.subsidiary_Id AS pom_subsidiary_id,
							pvt.organisation_size AS pom_organisation_size,
							pvt.fileName as pom_filename,
							packaging_type,
							[SO] AS Brand_Owner_Pom,
							[IM] AS Importer_Pom,
							[PF] AS Packer_Filler_Pom,
							[HL] AS Service_Provider_Pom,
							[SE] AS Distributor_Pom,
							[OM] AS Online_Market_Place_Pom
						FROM (
							SELECT Organisation_Id ,
								subsidiary_Id,
								organisation_size,
								FileName,
								submission_period,
								isnull(Packaging_activity,'No-activity') as Packaging_activity,
								Packaging_material_weight,
								packaging_type
							FROM rpd.POM
							where FileName in ( @PomFileName1, @PomFileName2)
							) sub
						PIVOT(SUM(packaging_material_weight) FOR Packaging_Activity IN ([SO], [IM], [PF], [HL], [SE], [OM])) AS pvt
				),

				org_pom_data AS (

					SELECT 
							cd.*, 
							p.*
					FROM Org_Data cd 
					full outer JOIN pom_data p 
						ON cd.org_organisation_id = p.pom_organisation_id and ISNULL(p.pom_subsidiary_id,'') = ISNULL(cd.org_subsidiary_id, '')
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

					SELECT lp.*, op.*, 
					   CASE 
						   WHEN op.Liable_to_Pay_Disposal_Cost = 'Yes' AND op.packaging_type Not IN ('HH', 'PB') THEN 'Non Compliant'
						   WHEN op.Liable_to_Pay_Disposal_Cost = 'No' AND op.packaging_type IN ('HH', 'PB') THEN 'Non Compliant'
						   ELSE 'Compliant' 
					   END AS Highlighted_liability_cost_flag,

					   CASE
					       WHEN  op.total_tonnage > 50 AND op.org_organisation_size = 'S' THEN 'Non Compliant'
						   WHEN  op.total_tonnage <= 50 AND op.org_organisation_size = 'S' THEN 'Compliant'
						   ELSE 'N/A'
						END AS Small_producer_total_tonnage

				FROM Org_Pom_submitted_files lp
				full outer JOIN Org_Pom_Data op
				ON lp.landing_cd_filename= op.org_filename 
				and lp.landing_pom_filename = op.pom_filename
		end;

		if @CS_or_DP = 'All producers'
		begin
					WITH Org_Data AS 
					(
						SELECT 
							[organisation_id] as org_organisation_id
						  ,[subsidiary_id] as org_subsidiary_id
						  ,[organisation_name]
						  ,[organisation_size] AS org_organisation_size
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
						FROM [rpd].[CompanyDetails]
					),

					pom_data AS (


					SELECT		pvt.organisation_id AS pom_organisation_id,
								pvt.subsidiary_Id AS pom_subsidiary_id,
								pvt.organisation_size AS pom_organisation_size,
								pvt.fileName as pom_filename,
								packaging_type,
								[SO] AS Brand_Owner_Pom,
								[IM] AS Importer_Pom,
								[PF] AS Packer_Filler_Pom,
								[HL] AS Service_Provider_Pom,
								[SE] AS Distributor_Pom,
								[OM] AS Online_Market_Place_Pom
							FROM (
								SELECT Organisation_Id ,
									subsidiary_Id,
									organisation_size,
									FileName,
									submission_period,
									Packaging_activity,
									Packaging_material_weight,
									packaging_type
								FROM rpd.POM
								) sub
							PIVOT(SUM(packaging_material_weight) FOR Packaging_Activity IN ([SO], [IM], [PF], [HL], [SE], [OM])) AS pvt
					),

					org_pom_data AS (

						SELECT 
								cd.*, 
								p.*
						FROM Org_Data cd 
						LEFT JOIN pom_data p 
							ON cd.org_organisation_id = p.pom_organisation_id and ISNULL(p.pom_subsidiary_id,'') = ISNULL(cd.org_subsidiary_id, '')
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
						  ,ROW_NUMBER() OVER (
												PARTITION BY file_submitted_organisation 
												ORDER BY pom_Submission_time DESC
											) AS pom_submission_rank

					  FROM [dbo].[v_CrossValidation_Landing_Page]
					  where RelevantYear = @RYear
					)


					SELECT lp.*, op.*, 
					   CASE 
						   WHEN op.Liable_to_Pay_Disposal_Cost = 'Yes' AND op.packaging_type Not IN ('HH', 'PB') THEN 'Non Compliant'
						   WHEN op.Liable_to_Pay_Disposal_Cost = 'No' AND op.packaging_type IN ('HH', 'PB') THEN 'Non Compliant'
						   ELSE 'Compliant' 
					   END AS Highlighted_liability_cost_flag,

					   CASE
					       WHEN  op.total_tonnage > 50 AND op.org_organisation_size = 'S' THEN 'Non Compliant'
						   WHEN  op.total_tonnage <= 50 AND op.org_organisation_size = 'S' THEN 'Compliant'
						   ELSE 'N/A'
						END AS Small_producer_total_tonnage


					FROM Org_Pom_submitted_files lp
					LEFT JOIN Org_Pom_Data op

					ON lp.landing_cd_filename= op.org_filename 
					AND lp.landing_pom_filename = op.pom_filename 	
					where pom_submission_rank = 1
			
		end;
		
END;