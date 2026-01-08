CREATE TABLE [dbo].[t_myc_error_report]
(
	[relevant_year] [int] NULL,
	[organisation_id] [int] NULL,
	[subsidiary_id] [nvarchar](4000) NULL,
	[submitter_id] [nvarchar](4000) NULL,
	[organisation_name] [nvarchar](4000) NULL,
	[compliance_scheme_name] [nvarchar](4000) NULL,
	[submitter_type] [nvarchar](4000) NULL,
	[leaver_code] [nvarchar](4000) NULL,
	[error_code] [nvarchar](4000) NULL,
	[PomAcceptedDate] [date] NULL,
	[RegAcceptedDate] [date] NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
);
