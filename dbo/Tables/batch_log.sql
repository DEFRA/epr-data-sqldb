CREATE TABLE [dbo].[batch_log] (
    [ID]               INT             NOT NULL,
    [ProcessName]      NVARCHAR (4000) NULL,
    [SubProcessName]   NVARCHAR (4000) NULL,
    [Count]            BIGINT          NULL,
    [start_time_stamp] DATETIME        NULL,
    [end_time_stamp]   DATETIME        NULL,
    [Comments]         NVARCHAR (4000) NULL,
    [batch_id]         BIGINT          NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

