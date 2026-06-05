CREATE TABLE [dbo].[t_PomResubmissionPaycalEvents]
(
    [SubmissionId] [nvarchar](4000) NULL,
    [PackagingResubmissionReferenceNumber] [nvarchar](4000) NULL
)
WITH
(
    DISTRIBUTION = HASH ( [SubmissionId] ),
    CLUSTERED COLUMNSTORE INDEX
);
