CREATE TABLE [dbo].[t_organisation_details_not_submitted]
(
	[Organisations_Id] [varchar](20) NULL,
	[FromOrganisation_Type] [nvarchar](4000) NULL,
	[FromOrganisation_CompaniesHouseNumber] [nvarchar](4000) NULL,
	[FromOrganisation_Name] [nvarchar](4000) NULL,
	[FromOrganisation_ReferenceNumber] [nvarchar](4000) NULL,
	[FromOrganisation_IsComplianceScheme] [bit] NULL,
	[ComplianceSchemes_Name] [nvarchar](4000) NULL,
	[Enrolment_CreatedOn] [nvarchar](4000) NULL,
	[FromOrganisation_NationName] [nvarchar](4000) NULL,
	[ToOrganisation_NationName] [nvarchar](4000) NULL,
	[ApprovedPerson_FirstName] [nvarchar](4000) NULL,
	[ApprovedPerson_LastName] [nvarchar](4000) NULL,
	[ApprovedPerson_Email] [nvarchar](4000) NULL,
	[ApprovedPerson_Telephone] [nvarchar](4000) NULL,
	[ApprovedPerson_JobTitle] [nvarchar](4000) NULL,
	[Status] [nvarchar](4000) NULL,
	[Regulator_Rejection_Comments] [nvarchar](4000) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
);
