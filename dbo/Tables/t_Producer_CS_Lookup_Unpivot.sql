﻿CREATE TABLE [dbo].[t_Producer_CS_Lookup_Unpivot] (
    [Producer_Id]                   INT             NULL,
    [Producer_Name]                 NVARCHAR (4000) NULL,
    [Operator_Id]                   INT             NULL,
    [Operator_Name]                 NVARCHAR (4000) NULL,
    [Operator_CompaniesHouseNumber] NVARCHAR (4000) NULL,
    [CS_Id]                         INT             NULL,
    [CS_Name]                       NVARCHAR (4000) NULL,
    [Submission_Type]               VARCHAR (8)     NOT NULL,
    [StartPoint]                    VARCHAR (12)    NOT NULL,
    [SecurityQuery]                 NVARCHAR (4000) NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);



