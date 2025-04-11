CREATE TABLE [rpd].[Material] (
    [MaterialName] NVARCHAR (4000) NULL,
    [MaterialCode] NVARCHAR (4000) NULL,
    [Id]           INT             NULL,
    [load_ts]      DATETIME2 (7)   NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

