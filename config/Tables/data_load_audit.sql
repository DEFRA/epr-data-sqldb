CREATE TABLE [config].[data_load_audit] (
    [table_name]    NVARCHAR (50) NULL,
    [full_load_ind] NVARCHAR (1)  DEFAULT ('N') NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

