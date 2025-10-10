CREATE TABLE [rpd].[CodeScenarioMapping] (
    [Id]                  INT           NULL,
    [CodeStatusConfigId]  INT           NULL,
    [ScenarioReferenceId] INT           NULL,
    [Active]              BIT           NULL,
    [ExternalId]          NVARCHAR (36) NULL,
    [CreatedOn]           NVARCHAR (50) NULL,
    [LastUpdatedOn]       NVARCHAR (50) NULL,
    [IsDeleted]           BIT           NULL,
    [load_ts]             DATETIME2 (7) NULL
)
WITH (CLUSTERED INDEX([Id]), DISTRIBUTION = REPLICATE);

