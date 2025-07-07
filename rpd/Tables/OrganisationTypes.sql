CREATE TABLE [rpd].[OrganisationTypes] (
    [Id]      INT            NULL,
    [Name]    NVARCHAR (100) NULL,
    [load_ts] DATETIME2 (7)  NULL
)
WITH (CLUSTERED INDEX([Name]), DISTRIBUTION = REPLICATE);

