CREATE VIEW [dbo].[v_enrolment_history]
AS select row_number() over(order by u.UserId, B.LastUpdatedOn desc) as his_id
	,u.UserId, poc.OrganisationId, poc.PersonId, B.EID, B.CreatedOn, B.LastUpdatedOn, B.ServiceRoleId, B.ConnectionId , sr.[Key]  as Service_Role, sr.Name as Service_Name
	from 
	(
		SELECT distinct JSON_VALUE(val, '$.Id') AS EID /* get distinct values*/
			,JSON_VALUE(val, '$.CreatedOn') as CreatedOn
			,JSON_VALUE(val, '$.LastUpdatedOn') as LastUpdatedOn
			,JSON_VALUE(val, '$.ServiceRoleId') as ServiceRoleId
			,JSON_VALUE(val, '$.ConnectionId') as ConnectionId
		FROM 
		(
			select OldValues as val from [rpd].[AuditLogs] where Entity = 'Enrolment' 
			union 
			select NewValues as val  from [rpd].[AuditLogs] where Entity = 'Enrolment' 
		) A
		where val is not null
	) B 
		inner join rpd.PersonOrganisationConnections poc on poc.id = B.ConnectionId
		inner join rpd.Persons p on p.id = poc.PersonId
		inner join rpd.Users u on u.id = p.UserId
		inner join rpd.ServiceRoles sr on sr.Id = B.ServiceRoleId;