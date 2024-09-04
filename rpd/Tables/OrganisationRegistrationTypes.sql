CREATE TABLE [rpd].[OrganisationRegistrationTypes] (
    [Id]      INT             NULL,
    [Name]    NVARCHAR (4000) NULL,
    [Key]     NVARCHAR (4000) NULL,
    [load_ts] DATETIME2 (7)   NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

