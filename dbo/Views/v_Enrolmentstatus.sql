CREATE VIEW [dbo].[v_Enrolmentstatus] AS select EnrolmentID,Regulator_Status,Regulator_Rejection_Comments,Decision_Date,Regulator_User_Name
from (
select e.id EnrolmentID
--,e.EnrolmentStatusId EnrolmentStatusId
,es.Name Regulator_Status
--,rc.EnrolmentId
--,rc.PersonId
,rc.RejectedComments Regulator_Rejection_Comments
--,rc.CreatedOn
--,e.LastUpdatedOn
,case when rc.CreatedOn > e.LastUpdatedOn then rc.CreatedOn else e.LastUpdatedOn end as Decision_Date
--,p.FirstName
--,p.LastName
,ISNULL(p.FirstName,'') +' '+ ISNULL(p.LastName,'') Regulator_User_Name
,row_number() over(partition by rc.EnrolmentId  order by rc.LastUpdatedOn desc) as rn
from [rpd].[Enrolments] e
left outer join 
[rpd].[EnrolmentStatuses] es
on e.[EnrolmentStatusId]=es.id
left outer join 
[rpd].[RegulatorComments] rc
on rc.[EnrolmentId]=e.id
left outer join [rpd].[Persons] p 
on rc.PersonId=p.id and p.isdeleted=0
where e.EnrolmentStatusId=4 ) a
where a.rn=1 

union

select e.Id EnrolmentID
--,e.EnrolmentStatusId EnrolmentStatusId
,es.Name as Regulator_Status
,'' Regulator_Rejection_Comments
,e.LastUpdatedOn Decision_Date
--,e.ConnectionId
--,poc.PersonId
--,p.FirstName FirstName
--,p.LastName LastName
,ISNULL(p.FirstName,'') +' '+ ISNULL(p.LastName,'')  Regulator_User_Name

from rpd.enrolments e
left outer join 
[rpd].[EnrolmentStatuses] es
on e.[EnrolmentStatusId]=es.id
left outer join [rpd].[PersonOrganisationConnections] poc on e.ConnectionId = poc.Id
left outer join [rpd].[Persons] p on poc.PersonId=p.Id and p.isdeleted=0
where e.EnrolmentStatusId<>4;