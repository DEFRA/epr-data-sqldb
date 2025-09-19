CREATE TABLE [rpd].[ObligationCalculations] (
    [Id]                      INT             NULL,
    [OrganisationId]          NVARCHAR (4000) NULL,
    [MaterialName]            NVARCHAR (4000) NULL,
    [MaterialObligationValue] INT             NULL,
    [Year]                    INT             NULL,
    [CalculatedOn]            DATETIME2 (7)   NULL,
    [Tonnage]                 FLOAT (53)      NULL,
    [load_ts]                 DATETIME2 (7)   NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

