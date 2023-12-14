CREATE TABLE [rpd].[Partnerships] (
    [organisation_id]      INT             NULL,
    [subsidiary_id]        NVARCHAR (4000) NULL,
    [partner_first_name]   NVARCHAR (4000) NULL,
    [partner_last_name]    NVARCHAR (4000) NULL,
    [partner_phone_number] NVARCHAR (4000) NULL,
    [partner_email]        NVARCHAR (4000) NULL,
    [load_ts]              DATETIME2 (7)   NOT NULL,
    [FileName]             NVARCHAR (4000) NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);





