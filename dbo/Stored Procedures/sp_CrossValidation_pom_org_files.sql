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
										--od_inner.organisation_name = od.organisation_name  -- Ensure org_name is matched --Tufan
										p_inner.organisation_id = pvt.organisation_id  ----Tufan
										AND ISNULL(p_inner.subsidiary_Id, '') = ISNULL(pvt.subsidiary_Id, '')  ----Tufan
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
			With 
			spOrd As (
				Select 
					 SubmissionCode		= Code
					,SubPeriodOrdr		= Row_Number() Over(Partition By [Type] Order By Replace(Replace(Code,'P','1'),'H','2'))
					,SubmissionType		= [Type]
					,SubmissionPeriod	= [Text]
				From
					dbo.t_pom_codes
				Where
					[Type] in ('apps_submission_period')
				And 
					Try_Convert(int,Left(Code,4)) >= 2025
			),
			PomSpOrd As (
				Select 
					 SubmissionCode		= Code
					,SubPeriodOrdr		= Row_Number() Over(Partition By [Type] Order By Replace(Replace(Code,'P','1'),'H','2'))
					,SubmissionType		= [Type]
					,SubmissionPeriod	= [Text]
				From
					dbo.t_pom_codes
				Where
					[Type] in ('apps_submission_period')
				And 
					Try_Convert(int,Left(Code,4)) >= 2024
			),
			OrgSubType As (
				Select 	SubTypeCode='LIC', SubTypeDesc='Licensor' Union
				Select 	SubTypeCode='POB', SubTypeDesc='Pub operating business ' Union
				Select 	SubTypeCode='FRA', SubTypeDesc='Franchisor ' Union
				Select 	SubTypeCode='NAO', SubTypeDesc='Non-associated organisation' Union
				Select 	SubTypeCode='HCY', SubTypeDesc='Holding company' Union
				Select 	SubTypeCode='SUB', SubTypeDesc='Subsidiary' Union
				Select 	SubTypeCode='LFR', SubTypeDesc='Licensee/Franchisee' Union
				Select 	SubTypeCode='TEN', SubTypeDesc='Tenant' Union
				Select 	SubTypeCode='OTH', SubTypeDesc='Others'
			),

			PomPvtData As (
				Select
					 pom_organisation_id				= pvt.organisation_id
					,pom_subsidiary_id					= pvt.subsidiary_Id
					,pom_organisation_size				= pvt.organisation_size
					,pom_filename						= pvt.[FileName]
					,Brand_Owner_Pom					= IsNull([SO],0)
					,Importer_Pom						= IsNull([IM],0)
					,Packer_Filler_Pom					= IsNull([PF],0)
					,Service_Provider_Pom				= IsNull([HL],0)
					,Distributor_Pom					= IsNull([SE],0)
					,Online_Market_Place_Pom			= IsNull([OM],0)
					,total_packaging_material_weight	= IsNull([SO],0) + IsNull([IM],0) + IsNull([PF],0) + IsNull([HL],0) + IsNull([SE],0) + IsNull([OM],0)
					,has_HH_PB						=
						Case 
							When Exists (
								Select	1 
								From	rpd.POM				p_inner
								Join	rpd.CompanyDetails	od_inner	on p_inner.Organisation_Id = od_inner.organisation_id
											And IsNull(p_inner.subsidiary_Id,'') = IsNull(od_inner.subsidiary_id,'')
								Where 
									p_inner.organisation_id = pvt.organisation_id
										And IsNull(p_inner.subsidiary_Id, '') = IsNull(pvt.subsidiary_Id, '') 
										And p_inner.[Filename] = pvt.[Filename]
										And p_inner.packaging_type in ('HH', 'PB')  
								) Then 1 Else 0 
						End
				From (
					Select
						 Organisation_Id
						,subsidiary_Id
						,organisation_size
						,[Filename]
						,submission_period
						,Packaging_activity
						,Packaging_material_weight	= Coalesce(SUM(Packaging_material_weight),0)
					From
						rpd.Pom
					Group By
						 Organisation_Id
						,subsidiary_Id
						,organisation_size
						,[Filename]
						,submission_period
						,Packaging_activity
					) sub
					Pivot( Sum(packaging_material_weight) For Packaging_Activity
						In ([SO], [IM], [PF], [HL], [SE], [OM])
				) As pvt

			),
			RegFileLtst As (
				Select 
					 org_organisation_id				= cd.organisation_id 
					,org_subsidiary_id					= cd.subsidiary_id
					,cd.organisation_name
					,org_organisation_size				= cd.organisation_size
					,Org_Sub_Type						= SubTypeDesc
					,single_or_group					= Case When cd.subsidiary_id Is Null Then 'Single' Else 'Group' End
					,cd.joiner_date
					,cd.leaver_date
					,cd.leaver_code
					,cd.organisation_size
					,Brand_Owner_Org					= cd.packaging_activity_so
					,Packer_Filler_Org					= cd.packaging_activity_pf
					,Importer_Org						= cd.packaging_activity_im
					,Distributor_Org					= cd.packaging_activity_se 
					,Service_Provider_Org				= cd.packaging_activity_hl
					,Online_Market_Place_Org			= cd.packaging_activity_om 
					,Seller_Org							= cd.packaging_activity_sl 
					,Liable_to_Pay_Disposal_Cost		= cd.liable_for_disposal_costs_flag
					,total_tonnage
					,org_filename						= cd.[FileName]
					,Reg_SubmissionPeriod				= reg.SubmissionPeriod
					,Reg_SubmissionDate					= reg.Created
					,reg.SubmissionId
					,reg.RegistrationSetId
					,reg.OrganisationId
					,reg.[FileName]
					,reg.FileType
					,reg.OriginalFileName
					,reg.TargetDirectoryName
					,o.ReferenceNumber
					,o.IsComplianceScheme
					,o.NationId
					,spo.SubPeriodOrdr
					,OrgNationName						= orgn.[Name]
					,CS_Name							= cs.[Name]
					,CS_Nation							= csn.[Name]
					,RelevantYear						= Try_Convert(int,Right((cfm.submissionperiod),4))
					,reg.Regulator_Status
					,Created_frmtDT						= Convert(datetime2,Replace(Replace(cfm.Created,'T', ' '),'Z', ' '))
					,RegIsLatest						= Row_Number() Over(Partition By reg.OrganisationId Order by spo.SubPeriodOrdr Desc, reg.Created Desc )
				FROM 
					rpd.cosmos_file_metadata					cfm
				Join
					dbo.v_submitted_pom_org_file_status			reg
						on cfm.[Filename] = reg.[Filename]
				Join
					spOrd										spo
						on reg.SubmissionPeriod = spo.SubmissionPeriod
				Left Join
					rpd.CompanyDetails							cd
						on reg.[FileName] = cd.[FileName]
				Left Join
					rpd.Organisations							o
						on cfm.OrganisationId = o.ExternalId
				Left Join
					rpd.ComplianceSchemes						cs
						on cfm.ComplianceSchemeId = cs.ExternalId
				Left Join
					OrgSubType									so
						on cd.organisation_sub_type_code = so.SubTypeCode
				Left Join
					rpd.Nations									csn 
						on cs.NationId = csn.id
				Left Join
					rpd.Nations									orgn 
						on o.NationId = orgn.id
				Where
					cfm.FileType = 'CompanyDetails'
				And
					reg.SubmissionType ='Registration'
				And
					reg.Regulator_Status in ('Pending','Accepted','Granted')
				And
					Try_Convert(int,Right((cfm.submissionperiod),4)) = @RYear
			),

			PomFileLtst As (
				Select 
					 pom_organisation_id			
					,pom_subsidiary_id				
					,pom_organisation_size			
					,pom_filename		
					,pom_SubmissionPeriod				= (cfm.submissionperiod)
					,pom_Regulator_Status				= pfs.Regulator_Status
					,pom_Original_Filename				= cfm.OriginalFileName
					,Brand_Owner_Pom				
					,Importer_Pom					
					,Packer_Filler_Pom				
					,Service_Provider_Pom			
					,Distributor_Pom				
					,Online_Market_Place_Pom		
					,cfm.submissionperiod
					,total_packaging_material_weight
					,has_HH_PB						
					,pom_submission_date				= Convert(Datetime,substring(cfm.Created,1,23))
					,RelevantYear						= Try_Convert(int,Right((cfm.submissionperiod),4))
					,Pom_Created_frmtDT					= Convert(datetime2,Replace(Replace(cfm.Created,'T', ' '),'Z', ' '))
					,pom_subPeriod_ord					= pso.SubPeriodOrdr
					,pom_Created						= pfs.Created
				From 
					rpd.cosmos_file_metadata					cfm
				Join
					dbo.v_submitted_pom_org_file_status			pfs
						on cfm.[Filename] = pfs.[Filename]	
				Left Join
					PomPvtData									pom
						on pfs.[Filename] = pom.pom_filename
				Join
					PomSpOrd									pso
						on (cfm.submissionperiod) = pso.SubmissionPeriod
				Where 
					cfm.Filetype = 'POM'
				And 
					pfs.Regulator_Status in ('Pending','Accepted','Granted')
			),
			src As (
				Select 
					 file_submitted_organisation						= reg.ReferenceNumber
					,file_submitted_organisation_IsComplianceScheme		= reg.IsComplianceScheme
					,Org_SubmissionPeriod								= reg.Reg_SubmissionPeriod
					,Org_Submission_Date								= reg.reg_SubmissionDate
					,Org_Regulator_Status								= reg.Regulator_Status
					,landing_cd_filename								= reg.org_filename
					,RelevantYear										= Case When reg.RelevantYear >=2025 And reg.FileType='Companydetails' 
																			Then reg.RelevantYear
																			Else reg.RelevantYear + 1
																		 End
					,CS_or_DP											= Case When reg.IsComplianceScheme = 1 Then 'Compliance Scheme' Else 'Direct Producer' End 
					,reg.CS_Name									
					,reg.CS_Nation
					,reg.Created_frmtDT
					,DisplayFilenameCD									= Concat(reg.OriginalFileName,'_',reg.Created_frmtDT,'_',IsNull(reg.Regulator_Status,'Pending')) 
					,DisplayFilenameCDSort								= Concat(format(convert(datetime,reg.Created_frmtDT,122),'yyyyMMddHHmiss'),'_',reg.OriginalFileName,'_',IsNull(reg.Regulator_Status,'Pending'))	
					,FilenameCDExclude									= Case When IsNull(reg.Regulator_Status,'') In ('Uploaded','') Then 1 Else 0 End
					,ProducerName										= reg.organisation_name
					,ProducerNationId									= reg.NationId
					,ProducerNationName									= reg.OrgNationName
					,reg.org_organisation_id
					,reg.org_subsidiary_id
					,reg.organisation_name
					,reg.organisation_size
					,reg.Org_Sub_Type
					,reg.Brand_Owner_Org			
					,reg.Packer_Filler_Org			
					,reg.Importer_Org				
					,reg.Distributor_Org			
					,reg.Service_Provider_Org		
					,reg.Online_Market_Place_Org	
					,reg.Seller_Org					
					,reg.Liable_to_Pay_Disposal_Cost
					,reg.total_tonnage
					,reg.org_filename 
					,reg.joiner_date
					,reg.leaver_date
					,reg.leaver_code
					,reg.single_or_group
					,DisplayFilenamePOM									= Concat(pom.pom_Original_Filename,'_',pom.pom_Created_frmtDT,'_',IsNull(pom.pom_Regulator_Status,'Pending')) 
					,DisplayFilenamePOMSort								= Concat(format(convert(datetime,pom.pom_Created_frmtDT,122),'yyyyMMddHHmiss'),'_',pom.pom_Original_Filename,'_',IsNull(pom.pom_Regulator_Status,'Pending'))	
					,pom.Pom_Submission_Date
					,pom_Regulator_Status
					,pom.pom_SubmissionPeriod	
					,landing_pom_filename			= pom.pom_filename
					,pom.pom_organisation_id
					,pom.pom_subsidiary_id
					,pom.pom_organisation_size
					,pom.pom_filename
					,pom.Brand_Owner_Pom
					,pom.Importer_Pom
					,pom.Packer_Filler_Pom
					,pom.Service_Provider_Pom
					,pom.Distributor_Pom
					,pom.Online_Market_Place_Pom
					,pom.total_packaging_material_weight
					,pom.has_HH_PB
					,Small_producer_total_tonnage				= Case 
																		When pom.total_packaging_material_weight > 50000 And reg.org_organisation_size = 'S' Then 'Non Compliant'
																		When pom.total_packaging_material_weight <= 50000 And reg.org_organisation_size = 'S' Then 'Compliant'
																		Else 'N/A'
																	 End
					,Highlighted_liability_cost_flag			= Case 
																		When reg.Liable_to_Pay_Disposal_Cost = 'Yes' And pom.has_HH_PB = 0 Then 'Non Compliant'
																		When reg.Liable_to_Pay_Disposal_Cost = 'No' AND pom.has_HH_PB = 1 Then 'Non Compliant'
																		When  reg.Liable_to_Pay_Disposal_Cost = 'Yes' AND  reg.org_organisation_size = 'S' Then 'Non Compliant'
																		When ((reg.Liable_to_Pay_Disposal_Cost = 'Yes' and pom.has_HH_PB = 1 and reg.org_organisation_size <> 'S') 
																				or (reg.Liable_to_Pay_Disposal_Cost = 'No' and pom.has_HH_PB = 0)) Then 'Compliant'
																		Else 'Non Compliant' 
																	 End
					,reg.RegIsLatest
	From
					RegFileLtst					reg

				Left Join
					PomFileLtst					pom
						on reg.org_organisation_id = pom.pom_organisation_id
							And IsNull(reg.org_subsidiary_id,'x') = IsNull(pom.pom_subsidiary_id,'x')
							
			
			),
main as (

			Select 
				 src.*
				,PomIsLatest								= Row_Number() Over(Partition By pom_organisation_id  Order by Pom_Submission_Date Desc )
				
			From
				src
Where
				src.RegIsLatest = 1
			And
				Right(Org_SubmissionPeriod,4) = Right(pom_SubmissionPeriod,4)+1
)

Select *
from Main
where PomIsLatest = 1;


	end;

		
END;