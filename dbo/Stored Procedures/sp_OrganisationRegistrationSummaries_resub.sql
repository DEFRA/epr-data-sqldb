﻿CREATE PROC [dbo].[sp_OrganisationRegistrationSummaries_resub] AS
BEGIN
	SET NOCOUNT ON;

	WITH 
	SubmissionEventsCTE as (
		select * from (
			SELECT
				decisions.SubmissionId,
				decisions.SubmissionEventId,
				decisions.Created AS DecisionDate,
				decisions.Comments AS Comment,
				decisions.UserId,
				decisions.Type,
				decisions.FileId,
				CASE 
					WHEN decisions.Type = 'RegulatorRegistrationDecision' AND decisions.FileId IS NULL THEN
						CASE 
							WHEN LTRIM(RTRIM(decisions.Decision)) = 'Accepted' THEN 'Granted'
							WHEN LTRIM(RTRIM(decisions.Decision)) = 'Rejected' THEN 'Refused'
							WHEN decisions.Decision IS NULL THEN 'Pending'
							ELSE decisions.Decision
						END
					ELSE NULL
				END AS SubmissionStatus,
				CASE 
					WHEN decisions.Type = 'RegulatorRegistrationDecision' AND decisions.FileId IS NOT NULL THEN
						CASE 
							WHEN decisions.Decision IS NULL THEN 'Pending'
							ELSE decisions.Decision
						END
					ELSE NULL
				END AS ResubmissionStatus,
				CASE WHEN decisions.Type = 'RegulatorRegistrationDecision' AND FileId IS NULL THEN 1 ELSE 0 END AS IsRegulatorDecision,
				CASE WHEN decisions.Type = 'RegulatorRegistrationDecision' AND FileId IS NOT NULL THEN 1 ELSE 0 END AS IsRegulatorResubmissionDecision,
				CASE WHEN decisions.Type = 'Submitted' THEN 1 ELSE 0 END AS UploadEvent,
				CASE 
					WHEN decisions.Type = 'RegistrationApplicationSubmitted' AND ISNULL(decisions.IsResubmission,0) = 0 THEN 1 ELSE 0
				END AS IsProducerSubmission,
				CASE 
					WHEN decisions.Type = 'RegistrationApplicationSubmitted' AND ISNULL(decisions.IsResubmission,0) = 1 THEN 1 ELSE 0
				END AS IsProducerResubmission,
				decisions.RegistrationReferenceNumber,
				decisions.DecisionDate AS StatusPendingDate,
				ROW_NUMBER() OVER (PARTITION BY decisions.SubmissionId, decisions.SubmissionEventId ORDER BY decisions.Created DESC) AS RowNum
			FROM rpd.SubmissionEvents AS decisions
			WHERE decisions.Type IN ('RegistrationApplicationSubmitted', 'RegulatorRegistrationDecision', 'Submitted')
		) t where t.RowNum = 1
	)
	,LatestUploadsCTE AS (
		SELECT *, ROW_NUMBER() OVER (PARTITION BY SubmissionId ORDER BY DecisionDate DESC) AS UploadOrder
		FROM SubmissionEventsCTE
		WHERE UploadEvent = 1
	)
	,ReconciledSubmissionEvents AS (
		SELECT
			f.SubmissionId,
			f.SubmissionEventId,
			f.DecisionDate,
			f.Comment,
			f.UserId,
			f.Type,
			(SELECT TOP 1 l.FileId FROM LatestUploadsCTE l WHERE l.SubmissionId = f.SubmissionId AND l.DecisionDate < f.DecisionDate ORDER BY l.UploadOrder ASC) AS FileId,
			f.RegistrationReferenceNumber,
			f.SubmissionStatus,
			f.ResubmissionStatus,
			f.StatusPendingDate,
			f.IsRegulatorDecision,
			f.IsRegulatorResubmissionDecision,
			f.IsProducerSubmission,
			f.IsProducerResubmission,
			f.UploadEvent
		FROM SubmissionEventsCTE f
		WHERE f.IsProducerSubmission = 1 OR f.IsProducerResubmission = 1 OR f.IsRegulatorDecision = 1 OR f.IsRegulatorResubmissionDecision = 1
	)
	,InitialSubmissionCTE AS (
		SELECT * FROM (
			SELECT *, ROW_NUMBER() OVER (PARTITION BY SubmissionId ORDER BY DecisionDate DESC) AS RowNum
			FROM ReconciledSubmissionEvents
			WHERE IsProducerSubmission = 1 AND IsProducerResubmission = 0
		) t WHERE RowNum = 1
	)
	,InitialDecisionCTE AS (
		SELECT * FROM (
			SELECT *, ROW_NUMBER() OVER (PARTITION BY SubmissionId ORDER BY DecisionDate DESC) AS RowNum
			FROM ReconciledSubmissionEvents
			WHERE IsRegulatorDecision = 1 AND IsRegulatorResubmissionDecision = 0
		) t WHERE RowNum = 1
	)
	,ResubmissionCTE AS (
		SELECT * FROM (
			SELECT *, ROW_NUMBER() OVER (PARTITION BY SubmissionId ORDER BY DecisionDate DESC) AS RowNum
			FROM ReconciledSubmissionEvents
			WHERE IsProducerResubmission = 1
		) t WHERE RowNum = 1
	)
	,ResubmissionDecisionCTE AS (
		SELECT * FROM (
			SELECT *, ROW_NUMBER() OVER (PARTITION BY SubmissionId ORDER BY DecisionDate DESC) AS RowNum
			FROM ReconciledSubmissionEvents
			WHERE IsRegulatorResubmissionDecision = 1
		) t WHERE RowNum = 1
	)
	,SubmissionStatusCTE AS (
		SELECT
			s.SubmissionId,
			CASE WHEN s.DecisionDate > id.DecisionDate THEN 'Pending'
					  ELSE COALESCE(id.SubmissionStatus, 'Pending') 
				 END AS SubmissionStatus,
			CASE
				WHEN r.SubmissionEventId IS NOT NULL AND rd.SubmissionEventId IS NOT NULL THEN rd.ResubmissionStatus
				WHEN r.SubmissionEventId IS NOT NULL THEN 'Pending'
				ELSE NULL
			END AS ResubmissionStatus,
			s.DecisionDate as SubmissionDate,
			s.SubmissionEventId as ProducerSubmissionEventId,
			id.DecisionDate AS RegistrationDate,
			id.SubmissionEventId AS SubmissionDecisionEventId,
			id.StatusPendingDate,
			rd.DecisionDate AS ResubmissionDecisionDate,
			rd.SubmissionEventId AS ResubmissionDecisionEventId,
			r.DecisionDate as ResubmissionDate, 
			r.SubmissionEventId AS ResubmissionEventId,
			COALESCE(r.FileId, s.FileId) AS FileId,
			COALESCE(r.UserId, s.UserId) AS ProducerUserId,
			COALESCE(rd.UserId, id.UserId) AS RegulatorUserId,
			id.RegistrationReferenceNumber
		FROM InitialSubmissionCTE s
		LEFT JOIN InitialDecisionCTE id ON id.SubmissionId = s.SubmissionId
		LEFT JOIN ResubmissionCTE r ON r.SubmissionId = s.SubmissionId
		LEFT JOIN ResubmissionDecisionCTE rd ON rd.SubmissionId = r.SubmissionId AND rd.FileId = r.FileId
	)
	,LatestOrganisationRegistrationSubmissionsCTE
    AS
    (
        SELECT
            a.*
        FROM
            (
            SELECT
                s.SubmissionId
                ,o.Name AS OrganisationName
                ,org.UploadOrgName as UploadedOrganisationName
				,o.ReferenceNumber
				,o.Id as OrganisationInternalId
				,o.ExternalId as OrganisationId
                ,s.AppReferenceNumber AS ApplicationReferenceNumber
                ,CASE 
					WHEN cs.NationId IS NOT NULL THEN cs.NationId
					ELSE
					CASE UPPER(org.NationCode)
						WHEN 'EN' THEN 1
						WHEN 'NI' THEN 2
						WHEN 'SC' THEN 3
						WHEN 'WS' THEN 4
						WHEN 'WA' THEN 4
					 END
				 END AS NationId
                ,CASE
					WHEN cs.NationId IS NOT NULL THEN
						CASE cs.NationId
							WHEN 1 THEN 'GB-ENG'
							WHEN 2 THEN 'GB-NIR'
							WHEN 3 THEN 'GB-SCT'
							WHEN 4 THEN 'GB-WLS'
						END
					ELSE
					CASE UPPER(org.NationCode)
						WHEN 'EN' THEN 'GB-ENG'
						WHEN 'NI' THEN 'GB-NIR'
						WHEN 'SC' THEN 'GB-SCT'
						WHEN 'WS' THEN 'GB-WLS'
						WHEN 'WA' THEN 'GB-WLS'
					END
				 END AS NationCode
                ,ss.RegistrationReferenceNumber
				,ss.RegistrationDate
				,ss.SubmissionDate as SubmittedDateTime
                ,CASE WHEN ss.ResubmissionDate IS NOT NULL 
						  THEN 1
						  ELSE 0
				 END as IsResubmission
				,ss.ResubmissionStatus
				,ss.SubmissionStatus
				,ss.ResubmissionDecisionDate
				,ss.StatusPendingDate
				,'' as ProducerComment
				,s.SubmissionPeriod
                ,CAST(
                    SUBSTRING(
                        s.SubmissionPeriod,
                        PATINDEX('%[0-9][0-9][0-9][0-9]%', s.SubmissionPeriod),
                        4
                    ) AS INT
                 ) AS RelevantYear
				,CASE UPPER(TRIM(org.organisationsize))
					WHEN 'S' THEN 'Small'
					WHEN 'L' THEN 'Large'
				 END 
				 as ProducerSize
				,CASE WHEN s.ComplianceSchemeId is not null THEN 1 ELSE 0 END 
				 as IsComplianceScheme
				,ss.RegulatorUserId
				,ss.ProducerSubmissionEventId
				,ss.SubmissionDecisionEventId as RegulatorGrantedEventId
				,ss.ResubmissionDecisionEventId as ResubmissionDecisionEventId
				,ss.ResubmissionEventId as ResubmissionEventId
            	,ss.ResubmissionDate
				,s.OrganisationId AS InternalOrgId
                ,s.SubmissionType
                ,s.UserId AS SubmittedUserId
                ,CAST(
                    CASE
                        WHEN ss.SubmissionDate > DATEFROMPARTS(CONVERT( int, SUBSTRING(
                                        s.SubmissionPeriod,
                                        PATINDEX('%[0-9][0-9][0-9][0-9]', s.SubmissionPeriod),
                                        4
                                    )),4,1) THEN 1
                        ELSE 0
                    END AS BIT
                ) AS IsLateSubmission
				,ROW_NUMBER() OVER (
                    PARTITION BY s.OrganisationId,
                    s.SubmissionPeriod, s.ComplianceSchemeId
                    ORDER BY s.Created DESC, s.load_ts DESC
                ) AS RowNum
            FROM
                [rpd].[Submissions] AS s
                INNER JOIN [dbo].[v_UploadedRegistrationDataBySubmissionPeriod] org 
					ON org.SubmittingExternalId = s.OrganisationId 
					and org.SubmissionPeriod = s.SubmissionPeriod
				INNER JOIN [rpd].[Organisations] o on o.ExternalId = s.OrganisationId
				INNER JOIN SubmissionStatusCTE ss on ss.SubmissionId = s.SubmissionId
				LEFT JOIN [rpd].[ComplianceSchemes] cs on cs.ExternalId = s.ComplianceSchemeId 
            WHERE s.AppReferenceNumber IS NOT NULL
                AND s.SubmissionType = 'Registration'
				AND s.IsSubmitted = 1
        ) AS a
        WHERE a.RowNum = 1
    )

   -- SELECT * FROM LatestOrganisationRegistrationSubmissionsCTE
	,AllSubmissionsAndDecisionsAndCommentCTE
    AS
    (
        SELECT DISTINCT
            submissions.SubmissionId
			,submissions.OrganisationId
			,submissions.OrganisationInternalId
            ,submissions.OrganisationName
			,submissions.UploadedOrganisationName
            ,submissions.ReferenceNumber as OrganisationReference
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
            ,submissions.RegistrationDate
			,submissions.IsResubmission
			,submissions.ResubmissionDate
			,submissions.RelevantYear
            ,submissions.SubmissionPeriod
            ,submissions.IsLateSubmission
            ,ISNULL(submissions.SubmissionStatus, 'Pending') as SubmissionStatus
            ,submissions.ResubmissionStatus
			,ResubmissionDecisionDate
			,StatusPendingDate
            ,submissions.NationId
            ,submissions.NationCode
        FROM
            LatestOrganisationRegistrationSubmissionsCTE submissions
		)
    INSERT INTO #TempTable
	SELECT
		DISTINCT *
	FROM
		AllSubmissionsAndDecisionsAndCommentCTE submissions;
	END;