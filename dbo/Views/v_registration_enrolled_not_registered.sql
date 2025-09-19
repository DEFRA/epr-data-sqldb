CREATE VIEW [dbo].[v_registration_enrolled_not_registered]
AS WITH 
/*** Ticket 520206 YM: This view is used for the Enrolled - Not Registered report ***/
EnrolmentData as (
select 
a.[Organisations_Id],
a.[FromOrganisation_Type],
a.[FromOrganisation_CompaniesHouseNumber],
a.[FromOrganisation_Name],
a.[FromOrganisation_ReferenceNumber],
a.[FromOrganisation_IsComplianceScheme],
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
from [dbo].[t_rpd_data_SECURITY_FIX] a -- Enrolment
),

-- Latest Registation and count of registrations 
-- specifically counting where there is an applicationrefereceno as this means
-- cannot be uploaded status, uploaded status would not have an applicationreferenceno present

LatestRegistrations as (
select 
organisation_id,
submissionperiod,
regulator_status,
created,
decision_date,
row_number() over (partition by organisation_id, submissionperiod order by coalesce(decision_date,created) desc) as IsLatest,
count(applicationreferenceno) over (partition by organisation_id, submissionperiod) as RegCount
 FROM dbo.t_BrndPrtnr_Registrations
),

--We do not want to include these in this report
-- until they submit a file we do not know if it might be org or registration file
-- This submission will determine if reg or org report
-- These records should end up in the v_organisation_details_not_submitted instead
OLD_Enrol_No_File as (select 
DISTINCT FromOrganisation_ReferenceNumber as organisation_id
from EnrolmentData ed
where year(ed.[Enrolment_CreatedOn]) = 2024  
and not exists (
select distinct b.organisation_id
from [rpd].[CompanyDetails] b
where ed.FromOrganisation_ReferenceNumber = b.organisation_id
--File that is for submission period <2025--
				)
					)



---SELECTION OF DATA---
-- Selecting from Enrolment
-- Where there is a CreatedOn date ie enrolment has happened
-- But does not exist
-- where its the latest registration and the count is >= 1
-- i.e. we want where count = 0 
select 
ed.*
from EnrolmentData ed
where ed.Enrolment_CreatedOn is not null 
and not exists (
select lr.organisation_id
from LatestRegistrations lr
where lr.organisation_id = ed.FromOrganisation_ReferenceNumber
AND lr.IsLatest = 1
AND lr.RegCount >= 1
)
--BLOCK NO FILE SUBMISSIONS--
--
and Not exists (
SELECT * FROM OLD_Enrol_No_File oenf
where oenf.organisation_id = ed.FromOrganisation_ReferenceNumber)

--IF does not exist in this query it means its not a registration file, but org file
--Hence only want ones that do exist in this query i.e. registration files
and EXISTS (
select lr.organisation_id
from LatestRegistrations lr
where lr.organisation_id = ed.FromOrganisation_ReferenceNumber
AND lr.IsLatest = 1
AND lr.RegCount = 0)

union 

-- 2025_Enrol_No_File
-- We do want to include these in this report--
select 
ed.*
from EnrolmentData ed
where year(ed.[Enrolment_CreatedOn]) >= 2025  
and not exists (
select distinct b.organisation_id
from [rpd].[CompanyDetails] b
where ed.FromOrganisation_ReferenceNumber = b.organisation_id
);