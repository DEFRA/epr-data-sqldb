CREATE VIEW [dbo].[v_CV_Static_AllProducers]
AS WITH
    spOrd As (
        Select
             SubmissionCode     = Code
            ,SubPeriodOrdr      = Row_Number() Over(Partition By [Type] Order By Replace(Replace(Code,'P','1'),'H','2'))
            ,SubmissionType     = [Type]
            ,SubmissionPeriod   = [Text]
        From dbo.t_pom_codes
        Where [Type] in ('apps_submission_period')
        And Try_Convert(int,Left(Code,4)) >= 2025
    ),
    OrgSubType As (
        Select  SubTypeCode='LIC', SubTypeDesc='Licensor' Union
        Select  SubTypeCode='POB', SubTypeDesc='Pub operating business ' Union
        Select  SubTypeCode='FRA', SubTypeDesc='Franchisor ' Union
        Select  SubTypeCode='NAO', SubTypeDesc='Non-associated organisation' Union
        Select  SubTypeCode='HCY', SubTypeDesc='Holding company' Union
        Select  SubTypeCode='SUB', SubTypeDesc='Subsidiary' Union
        Select  SubTypeCode='LFR', SubTypeDesc='Licensee/Franchisee' Union
        Select  SubTypeCode='TEN', SubTypeDesc='Tenant' Union
        Select  SubTypeCode='OTH', SubTypeDesc='Others'
    ),
    cv_file_status As (
        SELECT [FileName], SubmissionId, RegistrationSetId, OrganisationId, FileType,
               OriginalFileName, TargetDirectoryName, SubmissionType, SubmissionPeriod,
               Regulator_Status, Created
        FROM dbo.t_submitted_pom_org_file_status
        WHERE Regulator_Status IN ('Pending','Accepted','Granted')
          AND FileType IN ('CompanyDetails','Pom')
    ),
    RegFileLtst As (
        Select
             org_organisation_id            = cd.organisation_id
            ,org_subsidiary_id              = cd.subsidiary_id
            ,cd.organisation_name
            ,org_organisation_size          = cd.organisation_size
            ,Org_Sub_Type                   = SubTypeDesc
            ,single_or_group                = Case When cd.subsidiary_id Is Null Then 'Single' Else 'Group' End
            ,cd.joiner_date
            ,cd.leaver_date
            ,cd.leaver_code
            ,cd.organisation_size
            ,Brand_Owner_Org                = cd.packaging_activity_so
            ,Packer_Filler_Org              = cd.packaging_activity_pf
            ,Importer_Org                   = cd.packaging_activity_im
            ,Distributor_Org                = cd.packaging_activity_se
            ,Service_Provider_Org           = cd.packaging_activity_hl
            ,Online_Market_Place_Org        = cd.packaging_activity_om
            ,Seller_Org                     = cd.packaging_activity_sl
            ,Liable_to_Pay_Disposal_Cost    = cd.liable_for_disposal_costs_flag
            ,total_tonnage
            ,org_filename                   = cd.[FileName]
            ,Reg_SubmissionPeriod           = reg.SubmissionPeriod
            ,Reg_SubmissionDate             = reg.Created
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
            ,OrgNationName                  = orgn.[Name]
            ,CS_Name                        = cs.[Name]
            ,CS_Nation                      = csn.[Name]
            ,RelevantYear                   = Try_Convert(int,Right((cfm.submissionperiod),4))
            ,reg.Regulator_Status
            ,Created_frmtDT                 = Convert(datetime2,Replace(Replace(cfm.Created,'T', ' '),'Z', ' '))
            ,RegIsLatest                    = Row_Number() Over(Partition By Try_Convert(int,Right((cfm.submissionperiod),4)), cd.organisation_id, IsNull(cd.subsidiary_id, '') Order by Case When Upper(LTrim(RTrim(reg.Regulator_Status))) In ('GRANTED','ACCEPTED') Then 1 Else 2 End Asc, spo.SubPeriodOrdr Desc, Convert(datetime2,Replace(Replace(cfm.Created,'T', ' '),'Z', ' ')) Desc, reg.Created Desc, reg.SubmissionId Desc, reg.[FileName] Desc )
        FROM rpd.cosmos_file_metadata      cfm
        Join cv_file_status                reg  on cfm.[Filename] = reg.[Filename]
        Join spOrd                         spo  on reg.SubmissionPeriod = spo.SubmissionPeriod
        Left Join rpd.CompanyDetails       cd   on reg.[FileName] = cd.[FileName]
        Left Join rpd.Organisations        o    on cfm.OrganisationId = o.ExternalId
        Left Join rpd.ComplianceSchemes    cs   on cfm.ComplianceSchemeId = cs.ExternalId
        Left Join OrgSubType               so   on cd.organisation_sub_type_code = so.SubTypeCode
        Left Join rpd.Nations              csn  on cs.NationId = csn.id
        Left Join rpd.Nations              orgn on o.NationId = orgn.id
        Where cfm.FileType = 'CompanyDetails'
          And reg.SubmissionType = 'Registration'
          And reg.Regulator_Status in ('Pending','Accepted','Granted')
          And Try_Convert(int,Right((cfm.submissionperiod),4)) >= 2025
    ),
    cv_reg As (
        SELECT r.*, sub_key = IsNull(r.org_subsidiary_id, '')
        FROM RegFileLtst r
        WHERE r.RegIsLatest = 1
    ),
    PomSpOrd As (
        Select
             SubmissionCode     = Code
            ,SubPeriodOrdr      = Row_Number() Over(Partition By [Type] Order By Replace(Replace(Code,'P','1'),'H','2'))
            ,SubmissionType     = [Type]
            ,SubmissionPeriod   = [Text]
        From dbo.t_pom_codes
        Where [Type] in ('apps_submission_period')
        And Try_Convert(int,Left(Code,4)) >= 2024
    ),
    cv_pom_files As (
        SELECT
             pom_filename          = pfs.[FileName]
            ,pom_SubmissionPeriod  = cfm.submissionperiod
            ,pom_Regulator_Status  = pfs.Regulator_Status
            ,pom_Original_Filename = cfm.OriginalFileName
            ,submissionperiod      = cfm.submissionperiod
            ,pom_submission_date   = Convert(Datetime,substring(cfm.Created,1,23))
            ,pom_RelevantYear      = Try_Convert(int,Right((cfm.submissionperiod),4)) + 1
            ,Pom_Created_frmtDT    = Convert(datetime2,Replace(Replace(cfm.Created,'T', ' '),'Z', ' '))
            ,pom_subPeriod_ord     = pso.SubPeriodOrdr
            ,pom_Created           = pfs.Created
            ,pom_SubmissionId      = pfs.SubmissionId
        FROM rpd.cosmos_file_metadata cfm
        JOIN cv_file_status pfs ON cfm.[Filename] = pfs.[Filename]
        JOIN PomSpOrd pso       ON (cfm.submissionperiod) = pso.SubmissionPeriod
        WHERE cfm.Filetype = 'POM'
          AND pfs.Regulator_Status in ('Pending','Accepted','Granted')
          AND Try_Convert(int,Right((cfm.submissionperiod),4)) + 1 >= 2025
    ),
    cv_pom_agg As (
        SELECT
             pom_organisation_id     = p.Organisation_Id
            ,pom_subsidiary_id       = NullIf(p.subsidiary_Id, '')
            ,pom_organisation_size   = p.organisation_size
            ,pom_filename            = p.[FileName]
            ,submission_period       = p.submission_period
            ,Brand_Owner_Pom         = IsNull(Sum(Case When p.Packaging_activity = 'SO' Then p.Packaging_material_weight End), 0)
            ,Importer_Pom            = IsNull(Sum(Case When p.Packaging_activity = 'IM' Then p.Packaging_material_weight End), 0)
            ,Packer_Filler_Pom       = IsNull(Sum(Case When p.Packaging_activity = 'PF' Then p.Packaging_material_weight End), 0)
            ,Service_Provider_Pom    = IsNull(Sum(Case When p.Packaging_activity = 'HL' Then p.Packaging_material_weight End), 0)
            ,Distributor_Pom         = IsNull(Sum(Case When p.Packaging_activity = 'SE' Then p.Packaging_material_weight End), 0)
            ,Online_Market_Place_Pom = IsNull(Sum(Case When p.Packaging_activity = 'OM' Then p.Packaging_material_weight End), 0)
            ,hh_pb_in_group          = Max(Case When p.packaging_type In ('HH','PB') Then 1 Else 0 End)
        FROM rpd.Pom p
        WHERE p.[FileName] IN (SELECT pom_filename FROM cv_pom_files)
        GROUP BY p.Organisation_Id, NullIf(p.subsidiary_Id, ''), p.organisation_size, p.[FileName], p.submission_period
    ),
    cv_pom As (
        SELECT
             a.pom_organisation_id
            ,a.pom_subsidiary_id
            ,a.pom_organisation_size
            ,a.pom_filename
            ,f.pom_SubmissionPeriod
            ,f.pom_Regulator_Status
            ,f.pom_Original_Filename
            ,a.Brand_Owner_Pom
            ,a.Importer_Pom
            ,a.Packer_Filler_Pom
            ,a.Service_Provider_Pom
            ,a.Distributor_Pom
            ,a.Online_Market_Place_Pom
            ,f.submissionperiod
            ,total_packaging_material_weight = a.Brand_Owner_Pom + a.Importer_Pom + a.Packer_Filler_Pom + a.Service_Provider_Pom + a.Distributor_Pom + a.Online_Market_Place_Pom
            ,has_HH_PB = Max(a.hh_pb_in_group) Over (Partition By a.pom_organisation_id, IsNull(a.pom_subsidiary_id, ''), a.pom_filename)
            ,f.pom_submission_date
            ,f.pom_RelevantYear
            ,f.Pom_Created_frmtDT
            ,f.pom_subPeriod_ord
            ,f.pom_Created
            ,f.pom_SubmissionId
            ,sub_key = IsNull(a.pom_subsidiary_id, '')
        FROM cv_pom_files f
        JOIN cv_pom_agg   a ON a.pom_filename = f.pom_filename
    ),
    src As (
        Select
             file_submitted_organisation                    = reg.ReferenceNumber
            ,file_submitted_organisation_IsComplianceScheme = reg.IsComplianceScheme
            ,Org_SubmissionPeriod                           = reg.Reg_SubmissionPeriod
            ,Org_Submission_Date                            = reg.reg_SubmissionDate
            ,Org_Regulator_Status                           = reg.Regulator_Status
            ,landing_cd_filename                            = reg.org_filename
            ,reg.RelevantYear
            ,pom.pom_RelevantYear
            ,CS_or_DP                                       = Case When reg.IsComplianceScheme = 1 Then 'Compliance Scheme' Else 'Direct Producer' End
            ,reg.CS_Name
            ,reg.CS_Nation
            ,reg.Created_frmtDT
            ,DisplayFilenameCD                              = Concat(reg.OriginalFileName,'_',reg.Created_frmtDT,'_',IsNull(reg.Regulator_Status,'Pending'))
            ,DisplayFilenameCDSort                          = Concat(format(convert(datetime,reg.Created_frmtDT,122),'yyyyMMddHHmmss'),'_',reg.OriginalFileName,'_',IsNull(reg.Regulator_Status,'Pending'))
            ,FilenameCDExclude                              = Case When IsNull(reg.Regulator_Status,'') In ('Uploaded','') Then 1 Else 0 End
            ,ProducerName                                   = reg.organisation_name
            ,ProducerNationId                               = reg.NationId
            ,ProducerNationName                             = reg.OrgNationName
            ,reg.org_organisation_id
            ,reg.org_subsidiary_id
            ,reg.organisation_name
            ,org_organisation_size                          = reg.organisation_size
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
            ,DisplayFilenamePOM                             = Concat(pom.pom_Original_Filename,'_',pom.pom_Created_frmtDT,'_',IsNull(pom.pom_Regulator_Status,'Pending'))
            ,DisplayFilenamePOMSort                         = Concat(format(convert(datetime,pom.pom_Created_frmtDT,122),'yyyyMMddHHmmss'),'_',pom.pom_Original_Filename,'_',IsNull(pom.pom_Regulator_Status,'Pending'))
            ,pom.Pom_Submission_Date
            ,pom_Regulator_Status
            ,pom.pom_SubmissionPeriod
            ,landing_pom_filename                           = pom.pom_filename
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
            ,pom.pom_SubmissionId
            ,Small_producer_total_tonnage    = Case
                                                    When pom.total_packaging_material_weight > 50000 And reg.org_organisation_size = 'S' Then 'Non Compliant'
                                                    When pom.total_packaging_material_weight <= 50000 And reg.org_organisation_size = 'S' Then 'Compliant'
                                                    Else 'N/A'
                                               End
            ,Highlighted_liability_cost_flag = Case
                                                    When reg.Liable_to_Pay_Disposal_Cost = 'Yes' And pom.has_HH_PB = 0 Then 'Non Compliant'
                                                    When reg.Liable_to_Pay_Disposal_Cost = 'No' AND pom.has_HH_PB = 1 Then 'Non Compliant'
                                                    When reg.Liable_to_Pay_Disposal_Cost = 'Yes' AND reg.org_organisation_size = 'S' Then 'Non Compliant'
                                                    When ((reg.Liable_to_Pay_Disposal_Cost = 'Yes' and pom.has_HH_PB = 1 and reg.org_organisation_size <> 'S')
                                                            or (reg.Liable_to_Pay_Disposal_Cost = 'No' and pom.has_HH_PB = 0)) Then 'Compliant'
                                                    Else 'Non Compliant'
                                               End
            ,reg.RegIsLatest
        From cv_reg reg
        Left Join cv_pom pom
                on  reg.org_organisation_id = pom.pom_organisation_id
                And reg.sub_key             = pom.sub_key
                And pom.pom_RelevantYear    = reg.RelevantYear
    ),
    main As (
        Select
             src.*
            ,PomIsLatest = Row_Number() Over(Partition By RelevantYear, org_organisation_id, IsNull(org_subsidiary_id, '') Order by Pom_Submission_Date Desc, pom_SubmissionId Desc, pom_filename Desc )
        From src
        Where src.RegIsLatest = 1
    )
SELECT mn.*
FROM main mn
WHERE mn.PomIsLatest = 1
  AND mn.RelevantYear = mn.pom_RelevantYear;
