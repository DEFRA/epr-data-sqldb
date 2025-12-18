CREATE VIEW [dbo].[v_PRN_Recycling_Obligation_stat_Count]
AS with Direct_prod AS  
(select id as orgid,
        null subsidaryid
  from [rpd].[Organisations] 
 where IscomplianceScheme =0
   and id not in ( select c.FromOrganisationid from rpd.complianceSchemes a 
                                           INNER JOIN rpd.selectedschemes b ON a.id =b.ComplianceSchemeid and b.Isdeleted=0 
                                           INNER JOIN [rpd].[OrganisationsConnections] c ON b.id =c.id  ) 
   and id not in ( SELECT a.fromorganisationId as orgid   FROM [rpd].[OrganisationsConnections] a JOIN rpd.organisations b  ON a.ToOrganisationId =b.id and b.Isdeleted=0 )
   )
--
 ,DP_Subsidary AS
(SELECT DISTINCT orgr.firstOrganisationId  as orgid,
                 orgr.SecondOrganisationId as subsidaryid
 FROM rpd.ObligationCalculations oc 
INNER JOIN rpd.organisations o ON o.ExternalId = oc.organisationid
INNER JOIN rpd.OrganisationRelationships orgr ON orgr.FirstOrganisationId = o.Id AND RelationToDate IS NULL		
INNER JOIN rpd.organisations o2 ON o2.id = orgr.SecondOrganisationId
INNER JOIN rpd.ObligationCalculations oc2 ON oc2.OrganisationId = o2.ExternalId 
and orgr.firstOrganisationId not in 
( SELECT a.fromorganisationId as orgid
         FROM [rpd].[OrganisationsConnections] a JOIN rpd.organisations b
    ON a.ToOrganisationId =b.id 
	and b.Isdeleted=0 )
	)
--
,DP_final_org AS (  
Select distinct a.orgid as Orgid,
       b.subsidaryid as Subid
  from DP_Subsidary b RIGHT JOIN  Direct_prod a On b.orgid =a.orgid
Union
select 
       b.orgid,
       b.subsidaryid
  from DP_Subsidary b LEFT JOIN Direct_prod a ON b.orgid =a.orgid
)
---
,cal_orgidsum AS
(
Select Distinct 
       b.id as orgid,
       SUM(a.MaterialObligationValue) as ordsum ,
      a.year as YR
 from rpd.ObligationCalculations a JOIN [rpd].[Organisations] b 
   ON  a.OrganisationId=b.externalid --JOIN DP_final_org c    ON b.id =c.Orgid
  and b.Isdeleted=0 
  and b.IscomplianceScheme =0
  group by b.id,a.year 
)
, cal_subidsum as ( 
Select Distinct 
         c.orgid as orgid,                
		 SUM(a.MaterialObligationValue) as subsum,
		 a.year as YR
    from rpd.ObligationCalculations a JOIN [rpd].[Organisations] b 
      ON a.OrganisationId=b.externalid JOIN DP_final_org c ON b.id =c.subid
     and b.Isdeleted=0 
     and IscomplianceScheme =0
 group by c.orgid,a.year
)
--
,Allsum AS(
select  distinct a.orgid as Orgid,
       c.YR as YR,  
       (ISNULL(c.ordsum,0)+ ISNULL(b.subsum,0)) as total
 from DP_final_org a    JOIN cal_orgidsum c 
   ON  a.orgid = c.orgid left JOIN cal_subidsum b
   ON a.orgid =b.orgid Or c.orgid = a.subid 
)
,RankedRows AS (
    SELECT 
        distinct d.orgid,
        d.subid,
        ROW_NUMBER() OVER (PARTITION BY d.orgid ORDER BY d.subid) AS rn
    FROM DP_final_org d
)
, Recycling_obligation AS(
SELECT 
    Distinct r.orgid as Orgid,
	null   Subsidiaryid,
	s.YR,
    s.total AS Recyling_Obligation
FROM RankedRows r
JOIN AllSum s ON r.orgid = s.orgid
UNION 
SELECT 
    r.orgid as Orgid,
	r.subid As  Subsidiaryid,
	s.YR,
    0 AS Recyling_Obligation
FROM RankedRows r
JOIN AllSum s ON r.orgid = s.orgid 
),
-- Process End for direct Prod

--Calculatin Tonnage values based on PRN Status 
Prn_Awaiting_Acceptance_count  
AS(
  Select c.Id ,
         sum(a.TonnageValue) as PrnAwaitingStatus
    from rpd.prn a Join rpd.PrnStatus b  On a.prnStatusId=b.id
    Join [rpd].[Organisations] c On a.organisationid=c.externalid
    where a.prnstatusid =4 
	group by c.id
 ),
-- 
Prn_Total_Accepted_count 
AS(
   Select 
         c.Id ,
         sum(a.TonnageValue) as PrnTotalAcceptedStatus
   from rpd.prn a Join rpd.PrnStatus b  On a.prnStatusId=b.id
   Join [rpd].[Organisations] c On a.organisationid=c.externalid
   where a.prnstatusid =1 --StatusDescription='Prn Accepted' 
    group by c.id
 ),
 --- Calculate obligation for the Indirect Memeber
Compliance_scheme_members_ordid  AS(
 SELECT distinct
       a.fromorganisationId as orgid
       --null --c.SecondOrganisationId as Subsidiaryid 
  FROM [rpd].[OrganisationsConnections] a JOIN rpd.organisations b
    ON a.ToOrganisationId =b.id LEFT OUTER JOIN  rpd.organisationRelationships c 
	ON c.FirstOrganisationId = a.fromorganisationId
	and b.Isdeleted=0
 )
 , Compliance_scheme_members_Subid  AS(
 SELECT distinct
        a.fromorganisationId as orgid, 
        c.SecondOrganisationId as Subsidiaryid 
  FROM [rpd].[OrganisationsConnections] a JOIN rpd.organisations b
    ON a.ToOrganisationId =b.id LEFT OUTER JOIN  rpd.organisationRelationships c 
	ON c.FirstOrganisationId = a.fromorganisationId
	and b.Isdeleted=0
	 )
--
,CSM_MaterialObligation AS(
 select b.id as Orgid,
 	    ISNULL(SUM(a.MaterialObligationValue),0) as ord_obligation,
        a.year as YR
    from rpd.ObligationCalculations a JOIN [rpd].[Organisations] b 
	 ON  a.OrganisationId=b.externalid 
	 JOIN Compliance_scheme_members_ordid c ON b.id =c.orgid
    and b.Isdeleted=0 
    and b.IscomplianceScheme =0
	group by b.id, a.year
)
--
,CSMsub_MaterialObligation AS(
 select c.orgid as orgid,
 	   ISNULL(SUM(a.MaterialObligationValue),0) as sub_obligation,
        a.year as YR
    from rpd.ObligationCalculations a JOIN [rpd].[Organisations] b 
	 ON  a.OrganisationId=b.externalid JOIN Compliance_scheme_members_Subid c ON b.id =c.Subsidiaryid
    and b.Isdeleted=0 
    and b.IscomplianceScheme =0
	group by c.Orgid , a.year
)
--
,finalSC_member AS (
select Distinct a.orgid as Orgid,
	   null   Subsidiaryid,
	   ISNULL(b.YR,c.YR) as YR,
      ISNULL(b.ord_obligation,0) +	  ISNULL(c.sub_obligation,0) AS Recyling_Obligation
from Compliance_scheme_members_ordid a LEFT JOIN CSM_MaterialObligation b ON a.orgid =b.orgid
LEFT JoIN CSMsub_MaterialObligation c  ON a.orgid =c.orgid
Union
select a.orgid as Orgid,
	   a.Subsidiaryid,
	   b.YR,
	   0 AS Recyling_Obligation
from Compliance_scheme_members_Subid a LEFT JOIN CSMsub_MaterialObligation b ON a.orgid =b.orgid
)

,CSM_RANK AS ( 
select 
       distinct s.orgid ,
	   s.Subsidiaryid,
	   s.YR,
       s.Recyling_Obligation,
	   ROW_NUMBER() OVER (PARTITION BY s.orgid ORDER BY s.Subsidiaryid,s.Recyling_Obligation desc) AS rn
from  finalSC_member s
) 
-- Compliance Scheme - indirect Producer and Subsidaries
, ComplianceScheme
AS 
( 
  select  distinct toOrganisationId As  Orgid,
          c.fromOrganisationId As Subsidiaryid
   from [rpd].[Organisations] b   JOIN [rpd].[OrganisationsConnections] c  ON b.id =c.fromOrganisationid
  where c.toOrganisationId in 
  (
   select c.TOOrganisationid 
    from rpd.complianceSchemes a Inner JOin rpd.selectedschemes b
      on a.id =b.ComplianceSchemeid 
     and b.Isdeleted=0 Inner Join [rpd].[OrganisationsConnections] c 
      on b.id =c.id and c.isdeleted =0
   ) 
   and c.isdeleted =0 and b.isdeleted =0
    )
--
, CS_sub AS(
  SELECT DISTINCT b.Orgid as Orgid,
                 orgr.SecondOrganisationId as subsidaryid
 FROM  rpd.OrganisationRelationships orgr 	
INNER JOIN rpd.organisations o2 ON o2.id = orgr.SecondOrganisationId
INNER JOIN rpd.organisations o ON  orgr.FirstOrganisationId = o.Id AND RelationToDate IS NULL	
INNER JOIN ComplianceScheme b ON orgr.FirstOrganisationId =b.Subsidiaryid
) 
--

,CS_Subsum AS ( 
Select Distinct 
      c.orgid as orgid,
      SUM(a.MaterialObligationValue) as Mobligation_Cssubsum ,
	  a.year as YR
 from rpd.ObligationCalculations a JOIN [rpd].[Organisations] b 
   ON a.OrganisationId=b.externalid JOIN CS_sub c    ON b.id =c.subsidaryid
  and b.Isdeleted=0 
  and b.IscomplianceScheme =0
 group by c.orgid,a.year 
)
--
,CS_Orgid AS ( 
Select Distinct 
      b.id as orgid,
      SUM(a.MaterialObligationValue) as ordsum ,
	  a.year as YR
 from rpd.ObligationCalculations a JOIN [rpd].[Organisations] b 
   ON a.OrganisationId=b.externalid JOIN ComplianceScheme c    ON b.id =c.Orgid
  and b.Isdeleted=0 
  and b.IscomplianceScheme =0
 group by b.id,a.year 
) 
,CS_subid AS ( 
Select Distinct 
       c.Orgid as orgid,
       SUM(a.MaterialObligationValue) as subsum ,
	    a.year as YR
 from rpd.ObligationCalculations a JOIN [rpd].[Organisations] b 
   ON  a.OrganisationId=b.externalid JOIN ComplianceScheme c    ON b.id =c.Subsidiaryid
  and b.Isdeleted=0 
  and b.IscomplianceScheme =0
 group by c.Orgid,a.year 
) 
--
,ComplianceScheme_rank AS ( 
Select d.Orgid,
       null Subsidiaryid,
	   b.YR,
	   ISNULL(b.subsum,0) +ISNULL(a.Mobligation_Cssubsum,0)+
	  ISNULL((select a.ordsum from CS_Orgid a where a.orgid =d.Orgid),0) AS Recy_obligation
from CS_subid b LEFT JOIN ComplianceScheme d ON b.orgid =d.orgid
LEFT JOIN CS_Subsum a On d.orgid =a.orgid
UNION
Select d.Orgid,
       d.Subsidiaryid,
	   b.YR,
	   0 AS Recy_obligation
from CS_subid b LEFT JOIN ComplianceScheme d ON b.orgid =d.orgid
)
--
,CS_awaitng_status_sum AS ( 
 Select c.Id ,
         sum(a.TonnageValue) as PrnAwaitingStatus
    from rpd.prn a Join rpd.PrnStatus b  On a.prnStatusId=b.id
    Join [rpd].[Organisations] c On a.organisationid=c.externalid
	JOIN CS_sub d ON c.id =d.orgid OR  c.id =d.subsidaryid
	JOIN ComplianceScheme e ON c.id = e.orgid OR c.id =e.Subsidiaryid
    where a.prnstatusid =4 and c.isdeleted =0 
	group by c.id 
)
--
,CS_accepted_status_sum AS (
   Select 
         c.Id ,
         sum(a.TonnageValue) as PrnTotalAcceptedStatus
   from rpd.prn a Join rpd.PrnStatus b  On a.prnStatusId=b.id
   Join [rpd].[Organisations] c On a.organisationid=c.externalid
   JOIN CS_sub d ON c.id =d.orgid OR  c.id =d.subsidaryid
   JOIN ComplianceScheme e ON c.id = e.orgid OR c.id =e.Subsidiaryid
    where a.prnstatusid =1 and c.isdeleted =0     --StatusDescription='Prn Accepted' 
    group by c.id
 )
--
,CS_Rank AS(
select s.orgid ,
	   s.Subsidiaryid,
	   s.YR,
       s.Recy_obligation,
	   ISNULL(a.PrnAwaitingStatus,0)   as CS_PRNAWAITING,
	   ISNULL(b.PrnTotalAcceptedStatus,0) as CS_PRNACCEPTED,
	   ISNULL(Recy_obligation,0) - ISNULL(b.PrnTotalAcceptedStatus,0) as CS_PRNOUTSTANDING,
       ROW_NUMBER() OVER (PARTITION BY s.orgid ORDER BY s.Subsidiaryid) AS rn
from 
     ComplianceScheme_rank s
     LEFT OUTER JOIN CS_awaitng_status_sum a  ON s.Orgid =a.Id 
	 LEFT OUTER JOIN  CS_accepted_status_sum b ON s.Orgid =b.Id 
 )
 --
,DP_rank AS (
select 
       'Direct Producer' as ReportType,
       s.orgid ,
	   s.Subsidiaryid,
	   s.YR,
       Recyling_Obligation,
	   ISNULL(a.PrnAwaitingStatus,0) as PRNAWAITING,
	   ISNULL(b.PrnTotalAcceptedStatus,0) as PRNACCEPTED,
	   ISNULL(Recyling_Obligation,0) - ISNULL(b.PrnTotalAcceptedStatus,0) as PRNOUTSTANDING,
       ROW_NUMBER() OVER (PARTITION BY s.orgid ORDER BY s.Subsidiaryid,Recyling_Obligation desc) AS rn
from 
      Recycling_obligation s
     LEFT OUTER JOIN Prn_Awaiting_Acceptance_count a  ON s.Orgid =a.Id OR s.Subsidiaryid =a.id 
     LEFT OUTER JOIN Prn_Total_Accepted_count b ON s.Orgid =b.Id OR s.Subsidiaryid =b.id 
)        
--

,cs_final AS (
select 'Compliance Scheme' as ReportType,
       s.Orgid ,
	   s.Subsidiaryid,
	   s.YR,
       s.Recy_obligation,
	   ( select  ISNULL(CS_PRNAWAITING,0) from CS_rank a where rn =2 and a.orgid =s.orgid  ) PRNAWAITING,
	   ( select ISNULL(CS_PRNACCEPTED,0) from CS_rank b where rn =2 and b.orgid =s.orgid ) PRNACCEPTED,
	   ISNULL( s.Recy_obligation, 0) +  CASE WHEN rn = 1 THEN ISNULL(CS_PRNACCEPTED,0) ELSE 0 END AS PRNOUTSTANDING,
	     ROW_NUMBER() OVER (PARTITION BY s.orgid ORDER BY s.Subsidiaryid) AS rn
from  CS_rank s
)
--
select 
       ReportType,
       orgid ,
	   Subsidiaryid,
	   YR,
       Recyling_Obligation,
	   CASE when rn =1 then PRNAWAITING ELSE 0 END as "TOTAL PRN/PERN Awaiting Acceptance",
	   CASE when rn =1 then PRNACCEPTED ELSE 0 END as "TOTAL PRN/PERN Accepted",
       CASE when rn =1 then PRNOUTSTANDING ELSE 0 END  as "TOTAl PRN/PERN Outstanding"
from DP_rank 
WHERE NOT (
    Subsidiaryid IS NULL and
    ISNULL(PRNAWAITING, 0) = 0 AND 
    ISNULL(PRNACCEPTED, 0) = 0 AND 
    ISNULL(PRNOUTSTANDING, 0) = 0 AND
    ISNULL(Recyling_Obligation, 0) = 0 )
union 
  Select 'Compliance Scheme Member',
          a.Orgid,
		  a.Subsidiaryid,
		  a.YR,
		  a.Recyling_Obligation,
		  NULL,
		  null,
		  null
	from CSM_RANK a 
	WHERE NOT (
    Subsidiaryid IS NULL --AND rn !=1 
	and ISNULL(Recyling_Obligation, 0) = 0 )
Union 
select 
       ReportType,
       orgid ,
	   Subsidiaryid,
	   YR,
       Recy_obligation,
	   CASE when rn =1 then PRNAWAITING ELSE 0 END as "TOTAL PRN/PERN Awaiting Acceptance",
	   CASE when rn =1 then PRNACCEPTED ELSE 0 END as "TOTAL PRN/PERN Accepted",
       CASE when rn =1 then PRNOUTSTANDING ELSE 0 END  as "TOTAl PRN/PERN Outstanding"
from CS_Final 
WHERE NOT (
    Subsidiaryid IS NULL AND rn =1 and
    ISNULL(PRNAWAITING, 0) = 0 AND 
    ISNULL(PRNACCEPTED, 0) = 0 AND 
    ISNULL(PRNOUTSTANDING, 0) = 0 AND
    ISNULL(Recy_obligation, 0) = 0 );