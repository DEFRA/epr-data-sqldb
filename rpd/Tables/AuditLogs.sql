CREATE TABLE [rpd].[AuditLogs] (
    [Id]             BIGINT          NULL,
    [UserId]         NVARCHAR (4000) NULL,
    [OrganisationId] NVARCHAR (4000) NULL,
    [ServiceId]      NVARCHAR (4000) NULL,
    [Timestamp]      NVARCHAR (4000) NULL,
    [Entity]         NVARCHAR (4000) NULL,
    [Operation]      NVARCHAR (4000) NULL,
    [InternalId]     INT             NULL,
    [ExternalId]     NVARCHAR (4000) NULL,
    [OldValues]      NVARCHAR (4000) NULL,
    [NewValues]      NVARCHAR (4000) NULL,
    [Changes]        NVARCHAR (4000) NULL,
    [load_ts]        DATETIME2 (7)   NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

