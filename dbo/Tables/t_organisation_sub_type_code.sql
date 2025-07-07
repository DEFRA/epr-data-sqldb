CREATE TABLE [dbo].[t_organisation_sub_type_code] (
    [Id]            INT           NULL,
    [sub_type_code] NVARCHAR (5)  NULL,
    [Name]          NVARCHAR (32) NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = REPLICATE);

