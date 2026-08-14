CREATE TABLE [apps].[OrgRegistrationsSummaries]
(
    [SubmissionId] [nvarchar](4000) NULL,
    [OrganisationId] [nvarchar](4000) NULL,
    [OrganisationInternalId] [int] NULL,
    [OrganisationName] [nvarchar](4000) NULL,
    [UploadedOrganisationName] [nvarchar](4000) NULL,
    [OrganisationReference] [nvarchar](4000) NULL,
    [SubmittedUserId] [nvarchar](4000) NULL,
    [IsComplianceScheme] [int] NOT NULL,
    [OrganisationType] [varchar](10) NULL,
    [ProducerSize] [varchar](5) NULL,
    [ApplicationReferenceNumber] [nvarchar](4000) NULL,
    [RegistrationReferenceNumber] [nvarchar](4000) NULL,
    [SubmittedDateTime] [nvarchar](4000) NULL,
    [FirstSubmissionDate] [nvarchar](4000) NULL,
    [RegistrationDate] [nvarchar](4000) NULL,
    [IsResubmission] [int] NOT NULL,
    [ResubmissionDate] [nvarchar](4000) NULL,
    [RelevantYear] [int] NULL,
    [SubmissionPeriod] [nvarchar](4000) NULL,
    [IsLateSubmission] [bit] NULL,
    [SubmissionStatus] [nvarchar](4000) NOT NULL,
    [ResubmissionStatus] [nvarchar](4000) NULL,
    [ResubmissionDecisionDate] [nvarchar](4000) NULL,
    [RegulatorDecisionDate] [nvarchar](4000) NULL,
    [StatusPendingDate] [nvarchar](4000) NULL,
    [NationId] [int] NULL,
    [NationCode] [varchar](6) NULL,
    [ComplianceSchemeId] [nvarchar](4000) NULL,
    [ProducerComment] [nvarchar](4000) NULL,
    [RegulatorComment] [nvarchar](4000) NULL,
    [FileId] [nvarchar](4000) NULL,
    [ResubmissionComment] [nvarchar](4000) NULL,
    [ResubmittedUserId] [nvarchar](4000) NULL,
    [ProducerUserId] [nvarchar](4000) NULL,
    [RegulatorUserId] [nvarchar](4000) NULL,
    [RegistrationJourney] [nvarchar](128) NULL
)
WITH
(
    DISTRIBUTION = HASH ( [FileId] ),
    CLUSTERED COLUMNSTORE INDEX
);
