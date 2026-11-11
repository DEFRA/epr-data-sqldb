CREATE VIEW [dbo].[v_CV_Static_ComplianceScheme]
AS WITH
    cs_fs As (
        SELECT *
        FROM (
            SELECT
                 m.OrganisationId
                ,m.SubmissionPeriod
                ,m.OriginalFileName
                ,Convert(DATETIME, Substring(m.Created, 1, 23))                      AS Submission_time
                ,Convert(datetime2, Replace(Replace(m.Created,'T',' '),'Z',' '))     AS Created_frmtDT
                ,m.FileType
                ,m.[FileName]                                                        AS [filename]
                ,st.Regulator_Status
                ,m.[ComplianceSchemeId]
                ,cs.[Name]                                                           AS CS_Name
                ,n.[Name]                                                            AS CS_nation
                ,CASE
                    WHEN CAST('20' + Reverse(Substring(Reverse(Trim(m.SubmissionPeriod)), 1, 2)) AS INT) >= 2025
                         AND Upper(m.FileType) = 'COMPANYDETAILS'
                    THEN CAST('20' + Reverse(Substring(Reverse(Trim(m.SubmissionPeriod)), 1, 2)) AS INT)
                    ELSE CAST('20' + Reverse(Substring(Reverse(Trim(m.SubmissionPeriod)), 1, 2)) AS INT) + 1
                 END                                                                 AS RelevantYear
                ,org.[Name]                                                          AS ProducerName
                ,org.NationId                                                        AS ProducerNationId
                ,org.ReferenceNumber                                                 AS file_submitted_organisation
                ,org.IsComplianceScheme                                              AS file_submitted_organisation_IsComplianceScheme
            FROM rpd.cosmos_file_metadata m
            JOIN dbo.t_submitted_pom_org_file_status st ON m.[FileName] = st.[FileName]
            LEFT JOIN rpd.ComplianceSchemes cs ON cs.ExternalId = m.[ComplianceSchemeId]
            LEFT JOIN rpd.Nations n ON n.id = cs.NationId
            LEFT JOIN rpd.Organisations org ON org.ExternalId = m.OrganisationId
            WHERE Upper(m.FileType) IN ('COMPANYDETAILS','POM')
              AND m.[ComplianceSchemeId] IS NOT NULL
        ) x
        WHERE x.RelevantYear >= 2025
          AND NOT (Upper(Trim(IsNull(x.Regulator_Status,''))) = 'UPLOADED' AND x.RelevantYear >= 2025)
    ),
    cs_pairs As (
        SELECT
             cd.file_submitted_organisation
            ,cd.file_submitted_organisation_IsComplianceScheme
            ,cd.SubmissionPeriod                                                     AS Org_SubmissionPeriod
            ,cd.Submission_time                                                      AS Org_Submission_Date
            ,IsNull(cd.Regulator_Status,'Pending')                                   AS Org_Regulator_Status
            ,cd.[filename]                                                           AS landing_cd_filename
            ,pom.Submission_time                                                     AS Pom_Submission_Date
            ,IsNull(pom.Regulator_Status,'Pending')                                  AS Pom_Regulator_Status
            ,pom.[filename]                                                          AS landing_pom_filename
            ,pom.SubmissionPeriod                                                    AS Pom_SubmissionPeriod
            ,cd.RelevantYear
            ,'Compliance Scheme'                                                     AS CS_or_DP
            ,cd.CS_Name
            ,cd.CS_nation
            ,Concat(cd.OriginalFileName,'_',format(convert(datetime,cd.Created_frmtDT,122),'yyyyMMddHHmiss'),'_',IsNull(cd.Regulator_Status,'Pending'))    AS DisplayFilenameCD
            ,Concat(pom.OriginalFileName,'_',format(convert(datetime,pom.Created_frmtDT,122),'yyyyMMddHHmiss'),'_',IsNull(pom.Regulator_Status,'Pending')) AS DisplayFilenamePOM
            ,cd.ProducerName
            ,cd.ProducerNationId
            ,np.[Name]                                                               AS ProducerNationName
        FROM cs_fs cd
        JOIN cs_fs pom
            ON  pom.OrganisationId = cd.OrganisationId
            AND ISNULL(pom.[ComplianceSchemeId],'') = ISNULL(cd.[ComplianceSchemeId],'')
            AND pom.RelevantYear = cd.RelevantYear
            AND Upper(pom.FileType) = 'POM'
        JOIN rpd.Nations np ON np.id = cd.ProducerNationId
        WHERE Upper(cd.FileType) = 'COMPANYDETAILS'
          AND UPPER(TRIM(ISNULL(cd.Regulator_Status, 'Pending')))  IN ('PENDING','ACCEPTED','QUERIED','GRANTED','REJECTED','CANCELLED','REFUSED')
          AND UPPER(TRIM(ISNULL(pom.Regulator_Status, 'Pending'))) IN ('PENDING','ACCEPTED','QUERIED','GRANTED','REJECTED','CANCELLED','REFUSED')
    ),
    cs_org As (
        SELECT
           [organisation_id] as org_organisation_id
          ,[subsidiary_id] as org_subsidiary_id
          ,[organisation_name]
          ,[organisation_size] aS org_organisation_size
          ,CASE
                WHEN [organisation_sub_type_code] = 'LIC' THEN 'Licensor'
                WHEN [organisation_sub_type_code] = 'POB' THEN 'Pub operating business '
                WHEN [organisation_sub_type_code] = 'FRA' THEN 'Franchisor '
                WHEN [organisation_sub_type_code] = 'NAO' THEN 'Non-associated organisation'
                WHEN [organisation_sub_type_code] = 'HCY' THEN 'Holding company'
                WHEN [organisation_sub_type_code] = 'SUB' THEN 'Subsidiary'
                WHEN [organisation_sub_type_code] = 'LFR' THEN 'Licensee/Franchisee'
                WHEN [organisation_sub_type_code] = 'TEN' THEN 'Tenant'
                WHEN [organisation_sub_type_code] = 'OTH' THEN 'Others'
            ELSE NULL END [Org_Sub_Type]
          ,CASE WHEN [subsidiary_id] is null THEN 'single' ELSE 'group' END AS single_or_group
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
        WHERE [FileName] IN (SELECT landing_cd_filename FROM cs_pairs)
    ),
    cs_hh As (
        SELECT DISTINCT
             Organisation_Id
            ,subsidiary_Id = ISNULL(subsidiary_Id, '')
            ,FileName
            ,1 AS has_HH_PB
        FROM rpd.POM
        WHERE packaging_type IN ('HH', 'PB')
          AND FileName IN (SELECT landing_pom_filename FROM cs_pairs)
    ),
    cs_pvt As (
        SELECT
             pvt.organisation_id     AS pom_organisation_id
            ,pvt.subsidiary_Id       AS pom_subsidiary_id
            ,pvt.organisation_size   AS pom_organisation_size
            ,pvt.fileName            AS pom_filename
            ,[SO]                    AS Brand_Owner_Pom
            ,[IM]                    AS Importer_Pom
            ,[PF]                    AS Packer_Filler_Pom
            ,[HL]                    AS Service_Provider_Pom
            ,[SE]                    AS Distributor_Pom
            ,[OM]                    AS Online_Market_Place_Pom
            ,pvt.total_packaging_material_weight
        FROM (
            SELECT
                Organisation_Id,
                subsidiary_Id,
                organisation_size,
                FileName,
                submission_period,
                ISNULL(Packaging_activity, 'No-activity') AS Packaging_activity,
                SUM(Packaging_material_weight) AS Packaging_material_weight,
                SUM(SUM(Packaging_material_weight)) OVER (PARTITION BY Organisation_Id, subsidiary_Id, FileName)
                    AS total_packaging_material_weight
            FROM rpd.POM
            WHERE FileName IN (SELECT landing_pom_filename FROM cs_pairs)
            GROUP BY Organisation_Id, subsidiary_Id, organisation_size, FileName, submission_period, Packaging_activity
        ) sub
        PIVOT(
            SUM(packaging_material_weight) FOR Packaging_Activity
            IN ([SO], [IM], [PF], [HL], [SE], [OM])
        ) AS pvt
    ),
    cs_op As (
        SELECT
             od.org_organisation_id
            ,od.org_subsidiary_id
            ,od.organisation_name
            ,od.org_organisation_size
            ,od.Org_Sub_Type
            ,od.single_or_group
            ,od.Brand_Owner_Org
            ,od.Packer_Filler_Org
            ,od.Importer_Org
            ,od.Distributor_Org
            ,od.Service_Provider_Org
            ,od.Online_Market_Place_Org
            ,od.Seller_Org
            ,od.Liable_to_Pay_Disposal_Cost
            ,od.total_tonnage
            ,od.org_filename
            ,od.joiner_date
            ,od.leaver_date
            ,od.leaver_code
            ,pv.pom_organisation_id
            ,pv.pom_subsidiary_id
            ,pv.pom_organisation_size
            ,pv.pom_filename
            ,pv.Brand_Owner_Pom
            ,pv.Importer_Pom
            ,pv.Packer_Filler_Pom
            ,pv.Service_Provider_Pom
            ,pv.Distributor_Pom
            ,pv.Online_Market_Place_Pom
            ,pv.total_packaging_material_weight
            ,ISNULL(hh.has_HH_PB, 0) AS has_HH_PB
        FROM (SELECT DISTINCT landing_cd_filename, landing_pom_filename FROM cs_pairs) pr
        JOIN cs_org od
            ON od.org_filename = pr.landing_cd_filename
        JOIN cs_pvt pv
            ON  pv.pom_filename = pr.landing_pom_filename
            AND pv.pom_organisation_id = od.org_organisation_id
            AND ISNULL(pv.pom_subsidiary_id, '') = ISNULL(od.org_subsidiary_id, '')
        LEFT JOIN cs_hh hh
            ON  hh.Organisation_Id = pv.pom_organisation_id
            AND ISNULL(hh.subsidiary_Id, '') = ISNULL(pv.pom_subsidiary_id, '')
            AND hh.FileName = pv.pom_filename
    )
SELECT
     lp.file_submitted_organisation
    ,lp.file_submitted_organisation_IsComplianceScheme
    ,lp.Org_SubmissionPeriod
    ,lp.Org_Submission_Date
    ,lp.Org_Regulator_Status
    ,Cast(lp.landing_cd_filename AS NVARCHAR(50))  AS landing_cd_filename
    ,lp.Pom_Submission_Date
    ,lp.Pom_Regulator_Status
    ,Cast(lp.landing_pom_filename AS NVARCHAR(50)) AS landing_pom_filename
    ,lp.Pom_SubmissionPeriod
    ,lp.RelevantYear
    ,lp.CS_or_DP
    ,lp.CS_Name
    ,lp.CS_nation
    ,lp.DisplayFilenameCD
    ,lp.DisplayFilenamePOM
    ,lp.ProducerName
    ,lp.ProducerNationId
    ,lp.ProducerNationName
    ,op.org_organisation_id
    ,op.org_subsidiary_id
    ,op.organisation_name
    ,op.org_organisation_size
    ,op.Org_Sub_Type
    ,op.single_or_group
    ,op.Brand_Owner_Org
    ,op.Packer_Filler_Org
    ,op.Importer_Org
    ,op.Distributor_Org
    ,op.Service_Provider_Org
    ,op.Online_Market_Place_Org
    ,op.Seller_Org
    ,op.Liable_to_Pay_Disposal_Cost
    ,op.total_tonnage
    ,op.org_filename
    ,op.joiner_date
    ,op.leaver_date
    ,op.leaver_code
    ,op.pom_organisation_id
    ,op.pom_subsidiary_id
    ,op.pom_organisation_size
    ,op.pom_filename
    ,op.Brand_Owner_Pom
    ,op.Importer_Pom
    ,op.Packer_Filler_Pom
    ,op.Service_Provider_Pom
    ,op.Distributor_Pom
    ,op.Online_Market_Place_Pom
    ,op.total_packaging_material_weight
    ,op.has_HH_PB
    ,CASE
        WHEN op.Liable_to_Pay_Disposal_Cost = 'Yes' AND op.has_HH_PB = 0 THEN 'Non Compliant'
        WHEN op.Liable_to_Pay_Disposal_Cost = 'No'  AND op.has_HH_PB = 1 THEN 'Non Compliant'
        WHEN op.Liable_to_Pay_Disposal_Cost = 'Yes' AND op.org_organisation_size = 'S' THEN 'Non Compliant'
        WHEN (
                (op.Liable_to_Pay_Disposal_Cost = 'Yes' and op.has_HH_PB = 1 and op.org_organisation_size <> 'S')
                    or
                (op.Liable_to_Pay_Disposal_Cost = 'No' and op.has_HH_PB = 0)
             ) THEN 'Compliant'
        ELSE 'Non Compliant'
     END AS Highlighted_liability_cost_flag
    ,CASE
        WHEN op.total_packaging_material_weight > 50000 AND op.org_organisation_size = 'S' THEN 'Non Compliant'
        WHEN op.total_packaging_material_weight <= 50000 AND op.org_organisation_size = 'S' THEN 'Compliant'
        ELSE 'N/A'
     END AS Small_producer_total_tonnage
FROM cs_pairs lp
LEFT JOIN cs_op op
    ON  lp.landing_cd_filename  = op.org_filename
    AND lp.landing_pom_filename = op.pom_filename;
