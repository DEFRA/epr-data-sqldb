CREATE VIEW [dbo].[v_Producer_CS_Lookup_Pivot]
AS SELECT DISTINCT Producer_Id
,Producer_Name
,Operator_Id
,Operator_Name
,Operator_CompaniesHouseNumber
,CS_Id
,CS_Name
,Producer_Nation
,CS_Nation
,Submission_Type
,StartPoint



FROM (
    SELECT DISTINCT o.ReferenceNumber AS Producer_Id
    ,o.Name AS Producer_Name
    ,op.ReferenceNumber as Operator_Id
    ,op.Name AS Operator_Name
    ,cs.CompaniesHouseNumber AS Operator_CompaniesHouseNumber
    ,cs.Id AS CS_Id
    ,cs.Name AS CS_Name
    ,pn.Name AS Producer_Nation
    ,csn.Name AS CS_Nation
    ,'Operator' AS Submission_Type
    ,'OP_CS_START' AS StartPoint

    FROM rpd.ComplianceSchemes cs

    JOIN rpd.SelectedSchemes ss
    ON cs.Id = ss.ComplianceSchemeId

    JOIN rpd.OrganisationsConnections oc
    ON ss.OrganisationConnectionId = oc.Id

    JOIN rpd.Organisations o
    ON oc.FromOrganisationId = o.Id

    JOIN rpd.Organisations op
    ON cs.CompaniesHouseNumber = op.CompaniesHouseNumber

    JOIN rpd.Nations pn
    ON o.NationId = pn.Id

    JOIN rpd.Nations csn
    ON cs.NationId = csn.Id

    WHERE cs.IsDeleted = 0
    AND ss.IsDeleted = 0
    AND oc.IsDeleted = 0
    AND o.IsDeleted = 0
    AND op.IsDeleted = 0
) op_cs_start

UNION

SELECT * FROM (
    SELECT DISTINCT sec.FromOrganisation_ReferenceNumber AS Producer_Id
    ,sec.FromOrganisation_Name AS Producer_Name
    ,sec.ToOrganisation_ReferenceNumber AS Operator_Id
    ,sec.ToOrganisation_Name AS Operator_Name
    ,cs.CompaniesHouseNumber AS Operator_CompaniesHouseNumber
    ,cs.Id AS CS_Id
    ,cs.Name AS CS_Name
    ,NULL AS Producer_Nation
    ,csn.Name AS CS_Nation
    ,'Operator' AS Submission_Type
    ,'OP_POM_START' AS StartPoint

    FROM rpd.Pom pom

    JOIN rpd.cosmos_file_metadata meta
        ON pom.FileName = meta.FileName

    JOIN rpd.ComplianceSchemes cs
        ON meta.ComplianceSchemeId = cs.ExternalId
/*
    JOIN rpd.SelectedSchemes ss
        ON cs.Id = ss.ComplianceSchemeId

    JOIN rpd.OrganisationsConnections oc
        ON ss.OrganisationConnectionId = oc.Id

    JOIN rpd.Organisations o
        ON oc.FromOrganisationId = o.Id

    JOIN rpd.Organisations op
        ON cs.CompaniesHouseNumber = op.CompaniesHouseNumber
*/
    JOIN rpd.Nations csn
        ON cs.NationId = csn.Id

    JOIN v_rpd_data_SECURITY_FIX sec
     on pom.[organisation_id]  = sec.[FromOrganisation_ReferenceNumber] 
      --  ON op.ReferenceNumber = sec.ToOrganisation_ReferenceNumber
        --AND cs.Id = sec.ComplianceSchemes_Id

    WHERE cs.IsDeleted = 0
   -- AND ss.IsDeleted = 0
  --  AND oc.IsDeleted = 0
  --  AND o.IsDeleted = 0
  --  AND op.IsDeleted = 0
) op_pom_start

UNION

SELECT * FROM (
    SELECT DISTINCT pr_pom_start.organisation_id AS Producer_Id
    ,pr_pom_start.Org_Name AS Producer_Name
    ,NULL As Operator_Id
    ,NULL As Operator_Name
    ,pr_pom_start.CH_Number AS Operator_CompaniesHouseNumber
    ,NULL AS CS_Id
    ,pr_pom_start.Compliance_Scheme AS CS_Name
    ,pr_pom_start.Nation_Of_Enrolment AS Producer_Nation
    ,pr_pom_start.ToOrganisation_NationName AS CS_Nation
    ,'Producer' AS Submission_Type
    ,'PR_POM_START' AS StartPoint

    FROM t_POM_Submissions pr_pom_start

    WHERE PCS_Or_Direct_Producer = 'Producer'
) pr_pom_start

UNION

-- SELECT * FROM (
--     SELECT DISTINCT FromOrganisation_ReferenceNumber AS Producer_Id
--     ,FromOrganisation_Name AS Producer_Name
--     ,ToOrganisation_ReferenceNumber AS Operator_Id
--     ,ToOrganisation_Name AS Operator_Name
--     ,ToOrganisation_CompaniesHouseNumber AS Operator_CompaniesHouseNumber
--     ,NULL AS CS_Id
--     ,NULL AS CS_Name
--     ,FromOrganisation_NationName AS Producer_Nation
--     ,ToOrganisation_NationName as CS_Nation
--     ,'Producer' AS Submission_Type
--     ,'PR_ENR_START' AS StartPoint

--     FROM v_rpd_data_SECURITY_FIX
--     WHERE Organisations_Id IS NOT NULL
--     AND FromOrganisation_IsDeleted = 0
--     AND FromOrganisation_IsComplianceScheme = 0
--     AND ( ToOrganisation_IsComplianceScheme = 0 OR ToOrganisation_IsComplianceScheme IS NULL )
-- ) pr_enr_start

SELECT * FROM (
    SELECT o.ReferenceNumber AS Producer_Id
    ,o.Name AS Producer_Name
    ,oc.Id AS Operator_Id
    ,NULL AS Operator_Name
    ,NULL AS Operator_CompaniesHouseNumber
    ,NULL AS CS_Id
    ,NULL AS CS_Name
    ,n.Name AS Producer_Nation
    ,NULL AS CS_Nation
    ,'Producer' AS Submission_Type
    ,'PR_ENR_START' AS StartPoint
    
    FROM rpd.Organisations o

    LEFT JOIN rpd.OrganisationsConnections oc
    ON o.Id = oc.FromOrganisationId

    JOIN rpd.Nations n
    ON o.NationId = n.Id
    
    WHERE oc.FromOrganisationId IS NULL
    AND o.IsDeleted IS NOT NULL
) pr_enr_start;