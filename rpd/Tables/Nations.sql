CREATE TABLE [rpd].[Nations] (
    [Id]         INT           NULL,
    [Name]       NVARCHAR (54) NULL,
    [NationCode] NVARCHAR (10) NULL,
    [load_ts]    DATETIME2 (7) NULL
)
WITH (CLUSTERED INDEX([NationCode]), DISTRIBUTION = REPLICATE);

