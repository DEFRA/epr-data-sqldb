CREATE TABLE [rpd].[SubsidiaryOrganisations] (
    [Id]             INT             NULL,
    [OrganisationId] INT             NULL,
    [SubsidiaryId]   NVARCHAR (4000) NULL,
    [CreatedOn]      NVARCHAR (4000) NULL,
    [LastUpdatedOn]  NVARCHAR (4000) NULL,
    [load_ts]        DATETIME2 (7)   NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

