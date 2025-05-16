CREATE TABLE [rpd].[Services] (
    [Id]          INT             NULL,
    [Key]         NVARCHAR (4000) NULL,
    [Name]        NVARCHAR (4000) NULL,
    [Description] NVARCHAR (4000) NULL,
    [load_ts]     DATETIME2 (7)   NULL
)
WITH (CLUSTERED INDEX([Name]), DISTRIBUTION = REPLICATE);

