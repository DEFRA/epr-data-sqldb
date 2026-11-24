CREATE TABLE [apps].[approved_submissions_myc_with_obligations]
(
    SubmissionPeriod nvarchar(32) NULL,
    SubmitterType nvarchar(50) NULL,
    SubmitterId uniqueidentifier NULL,
    OrganisationId uniqueidentifier NULL,
    PackagingMaterial nvarchar(128) NULL,
    PackagingMaterialWeight int NULL,
    NumberOfDaysObligated smallint NULL,
    PackagingMaterialWeightKg bigint NULL,
    ObligationStatus char(1) NULL,
    LeaverCode nvarchar(128) NULL,
    JoinerDate date NULL,
    LeaverDate date NULL
)
WITH
(
    DISTRIBUTION = REPLICATE,
    CLUSTERED INDEX ([OrganisationId] ASC)
);