CREATE TABLE [dbo].[t_rptPOM_All_Submissions] (
    [organisation_id]          INT         NULL,
    [Is_Present_in_POM_report] VARCHAR (1) NOT NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

