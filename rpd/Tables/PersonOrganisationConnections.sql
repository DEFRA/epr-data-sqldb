CREATE TABLE [rpd].[PersonOrganisationConnections] (
    [Id]                 INT             NULL,
    [JobTitle]           NVARCHAR (4000) NULL,
    [OrganisationId]     INT             NULL,
    [OrganisationRoleId] INT             NULL,
    [PersonId]           INT             NULL,
    [PersonRoleId]       INT             NULL,
    [ExternalId]         NVARCHAR (4000) NULL,
    [CreatedOn]          NVARCHAR (4000) NULL,
    [LastUpdatedOn]      NVARCHAR (4000) NULL,
    [IsDeleted]          BIT             NULL,
    [load_ts]            DATETIME2 (7)   NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

