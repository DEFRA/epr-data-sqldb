CREATE TABLE [dbo].[t_PRN_Recycling_Obligation_stat_Count] (
    [ReportType]                         VARCHAR (24) NOT NULL,
    [orgid]                              INT          NULL,
    [Subsidiaryid]                       INT          NULL,
    [YR]                                 INT          NULL,
    [Recyling_Obligation]                INT          NULL,
    [TOTAL PRN/PERN Awaiting Acceptance] INT          NULL,
    [TOTAL PRN/PERN Accepted]            INT          NULL,
    [TOTAl PRN/PERN Outstanding]         INT          NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

