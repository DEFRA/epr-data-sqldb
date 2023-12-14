CREATE TABLE [rpd].[Persons] (
    [Id]            INT             NULL,
    [FirstName]     NVARCHAR (4000) NULL,
    [LastName]      NVARCHAR (4000) NULL,
    [Email]         NVARCHAR (4000) NULL,
    [Telephone]     NVARCHAR (4000) NULL,
    [UserId]        INT             NULL,
    [ExternalId]    NVARCHAR (4000) NULL,
    [CreatedOn]     NVARCHAR (4000) NULL,
    [LastUpdatedOn] NVARCHAR (4000) NULL,
    [IsDeleted]     BIT             NULL,
    [load_ts]       DATETIME2 (7)   NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

