CREATE TABLE [dbo].[t_POM_Com_Landing_Filter]
(
    [securityquery]           nvarchar(4000) NULL,
    [PCS_Or_Direct_Producer]  varchar(17)    NOT NULL,
    [Organisation]            nvarchar(4000) NULL,
    [compliance_year]         varchar(4)     NOT NULL,
    [submission_period]       varchar(34)    NULL,
    [filecode]                nvarchar(4000) NULL,
    [filename]                nvarchar(4000) NULL,
    [OrganisationID]          int            NULL,
    [Compliance_Scheme]       nvarchar(4000) NULL,
    [originalfilename]        nvarchar(4000) NULL,
    [submittedby]             nvarchar(4000) NOT NULL,
    [submtteremail]           nvarchar(4000) NULL,
    [serviceroles_name]       nvarchar(100)  NULL,
    [submission_date]         datetime       NULL,
    [Regulator_Status]        nvarchar(4000) NULL
)
WITH
(
    CLUSTERED COLUMNSTORE INDEX,
    DISTRIBUTION = ROUND_ROBIN
);