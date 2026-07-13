CREATE TABLE [dbo].[t_Registration_Comparison_Landing_Page]
(
    [CompanyOrgId]             int            NULL,
    [Organisation]             nvarchar(4000) NULL,
    [CompanyOriginalFileName]  nvarchar(4000) NULL,
    [SubmissionPeriod]         nvarchar(4000) NULL,
    [IsSubmitted]              bit            NULL,
    [FileCode]                 nvarchar(4000) NULL,
    [Regulator_Status]         nvarchar(4000) NULL,
    [FileName]                 nvarchar(4000) NULL,
    [CompanyFileType]          nvarchar(4000) NULL,
    [SubmittedBy]              nvarchar(4000) NOT NULL,
    [SubmitterEmail]           nvarchar(4000) NULL,
    [ServiceRoleType]          nvarchar(100)  NULL,
    [SubmissionDateTime]       datetime       NULL,
    [Compliance_Year]          varchar(4)     NOT NULL,
    [ComplianceSchemeName]     nvarchar(4000) NULL,
    [CSORPD]                   varchar(17)    NOT NULL,
    [Nation]                   varchar(1)     NOT NULL,
    [CompanyRegID]             nvarchar(4000) NULL
)
WITH
(
    CLUSTERED COLUMNSTORE INDEX,
    DISTRIBUTION = ROUND_ROBIN
);