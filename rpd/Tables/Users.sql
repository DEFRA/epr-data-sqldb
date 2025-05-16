CREATE TABLE [rpd].[Users] (
    [Id]                INT             NULL,
    [UserId]            NVARCHAR (4000) NULL,
    [ExternalIdpId]     NVARCHAR (4000) NULL,
    [ExternalIdpUserId] NVARCHAR (4000) NULL,
    [Email]             NVARCHAR (4000) NULL,
    [IsDeleted]         BIT             NULL,
    [InviteToken]       NVARCHAR (4000) NULL,
    [InvitedBy]         NVARCHAR (4000) NULL,
    [load_ts]           DATETIME2 (7)   NULL
)
WITH (CLUSTERED INDEX([UserId]), DISTRIBUTION = REPLICATE);

