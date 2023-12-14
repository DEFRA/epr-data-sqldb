CREATE TABLE [rpd].[DelegatedPersonEnrolments] (
    [Id]                           INT             NULL,
    [EnrolmentId]                  INT             NULL,
    [NominatorEnrolmentId]         INT             NULL,
    [RelationshipType]             NVARCHAR (4000) NULL,
    [ConsultancyName]              NVARCHAR (4000) NULL,
    [ComplianceSchemeName]         NVARCHAR (4000) NULL,
    [OtherOrganisationName]        NVARCHAR (4000) NULL,
    [OtherRelationshipDescription] NVARCHAR (4000) NULL,
    [NominatorDeclaration]         NVARCHAR (4000) NULL,
    [NominatorDeclarationTime]     NVARCHAR (4000) NULL,
    [NomineeDeclaration]           NVARCHAR (4000) NULL,
    [NomineeDeclarationTime]       NVARCHAR (4000) NULL,
    [CreatedOn]                    NVARCHAR (4000) NULL,
    [LastUpdatedOn]                NVARCHAR (4000) NULL,
    [IsDeleted]                    BIT             NULL,
    [load_ts]                      DATETIME2 (7)   NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

