CREATE TABLE [dbo].[tstInput] (
    [id]       BIGINT         NULL,
    [EName]    VARCHAR (4000) NULL,
    [Nation]   VARCHAR (4000) NULL,
    [County]   VARCHAR (4000) NULL,
    [Industry] VARCHAR (4000) NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

