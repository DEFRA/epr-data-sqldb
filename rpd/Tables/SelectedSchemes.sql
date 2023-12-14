CREATE TABLE [rpd].[SelectedSchemes] (
    [Id]                       INT             NULL,
    [OrganisationConnectionId] INT             NULL,
    [ComplianceSchemeId]       INT             NULL,
    [ExternalId]               NVARCHAR (4000) NULL,
    [CreatedOn]                NVARCHAR (4000) NULL,
    [LastUpdatedOn]            NVARCHAR (4000) NULL,
    [IsDeleted]                BIT             NULL,
    [load_ts]                  DATETIME2 (7)   NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

