CREATE TABLE [dbo].[ORG_PENDING_ACCEPT_ONLY_UPDATED] (
    [OrganisationId]                            INT             NULL,
    [ReferenceNumber]                           INT             NULL,
    [SubmissionPeriod]                          INT             NOT NULL,
    [ReportingYear]                             INT             NOT NULL,
    [Submission_time]                           DATETIME        NULL,
    [ComplianceSchemeId]                        INT             NULL,
    [FileName]                                  NVARCHAR (4000) NULL,
    [File_Status]                               VARCHAR (9)     NOT NULL,
    [Source]                                    VARCHAR (8)     NOT NULL,
    [FirstName]                                 NVARCHAR (4000) NULL,
    [CS_Name]                                   NVARCHAR (4000) NULL,
    [CS Nation]                                 NVARCHAR (4000) NULL,
    [Who submitted]                             VARCHAR (2)     NOT NULL,
    [cd_filename]                               NVARCHAR (4000) NULL,
    [Regulator_Status]                          NVARCHAR (4000) NULL,
    [Actual_Regulator_Status]                   NVARCHAR (4000) NULL,
    [cd_organisation_size]                      NVARCHAR (4000) NOT NULL,
    [cd_submission_period_code]                 VARCHAR (7)     NOT NULL,
    [First_submission]                          BIGINT          NULL,
    [Last_submission]                           BIGINT          NULL,
    [First_pending_accepted_submission]         BIGINT          NULL,
    [Last_pending_accepted_submission]          BIGINT          NULL,
    [First_pending_accepted_submission_updated] BIGINT          NULL,
    [Last_pending_accepted_submission_updated]  BIGINT          NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

