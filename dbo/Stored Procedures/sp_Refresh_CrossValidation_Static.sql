CREATE PROC [dbo].[sp_Refresh_CrossValidation_Static] @BuildFromYear [INT] AS
BEGIN
    SET NOCOUNT ON;

    -- @BuildFromYear has no default value. Azure Synapse dedicated SQL pool
    -- rejects default parameter values on a procedure with Msg 104398, so the
    -- year must be passed on every call. Use 2025.

    DECLARE @RunStart  DATETIME2;
    DECLARE @RunEnd    DATETIME2;
    DECLARE @RunId     BIGINT;
    DECLARE @ApRows    BIGINT;
    DECLARE @CsRows    BIGINT;
    DECLARE @WarmStart DATETIME2;
    DECLARE @WarmupSeconds INT;

    SET @RunStart = SysDateTime();
    SET @ApRows   = 0;
    SET @CsRows   = 0;

    -- ───────────────────────────────────────────────────────────────────
    -- DO NOT START IF ANOTHER RUN IS ALREADY BUILDING
    -- 25 Sep 2026. Two runs at once would drop each other's half built
    -- _NEW tables. They could also both take the same RunId. A run that started
    -- in the last 60 minutes and is still on Running is treated as in
    -- progress. A full refresh has taken 59 to 206 seconds, so 60 minutes
    -- is generous. A cancelled or crashed run stops blocking after 60
    -- minutes. To clear it sooner, close it by hand:
    --     UPDATE dbo.tbl_CV_Static_RefreshLog SET RunStatus = 'Cancelled' WHERE RunId = <id>;
    -- This raises an error rather than exiting quietly, so a scheduler
    -- reports the skipped run instead of treating it as a success.
    -- 25 Sep 2026: RETURN cannot be used here. The pool rejects it in a
    -- procedure with Msg 105045 (RETURN can only be used in user-defined
    -- functions). THROW is used instead, because THROW ends the procedure
    -- as well as raising the error.
    -- ───────────────────────────────────────────────────────────────────
    IF EXISTS (
        SELECT 1 FROM dbo.tbl_CV_Static_RefreshLog
        WHERE RunStatus = 'Running'
          AND RunStart > DateAdd(minute, -60, SysDateTime())
    )
        THROW 50001, 'sp_Refresh_CrossValidation_Static not started: another run is still showing Running in dbo.tbl_CV_Static_RefreshLog from the last 60 minutes.', 1;

    SELECT @RunId = IsNull(Max(RunId), 0) + 1 FROM dbo.tbl_CV_Static_RefreshLog;

    -- The run is logged as Running straight away and only updated to Success
    -- at the very end. A row still showing Running is the failure signal, so
    -- no TRY / CATCH block is used. CONFIRMED 25 Sep 2026: a throwaway
    -- procedure that ran SELECT 'before', then a CREATE STATISTICS that
    -- failed with Msg 1927, then SELECT 'after' returned only 'before'. On
    -- this pool a failed statement stops the procedure, so a failure can
    -- never reach the Success update below. Because statistics are built
    -- before the swap, a failure there also leaves the previous day's
    -- tables live and untouched.
    INSERT INTO dbo.tbl_CV_Static_RefreshLog
        (RunId, RunStart, RunEnd, BuildFromYear, AllProducers_RowCnt, ComplianceScheme_RowCnt, RunStatus, ErrorMessage)
    VALUES
        (@RunId, @RunStart, NULL, @BuildFromYear, NULL, NULL, 'Running', NULL);

    -- ───────────────────────────────────────────────────────────────────
    -- CLEAR ANY LEFTOVERS FROM A FAILED PREVIOUS RUN
    -- ───────────────────────────────────────────────────────────────────
    IF OBJECT_ID('dbo.tbl_CV_Static_AllProducers_NEW')     IS NOT NULL DROP TABLE dbo.tbl_CV_Static_AllProducers_NEW;
    IF OBJECT_ID('dbo.tbl_CV_Static_ComplianceScheme_NEW') IS NOT NULL DROP TABLE dbo.tbl_CV_Static_ComplianceScheme_NEW;
    IF OBJECT_ID('dbo.tbl_CV_Static_AllProducers_OLD')     IS NOT NULL DROP TABLE dbo.tbl_CV_Static_AllProducers_OLD;
    IF OBJECT_ID('dbo.tbl_CV_Static_ComplianceScheme_OLD') IS NOT NULL DROP TABLE dbo.tbl_CV_Static_ComplianceScheme_OLD;

    IF OBJECT_ID('tempdb..#cv_file_status') IS NOT NULL DROP TABLE #cv_file_status;
    IF OBJECT_ID('tempdb..#cv_reg')         IS NOT NULL DROP TABLE #cv_reg;
    IF OBJECT_ID('tempdb..#cv_pom_files')   IS NOT NULL DROP TABLE #cv_pom_files;
    IF OBJECT_ID('tempdb..#cv_pom_agg')     IS NOT NULL DROP TABLE #cv_pom_agg;
    IF OBJECT_ID('tempdb..#cv_pom')         IS NOT NULL DROP TABLE #cv_pom;
    IF OBJECT_ID('tempdb..#cs_fs')          IS NOT NULL DROP TABLE #cs_fs;
    IF OBJECT_ID('tempdb..#cs_pairs')       IS NOT NULL DROP TABLE #cs_pairs;
    IF OBJECT_ID('tempdb..#cs_cd_files')    IS NOT NULL DROP TABLE #cs_cd_files;
    IF OBJECT_ID('tempdb..#cs_pom_files')   IS NOT NULL DROP TABLE #cs_pom_files;
    IF OBJECT_ID('tempdb..#cs_org')         IS NOT NULL DROP TABLE #cs_org;
    IF OBJECT_ID('tempdb..#cs_hh')          IS NOT NULL DROP TABLE #cs_hh;
    IF OBJECT_ID('tempdb..#cs_pvt')         IS NOT NULL DROP TABLE #cs_pvt;
    IF OBJECT_ID('tempdb..#cs_op')          IS NOT NULL DROP TABLE #cs_op;


    /* ═══════════════════════════════════════════════════════════════════
       SECTION A — ALL PRODUCERS
       V8 steps 1 to 6, widened to every year from @BuildFromYear onwards.
       ═══════════════════════════════════════════════════════════════════ */

    -- ── A1: file status (V8 step 1, unchanged) ──
    CREATE TABLE #cv_file_status WITH (DISTRIBUTION = ROUND_ROBIN, HEAP) AS
    SELECT [FileName], SubmissionId, RegistrationSetId, OrganisationId, FileType,
           OriginalFileName, TargetDirectoryName, SubmissionType, SubmissionPeriod,
           Regulator_Status, Created
    FROM dbo.t_submitted_pom_org_file_status
    WHERE Regulator_Status IN ('Pending','Accepted','Granted')
      AND FileType IN ('CompanyDetails','Pom')
    OPTION (LABEL = 'CV_STATIC A1 file status');


    -- ── A2: latest registration file per company per year (V8 step 2) ──
    -- DIFFERENCE D1: year filter widened, RelevantYear added to the partition.
    CREATE TABLE #cv_reg WITH (DISTRIBUTION = ROUND_ROBIN, HEAP) AS
    WITH
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
                -- DIFFERENCE D1: RelevantYear added as the first partition key.
                -- Inside a single year this is a no-op, so per year behaviour is unchanged.
                ,RegIsLatest                    = Row_Number() Over(Partition By Try_Convert(int,Right((cfm.submissionperiod),4)), cd.organisation_id, IsNull(cd.subsidiary_id, '') Order by Case When Upper(LTrim(RTrim(reg.Regulator_Status))) In ('GRANTED','ACCEPTED') Then 1 Else 2 End Asc, spo.SubPeriodOrdr Desc, Convert(datetime2,Replace(Replace(cfm.Created,'T', ' '),'Z', ' ')) Desc, reg.Created Desc, reg.SubmissionId Desc, reg.[FileName] Desc )
            FROM rpd.cosmos_file_metadata      cfm
            Join #cv_file_status               reg  on cfm.[Filename] = reg.[Filename]
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
              -- DIFFERENCE D1: was "= @RYear"
              And Try_Convert(int,Right((cfm.submissionperiod),4)) >= @BuildFromYear
        )
    SELECT r.*, sub_key = IsNull(r.org_subsidiary_id, '')
    FROM RegFileLtst r
    WHERE r.RegIsLatest = 1
    OPTION (LABEL = 'CV_STATIC A2 registrations');


    -- ── A3: qualifying POM files (V8 step 3) ──
    -- DIFFERENCE D1: year filter widened.
    CREATE TABLE #cv_pom_files WITH (DISTRIBUTION = ROUND_ROBIN, HEAP) AS
    WITH
        PomSpOrd As (
            Select
                 SubmissionCode     = Code
                ,SubPeriodOrdr      = Row_Number() Over(Partition By [Type] Order By Replace(Replace(Code,'P','1'),'H','2'))
                ,SubmissionType     = [Type]
                ,SubmissionPeriod   = [Text]
            From dbo.t_pom_codes
            Where [Type] in ('apps_submission_period')
            And Try_Convert(int,Left(Code,4)) >= 2024
        )
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
    JOIN #cv_file_status pfs ON cfm.[Filename] = pfs.[Filename]
    JOIN PomSpOrd pso        ON (cfm.submissionperiod) = pso.SubmissionPeriod
    WHERE cfm.Filetype = 'POM'
      AND pfs.Regulator_Status in ('Pending','Accepted','Granted')
      -- DIFFERENCE D1: was "+ 1 = @RYear"
      AND Try_Convert(int,Right((cfm.submissionperiod),4)) + 1 >= @BuildFromYear
    OPTION (LABEL = 'CV_STATIC A3 POM files');


    -- ── A4: aggregate rpd.Pom in one pass (V8 step 4, unchanged) ──
    CREATE TABLE #cv_pom_agg WITH (DISTRIBUTION = ROUND_ROBIN, HEAP) AS
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
    WHERE p.[FileName] IN (SELECT pom_filename FROM #cv_pom_files)
    GROUP BY p.Organisation_Id, NullIf(p.subsidiary_Id, ''), p.organisation_size, p.[FileName], p.submission_period
    OPTION (LABEL = 'CV_STATIC A4 POM aggregate');


    -- ── A5: POM rows ready to join (V8 step 5, unchanged) ──
    CREATE TABLE #cv_pom WITH (DISTRIBUTION = ROUND_ROBIN, HEAP) AS
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
    FROM #cv_pom_files f
    JOIN #cv_pom_agg   a ON a.pom_filename = f.pom_filename
    OPTION (LABEL = 'CV_STATIC A5 POM rows');


    -- ── A6: final All Producers rows (V8 step 6) ──
    -- DIFFERENCE D1: RelevantYear added to the PomIsLatest partition.
    CREATE TABLE dbo.tbl_CV_Static_AllProducers_NEW
    WITH (DISTRIBUTION = ROUND_ROBIN, HEAP) AS
    WITH
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
        From #cv_reg reg
        Left Join #cv_pom pom
                on  reg.org_organisation_id = pom.pom_organisation_id
                And reg.sub_key             = pom.sub_key
                And pom.pom_RelevantYear    = reg.RelevantYear
        ),
        main as (
            Select
                 src.*
                -- DIFFERENCE D1: RelevantYear added as the first partition key.
                ,PomIsLatest = Row_Number() Over(Partition By RelevantYear, org_organisation_id, IsNull(org_subsidiary_id, '') Order by Pom_Submission_Date Desc, pom_SubmissionId Desc, pom_filename Desc )
            From src
            Where src.RegIsLatest = 1
        )
    SELECT mn.*
    FROM main mn
    WHERE mn.PomIsLatest = 1
      AND mn.RelevantYear = mn.pom_RelevantYear
    OPTION (LABEL = 'CV_STATIC A6 all producers final');

    SELECT @ApRows = Count_Big(*) FROM dbo.tbl_CV_Static_AllProducers_NEW;


    /* ═══════════════════════════════════════════════════════════════════
       SECTION B — COMPLIANCE SCHEME
       V8's Compliance Scheme branch, built for every eligible registration
       file / POM file pair instead of the three named files.
       ═══════════════════════════════════════════════════════════════════ */

    -- ── B1: file status for every scheme file (V8 CTE CS_file_status) ──
    -- The three filename predicates are removed. The CS_cd and CS_pom
    -- filters (ComplianceSchemeId present, not Uploaded from 2025 on) are
    -- applied here instead, which is equivalent.
    CREATE TABLE #cs_fs WITH (DISTRIBUTION = ROUND_ROBIN, HEAP) AS
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
    WHERE x.RelevantYear >= @BuildFromYear
      AND NOT (Upper(Trim(IsNull(x.Regulator_Status,''))) = 'UPLOADED' AND x.RelevantYear >= 2025)
    OPTION (LABEL = 'CV_STATIC B1 CS file status');


    -- ── B2: every registration file / POM file pair (V8 CTE Org_Pom_submitted_files) ──
    -- The INNER join to rpd.Nations is kept exactly as V8 has it. It is the
    -- cause of the Issue #8 row loss and is deliberately not fixed here, so
    -- this validates as a pure performance change.
    -- V8's final WHERE on the two regulator statuses is applied here instead
    -- of at the end. It only references these columns, so rows are unchanged.
    CREATE TABLE #cs_pairs WITH (DISTRIBUTION = ROUND_ROBIN, HEAP) AS
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
    FROM #cs_fs cd
    JOIN #cs_fs pom
        ON  pom.OrganisationId = cd.OrganisationId
        AND ISNULL(pom.[ComplianceSchemeId],'') = ISNULL(cd.[ComplianceSchemeId],'')
        AND pom.RelevantYear = cd.RelevantYear
        AND Upper(pom.FileType) = 'POM'
    JOIN rpd.Nations np ON np.id = cd.ProducerNationId
    WHERE Upper(cd.FileType) = 'COMPANYDETAILS'
      AND UPPER(TRIM(ISNULL(cd.Regulator_Status, 'Pending')))  IN ('PENDING','ACCEPTED','QUERIED','GRANTED','REJECTED','CANCELLED','REFUSED')
      AND UPPER(TRIM(ISNULL(pom.Regulator_Status, 'Pending'))) IN ('PENDING','ACCEPTED','QUERIED','GRANTED','REJECTED','CANCELLED','REFUSED')
    OPTION (LABEL = 'CV_STATIC B2 CS pairs');


    -- ── B3: the distinct files those pairs need ──
    CREATE TABLE #cs_cd_files WITH (DISTRIBUTION = ROUND_ROBIN, HEAP) AS
    SELECT DISTINCT cd_filename = landing_cd_filename FROM #cs_pairs
    OPTION (LABEL = 'CV_STATIC B3 CS cd files');

    CREATE TABLE #cs_pom_files WITH (DISTRIBUTION = ROUND_ROBIN, HEAP) AS
    SELECT DISTINCT pom_filename = landing_pom_filename FROM #cs_pairs
    OPTION (LABEL = 'CV_STATIC B3 CS pom files');


    -- ── B4: registration detail (V8 CTE Org_Data, widened to many files) ──
    CREATE TABLE #cs_org WITH (DISTRIBUTION = ROUND_ROBIN, HEAP) AS
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
    WHERE [FileName] IN (SELECT cd_filename FROM #cs_cd_files)
    OPTION (LABEL = 'CV_STATIC B4 CS org data');


    -- ── B5: household / public bin flags (V8 CTE HH_PB_Flags, widened) ──
    CREATE TABLE #cs_hh WITH (DISTRIBUTION = ROUND_ROBIN, HEAP) AS
    SELECT DISTINCT
         Organisation_Id
        ,subsidiary_Id = ISNULL(subsidiary_Id, '')
        ,FileName
        ,1 AS has_HH_PB
    FROM rpd.POM
    WHERE packaging_type IN ('HH', 'PB')
      AND FileName IN (SELECT pom_filename FROM #cs_pom_files)
    OPTION (LABEL = 'CV_STATIC B5 CS HH PB flags');


    -- ── B6: packaging pivot (V8 CTE pom_data source, widened) ──
    -- The PIVOT and the total weight window are kept exactly as V8 has them,
    -- including the fact that this total covers every activity, not the six
    -- named ones the All Producers branch uses (Issue #10 question 2).
    CREATE TABLE #cs_pvt WITH (DISTRIBUTION = ROUND_ROBIN, HEAP) AS
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
        WHERE FileName IN (SELECT pom_filename FROM #cs_pom_files)
        GROUP BY Organisation_Id, subsidiary_Id, organisation_size, FileName, submission_period, Packaging_activity
    ) sub
    PIVOT(
        SUM(packaging_material_weight) FOR Packaging_Activity
        IN ([SO], [IM], [PF], [HL], [SE], [OM])
    ) AS pvt
    OPTION (LABEL = 'CV_STATIC B6 CS pivot');


    -- ── B7: registration joined to packaging, per pair (V8 CTEs pom_data and org_pom_data) ──
    -- V8 joins pom_data to Org_Data (scoped to one registration file), then
    -- FULL OUTER JOINs Org_Data back on the same keys. Rows with no packaging
    -- data never survive the final join, so the two step join below returns
    -- the same rows. Column order matches V8's "cd.*, p.*" exactly.
    CREATE TABLE #cs_op WITH (DISTRIBUTION = ROUND_ROBIN, HEAP) AS
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
    FROM (SELECT DISTINCT landing_cd_filename, landing_pom_filename FROM #cs_pairs) pr
    JOIN #cs_org od
        ON od.org_filename = pr.landing_cd_filename
    JOIN #cs_pvt pv
        ON  pv.pom_filename = pr.landing_pom_filename
        AND pv.pom_organisation_id = od.org_organisation_id
        AND ISNULL(pv.pom_subsidiary_id, '') = ISNULL(od.org_subsidiary_id, '')
    LEFT JOIN #cs_hh hh
        ON  hh.Organisation_Id = pv.pom_organisation_id
        AND ISNULL(hh.subsidiary_Id, '') = ISNULL(pv.pom_subsidiary_id, '')
        AND hh.FileName = pv.pom_filename
    OPTION (LABEL = 'CV_STATIC B7 CS org pom data');


    -- ── B8: final Compliance Scheme rows (V8 final SELECT) ──
    -- Column order is lp.*, then op.*, then the two compliance flags, exactly
    -- as V8 returns them.
    -- The two filename columns arrive as nvarchar(4000) from
    -- rpd.cosmos_file_metadata but only ever hold 36 character GUIDs. They are
    -- narrowed to nvarchar(50) here for two reasons: an index key cannot
    -- exceed 900 bytes, and the clustered index below turns the report's read
    -- from a full scan of 2.3 million rows into a seek. 50 leaves headroom.
    -- Values are unchanged, so the report sees exactly the same text.
    CREATE TABLE dbo.tbl_CV_Static_ComplianceScheme_NEW
    WITH (
         DISTRIBUTION = HASH(landing_cd_filename)
        ,CLUSTERED INDEX (landing_cd_filename ASC, landing_pom_filename ASC)
    ) AS
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
    FROM #cs_pairs lp
    LEFT JOIN #cs_op op
        ON  lp.landing_cd_filename  = op.org_filename
        AND lp.landing_pom_filename = op.pom_filename
    OPTION (LABEL = 'CV_STATIC B8 CS final');

    SELECT @CsRows = Count_Big(*) FROM dbo.tbl_CV_Static_ComplianceScheme_NEW;


    /* ═══════════════════════════════════════════════════════════════════
       SECTION C — BUILD STATISTICS ON THE _NEW TABLES
       25 Sep 2026, moved here from after the swap. A second AI review
       pointed out that building statistics after the table was renamed
       into its production name left a short window, roughly the
       WarmupSeconds figure, where the live table had no statistics on it
       yet. Statistics belong to the object, not its name, so building
       them on the _NEW table here and letting the rename below carry them
       across closes that window to zero: RENAME OBJECT does not change
       the object_id, so the statistics travel with the table.

       History of how this step was arrived at: a plain Count_Big(*) with no WHERE clause did not work, the first
       real filtered read straight after still took 6.4 seconds. A
       filtered read using a real key did work (0.446 seconds) but cost
       5.4 seconds itself, since it fetches rows, not just builds a
       summary. CREATE STATISTICS, Synapse's equivalent of Teradata's
       COLLECT STATISTICS, is the version kept: about 5 seconds to build,
       first real read afterwards 0.963 and 0.730 seconds on two separate
       tests. Confirmed 25 Sep 2026 these are genuine executions, not
       result-set cache hits: result_cache_hit came back -128, a negative
       code, on both timed reads.

       Root cause: a table made by CREATE TABLE AS SELECT starts with no
       column statistics. Synapse builds them the first time a query
       filters on those columns. That query waits while they are built. Before this fix that was the report's first read of the day.

       Made idempotent: each statistic is created if missing, updated if
       present. Under the current design the _NEW table is always freshly
       built earlier in this same run, so this always takes the CREATE
       branch today. The IF is there so it keeps working without error if
       the refresh is ever changed to reuse the same table object instead
       of building a new one and renaming it in, without anyone having to
       remember why.
       ═══════════════════════════════════════════════════════════════════ */
    SET @WarmStart = SysDateTime();

    IF EXISTS (SELECT 1 FROM sys.stats WHERE object_id = OBJECT_ID('dbo.tbl_CV_Static_AllProducers_NEW') AND name = 'st_cv_ap_year')
        UPDATE STATISTICS dbo.tbl_CV_Static_AllProducers_NEW (st_cv_ap_year);
    ELSE
        CREATE STATISTICS st_cv_ap_year ON dbo.tbl_CV_Static_AllProducers_NEW (RelevantYear);

    IF EXISTS (SELECT 1 FROM sys.stats WHERE object_id = OBJECT_ID('dbo.tbl_CV_Static_ComplianceScheme_NEW') AND name = 'st_cv_cs_year')
        UPDATE STATISTICS dbo.tbl_CV_Static_ComplianceScheme_NEW (st_cv_cs_year);
    ELSE
        CREATE STATISTICS st_cv_cs_year ON dbo.tbl_CV_Static_ComplianceScheme_NEW (RelevantYear);

    IF EXISTS (SELECT 1 FROM sys.stats WHERE object_id = OBJECT_ID('dbo.tbl_CV_Static_ComplianceScheme_NEW') AND name = 'st_cv_cs_name')
        UPDATE STATISTICS dbo.tbl_CV_Static_ComplianceScheme_NEW (st_cv_cs_name);
    ELSE
        CREATE STATISTICS st_cv_cs_name ON dbo.tbl_CV_Static_ComplianceScheme_NEW (CS_Name);

    IF EXISTS (SELECT 1 FROM sys.stats WHERE object_id = OBJECT_ID('dbo.tbl_CV_Static_ComplianceScheme_NEW') AND name = 'st_cv_cs_cd')
        UPDATE STATISTICS dbo.tbl_CV_Static_ComplianceScheme_NEW (st_cv_cs_cd);
    ELSE
        CREATE STATISTICS st_cv_cs_cd ON dbo.tbl_CV_Static_ComplianceScheme_NEW (landing_cd_filename);

    IF EXISTS (SELECT 1 FROM sys.stats WHERE object_id = OBJECT_ID('dbo.tbl_CV_Static_ComplianceScheme_NEW') AND name = 'st_cv_cs_pom')
        UPDATE STATISTICS dbo.tbl_CV_Static_ComplianceScheme_NEW (st_cv_cs_pom);
    ELSE
        CREATE STATISTICS st_cv_cs_pom ON dbo.tbl_CV_Static_ComplianceScheme_NEW (landing_pom_filename);

    SET @WarmupSeconds = DateDiff(second, @WarmStart, SysDateTime());


    /* ═══════════════════════════════════════════════════════════════════
       SECTION D — SWAP THE NEW TABLES IN
       Rename only. No TRUNCATE, so the report never sees an empty table.
       By the time this runs, the _NEW tables already have their
       statistics, per Section C above, so the table the report sees
       under its production name is never without them.
       ═══════════════════════════════════════════════════════════════════ */

    IF OBJECT_ID('dbo.tbl_CV_Static_AllProducers') IS NOT NULL
        RENAME OBJECT dbo.tbl_CV_Static_AllProducers TO tbl_CV_Static_AllProducers_OLD;
    RENAME OBJECT dbo.tbl_CV_Static_AllProducers_NEW TO tbl_CV_Static_AllProducers;
    IF OBJECT_ID('dbo.tbl_CV_Static_AllProducers_OLD') IS NOT NULL
        DROP TABLE dbo.tbl_CV_Static_AllProducers_OLD;

    IF OBJECT_ID('dbo.tbl_CV_Static_ComplianceScheme') IS NOT NULL
        RENAME OBJECT dbo.tbl_CV_Static_ComplianceScheme TO tbl_CV_Static_ComplianceScheme_OLD;
    RENAME OBJECT dbo.tbl_CV_Static_ComplianceScheme_NEW TO tbl_CV_Static_ComplianceScheme;
    IF OBJECT_ID('dbo.tbl_CV_Static_ComplianceScheme_OLD') IS NOT NULL
        DROP TABLE dbo.tbl_CV_Static_ComplianceScheme_OLD;

    DROP TABLE #cv_file_status;
    DROP TABLE #cv_reg;
    DROP TABLE #cv_pom_files;
    DROP TABLE #cv_pom_agg;
    DROP TABLE #cv_pom;
    DROP TABLE #cs_fs;
    DROP TABLE #cs_pairs;
    DROP TABLE #cs_cd_files;
    DROP TABLE #cs_pom_files;
    DROP TABLE #cs_org;
    DROP TABLE #cs_hh;
    DROP TABLE #cs_pvt;
    DROP TABLE #cs_op;

    -- Mark the run as finished. Only reached if every step above succeeded.
    SET @RunEnd = SysDateTime();

    UPDATE dbo.tbl_CV_Static_RefreshLog
    SET  RunEnd                  = @RunEnd
        ,AllProducers_RowCnt     = @ApRows
        ,ComplianceScheme_RowCnt = @CsRows
        ,RunStatus               = 'Success'
        ,WarmupSeconds           = @WarmupSeconds
    WHERE RunId = @RunId;

END;
