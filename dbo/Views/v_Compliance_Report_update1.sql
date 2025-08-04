CREATE VIEW [dbo].[v_Compliance_Report_update1]
AS WITH reg_submissions AS (
/*Returns information about registration files partitioned over org id and submission period so that we return the first and latest dates for an org in that period*/
    SELECT
		pom.organisationid,org.referencenumber,
        pom.FileName,
        pom.Created AS SubmissionTime,
        pom.SubmissionPeriod,
        pom.FileType,
        pom.Regulator_Status,
		TRY_CAST('20' + RIGHT(RTRIM(pom.SubmissionPeriod), 2) AS INT)AS [Relevant_Year],
        ROW_NUMBER() OVER (PARTITION BY pom.organisationid,pom.SubmissionPeriod ORDER BY CAST(pom.Created AS DATETIME2)) AS rn_asc,
        ROW_NUMBER() OVER (PARTITION BY pom.organisationid,pom.SubmissionPeriod ORDER BY CAST(pom.Created AS DATETIME2) DESC) AS rn_desc
	FROM [v_submitted_pom_org_file_status] pom inner join rpd.Organisations Org on Org.ExternalId=pom.organisationid
	WHERE UPPER(pom.FileType) ='COMPANYDETAILS'
	
),
 reg_pom AS (
 /*Returns information about POM files partitioned over org id and submission period so that we return the first and latest dates for an org in that period. 
 Uses the same code as reg_submissions but is seperate to allow for easier bug fixing*/
    SELECT
		pom.organisationid,org.referencenumber,
        pom.FileName,
        pom.Created AS SubmissionTime,
        pom.SubmissionPeriod,
        pom.FileType,
        pom.Regulator_Status,
		TRY_CAST('20' + RIGHT(RTRIM(pom.SubmissionPeriod), 2) AS INT)+1 AS [Relevant_Year], -- relevent year is one after submission period year
        ROW_NUMBER() OVER (PARTITION BY pom.organisationid,pom.SubmissionPeriod ORDER BY CAST(pom.Created AS DATETIME2)) AS rn_asc,
        ROW_NUMBER() OVER (PARTITION BY pom.organisationid,pom.SubmissionPeriod ORDER BY CAST(pom.Created AS DATETIME2) DESC) AS rn_desc
	FROM [v_submitted_pom_org_file_status] pom inner join rpd.Organisations Org on Org.ExternalId=pom.organisationid
	WHERE UPPER(pom.FileType) ='POM'

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
  FROM [rpd].[RelevantYearLookup])

,
	pom_sub AS(
	/*Returns link between lookup dates and pom registrations*/
	SELECT lookup_dates.submission_period,lookup_dates.[Producer_Type], reg_pom.* FROM lookup_dates left join reg_pom on lookup_dates.submission_period=reg_pom.submissionperiod
	)
,
	rel_year as(
	/*Returns all distinct relevant years in the lookup table to use in the cross join to ensure orgs with no files submitted will have a relevant year and thus can be filtered on*/
		select distinct [Relevant_Year]  FROM [rpd].[RelevantYearLookup]
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
Prn_Outstanding
from

(
SELECT
    Org.ReferenceNumber AS [Organisation_ID], -- Organisation Reference Number from main Organisation table
    cd.subsidiary_id AS [Subsidiary_ID], -- Subsidiary ID from company details table, will be null if no registration file ever submitted or if org does not have a subsidiary
    Org.Name AS [Organisation_Name], -- Organisation Name from main Organisation table
    cd.organisation_size AS [Organisation_Size],-- Organisation size from company details table, will be null if no registration file ever submitted, can have both L and S in same submission period
    cs.Name AS [Scheme_Name], -- Compliance Scheme Name from Compliance scheme table, can be null
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
    
	rel.Relevant_year AS [Relevant_Year], -- Relevant year from distinct values in rpd.RelevantYearLookup table

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
	prn.[TOTAL PRN/PERN Outstanding] as [Prn_Outstanding]-- from v_PRN_Recycling_Obligation_stat_Count

FROM rpd.Organisations Org
cross join rel_year rel
left join	rpd.CompanyDetails cd 
	on Org.ReferenceNumber=cd.organisation_id
LEFT JOIN dbo.t_cosmos_file_metadata meta
    ON LOWER(LTRIM(RTRIM(cd.FileName))) = LOWER(LTRIM(RTRIM(meta.FileName)))
LEFT JOIN rpd.ComplianceSchemes cs
    ON cs.ExternalId = meta.ComplianceSchemeId
LEFT JOIN reg_submissions f
    ON f.referencenumber=Org.referenceNumber AND f.rn_asc = 1 and f.Relevant_Year=rel.Relevant_year--TRY_CAST('20' + RIGHT(RTRIM(meta.SubmissionPeriod), 2) AS INT)
LEFT JOIN reg_submissions l
    ON l.referencenumber=Org.referenceNumber AND l.rn_desc = 1 and l.Relevant_Year=rel.Relevant_year--TRY_CAST('20' + RIGHT(RTRIM(meta.SubmissionPeriod), 2) AS INT)
LEFT JOIN lookup_dates LDateR 
	ON LDateR.Producer_Type=cd.organisation_size and LDateR.Submission_Type='Registration' and LdateR.relevant_year=rel.Relevant_year--TRY_CAST('20' + RIGHT(RTRIM(meta.SubmissionPeriod), 2) AS INT) --meta.created>= LDateR.start_date and meta.created<=LDateR.end_date
LEFT JOIN lookup_dates LDateP 
	ON LDateP.Producer_Type=cd.organisation_size and LDateP.Submission_Type='Packaging' and LdateP.relevant_year=rel.Relevant_year--TRY_CAST('20' + RIGHT(RTRIM(meta.SubmissionPeriod), 2) AS INT)-- meta.created>= LDateP.start_date and meta.created<=LDateP.end_date
LEFT JOIN reg_pom lpom
    ON lpom.referencenumber=Org.referenceNumber AND lpom.rn_desc = 1 and lpom.Relevant_Year=rel.Relevant_year and lpom.SubmissionPeriod= LDateP.Submission_Period--TRY_CAST('20' + RIGHT(RTRIM(meta.SubmissionPeriod), 2) AS INT)
LEFT JOIN pom_sub fpom
    ON fpom.referencenumber=Org.referenceNumber AND fpom.rn_asc = 1 and fpom.Relevant_Year=rel.Relevant_year and fpom.SubmissionPeriod= LDateP.Submission_Period --TRY_CAST('20' + RIGHT(RTRIM(meta.SubmissionPeriod), 2) AS INT)
LEFT JOIN v_PRN_Recycling_Obligation_stat_Count prn
	ON Org.id=prn.orgid and prn.YR=rel.Relevant_year and prn.subsidiaryid is null and cd.subsidiary_id is null
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
Prn_Outstanding;