CREATE VIEW [dbo].[v_public_register_all_producers_extract]
AS WITH
/****************************************************************************************************************************
	History: This view is created for the ticket 459575 Public Register Report 
							
******************************************************************************************************************************/
  ApprovedReg
    AS
    (
        SELECT
            a.FileName,
            a.ComplianceSchemeId,
            a.SubmissionPeriod,
            a.created,
            se.fileid
        FROM [rpd].[cosmos_file_metadata] a
            INNER JOIN [rpd].[SubmissionEvents] se
            ON TRIM(se.fileid) = TRIM(a.fileid)
                AND se.[type] = 'RegulatorRegistrationDecision'
                AND se.Decision = 'Accepted'
    )
select 
    RPD_Organisation_ID,
    submission_period,
    Compliance_scheme,
    Companies_House_number,
    Subsidiary_ID,
    Organisation_name,
    Trading_name,
    Address_line_1,
    Address_line_2,
    Address_line_3,
    Address_line_4,
    Town,
    County,
    Country,
    Postcode,
    ProducerNation,
    ProducerNationId,
    ComplianceSchemeNation,
    ComplianceSchemeNationId,
    ProducerId,
    Environmental_regulator,
    Compliance_scheme_regulator,
    Reporting_year
from
    (select *, Row_number() over(Partition by RPD_Organisation_ID, Subsidiary_ID, Reporting_year order by SubmittedDateTime desc) as rn
    from
        (	
	SELECT DISTINCT
            cd.organisation_id AS 'RPD_Organisation_ID'
								, '' AS 'submission_period'
								, cs.Name AS 'Compliance_scheme'
								, case when cd.organisation_id is not null then cd.companies_house_number else pr.CompaniesHouseNumber end as 'Companies_House_number'
								, COALESCE( cd.subsidiary_id, '') AS 'Subsidiary_ID'
								, case when cd.organisation_id is not null then cd.organisation_name else pr.Name end as 'Organisation_name'
								, case when cd.organisation_id is not null then cd.Trading_Name else pr.TradingName end as 'Trading_name'
								, case 
									when cd.organisation_id is not null 
										then ISNULL(cd.registered_addr_line1,'') 
									else TRIM( ISNULL(pr.BuildingName,'') + ' ' +ISNULL(pr.BuildingNumber,'') )
										end as 'Address_line_1'									
								, case 
									when cd.organisation_id is not null 
										then ISNULL(cd.registered_addr_line2,'') 
									else ISNULL(pr.Street,'') 
										end as 'Address_line_2'								
								, '' as 'Address_line_3'
								, '' as 'Address_line_4'
								, case 
									when cd.organisation_id is not null 
										then ISNULL(cd.registered_city,'') 
									else ISNULL(pr.Town,'') 
										end as 'Town'
								, case 
									when cd.organisation_id is not null 
										then ISNULL(cd.registered_addr_county,'') 
									else ISNULL(pr.County,'') 
										end as 'County'
								, case 
									when cd.organisation_id is not null 
										then ISNULL(cd.registered_addr_country,'') 
									else ISNULL(pr.Country,'') 
										end as 'Country'
								, case 
									when cd.organisation_id is not null 
										then ISNULL(cd.registered_addr_postcode,'') 
									else ISNULL(pr.Postcode,'') 
										end as 'Postcode'
								, producernation.Name AS ProducerNation
								, producernation.Id AS ProducerNationId
								, csnation.Name AS ComplianceSchemeNation
								, csnation.Id AS ComplianceSchemeNationId
								, pr.ReferenceNumber AS ProducerId
								, (CASE producernation.Id
									WHEN 1 THEN 'Environment Agency (England)'
									WHEN 2 THEN 'Northern Ireland Environment Agency'
									WHEN 3 THEN 'Scottish Environment Protection Agency'
									WHEN 4 THEN 'Natural Resources Wales'
									END) As 'Environmental_regulator'
								, (CASE csnation.Id
									WHEN 1 THEN 'Environment Agency (England)'
									WHEN 2 THEN 'Northern Ireland Environment Agency'
									WHEN 3 THEN 'Scottish Environment Protection Agency'
									WHEN 4 THEN 'Natural Resources Wales'
									END) As 'Compliance_scheme_regulator'
								, '20'+reverse(substring(reverse(trim(meta.SubmissionPeriod)),1,2)) as 'Reporting_year'
								, meta.created SubmittedDateTime
        FROM [rpd].[CompanyDetails] cd
            inner join ApprovedReg meta
            on meta.FileName = cd.FileName
            LEFT JOIN dbo.v_rpd_ComplianceSchemes_Active cs
            ON meta.ComplianceSchemeId = cs.ExternalId
            left JOIN dbo.v_rpd_Organisations_Active pr
            ON cd.organisation_id = pr.ReferenceNumber
            LEFT JOIN rpd.Nations producernation
            ON pr.NationId = producernation.Id
            LEFT JOIN rpd.Nations csnation
            ON cs.NationId = csnation.Id
            left JOIN [dbo].[v_registration_latest_by_Year] rl
            ON cd.organisation_id = rl.organisation_id
                and isnull(cd.subsidiary_id,'') = isnull(rl.subsidiary_id,'')
                and rl.Reporting_year = '20'+reverse(substring(reverse(trim(meta.SubmissionPeriod)),1,2))
            left JOIN (SELECT FromOrganisation_ReferenceNumber, EnrolmentStatuses_EnrolmentStatus
            FROM t_rpd_data_SECURITY_FIX
            GROUP BY FromOrganisation_ReferenceNumber, EnrolmentStatuses_EnrolmentStatus) e_status
            ON e_status.FromOrganisation_ReferenceNumber = cd.organisation_id
        WHERE (cs.IsDeleted = 0 OR cs.IsDeleted IS NULL)
            AND (pr.isdeleted = 0 OR pr.isdeleted IS NULL)
            AND e_status.EnrolmentStatuses_EnrolmentStatus <> 'Rejected'
            AND (pr.IsComplianceScheme = 0 OR pr.IsComplianceScheme IS NULL)
						
		) A
	) B
where B.rn = 1;