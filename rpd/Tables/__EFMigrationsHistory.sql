CREATE TABLE [rpd].[__EFMigrationsHistory] (
    [MigrationId]    NVARCHAR (4000) NULL,
    [ProductVersion] NVARCHAR (4000) NULL,
    [load_ts]        DATETIME2 (7)   NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

