CREATE TABLE [dbo].[t_POM] (
    [organisation_id]             INT             NULL,
    [subsidiary_id]               NVARCHAR (4000) NULL,
    [organisation_size]           NVARCHAR (4000) NULL,
    [organisation_sub_type_code]  VARCHAR (1)     NOT NULL,
    [submission_period]           VARCHAR (34)    NULL,
    [submission_period_tile]      NVARCHAR (4000) NULL,
    [packaging_activity]          VARCHAR (34)    NULL,
    [packaging_type]              VARCHAR (34)    NULL,
    [packaging_class]             VARCHAR (34)    NULL,
    [packaging_material]          VARCHAR (34)    NULL,
    [packaging_sub_material]      NVARCHAR (4000) NULL,
    [from_nation]                 VARCHAR (34)    NULL,
    [to_nation]                   VARCHAR (34)    NULL,
    [quantity_kg]                 FLOAT (53)      NULL,
    [quantity_unit]               FLOAT (53)      NULL,
    [load_ts]                     DATETIME2 (7)   NOT NULL,
    [FileName]                    NVARCHAR (4000) NULL,
    [Quantity_kg_extrapolated]    FLOAT (53)      NULL,
    [Quantity_units_extrapolated] FLOAT (53)      NULL,
    [relative_move]               VARCHAR (72)    NULL,
    [File_submitted_time]         DATETIME        NULL,
    [Rank_over_time]              BIGINT          NULL,
    [IsLatest]                    INT             NOT NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);



