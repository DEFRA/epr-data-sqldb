CREATE VIEW [dbo].[v_Enrolmentstatus] AS SELECT EnrolmentID
	,[Status]
	,Regulator_Rejection_Comments
	,Decision_Date
	,Regulator_User_Name
FROM (
	SELECT e.id EnrolmentID
		,es.Name [Status]
		,rc.RejectedComments Regulator_Rejection_Comments
		,CASE 
			WHEN rc.CreatedOn > e.LastUpdatedOn THEN rc.CreatedOn
			ELSE e.LastUpdatedOn
			END AS Decision_Date
		,ISNULL(p.FirstName, '') + ' ' + ISNULL(p.LastName, '') Regulator_User_Name
		,row_number() OVER (
			PARTITION BY rc.EnrolmentId ORDER BY rc.LastUpdatedOn DESC
			) AS rn
	FROM [rpd].[Enrolments] e
	LEFT JOIN [rpd].[EnrolmentStatuses] es ON e.[EnrolmentStatusId] = es.id
	LEFT JOIN [rpd].[RegulatorComments] rc ON rc.[EnrolmentId] = e.id
	LEFT JOIN [rpd].[Persons] p ON rc.PersonId = p.id AND p.isdeleted = 0
	WHERE e.EnrolmentStatusId = 4
	) a
WHERE a.rn = 1

UNION

SELECT e.Id EnrolmentID
	,es.Name AS [Status]
	,'' Regulator_Rejection_Comments
	,e.LastUpdatedOn Decision_Date
	,CASE 
		WHEN es.id = 3
			THEN ISNULL(Auditlogs.FirstName, '') + ' ' + ISNULL(Auditlogs.LastName, '')
		ELSE ''
		END Regulator_User_Name
FROM [rpd].[Enrolments] e
LEFT JOIN [rpd].[EnrolmentStatuses] es ON e.[EnrolmentStatusId] = es.id
LEFT JOIN (
	SELECT p.[FirstName]
		,p.[LastName]
		,a.[ExternalId]
	FROM (
		SELECT *
			,Row_Number() OVER (
				PARTITION BY organisationid ORDER BY [Timestamp] DESC
				) AS RN
		FROM [rpd].[AuditLogs]
		WHERE Entity = 'Enrolment' and (userid is not null or organisationid is not null)  -- remove all after and
		) a
	LEFT JOIN [rpd].[Users] u ON u.userid = a.userid and  u.isdeleted=0
	LEFT JOIN rpd.persons p ON p.userid = u.id and p.isdeleted = 0
	WHERE RN = 1
	) Auditlogs ON Auditlogs.[ExternalId] = e.[ExternalId]
WHERE e.EnrolmentStatusId <> 4;