CREATE TABLE [dbo].[StatisticsMaintenanceQueue] (
    [schema_name]      [sysname]   NOT NULL,
    [table_name]       [sysname]   NOT NULL,
    [last_updated]     DATETIME    NULL,
    [status]           VARCHAR (7) NOT NULL,
    [duration_seconds] INT         NULL,
    [object_id]        INT         NOT NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

