CREATE TABLE [dbo].[t_Producer_CS_Lookup]
(
    [Operator_CompaniesHouseNumber]  nvarchar(4000) NULL,
    [Operator_Name]                  nvarchar(4000) NULL,
    [Operator_Id]                    nvarchar(4000) NULL,
    [Producer_Name]                  nvarchar(4000) NULL,
    [Producer_Id]                    nvarchar(4000) NULL,
    [Producer_Nation]                nvarchar(54)   NULL,
    [ComplianceScheme_Name]          nvarchar(4000) NULL,
    [ComplianceScheme_Id]            int            NULL,
    [ComplianceScheme_Nation]        nvarchar(54)   NULL
)
WITH
(
    CLUSTERED COLUMNSTORE INDEX,
    DISTRIBUTION = ROUND_ROBIN
);