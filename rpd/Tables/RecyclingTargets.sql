CREATE TABLE [rpd].[RecyclingTargets] (
    [Year]              INT            NULL,
    [PaperTarget]       DECIMAL (5, 2) NULL,
    [GlassTarget]       DECIMAL (5, 2) NULL,
    [AluminiumTarget]   DECIMAL (5, 2) NULL,
    [SteelTarget]       DECIMAL (5, 2) NULL,
    [PlasticTarget]     DECIMAL (5, 2) NULL,
    [WoodTarget]        DECIMAL (5, 2) NULL,
    [GlassRemeltTarget] DECIMAL (5, 2) NULL,
    [load_ts]           DATETIME2 (7)  NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

