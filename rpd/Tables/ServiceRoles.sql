CREATE TABLE [rpd].[ServiceRoles] (
    [Id]          INT             NULL,
    [ServiceId]   INT             NULL,
    [Key]         NVARCHAR (100)  NULL,
    [Name]        NVARCHAR (100)  NULL,
    [Description] NVARCHAR (2000) NULL,
    [load_ts]     DATETIME2 (7)   NULL
)
WITH (CLUSTERED INDEX([Name]), DISTRIBUTION = REPLICATE);

