CREATE TABLE [rpd].[RegulatorComments] (
    [Id]               INT             NULL,
    [PersonId]         INT             NULL,
    [EnrolmentId]      INT             NULL,
    [RejectedComments] NVARCHAR (4000) NULL,
    [TransferComments] NVARCHAR (4000) NULL,
    [OnHoldComments]   NVARCHAR (4000) NULL,
    [IsDeleted]        BIT             NULL,
    [CreatedOn]        NVARCHAR (4000) NULL,
    [LastUpdatedOn]    NVARCHAR (4000) NULL,
    [ExternalId]       NVARCHAR (4000) NULL,
    [load_ts]          DATETIME2 (7)   NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

