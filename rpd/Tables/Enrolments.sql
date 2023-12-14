CREATE TABLE [rpd].[Enrolments] (
    [Id]                INT             NULL,
    [ConnectionId]      INT             NULL,
    [ServiceRoleId]     INT             NULL,
    [EnrolmentStatusId] INT             NULL,
    [ValidFrom]         NVARCHAR (4000) NULL,
    [ValidTo]           NVARCHAR (4000) NULL,
    [ExternalId]        NVARCHAR (4000) NULL,
    [CreatedOn]         NVARCHAR (4000) NULL,
    [LastUpdatedOn]     NVARCHAR (4000) NULL,
    [IsDeleted]         BIT             NULL,
    [load_ts]           DATETIME2 (7)   NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

