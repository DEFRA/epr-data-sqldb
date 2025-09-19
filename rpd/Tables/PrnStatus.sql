CREATE TABLE [rpd].[PrnStatus] (
    [Id]                INT             NULL,
    [StatusName]        NVARCHAR (4000) NULL,
    [StatusDescription] NVARCHAR (4000) NULL,
    [load_ts]           DATETIME2 (7)   NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

