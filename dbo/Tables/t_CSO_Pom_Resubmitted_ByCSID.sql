CREATE TABLE [dbo].[t_CSO_Pom_Resubmitted_ByCSID]
(
    [CS_Reference_number] [nvarchar](4000) NULL,
    [CSid] [nvarchar](4000) NULL,
    [submissionperiod] [nvarchar](4000) NULL,
    [MemberCount] [int] NOT NULL
)
WITH
(
    DISTRIBUTION = ROUND_ROBIN,
    CLUSTERED COLUMNSTORE INDEX
);
