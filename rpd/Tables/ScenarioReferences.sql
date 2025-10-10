CREATE TABLE [rpd].[ScenarioReferences] (
    [Id]             INT            NULL,
    [ScenarioCode]   NVARCHAR (20)  NULL,
    [Description]    NVARCHAR (255) NULL,
    [ObligationFlag] NVARCHAR (50)  NULL,
    [Active]         BIT            NULL,
    [ExternalId]     NVARCHAR (36)  NULL,
    [CreatedOn]      NVARCHAR (50)  NULL,
    [LastUpdatedOn]  NVARCHAR (50)  NULL,
    [IsDeleted]      BIT            NULL,
    [load_ts]        DATETIME2 (7)  NULL
)
WITH (CLUSTERED INDEX([Id]), DISTRIBUTION = REPLICATE);

