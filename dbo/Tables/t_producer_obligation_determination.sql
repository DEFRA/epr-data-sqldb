CREATE TABLE [dbo].[t_producer_obligation_determination] (
    [organisation_id]              INT             NOT NULL,
    [subsidiary_id]                NVARCHAR (6)    NULL,
    [submitter_id]                 NVARCHAR (4000) NOT NULL,
    [organisation_name]            NVARCHAR (4000) NOT NULL,
    [trading_name]                 NVARCHAR (4000) NULL,
    [status_code]                  NVARCHAR (4000) NULL,
    [organisation_joining_date]    NVARCHAR (4000) NULL,
    [organisation_leaving_date]    NVARCHAR (4000) NULL,
    [obligation_status]            CHAR     (1)    NOT NULL,
    [calendar_year_days_obligated] SMALLINT        NULL,
    [error_code]                   NVARCHAR (4000) NULL,
    [submission_period_year]       INT             NULL
)
WITH(
    CLUSTERED COLUMNSTORE INDEX,
    DISTRIBUTION = HASH([organisation_id])
);
