CREATE TABLE [dbo].[t_producer_obligation_determination] (
    [organisation_id]              INT             NULL,
    [subsidiary_id]                NVARCHAR (4000) NULL,
    [submitter_id]                 NVARCHAR (4000) NULL,
    [organisation_name]            NVARCHAR (4000) NULL,
    [trading_name]                 NVARCHAR (4000) NULL,
    [status_code]                  NVARCHAR (4000) NULL,
    [leaver_date]                  NVARCHAR (4000) NULL,
    [joiner_date]                  NVARCHAR (4000) NULL,
    [obligation_status]            CHAR     (1)    NOT NULL,
    [num_days_obligated]           SMALLINT        NULL,
    [error_code]                   NVARCHAR (4000) NULL,
    [submission_period_year]       INT             NULL
)
WITH(
    CLUSTERED COLUMNSTORE INDEX,
    DISTRIBUTION = HASH([organisation_id])
);
