CREATE TABLE [dbo].[recyclers_table_log] (
    [desc]           NVARCHAR (4000) NULL,
    [value_str]      NVARCHAR (4000) NULL,
    [value_ts]       DATETIME        NULL,
    [value_int]      INT             NULL,
    [log_time_stamp] DATETIME        NULL,
    [Comments]       NVARCHAR (4000) NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

