CREATE TABLE [dbo].[EntityValues] (
    [EntityID] INT      NULL,
    [Value1]   CHAR (1) NULL,
    [Value2]   CHAR (1) NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

