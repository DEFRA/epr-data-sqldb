CREATE TABLE [dbo].[t_Producer_CS_Lookup] (
    [Operator_CompaniesHouseNumber] NVARCHAR (4000) NULL,
    [Operator_Name]                 NVARCHAR (4000) NULL,
    [Operator_Id]                   NVARCHAR (4000) NULL,
    [Producer_Name]                 NVARCHAR (4000) NULL,
    [Producer_Id]                   NVARCHAR (4000) NULL,
    [Producer_Nation]               NVARCHAR (4000) NULL,
    [ComplianceScheme_Name]         NVARCHAR (4000) NULL,
    [ComplianceScheme_Id]           INT             NULL,
    [ComplianceScheme_Nation]       NVARCHAR (4000) NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

