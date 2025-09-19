CREATE TABLE [rpd].[Pom] (
    [organisation_id]              INT             NULL,
    [subsidiary_id]                NVARCHAR (4000) NULL,
    [organisation_size]            NVARCHAR (4000) NULL,
    [submission_period]            NVARCHAR (4000) NULL,
    [packaging_activity]           NVARCHAR (4000) NULL,
    [packaging_type]               NVARCHAR (4000) NULL,
    [packaging_class]              NVARCHAR (4000) NULL,
    [packaging_material]           NVARCHAR (4000) NULL,
    [packaging_material_subtype]   NVARCHAR (4000) NULL,
    [from_country]                 NVARCHAR (4000) NULL,
    [to_country]                   NVARCHAR (4000) NULL,
    [packaging_material_weight]    FLOAT (53)      NULL,
    [packaging_material_units]     FLOAT (53)      NULL,
    [transitional_packaging_units] FLOAT (53)      NULL,
    [ram_rag_rating]               NVARCHAR (4000) NULL,
    [load_ts]                      DATETIME2 (7)   NOT NULL,
    [FileName]                     NVARCHAR (4000) NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

