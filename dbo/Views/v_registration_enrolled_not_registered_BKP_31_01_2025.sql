CREATE VIEW [dbo].[v_registration_enrolled_not_registered_BKP_31_01_2025]
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
)
--select 
--ed.*
--from EnrolmentData ed
--where YEAR(ed.[Enrolment_CreatedOn]) >= 2025 
--AND  NOT EXISTS (
--select distinct b.organisation_id
--FROM [rpd].[CompanyDetails] b
--inner join [dbo].[t_BrndPrtnr_Registrations] rbp
--on b.organisation_id =rbp.FromOrganisation_ReferenceNumber
--where rbp.Regulator_status in (
--'Refused'
--,'Granted'
--,'Pending'
--,'Cancelled'
--,'Queried') and b.organisation_id = ed.FromOrganisation_ReferenceNumber)
--union
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
union 
select 
ed.*
from EnrolmentData ed
where year(ed.[Enrolment_CreatedOn]) >= 2025  
and not exists (
select distinct b.organisation_id
from [rpd].[CompanyDetails] b
where ed.FromOrganisation_ReferenceNumber = b.organisation_id
);