CREATE TABLE [rpd].[PrnStatusHistory] (
    [Id]                      INT             NULL,
    [CreatedOn]               DATETIME2 (7)   NULL,
    [CreatedByUser]           NVARCHAR (4000) NULL,
    [CreatedByOrganisationId] NVARCHAR (4000) NULL,
    [PrnStatusIdFk]           INT             NULL,
    [PrnIdFk]                 INT             NULL,
    [Comment]                 NVARCHAR (4000) NULL,
    [load_ts]                 DATETIME2 (7)   NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

