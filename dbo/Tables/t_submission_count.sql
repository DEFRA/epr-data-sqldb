CREATE TABLE [dbo].[t_submission_count] (
    [Org ID]        INT NULL,
    [ReportingYear] INT NOT NULL,
    [cnt]           INT NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

