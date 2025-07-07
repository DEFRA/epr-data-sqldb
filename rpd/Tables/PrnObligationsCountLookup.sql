CREATE TABLE [rpd].[PrnObligationsCountLookup] (
    [ReportType]               NVARCHAR (100) NULL,
    [OrganisationId]           INT            NULL,
    [Subsidiaryid]             INT            NULL,
    [ObligationYear]           INT            NULL,
    [Recyclingobligation]      INT            NULL,
    [TotPrnAwaitingAcceptance] INT            NULL,
    [TotPrnAcceptedStatus]     INT            NULL,
    [TotPrnOutstandingStatus]  INT            NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

