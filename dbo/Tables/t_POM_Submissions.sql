﻿CREATE TABLE [dbo].[t_POM_Submissions] (
    [Org_Name]                    NVARCHAR (4000) NULL,
    [PCS_Or_Direct_Producer]      VARCHAR (17)    NOT NULL,
    [Compliance_Scheme]           NVARCHAR (4000) NULL,
    [Org_Type]                    NVARCHAR (4000) NULL,
    [Org_Sub_Type]                VARCHAR (27)    NULL,
    [organisation_size]           NVARCHAR (4000) NULL,
    [Submission_Date]             DATETIME        NULL,
    [submission_period]           VARCHAR (34)    NULL,
    [organisation_id]             INT             NULL,
    [subsidiary_id]               NVARCHAR (4000) NULL,
    [CH_Number]                   NVARCHAR (4000) NULL,
    [Nation_Of_Enrolment]         NVARCHAR (4000) NULL,
    [packaging_activity]          VARCHAR (34)    NULL,
    [packaging_type]              VARCHAR (34)    NULL,
    [packaging_class]             VARCHAR (34)    NULL,
    [packaging_material]          VARCHAR (34)    NULL,
    [packaging_sub_material]      NVARCHAR (4000) NULL,
    [from_nation]                 VARCHAR (34)    NULL,
    [to_nation]                   VARCHAR (34)    NULL,
    [quantity_kg]                 FLOAT (53)      NULL,
    [quantity_unit]               FLOAT (53)      NULL,
    [Quantity_kg_extrapolated]    FLOAT (53)      NULL,
    [Quantity_units_extrapolated] FLOAT (53)      NULL,
    [ToOrganisation_NationName]   NVARCHAR (4000) NULL,
    [Nation]                      NVARCHAR (4000) NULL,
    [FromOrganisation_NationName] NVARCHAR (4000) NULL,
    [FileName]                    NVARCHAR (4000) NULL,
    [ServiceRoles_Role]           NVARCHAR (4000) NULL,
    [SubmittedBy]                 NVARCHAR (4000) NULL,
    [filetype]                    NVARCHAR (4000) NULL,
    [Users_Email]                 NVARCHAR (4000) NULL,
    [Persons_Email]               NVARCHAR (4000) NULL,
    [metafile]                    NVARCHAR (4000) NULL,
    [JOINFIELD]                   NVARCHAR (4000) NULL,
    [relative_move]               VARCHAR (72)    NULL,
    [TransferNation]              NVARCHAR (4000) NULL,
    [SubmtterEmail]               NVARCHAR (4000) NULL,
    [ServiceRoles_Name]           NVARCHAR (4000) NULL,
    [OriginalFileName]            NVARCHAR (4000) NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);





