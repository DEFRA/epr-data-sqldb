CREATE TABLE [dbo].[t_registration_latest] (
    [organisation_id]        INT             NULL,
    [subsidiary_id]          NVARCHAR (4000) NULL,
    [registration_type_code] NVARCHAR (4000) NULL,
    [Org_Sub_Type]           VARCHAR (27)    NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

