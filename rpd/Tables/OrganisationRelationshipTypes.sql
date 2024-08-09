CREATE TABLE [rpd].[OrganisationRelationshipTypes] (
    [Id]      INT             NULL,
    [Name]    NVARCHAR (4000) NULL,
    [load_ts] DATETIME2 (7)   NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

