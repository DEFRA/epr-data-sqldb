CREATE TABLE [rpd].[RecyclingTargets] (
	[Id] [int] NULL,
	[Year] [int] NULL,
	[MaterialNameRT] [nvarchar](4000) NULL,
	[Target] [decimal](5, 2) NULL,
	[load_ts] [datetime2](7) NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);
