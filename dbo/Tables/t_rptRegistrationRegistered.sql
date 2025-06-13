CREATE TABLE [dbo].[t_rptRegistrationRegistered] (
    [organisation_id]          INT         NULL,
    [Is_Present_in_Reg_report] VARCHAR (1) NOT NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

