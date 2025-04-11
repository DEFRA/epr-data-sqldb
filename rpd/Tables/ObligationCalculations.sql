CREATE TABLE [rpd].[ObligationCalculations] (
    [Id]                      INT             NULL,
    [OrganisationId]          NVARCHAR (4000) NULL,
    [MaterialObligationValue] INT             NULL,
    [Year]                    INT             NULL,
    [CalculatedOn]            DATETIME2 (7)   NULL,
    [Tonnage]                 INT             NULL,
    [MaterialId]              INT             NULL,
    [load_ts]                 DATETIME2 (7)   NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

