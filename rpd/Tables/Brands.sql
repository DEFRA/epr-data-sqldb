CREATE TABLE [rpd].[Brands] (
    [organisation_id] INT             NULL,
    [subsidiary_id]   NVARCHAR (4000) NULL,
    [brand_name]      NVARCHAR (4000) NULL,
    [brand_type_code] NVARCHAR (4000) NULL,
    [load_ts]         DATETIME2 (7)   NOT NULL,
    [FileName]        NVARCHAR (4000) NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);





