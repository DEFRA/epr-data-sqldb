CREATE TABLE [rpd].[OrganisationToPersonRoles] (
    [Id]      INT             NULL,
    [Name]    NVARCHAR (4000) NULL,
    [load_ts] DATETIME2 (7)   NULL
)
WITH (CLUSTERED INDEX([Name]), DISTRIBUTION = REPLICATE);

