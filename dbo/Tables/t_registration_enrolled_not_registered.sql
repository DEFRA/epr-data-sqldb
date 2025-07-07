CREATE TABLE [dbo].[t_registration_enrolled_not_registered] (
    [Organisations_Id]                      VARCHAR (20)    NULL,
    [FromOrganisation_Type]                 NVARCHAR (4000) NULL,
    [FromOrganisation_CompaniesHouseNumber] NVARCHAR (4000) NULL,
    [FromOrganisation_Name]                 NVARCHAR (4000) NULL,
    [FromOrganisation_ReferenceNumber]      NVARCHAR (4000) NULL,
    [FromOrganisation_IsComplianceScheme]   BIT             NULL,
    [ComplianceSchemes_Name]                NVARCHAR (4000) NULL,
    [Enrolment_CreatedOn]                   NVARCHAR (4000) NULL,
    [FromOrganisation_NationName]           NVARCHAR (4000) NULL,
    [ToOrganisation_NationName]             NVARCHAR (4000) NULL,
    [ApprovedPerson_FirstName]              NVARCHAR (4000) NULL,
    [ApprovedPerson_LastName]               NVARCHAR (4000) NULL,
    [ApprovedPerson_Email]                  NVARCHAR (4000) NULL,
    [ApprovedPerson_Telephone]              NVARCHAR (4000) NULL,
    [ApprovedPerson_JobTitle]               NVARCHAR (4000) NULL,
    [Status]                                NVARCHAR (4000) NULL,
    [Regulator_Rejection_Comments]          NVARCHAR (4000) NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

