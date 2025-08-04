CREATE VIEW [dbo].[v_organisation_details_not_submitted_bkp_17_04_2025]
AS WITH 
/****************************************************************************************************************************
	History:

	Created: 2025-03-17:	YM001:	Ticket - 520218:	This view used for the Org Details - Not Submitted report
	Update: 2025-04-16:		ST002:	Ticket - 520218: Fix to logic so that we do not bring through records where org not submitted but a registration has

******************************************************************************************************************************/

EnrolmentData AS (
    SELECT 
        a.[Organisations_Id],
        a.[FromOrganisation_Type],
        a.[FromOrganisation_CompaniesHouseNumber],
        a.[FromOrganisation_Name],
        a.[FromOrganisation_ReferenceNumber],
		a.FromOrganisation_IsComplianceScheme,
        a.[ComplianceSchemes_Name],
        a.[Enrolment_CreatedOn],
        a.[FromOrganisation_NationName],
        a.[ToOrganisation_NationName],
        a.[ApprovedPerson_FirstName],
        a.[ApprovedPerson_LastName],
        a.[ApprovedPerson_Email],
        a.[ApprovedPerson_Telephone],
        a.[ApprovedPerson_JobTitle],
        a.[Status],
        a.Regulator_Rejection_Comments
    FROM [dbo].[t_rpd_data_SECURITY_FIX] a -- Enrolment
)
--Exclude records where no submission either org or registration exists
--If organisation submission was done we want this on the org report
--If registration submission done we want this on the registration report - do not want to show here
SELECT 
    ed.*
FROM EnrolmentData ed
WHERE NOT EXISTS (
    SELECT distinct b.organisation_id
    FROM [rpd].[CompanyDetails] b
    WHERE ed.FromOrganisation_ReferenceNumber = b.organisation_id
)
AND YEAR(ed.[Enrolment_CreatedOn]) < 2025;