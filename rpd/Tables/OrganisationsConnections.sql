CREATE TABLE [rpd].[OrganisationsConnections] (
    [Id]                     INT             NULL,
    [FromOrganisationId]     INT             NULL,
    [FromOrganisationRoleId] INT             NULL,
    [ToOrganisationId]       INT             NULL,
    [ToOrganisationRoleId]   INT             NULL,
    [ExternalId]             NVARCHAR (4000) NULL,
    [CreatedOn]              NVARCHAR (4000) NULL,
    [LastUpdatedOn]          NVARCHAR (4000) NULL,
    [IsDeleted]              BIT             NULL,
    [load_ts]                DATETIME2 (7)   NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

