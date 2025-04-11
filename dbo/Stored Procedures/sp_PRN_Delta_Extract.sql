CREATE PROC [dbo].[sp_PRN_Delta_Extract] @From_Date [Datetime],@To_Date [Datetime] AS
BEGIN
 -- Disable row count for performance
    SET NOCOUNT ON;

WITH latest_record AS(
select *
			, row_number() over(partition by OrganisationId, ReferenceNumber order by Submission_time desc) as Last_submission
		from 
		(
				select distinct o.id as OrganisationId, cd.organisation_id as ReferenceNumber
					, case when cfm.SubmissionPeriod in ('Jan to Jun 2023','January to June 2023','July to December 2023') then 2023 
							when cfm.SubmissionPeriod in ('Jan to Jun 2024','January to June 2024','July to December 2024') then 2024
							when cfm.SubmissionPeriod in ('Jan to Jun 2025','January to June 2025','July to December 2025') then 2025
							when cfm.SubmissionPeriod in ('Jan to Jun 2026','January to June 2026','July to December 2026') then 2026
							when cfm.SubmissionPeriod in ('Jan to Jun 2027','January to June 2027','July to December 2027') then 2027
							when cfm.SubmissionPeriod in ('Jan to Jun 2028','January to June 2028','July to December 2028') then 2028
							else 0
							end as ReportingYear
					,'20'+reverse(substring(reverse(trim(cfm.SubmissionPeriod)),1,2)) as SubmissionPeriodYear
					, CONVERT(DATETIME,substring(cfm.Created,1,23)) as Submission_time
					, cs.id as ComplianceSchemeId
					, cfm.FileName
					, cs.Name as 'CS_Name'
					, case when cs.id is NULL then 'DP' else 'CS' end as 'SubmittedBy'
					, cd.FileName as cd_filename
					, cd.organisation_size
					,cd.[organisation_name] as OrganisationName,
					cd.[trading_name] TradingName,
					cd.[registered_addr_line1] as AddressLine1, 
					cd.[registered_addr_line2] as AddressLine2,
					cd.[registered_city] as Town,
					cd.[registered_addr_county] as County,
					cd.[registered_addr_country] as Country,
					cd.[registered_addr_postcode] as Postcode
			from [rpd].[CompanyDetails] cd
			left join rpd.Organisations o on o.ReferenceNumber = cd.organisation_id
			left join [rpd].[cosmos_file_metadata] cfm on cfm.FileName = cd.FileName
			left join [rpd].[ComplianceSchemes] cs on cs.ExternalId = cfm.ComplianceSchemeId	
		) A
		WHERE  '20'+reverse(substring(reverse(trim(a.SubmissionPeriodYear)),1,2)) IN ('2024','2025')
		--ORDER BY ReferenceNumber asc, Last_submission asc)
)

,Active_ComplianceScheme  
AS (
  SELECT DISTINCT cs.id as ComplianceSchemeId, MAX(CONVERT(DATETIME,substring(cfm2.Created,1,23))) as submission_time  
  FROM rpd.cosmos_file_metadata cfm2
  left join [rpd].[ComplianceSchemes] cs on cs.ExternalId = cfm2.ComplianceSchemeId	
  WHERE complianceSchemeID IS NOT NULL
  AND FileType = 'CompanyDetails'
  and '20'+reverse(substring(reverse(trim(SubmissionPeriod)),1,2)) IN ('2024','2025')
  GROUP BY cs.id
  )


--DR Registered--
select
l.OrganisationName,
l.TradingName,
'DR' as OrganisationType,
e.CompaniesHouseNumber as CompaniesHouseNumber,
e.referencenumber as organisationId,
l.AddressLine1, 
l.AddressLine2,
l.Town,
l.County,
l.Country,
l.Postcode,
e.externalid as pEPRID,
'DR Registered' as status
,N.Name as 'BusinessCountry'
,l.Submission_time as UpdatedDateTime
from [rpd].[Organisations] e  
INNER JOIN latest_record l on e.referencenumber =l.referencenumber and e.isdeleted=0 and e.iscompliancescheme=0 
and l.SubmittedBy = 'DP' AND l.Last_submission = 1 AND ISNULL(l.organisation_size, 'L') ='L'
--ADDED IN DUE TO FRONT END NOT VALIDATING SUBMISSIONS
and l.referencenumber IS NOT NULL
LEFT JOIN rpd.Nations N on N.Id = e.NationId
where l.Submission_time between @From_Date and @To_Date


UNION


-- DR DELETED--
select 
l.OrganisationName,
l.TradingName,
'DR' as OrganisationType,
e.CompaniesHouseNumber as CompaniesHouseNumber,
e.referencenumber as organisationId,
l.AddressLine1, 
l.AddressLine2,
l.Town,
l.County,
l.Country,
l.Postcode,
e.externalid as pEPRID,
--'DR Deleted' as status,
'DR Deleted' as status
,N.Name as 'BusinessCountry'
,CAST(CONVERT(datetimeoffset, e.lastupdatedon) as datetime) as UpdatedDateTime
from [rpd].[Organisations] e 
INNER JOIN latest_record l on e.referencenumber =l.referencenumber and e.isdeleted=1 and e.iscompliancescheme=0 
and l.SubmittedBy = 'DP' AND l.Last_submission = 1 AND ISNULL(l.organisation_size, 'L') ='L'
LEFT JOIN rpd.Nations N on N.Id = e.NationId
where e.isdeleted=1 AND e.iscompliancescheme=0
and  CAST(CONVERT(datetimeoffset, e.lastupdatedon) as datetime) between @From_Date and @To_Date

union

-- DR Moved to Compliance Scheme
select 
l.OrganisationName,
l.TradingName,
'CSM' as OrganisationType,
e.CompaniesHouseNumber as CompaniesHouseNumber,
e.referencenumber as organisationId,
l.AddressLine1, 
l.AddressLine2,
l.Town,
l.County,
l.Country,
l.Postcode,
e.externalid as pEPRID,
'DR Moved to CS' as status
,N.Name as 'BusinessCountry'
,l.Submission_time as UpdatedDateTime
from [rpd].[Organisations] e  
--join [rpd].[OrganisationsConnections] oc on e.id=oc.fromorganisationid and e.isdeleted=0 and oc.isdeleted=0
--NEW--
INNER JOIN latest_record l on e.referencenumber =l.referencenumber and e.isdeleted=0 and e.iscompliancescheme=0 
and l.SubmittedBy = 'CS' AND l.Last_submission = 1 AND ISNULL(l.organisation_size, 'L') ='L'
LEFT JOIN rpd.Nations N on N.Id = e.NationId
where CAST(CONVERT(datetimeoffset, l.Submission_time) as datetime) between @From_Date and @To_Date


union
-- Compliance Scheme Added
select 
distinct
o.name as OrganisationName,
cs.name as TradingName,
'S' as OrganisationType,
o.CompaniesHouseNumber,
o.referencenumber as organisationId ,
o.BuildingName as AddressLine1,
o.Street as AddressLine2,
o.Town,
o.County,
o.Country,
o.Postcode,
cs.externalid as pEPRID,
'CS Added' as status
,N.Name as 'BusinessCountry'
,acs.Submission_time as UpdatedDateTime
from [rpd].[Organisations] o  
join [rpd].[OrganisationsConnections] oc on o.id=oc.toorganisationid   and o.iscompliancescheme=1 and o.isdeleted=0 and oc.isdeleted=0
left join [rpd].[SelectedSchemes] ss on ss.OrganisationConnectionid=oc.ID and ss.isdeleted=0
left join [rpd].[ComplianceSchemes] cs on ss.ComplianceSchemeid = cs.id and cs.isdeleted=0
left join [rpd].[ComplianceSchemes] cs_not_sub on cs_not_sub.CompaniesHouseNumber = o.CompaniesHouseNumber and cs_not_sub.isdeleted=0
INNER JOIN Active_ComplianceScheme acs ON cs.id =acs.ComplianceSchemeId
LEFT JOIN rpd.Nations N on N.Id = cs.NationId
where 
--The following load criteria means each time a CS makes a file submission it would come through
--But the upsert would handle this and simply update NPWD with existing information, or updated information if say address details have been changed/improved--
CAST(CONVERT(datetimeoffset, acs.Submission_time) as datetime) between @From_Date and @To_Date



union
-- Compliance Scheme Deleted
select 
distinct
o.name as OrganisationName,
cs.name as TradingName,
'S' as OrganisationType,
o.CompaniesHouseNumber,
o.referencenumber as organisationId ,
o.BuildingName as AddressLine1,
o.Street as AddressLine2,
o.Town,
o.County,
o.Country,
o.Postcode,
cs.externalid as pEPRID,
'CS Deleted'
,N.Name as 'BusinessCountry'
,CAST(CONVERT(datetimeoffset, cs.lastupdatedon) as datetime) as UpdatedDateTime
from [rpd].[Organisations] o  
join [rpd].[OrganisationsConnections] oc on o.id=oc.toorganisationid   and o.iscompliancescheme=1
left join [rpd].[SelectedSchemes] ss on ss.OrganisationConnectionid=oc.ID
left join [rpd].[ComplianceSchemes] cs on ss.ComplianceSchemeid = cs.id and cs.isdeleted=1
LEFT JOIN rpd.Nations N on N.Id = cs.NationId
where CAST(CONVERT(datetimeoffset, cs.lastupdatedon) as datetime)  between @From_Date and @To_Date

END;