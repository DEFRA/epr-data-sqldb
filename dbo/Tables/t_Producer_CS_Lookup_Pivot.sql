CREATE TABLE [dbo].[t_Producer_CS_Lookup_Pivot] (
    [Producer_Id]                   INT             NULL,
    [Producer_Name]                 NVARCHAR (4000) NULL,
    [Operator_Id]                   NVARCHAR (4000) NULL,
    [Operator_Name]                 NVARCHAR (4000) NULL,
    [Operator_CompaniesHouseNumber] NVARCHAR (4000) NULL,
    [CS_Id]                         INT             NULL,
    [CS_Name]                       NVARCHAR (4000) NULL,
    [Producer_Nation]               NVARCHAR (4000) NULL,
    [CS_Nation]                     NVARCHAR (4000) NULL,
    [Submission_Type]               VARCHAR (8)     NOT NULL,
    [StartPoint]                    VARCHAR (12)    NOT NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

