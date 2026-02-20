CREATE TABLE [rpd].[CodeStatusConfigs] (
    [Id]                 INT            NULL,
    [Code]               NVARCHAR (2)   NULL,
    [LegacyCode]         NVARCHAR (1)   NULL,
    [Description]        NVARCHAR (255) NULL,
    [ClassificationId]   INT            NULL,
    [RequiresJoinerDate] BIT            NULL,
    [RequiresLeaverDate] BIT            NULL,
    [RequiresRegType]    BIT            NULL,
    [MatchType]          NVARCHAR (50)  NULL,
    [MappedOldCodes]     NVARCHAR (50)  NULL,
    [Enabled]            BIT            NULL,
    [ExternalId]         NVARCHAR (36)  NULL,
    [CreatedOn]          NVARCHAR (50)  NULL,
    [LastUpdatedOn]      NVARCHAR (50)  NULL,
    [IsDeleted]          BIT            NULL,
    [load_ts]            DATETIME2 (7)  NULL
)
WITH (CLUSTERED INDEX([Id]), DISTRIBUTION = REPLICATE);

