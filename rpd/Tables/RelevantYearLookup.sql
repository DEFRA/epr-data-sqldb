CREATE TABLE [rpd].[RelevantYearLookup] (
    [ID]              INT            NULL,
    [Producer_Type]   NVARCHAR (100) NULL,
    [Submission_Type] NVARCHAR (100) NULL,
    [Start_Date]      DATE           NULL,
    [End_Date]        DATE           NULL,
    [Deadline_Date]   DATE           NULL,
    [Relevant_Year]   INT            NULL,
    [load_ts]         DATETIME2 (7)  NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

