CREATE PROC [dbo].[sp_CrossValidation_pom_org_files] @RYear [INT],@CS_or_DP [varchar](100),@CS_Name [nvarchar](4000),@OrgFileName [nvarchar](4000),@PomFileName1 [nvarchar](4000),@PomFileName2 [nvarchar](4000) AS
BEGIN

    SET NOCOUNT ON;

    IF @CS_or_DP = 'Compliance Scheme'
    BEGIN

        SELECT *
        FROM dbo.tbl_CV_Static_ComplianceScheme
        WHERE RelevantYear          = @RYear
          AND CS_Name               = @CS_Name
          AND landing_cd_filename   = @OrgFileName
          AND landing_pom_filename IN (@PomFileName1, @PomFileName2)
        OPTION (LABEL = 'CV_STATIC read CS');

    END;

    IF @CS_or_DP = 'All producers'
    BEGIN

        SELECT *
        FROM dbo.tbl_CV_Static_AllProducers
        WHERE RelevantYear = @RYear
        OPTION (LABEL = 'CV_STATIC read AP');

    END;

END;