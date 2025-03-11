CREATE TABLE [dbo].[tblCheckpoint] (
    [Module]     NVARCHAR (4000) NULL,
    [CheckPoint] INT             NULL,
    [Timestamp]  NVARCHAR (4000) NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

