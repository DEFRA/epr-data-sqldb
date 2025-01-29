CREATE TABLE [dbo].[t_Registration_Comparison_Landing_Page] (
    [CompanyOrgId]            INT             NULL,
    [Organisation]            NVARCHAR (4000) NULL,
    [CompanyOriginalFileName] NVARCHAR (4000) NULL,
    [SubmissionPeriod]        NVARCHAR (4000) NULL,
    [IsSubmitted]             BIT             NULL,
    [FileCode]                NVARCHAR (4000) NULL,
    [Regulator_Status]        NVARCHAR (4000) NULL,
    [FileName]                NVARCHAR (4000) NULL,
    [CompanyFileType]         NVARCHAR (4000) NULL,
    [SubmittedBy]             NVARCHAR (4000) NOT NULL,
    [SubmitterEmail]          NVARCHAR (4000) NULL,
    [ServiceRoleType]         NVARCHAR (4000) NULL,
    [SubmissionDateTime]      DATETIME        NULL,
    [Compliance_Year]         VARCHAR (4)     NOT NULL,
    [ComplianceSchemeName]    NVARCHAR (4000) NULL,
    [CSORPD]                  VARCHAR (17)    NOT NULL,
    [Nation]                  VARCHAR (1)     NOT NULL,
    [CompanyRegID]            NVARCHAR (4000) NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

