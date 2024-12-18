﻿CREATE VIEW [dbo].[v_OrganisationRegistrationSummaries]
AS WITH
	ProdCommentsRegulatorDecisionsCTE as (
		SELECT
			decisions.SubmissionId
			,decisions.SubmissionEventId
			,decisions.SubmissionDate as DecisionDate
			,decisions.Comments AS Comment
			,decisions.RegistrationReferenceNumber AS RegistrationReferenceNumber
			,CASE
				WHEN LTRIM(RTRIM(decisions.Decision)) = 'Accepted' THEN 'Granted'
				WHEN LTRIM(RTRIM(decisions.Decision)) = 'Rejected' THEN 'Refused'
				WHEN decisions.decision IS NULL THEN 'Pending'
				ELSE decisions.Decision
			END AS SubmissionStatus
			,decisions.DecisionDate AS StatusPendingDate
			,CASE WHEN decisions.Type = 'RegistrationApplicationSubmitted'
				 THEN 1
				 ELSE 0
		     END AS IsProducerComment
			,UserId
			,ROW_NUMBER() OVER (
				PARTITION BY decisions.SubmissionId, decisions.Type
				ORDER BY decisions.Created DESC -- mark latest submissionEvent synced from cosmos
			) AS RowNum
		FROM
			rpd.SubmissionEvents as decisions
		WHERE decisions.Type IN ( 'RegistrationApplicationSubmitted', 'RegulatorRegistrationDecision')		
	)
	,GrantedDecisionsCTE as (
		SELECT *
		FROM ProdCommentsRegulatorDecisionsCTE granteddecision
		WHERE IsProducerComment = 0
				AND SubmissionStatus = 'Granted'
	)
	,LatestOrganisationRegistrationSubmissionsCTE
    AS
    (
        SELECT
            a.*
        FROM
            (
            SELECT
                o.Name AS OrganisationName
                ,org.UploadOrgName as UploadedOrganisationName
				,o.ReferenceNumber
				,o.Id as OrganisationInternalId
				,o.ExternalId as OrganisationId
                ,s.AppReferenceNumber AS ApplicationReferenceNumber
                ,granteddecision.RegistrationReferenceNumber
				,granteddecision.SubmissionStatus
				,granteddecision.DecisionDate as RegulatorDecisionDate
				,granteddecision.UserId as RegulatorUserId
            	,se.DecisionDate as ProducerCommentDate
				,se.Comment as ProducerComment
				,se.SubmissionEventId as ProducerSubmissionEventId
				,granteddecision.SubmissionEventId as RegulatorSubmissionEventId
				,s.SubmissionPeriod
                ,s.SubmissionId
                ,s.OrganisationId AS InternalOrgId
                ,s.Created AS SubmittedDateTime
                ,CASE 
					UPPER(org.NationCode)
					WHEN 'EN' THEN 1
					WHEN 'SC' THEN 3
					WHEN 'WA' THEN 4
					WHEN 'NI' THEN 2
				 END AS NationId
                ,CASE
                    UPPER(org.NationCode)
                    WHEN 'EN' THEN 'GB-ENG'
                    WHEN 'NI' THEN 'GB-NIR'
                    WHEN 'SC' THEN 'GB-SCT'
                    WHEN 'WA' THEN 'GB-WLS'
                END AS NationCode
                ,s.SubmissionType
                ,s.UserId AS SubmittedUserId
                ,CAST(
                    SUBSTRING(
                        s.SubmissionPeriod,
                        PATINDEX('%[0-9][0-9][0-9][0-9]%', s.SubmissionPeriod),
                        4
                    ) AS INT
                ) AS RelevantYear
                ,CAST(
                    CASE
                        WHEN s.Created > DATEFROMPARTS(CONVERT( int, SUBSTRING(
                                        s.SubmissionPeriod,
                                        PATINDEX('%[0-9][0-9][0-9][0-9]', s.SubmissionPeriod),
                                        4
                                    )),4,1) THEN 1
                        ELSE 0
                    END AS BIT
                ) AS IsLateSubmission
				,CASE UPPER(TRIM(org.organisationsize))
					WHEN 'S' THEN 'Small'
					WHEN 'L' THEN 'Large'
				END as ProducerSize
				,o.IsComplianceScheme
                ,ROW_NUMBER() OVER (
                    PARTITION BY s.OrganisationId,
                    s.SubmissionPeriod
                    ORDER BY s.load_ts DESC -- mark latest submission synced from cosmos
                ) AS RowNum
            FROM
                [rpd].[Submissions] AS s
                INNER JOIN [dbo].[v_UploadedRegistrationDataBySubmissionPeriod] org ON org.SubmittingExternalId = s.OrganisationId and org.SubmissionPeriod = s.SubmissionPeriod
				INNER JOIN [rpd].[Organisations] o on o.ExternalId = s.OrganisationId
				LEFT JOIN GrantedDecisionsCTE granteddecision on granteddecision.SubmissionId = s.SubmissionId 
				INNER JOIN ProdCommentsRegulatorDecisionsCTE se on se.SubmissionId = s.SubmissionId and se.IsProducerComment = 1
            WHERE s.AppReferenceNumber IS NOT NULL
                AND s.SubmissionType = 'Registration'
				ANd s.IsSubmitted = 1
        ) AS a
        WHERE a.RowNum = 1
    )
	,LatestRelatedRegulatorDecisionsCTE AS
	(
		select b.SubmissionId
			,b.SubmissionEventId
			,b.DecisionDate as RegulatorDecisionDate
			,b.Comment as RegulatorComment
			,b.RegistrationReferenceNumber
			,b.SubmissionStatus
			,b.StatusPendingDate
			,b.UserId
		from ProdCommentsRegulatorDecisionsCTE as b
		where b.IsProducerComment = 0 and b.RowNum = 1
	)
	,AllRelatedProducerCommentEventsCTE
    AS
    (
        SELECT
            CONVERT(uniqueidentifier, c.SubmissionId) as SubmissionId
			,c.SubmissionEventId
			,c.Comment AS ProducerComment
			,c.DecisionDate AS ProducerCommentDate
        FROM
            (
			SELECT TOP 1
                ProdCommentsRegulatorDecisionsCTE.SubmissionEventId
				,ProdCommentsRegulatorDecisionsCTE.SubmissionId
				,ProdCommentsRegulatorDecisionsCTE.Comment 
				,ProdCommentsRegulatorDecisionsCTE.DecisionDate 
            FROM LatestOrganisationRegistrationSubmissionsCTE 
					LEFT JOIN ProdCommentsRegulatorDecisionsCTE 
					ON ProdCommentsRegulatorDecisionsCTE.IsProducerComment = 1 
					   AND ProdCommentsRegulatorDecisionsCTE.SubmissionId = LatestOrganisationRegistrationSubmissionsCTE.SubmissionId 
			ORDER BY ProdCommentsRegulatorDecisionsCTE.DecisionDate desc
		) AS c
    )
	,AllSubmissionsAndDecisionsAndCommentCTE
    AS
    (
        SELECT
            DISTINCT
            submissions.SubmissionId
            ,submissions.OrganisationId
			,submissions.OrganisationInternalId
            ,submissions.OrganisationName
			,submissions.UploadedOrganisationName
            ,submissions.ReferenceNumber as OrganisationReferenceNumber
            ,submissions.SubmittedUserId
            ,submissions.IsComplianceScheme
			,CASE 
				WHEN submissions.IsComplianceScheme = 1 THEN 'Compliance'
				ELSE submissions.ProducerSize
			END AS OrganisationType
            ,submissions.ProducerSize
            ,submissions.ApplicationReferenceNumber
			,submissions.RegistrationReferenceNumber
            ,submissions.SubmittedDateTime
            ,submissions.RelevantYear
            ,submissions.SubmissionPeriod
            ,submissions.IsLateSubmission
            ,ISNULL(decisions.SubmissionStatus, 'Pending') as SubmissionStatus
            ,decisions.StatusPendingDate
            ,decisions.RegulatorDecisionDate
			,decisions.UserId as RegulatorUserId
            ,ISNULL(submissions.ProducerCommentDate, producercomments.ProducerCommentDate) as ProducerCommentDate
            ,ISNULL(submissions.ProducerSubmissionEventId, producercomments.SubmissionEventId) as ProducerSubmissionEventId
			,ISNULL(submissions.RegulatorSubmissionEventId, decisions.SubmissionEventId) AS RegulatorSubmissionEventId
            ,submissions.NationId
            ,submissions.NationCode
        FROM
            LatestOrganisationRegistrationSubmissionsCTE submissions
            LEFT JOIN LatestRelatedRegulatorDecisionsCTE decisions
            ON decisions.SubmissionId = submissions.SubmissionId
            LEFT JOIN AllRelatedProducerCommentEventsCTE producercomments
            ON producercomments.SubmissionId = submissions.SubmissionId
    )
SELECT
    DISTINCT *
FROM
    AllSubmissionsAndDecisionsAndCommentCTE submissions;