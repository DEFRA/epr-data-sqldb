CREATE TABLE [dbo].[t_registration_latest] (
    [organisation_id]                    INT             NULL,
    [subsidiary_id]                      NVARCHAR (4000) NULL,
    [registration_type_code]             NVARCHAR (4000) NULL,
    [SubmittedDateTime]                  DATETIME        NULL,
    [filename]                           NVARCHAR (4000) NULL,
    [Org_Sub_Type]                       VARCHAR (27)    NULL,
    [organisation_type_code]             NVARCHAR (4000) NULL,
    [organisation_type_code_description] VARCHAR (29)    NULL,
    [companies_house_number]             NVARCHAR (4000) NULL,
    [organisation_name]                  NVARCHAR (4000) NULL,
    [Trading_Name]                       NVARCHAR (4000) NULL,
    [registered_addr_line1]              NVARCHAR (4000) NULL,
    [registered_addr_line2]              NVARCHAR (4000) NULL,
    [registered_city]                    NVARCHAR (4000) NULL,
    [registered_addr_country]            NVARCHAR (4000) NULL,
    [registered_addr_county]             NVARCHAR (4000) NULL,
    [registered_addr_postcode]           NVARCHAR (4000) NULL,
    [created]                            DATETIME        NULL,
    [rn]                                 BIGINT          NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);







