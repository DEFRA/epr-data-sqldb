CREATE TABLE [rpd].[OrganisationRegistrationTypes] (
    [Id]      INT            NULL,
    [Name]    NVARCHAR (100) NULL,
    [Key]     NVARCHAR (10)  NULL,
    [load_ts] DATETIME2 (7)  NULL
)
WITH (CLUSTERED INDEX([Name]), DISTRIBUTION = REPLICATE);

