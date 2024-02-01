CREATE TABLE [dbo].[t_POM_Com_Landing_Filter] (
    [securityquery]          NVARCHAR (4000) NULL,
    [PCS_Or_Direct_Producer] VARCHAR (17)    NOT NULL,
    [Organisation]           NVARCHAR (4000) NULL,
    [compliance_year]        VARCHAR (4)     NOT NULL,
    [submission_period]      VARCHAR (34)    NULL,
    [filecode]               NVARCHAR (4000) NULL,
    [filename]               NVARCHAR (4000) NULL,
    [organisation_id]        INT             NULL,
    [Compliance_Scheme]      NVARCHAR (4000) NULL,
    [originalfilename]       NVARCHAR (4000) NULL,
    [submittedby]            NVARCHAR (4000) NULL,
    [submtteremail]          NVARCHAR (4000) NULL,
    [serviceroles_name]      NVARCHAR (4000) NULL,
    [submission_date]        DATETIME        NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

