CREATE TABLE [rpd].[ComplianceSchemes] (
    [Id]                   INT             NULL,
    [Name]                 NVARCHAR (4000) NULL,
    [ExternalId]           NVARCHAR (4000) NULL,
    [CreatedOn]            NVARCHAR (4000) NULL,
    [LastUpdatedOn]        NVARCHAR (4000) NULL,
    [IsDeleted]            BIT             NULL,
    [CompaniesHouseNumber] NVARCHAR (4000) NULL,
    [NationId]             INT             NULL,
    [load_ts]              DATETIME2 (7)   NULL
)
WITH (CLUSTERED INDEX([ExternalId]), DISTRIBUTION = REPLICATE);

