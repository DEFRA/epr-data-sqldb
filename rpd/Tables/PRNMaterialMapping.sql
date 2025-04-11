CREATE TABLE [rpd].[PRNMaterialMapping] (
    [Id]               INT             NULL,
    [PRNMaterialId]    INT             NULL,
    [NPWDMaterialName] NVARCHAR (4000) NULL,
    [load_ts]          DATETIME2 (7)   NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

