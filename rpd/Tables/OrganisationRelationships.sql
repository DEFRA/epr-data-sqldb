CREATE TABLE [rpd].[OrganisationRelationships] (
    [Id]                             INT             NULL,
    [FirstOrganisationId]            INT             NULL,
    [SecondOrganisationId]           INT             NULL,
    [OrganisationRelationshipTypeId] INT             NULL,
    [RelationFromDate]               DATETIME2 (7)   NULL,
    [RelationToDate]                 DATETIME2 (7)   NULL,
    [RelationExpiryReason]           NVARCHAR (4000) NULL,
    [CreatedOn]                      NVARCHAR (4000) NULL,
    [LastUpdatedById]                INT             NULL,
    [LastUpdatedOn]                  NVARCHAR (4000) NULL,
    [LastUpdatedByOrganisationId]    INT             NULL,
    [OrganisationRegistrationTypeId] INT             NULL,
    [load_ts]                        DATETIME2 (7)   NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

