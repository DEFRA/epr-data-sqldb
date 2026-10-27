CREATE VIEW [dbo].[v_Compliance_Report] AS WITH reg_submissions AS (
/*
History:
Updated 2025-10-29: ST001: 623983: Added this history log. Now utilising t_submitted_pom_org_file_status rather than view for performance increase,
likewise utilising t_PRN_Recycling_Obligation_stat_Count rather than view as view with changes required was causing this to hang indefinitely.
*/
---------------------------------------------------
/*Returns information about registration files*/
    SELECT
		cfm.organisationid,
		cd.organisation_id,
		cd.subsidiary_id,
        cfm.FileName,
        cfm.Created AS SubmissionTime,
        cfm.SubmissionPeriod,
        cfm.FileType,
        sub.Regulator_Status,
		CASE WHEN CAST('20' + RIGHT(RTRIM(cfm.SubmissionPeriod), 2) AS INT) < 2025 THEN CAST('20' + RIGHT(RTRIM(cfm.SubmissionPeriod), 2) AS INT) + 1
		ELSE CAST('20' + RIGHT(RTRIM(cfm.SubmissionPeriod), 2) AS INT) 
		END AS [Relevant_Year]
	FROM [rpd].[cosmos_file_metadata] cfm inner join rpd.CompanyDetails cd on cd.FileName=cfm.FileName
	join [dbo].[t_submitted_pom_org_file_status] sub on sub.FileName = cfm.FileName 
	WHERE UPPER(cfm.FileType) ='COMPANYDETAILS'
	
),
/* Assigns first and latest registration file by organisation id and relevant year (bug fix 605827)*/
first_latest_reg_submissions AS (
SELECT *,
	ROW_NUMBER() OVER (PARTITION BY organisation_id, Relevant_Year ORDER BY CAST(SubmissionTime AS DATETIME2)) AS rn_asc,
    ROW_NUMBER() OVER (PARTITION BY organisation_id, Relevant_Year ORDER BY CAST(SubmissionTime AS DATETIME2) DESC) AS rn_desc
	FROM reg_submissions
),
 
 reg_pom AS (
 /*Returns information about POM files partitioned over org id and submission period so that we return the first and latest dates for an org in that period. 
 Uses the same code as reg_submissions but is seperate to allow for easier bug fixing*/
    SELECT
		cfm.organisationid,
		pom.organisation_id,
		pom.subsidiary_id,
        cfm.FileName,
        cfm.Created AS SubmissionTime,
        cfm.SubmissionPeriod,
        cfm.FileType,
        sub.Regulator_Status,
		CAST('20' + RIGHT(RTRIM(cfm.SubmissionPeriod), 2) AS INT)+1 AS [Relevant_Year], -- relevent year is one after submission period year
        ROW_NUMBER() OVER (PARTITION BY pom.organisation_id,cfm.SubmissionPeriod ORDER BY CAST(cfm.Created AS DATETIME2)) AS rn_asc,
        ROW_NUMBER() OVER (PARTITION BY pom.organisation_id,cfm.SubmissionPeriod ORDER BY CAST(cfm.Created AS DATETIME2) DESC) AS rn_desc
	FROM [rpd].[cosmos_file_metadata] cfm inner join rpd.POM pom on pom.FileName=cfm.FileName
	join [dbo].[t_submitted_pom_org_file_status] sub on sub.FileName = cfm.FileName 
	WHERE UPPER(cfm.FileType) ='POM'

)

,
	lookup_dates AS(
/*Returns information around deadline dates by differnt types  */
	SELECT	[Producer_Type]
      ,[Submission_Type]
      ,[Start_Date]
      ,[End_Date]
	  ,format([start_date],'MMMM') + ' to '+format([End_Date],'MMMM yyyy') as submission_period
      ,[Deadline_Date]
      ,[Relevant_Year]
  FROM [dbo].[v_relevant_year_lookup])

,
	pom_sub AS(
	/*Returns link between lookup dates and pom registrations*/
	SELECT lookup_dates.submission_period,lookup_dates.[Producer_Type], reg_pom.* FROM lookup_dates left join reg_pom on lookup_dates.submission_period=reg_pom.submissionperiod
	)
,
	rel_year as(
	/*Returns all distinct relevant years in the lookup table to use in the cross join to ensure orgs with no files submitted will have a relevant year and thus can be filtered on*/
		select distinct [Relevant_Year]  FROM [dbo].[v_relevant_year_lookup]
	),

/*Returns the associated compliance scheme for each CS member*/
org_selected_schemes as (

select producerOrg.ReferenceNumber as producerId, 
producerOrg.Name as producerName, 
csOrg.ReferenceNumber as operatorID, 
csOrg.Name as operatorName, 
cs.Name as schemeName,
case when ROW_NUMBER() OVER (PARTITION BY producerOrg.ReferenceNumber ORDER BY oc.CreatedOn desc) = 1 then 'latest scheme'
else 'old scheme' end as latestScheme,
oc.CreatedOn,
n.Name as CS_Nation  -- 567886 added CS nation for RLS
from rpd.SelectedSchemes ss
join rpd.OrganisationsConnections oc on oc.Id = ss.OrganisationConnectionId
join rpd.ComplianceSchemes cs on cs.Id = ss.ComplianceSchemeId
join rpd.Organisations producerOrg on producerOrg.Id = oc.FromOrganisationId
join rpd.Organisations csOrg on csOrg.Id = oc.ToOrganisationId
left join rpd.Nations n on n.id = cs.NationId
)
	/*Select uses max and Group By as a work-around to merge first and latest dates onto one line  */
  SELECT
Organisation_ID,
Subsidiary_ID,
Organisation_Name,
Organisation_Size,
Scheme_Name,
Organisation_Sub_Type,
Single_or_Group,
max(Enrolment_Date) AS Enrolment_Date,
Relevant_Year,
 max( [First_Registration_File_Submission_Date]) AS [First_Registration_File_Submission_Date],
 max([First_Registration_File_Status]) AS [First_Registration_File_Status],
 max([Latest_Registration_File_Submission_Date]) AS [Latest_Registration_File_Submission_Date],
 max([Latest_Registration_File_Status]) AS [Latest_Registration_File_Status],
max(Registration_File_Compliant) as Registration_File_Compliant,
POM_Submission_Period,
max(First_POM_Submission_Date) as First_POM_Submission_Date,
max(First_POM_Status) as First_POM_Status,
max(Latest_POM_Submission_Date) as Latest_POM_Submission_Date,
max(Latest_POM_Status) as Latest_POM_Status,
max(Pom_File_Compliant) as Pom_File_Compliant,
Registration_Submission_Deadline_Date,
max(POM_Submission_Deadline_Date) AS POM_Submission_Deadline_Date,
max(Joiner_Date) AS Joiner_Date,
max(Leaver_Date) AS Leaver_Date,
max(Leaver_Code) AS Leaver_Code,
max(Organisation_Change_Reason) AS Organisation_Change_Reason,
Prn_Accepted,
Prn_Awaiting_Acceptance,
Recycling_Obligation,
Prn_Outstanding,
Org_Nation,
CS_Nation
from

(
SELECT
    Org.ReferenceNumber AS [Organisation_ID], -- Organisation Reference Number from main Organisation table
    cd.subsidiary_id AS [Subsidiary_ID], -- Subsidiary ID from company details table, will be null if no registration file ever submitted or if org does not have a subsidiary
    Org.Name AS [Organisation_Name], -- Organisation Name from main Organisation table
    cd.organisation_size AS [Organisation_Size],-- Organisation size from company details table, will be null if no registration file ever submitted, can have both L and S in same submission period
    ss.schemeName AS [Scheme_Name], -- Compliance Scheme Name from Compliance scheme table, can be null
    CASE 
        WHEN cd.organisation_sub_type_code = 'LIC' THEN 'Licensor'
        WHEN cd.organisation_sub_type_code = 'POB' THEN 'Pub operating business'
        WHEN cd.organisation_sub_type_code = 'FRA' THEN 'Franchisor'
        WHEN cd.organisation_sub_type_code = 'NAO' THEN 'Non-associated organisation'
        WHEN cd.organisation_sub_type_code = 'HCY' THEN 'Holding company'
        WHEN cd.organisation_sub_type_code = 'SUB' THEN 'Subsidiary'
        WHEN cd.organisation_sub_type_code = 'LFR' THEN 'Licensee/Franchisee'
        WHEN cd.organisation_sub_type_code = 'TEN' THEN 'Tenant'
        WHEN cd.organisation_sub_type_code = 'OTH' THEN 'Others'
        ELSE NULL
    END AS [Organisation_Sub_Type],  --Organisation Sub Type from company details table will be null if no registration file ever submitted or sub type code is null
    CASE 
        WHEN cd.subsidiary_id IS NULL THEN 'Single'
        ELSE 'Group'
    END AS [Single_or_Group], -- Single or Group derived from company details subsidiary field, if populated then Group
    Org.CreatedOn AS [Enrolment_Date], -- Enrolment date from organisation created field
    
	rel.Relevant_year AS [Relevant_Year], -- Relevant year from distinct values in dbo.v_relevant_year_lookup view

    -- Registration Submission Details
    f.SubmissionTime AS [First_Registration_File_Submission_Date],
    f.Regulator_Status AS [First_Registration_File_Status],
    l.SubmissionTime AS [Latest_Registration_File_Submission_Date],
    l.Regulator_Status AS [Latest_Registration_File_Status],
	-- Registration Submission Deadline
    ldateR.deadline_date AS [Registration_Submission_Deadline_Date],
   CASE 
        WHEN f.SubmissionTime<    LdateR.deadline_Date THEN 'Yes'
        ELSE 'No'
    END  
	 AS [Registration_File_Compliant], -- if first file is before deadline date then Compliant else No

    -- POM Submission Details
	LDateP.Submission_Period AS [POM_Submission_Period], -- Pom submission period from the lookup table based on organisation size and relevant year
    fpom.SubmissionTime AS [First_POM_Submission_Date],
    fpom.Regulator_Status AS [First_POM_Status],
    lpom.SubmissionTime AS [Latest_POM_Submission_Date],
    lpom.Regulator_Status AS [Latest_POM_Status],
	-- Packaging Submission Deadline
	LDateP.deadline_date 	AS [POM_Submission_Deadline_Date],  -- Pom deadline from the lookup table based on organisation size and relevant year, will be null if we have never had registration info for this org,
	CASE 
        WHEN fpom.SubmissionTime<  LdateP.deadline_date THEN 'Yes'
        ELSE 'No'
    END  
	 AS [Pom_File_Compliant],  -- if first file is before deadline date then Compliant else No

    cd.joiner_date AS [Joiner_Date], -- Joiner date from Company Details table
    cd.leaver_date AS [Leaver_Date], --  Leaver date from Company Details table
    cd.leaver_code AS [Leaver_Code], -- Leaver code  from Company Details table
	cd.organisation_change_reason as [Organisation_Change_Reason], -- Organisation Change Reason from Company Details table
	prn.[TOTAL PRN/PERN Accepted] as [Prn_Accepted], -- from view v_PRN_Recycling_Obligation_stat_Count
	prn.[TOTAL PRN/PERN Awaiting Acceptance] as [Prn_Awaiting_Acceptance],-- from v_PRN_Recycling_Obligation_stat_Count
	prn.[Recyling_Obligation] as [Recycling_Obligation],-- from v_PRN_Recycling_Obligation_stat_Count
	prn.[TOTAL PRN/PERN Outstanding] as [Prn_Outstanding],-- from v_PRN_Recycling_Obligation_stat_Count
	n.Name as Org_Nation, --567886 added Org nation for RLS
	ss.CS_Nation
FROM rpd.Organisations Org
cross join rel_year rel
left join	rpd.CompanyDetails cd 
	on Org.ReferenceNumber=cd.organisation_id
LEFT JOIN dbo.t_cosmos_file_metadata meta
    ON LOWER(LTRIM(RTRIM(cd.FileName))) = LOWER(LTRIM(RTRIM(meta.FileName)))
LEFT JOIN rpd.ComplianceSchemes cs
    ON cs.ExternalId = meta.ComplianceSchemeId
LEFT JOIN first_latest_reg_submissions f
    ON f.organisation_id=Org.referenceNumber AND f.rn_asc = 1 and f.Relevant_Year=rel.Relevant_year--TRY_CAST('20' + RIGHT(RTRIM(meta.SubmissionPeriod), 2) AS INT)
LEFT JOIN first_latest_reg_submissions l
    ON l.organisation_id=Org.referenceNumber AND l.rn_desc = 1 and l.Relevant_Year=rel.Relevant_year--TRY_CAST('20' + RIGHT(RTRIM(meta.SubmissionPeriod), 2) AS INT)
LEFT JOIN lookup_dates LDateP 
	ON LDateP.Producer_Type=cd.organisation_size and LDateP.Submission_Type='Packaging' and LdateP.relevant_year=rel.Relevant_year --592034 moved join earlier to enable filtering by submission period in POM data join
LEFT JOIN pom_sub fpom
    ON fpom.organisation_id=Org.referenceNumber AND fpom.rn_asc = 1 and fpom.Relevant_Year=rel.Relevant_year and fpom.SubmissionPeriod=LDateP.submission_period--TRY_CAST('20' + RIGHT(RTRIM(meta.SubmissionPeriod), 2) AS INT) 592034 add submission period to join cond
LEFT JOIN reg_pom lpom
    ON lpom.organisation_id=Org.referenceNumber AND lpom.rn_desc = 1 and lpom.Relevant_Year=rel.Relevant_year and lpom.SubmissionPeriod=LDateP.submission_period--TRY_CAST('20' + RIGHT(RTRIM(meta.SubmissionPeriod), 2) AS INT) 592034 add submission period to join cond
LEFT JOIN lookup_dates LDateR 
	ON LDateR.Producer_Type=cd.organisation_size and LDateR.Submission_Type='Registration' and LdateR.relevant_year=rel.Relevant_year--TRY_CAST('20' + RIGHT(RTRIM(meta.SubmissionPeriod), 2) AS INT) --meta.created>= LDateR.start_date and meta.created<=LDateR.end_date
LEFT JOIN t_PRN_Recycling_Obligation_stat_Count prn
	ON Org.id=prn.orgid and prn.YR=rel.Relevant_year and prn.subsidiaryid is null and cd.subsidiary_id is null
lEFT JOIN org_selected_schemes ss
	ON ss.producerId = Org.ReferenceNumber and latestScheme = 'latest scheme' --ensures only the latest scheme is shown
LEFT JOIN rpd.Nations n
	On Org.NationId = n.id
	)A
	
	group by
	Organisation_ID,
Subsidiary_ID,
Organisation_Name,
Organisation_Size,
Scheme_Name,
Organisation_Sub_Type,
Single_or_Group,
Relevant_Year,
POM_Submission_Period,
Registration_Submission_Deadline_Date,
Prn_Accepted,
Prn_Awaiting_Acceptance,
Recycling_Obligation,
Prn_Outstanding,
Org_Nation,
CS_Nation;