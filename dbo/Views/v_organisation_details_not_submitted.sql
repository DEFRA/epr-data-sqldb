CREATE VIEW [dbo].[v_organisation_details_not_submitted]
AS WITH 
/****************************************************************************************************************************
	History:

	Created: 2025-03-17:	YM001:	Ticket - 520218:	This view used for the Org Details - Not Submitted report
	Update: 2025-04-16:		ST002:	Ticket - 520218: Fix to logic so that if an Org file has not been submitted it should show in this view
														If an Org file HAS been submitted, it should NOT show on this view. Irespective of Registration file uploaded/status

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

SELECT 
    ed.*
FROM EnrolmentData ed
WHERE YEAR(ed.[Enrolment_CreatedOn]) < 2025
--Only <2025 Enrolled organisations
AND NOT EXISTS (
--Exclude any record that has a confirmed org file submission
    SELECT distinct b.organisation_id
    FROM [rpd].[CompanyDetails] b
    INNER JOIN [dbo].[t_BrndPrtnr_Org_Submissions] rbp
        ON b.organisation_id = rbp.FromOrganisation_ReferenceNumber
    WHERE b.organisation_id = ed.FromOrganisation_ReferenceNumber
);