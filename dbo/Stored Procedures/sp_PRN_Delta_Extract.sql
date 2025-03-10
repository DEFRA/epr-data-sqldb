CREATE PROC [dbo].[sp_PRN_Delta_Extract] @From_Date [Datetime],@To_Date [Datetime] AS
BEGIN
 -- Disable row count for performance
    SET NOCOUNT ON;

WITH latest_org_record
       AS (select a.* from (SELECT cm.filename,
                  cm.originalfilename,
                  cm.organisationid,
                  cm.submissionperiod as submission_period_desc,
                  cm.complianceschemeid,
				  Row_number()
                    OVER(
                      partition BY cm.organisationid ORDER BY CONVERT(DATETIME, Substring(cm.created, 1, 23)) DESC) AS
                     org_rownumber,
					 CAST(CONVERT(datetimeoffset, cm.created) as datetime) AS submitted_time
					,'20'+reverse(substring(reverse(trim(cm.SubmissionPeriod)),1,2)) as SubmissionYear
           FROM   [rpd].[cosmos_file_metadata] cm
                  WHERE  Trim(cm.filetype) = 'CompanyDetails'
				  and '20'+reverse(substring(reverse(trim(cm.SubmissionPeriod)),1,2)) >= '2024'
				  )a where a.org_rownumber=1 
				  
				  )
				  
--Excluding CSO and CSMs--
--Will include deleted organisations so that this exclusion logic can be utilised for both DR Registered and DR Deleted queries
--Moved check on isdeleted to these specific queries rather than in the exclude_cso query below--
,exclude_cso  AS (select  
o.referencenumber,
o.externalid,
o.name, 
o.CompaniesHouseNumber,
o.BuildingName ,
o.Street,
o.Town,
o.County,
o.Country,
o.Postcode,
o.isdeleted
from [rpd].[Organisations] o
left join [rpd].[OrganisationsConnections] oc on o.id=oc.fromorganisationid  and o.iscompliancescheme=0 
and oc.isdeleted=0
where 
o.iscompliancescheme=0
and oc.id is null)

select
--l.SubmissionYear,
--cd.organisation_id,
cd.[organisation_name] as OrganisationName,--e.Name,
--cd.[subsidiary_id],cd.registration_type_code,cd.organisation_type_code,cd.organisation_sub_type_code,
cd.[trading_name] TradingName,--[subsidiary_id],
'DR' as OrganisationType,
--ot.name as OrganisationType,
e.CompaniesHouseNumber as CompaniesHouseNumber,
e.referencenumber as organisationId,
cd.[registered_addr_line1] as AddressLine1, 
--case when cd.[registered_addr_line1] is not null then cd.[registered_addr_line1] else e.BuildingName end as AddressLine1,
cd.[registered_addr_line2] as AddressLine2,
--case when cd.[registered_addr_line2] is not null then cd.[registered_addr_line2] else e.Street end as AddressLine2,
cd.[registered_city] as Town,
--case when cd.[registered_city] is not null then cd.[registered_city]  else e.Town end as Town,
cd.[registered_addr_county] as County,
--case when cd.[registered_addr_county] is not null then cd.[registered_addr_county]  else e.County end as County,
cd.[registered_addr_country] as Country,
--case when cd.[registered_addr_country] is not null then cd.[registered_addr_country]  else e.Country end as Country,
cd.[registered_addr_postcode] as Postcode,
--case when cd.[registered_addr_postcode] is not null then cd.[registered_addr_postcode]   else e.Postcode end as Postcode,
e.externalid as pEPRID,
'DR Registered' as status
,N.Name as 'BusinessCountry'
from [rpd].[Organisations] e  
--Excluding CSO and CSMs--
INNER JOIN latest_org_record l on e.externalid =l.organisationid and e.isdeleted=0 and e.iscompliancescheme=0 and l.complianceschemeid is null
INNER JOIN exclude_cso ecso ON ecso.externalid =l.organisationid and ecso.isdeleted = 0
join [rpd].[CompanyDetails] cd on cd.[FileName]=l.filename and ISNULL(cd.organisation_size, 'L') ='L' 
--ADDED IN DUE TO FRONT END NOT VALIDATING SUBMISSIONS
and cd.Organisation_id IS NOT NULL
and cd.[subsidiary_id] is null --or upper(cd.[subsidiary_id]) in ('N/A', 'NA','NOT APPLICABLE','NOTAPPLICABLE')
LEFT JOIN rpd.Nations N on N.Id = e.NationId
where l.submitted_time between @From_Date and @To_Date

union

--SUBSIDIARY_DRs--

select
--l.SubmissionYear,
--cd.organisation_id,
cd.[organisation_name] as OrganisationName,--e.Name,
--cd.[subsidiary_id],cd.registration_type_code,cd.organisation_type_code,cd.organisation_sub_type_code,
cd.[trading_name] TradingName,--[subsidiary_id],
'DR' as OrganisationType,
--ot.name as OrganisationType,
e.CompaniesHouseNumber as CompaniesHouseNumber,
e.referencenumber as organisationId,
cd.[registered_addr_line1] as AddressLine1, 
--case when cd.[registered_addr_line1] is not null then cd.[registered_addr_line1] else e.BuildingName end as AddressLine1,
cd.[registered_addr_line2] as AddressLine2,
--case when cd.[registered_addr_line2] is not null then cd.[registered_addr_line2] else e.Street end as AddressLine2,
cd.[registered_city] as Town,
--case when cd.[registered_city] is not null then cd.[registered_city]  else e.Town end as Town,
cd.[registered_addr_county] as County,
--case when cd.[registered_addr_county] is not null then cd.[registered_addr_county]  else e.County end as County,
cd.[registered_addr_country] as Country,
--case when cd.[registered_addr_country] is not null then cd.[registered_addr_country]  else e.Country end as Country,
cd.[registered_addr_postcode] as Postcode,
--case when cd.[registered_addr_postcode] is not null then cd.[registered_addr_postcode]   else e.Postcode end as Postcode,
e.externalid as pEPRID,
'DR Registered' as status
,N.Name as 'BusinessCountry'
from [rpd].[Organisations] e  
--Excluding CSO and CSMs--
INNER JOIN latest_org_record l on e.externalid =l.organisationid and e.isdeleted=0 and e.iscompliancescheme=0 and l.complianceschemeid is null
INNER JOIN exclude_cso ecso ON ecso.externalid =l.organisationid and ecso.isdeleted = 0
join [rpd].[CompanyDetails] cd on cd.[FileName]=l.filename and ISNULL(cd.organisation_size, 'L') ='L'
and cd.[subsidiary_id] is null --or upper(cd.[subsidiary_id]) in ('N/A', 'NA','NOT APPLICABLE','NOTAPPLICABLE')
LEFT JOIN rpd.Nations N on N.Id = e.NationId
WHERE CONVERT(varchar, cd.organisation_id) = cd.subsidiary_id
AND l.submitted_time between @From_Date and @To_Date


UNION


-- DR DELETED--
select 
e.Name as OrganisationName,
--cd.[subsidiary_id],cd.registration_type_code,cd.organisation_type_code,cd.organisation_sub_type_code,
e.[tradingname] TradingName,--[subsidiary_id],
'DR' as OrganisationType,
--ot.name as OrganisationType,
e.CompaniesHouseNumber as CompaniesHouseNumber,
e.referencenumber as organisationId,
e.BuildingName as AddressLine1,
e.Street as AddressLine2,
e.Town as Town,
e.County as County,
e.Country as Country,
e.Postcode as Postcode,
e.externalid as pEPRID,
--'DR Deleted' as status,
'DR Deleted' as status
,N.Name as 'BusinessCountry'
from [rpd].[Organisations] e 
--JOINS REQUIRED to find Organisation size and exclude CSO and CSM
INNER JOIN latest_org_record l on e.externalid =l.organisationid and e.isdeleted=1 and e.iscompliancescheme=0 and l.complianceschemeid is null
INNER JOIN exclude_cso ecso ON ecso.externalid =l.organisationid and ecso.isdeleted = 1
INNER JOIN [rpd].[CompanyDetails] cd on cd.[FileName]=l.filename and ISNULL(cd.organisation_size, 'L') ='L'
-- join latest_org_record l on e.externalid =l.organisationid and e.iscompliancescheme=0
LEFT JOIN rpd.Nations N on N.Id = e.NationId
where e.isdeleted=1 AND e.iscompliancescheme=0
and  CAST(CONVERT(datetimeoffset, e.lastupdatedon) as datetime) between @From_Date and @To_Date

union
-- DR Moved to Compliance Scheme
select 
e.Name as OrganisationName,
--cd.[subsidiary_id],cd.registration_type_code,cd.organisation_type_code,cd.organisation_sub_type_code,
e.[tradingname] TradingName,--[subsidiary_id],
'CSM' as OrganisationType,
--ot.name as OrganisationType,
e.CompaniesHouseNumber as CompaniesHouseNumber,
e.referencenumber as organisationId,
e.BuildingName as AddressLine1,
e.Street as AddressLine2,
e.Town as Town,
e.County as County,
e.Country as Country,
e.Postcode as Postcode,
e.externalid as pEPRID,
'DR Moved to CS' as status
--oc.Toorganisationid,ss.OrganisationConnectionid,ss.ComplianceSchemeid
,N.Name as 'BusinessCountry'
from [rpd].[Organisations] e  
join [rpd].[OrganisationsConnections] oc on e.id=oc.fromorganisationid and e.isdeleted=0 and oc.isdeleted=0
LEFT JOIN rpd.Nations N on N.Id = e.NationId
where CAST(CONVERT(datetimeoffset, oc.lastupdatedon) as datetime) between @From_Date and @To_Date

Union
-- Memeber moved from Compliance Scheme to DR
select 
e.Name as OrganisationName,
--cd.[subsidiary_id],cd.registration_type_code,cd.organisation_type_code,cd.organisation_sub_type_code,
e.[tradingname] TradingName,--[subsidiary_id],
'DR' as OrganisationType,
--ot.name as OrganisationType,
e.CompaniesHouseNumber as CompaniesHouseNumber,
e.referencenumber as organisationId,
e.BuildingName as AddressLine1,
e.Street as AddressLine2,
e.Town as Town,
e.County as County,
e.Country as Country,
e.Postcode as Postcode,
e.externalid as pEPRID,
'Not a Member of CS' as status
--oc.Toorganisationid,ss.OrganisationConnectionid,ss.ComplianceSchemeid
,N.Name as 'BusinessCountry'
from [rpd].[Organisations] e  
join [rpd].[OrganisationsConnections] oc on e.id=oc.fromorganisationid and e.isdeleted=0  and oc.isdeleted=1
LEFT JOIN rpd.Nations N on N.Id = e.NationId
where CAST(CONVERT(datetimeoffset, oc.lastupdatedon) as datetime)  between @From_Date and @To_Date

union
-- Compliance Scheme Added
select 
distinct
o.name as OrganisationName,--o.referencenumber,
cs.name as TradingName,
'S' as OrganisationType,
--ot.name as OrganisationType,
o.CompaniesHouseNumber,-- cs.CompaniesHouseNumber,
o.referencenumber as organisationId ,
o.BuildingName as AddressLine1,
o.Street as AddressLine2,
o.Town,
o.County,
o.Country,
o.Postcode,
cs.externalid as pEPRID,
'CS Added' as status
--,cs.id,
--cs.name
--oc.Toorganisationid,ss.OrganisationConnectionid,ss.ComplianceSchemeid
,N.Name as 'BusinessCountry'
from [rpd].[Organisations] o  
--left join [rpd].[OrganisationTypes] ot on ot.id=OrganisationTypeid
join [rpd].[OrganisationsConnections] oc on o.id=oc.toorganisationid   and o.iscompliancescheme=1 and o.isdeleted=0 and oc.isdeleted=0
left join [rpd].[SelectedSchemes] ss on ss.OrganisationConnectionid=oc.ID and ss.isdeleted=0
left join [rpd].[ComplianceSchemes] cs on ss.ComplianceSchemeid = cs.id and cs.isdeleted=0
left join [rpd].[ComplianceSchemes] cs_not_sub on cs_not_sub.CompaniesHouseNumber = o.CompaniesHouseNumber and cs_not_sub.isdeleted=0
LEFT JOIN rpd.Nations N on N.Id = cs.NationId
where CAST(CONVERT(datetimeoffset, cs.lastupdatedon) as datetime)  between @From_Date and @To_Date
or CAST(CONVERT(datetimeoffset, cs_not_sub.lastupdatedon) as datetime)  between @From_Date and @To_Date


union
-- Compliance Scheme Deleted
select 
distinct
o.name as OrganisationName,--o.referencenumber,
cs.name as TradingName,
'S' as OrganisationType,
--ot.name as OrganisationType,
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
--,cs.id,
--cs.name
--oc.Toorganisationid,ss.OrganisationConnectionid,ss.ComplianceSchemeid
,N.Name as 'BusinessCountry'
from [rpd].[Organisations] o  
--left join [rpd].[OrganisationTypes] ot on ot.id=OrganisationTypeid
join [rpd].[OrganisationsConnections] oc on o.id=oc.toorganisationid   and o.iscompliancescheme=1  and o.isdeleted=0 and oc.isdeleted=0
left join [rpd].[SelectedSchemes] ss on ss.OrganisationConnectionid=oc.ID and ss.isdeleted=0
left join [rpd].[ComplianceSchemes] cs on ss.ComplianceSchemeid = cs.id and cs.isdeleted=1
LEFT JOIN rpd.Nations N on N.Id = cs.NationId
where CAST(CONVERT(datetimeoffset, cs.lastupdatedon) as datetime)  between @From_Date and @To_Date

END;