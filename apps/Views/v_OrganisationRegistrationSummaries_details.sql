CREATE VIEW [apps].[v_OrganisationRegistrationSummaries_details]
AS WITH ReconciledCTE AS (
        SELECT se.Created AS DecisionDate,
            se.Comments AS Comment,
            se.Type,
            upload.FileId,
            se.Decision AS Status,
            CASE
                WHEN se.Type = 'RegulatorRegistrationDecision'
                AND upload.IsResubmission = 0 THEN CASE
                    se.Decision
                    WHEN 'Accepted' THEN 'Granted'
                    WHEN 'Rejected' THEN 'Refused'
                    WHEN 'Cancelled' THEN 'Cancelled'
                    ELSE se.Decision
                END
                WHEN se.Type = 'RegulatorRegistrationDecision'
                AND upload.IsResubmission = 1
                AND se.Decision = 'Cancelled' THEN 'Cancelled'
                ELSE NULL
            END AS SubmissionStatus,
            CASE
                WHEN se.Type = 'RegulatorRegistrationDecision'
                AND upload.IsResubmission = 1 THEN CASE
                    se.Decision
                    WHEN 'Accepted' THEN 'Accepted'
                    WHEN 'Rejected' THEN 'Rejected'
                    ELSE NULL
                END
                ELSE NULL
            END AS ResubmissionStatus,
            se.DecisionDate AS StatusPendingDate,
            CASE
                WHEN se.Type = 'RegulatorRegistrationDecision' THEN 1
                ELSE 0
            END AS IsRegulator,
            CASE
                WHEN se.Type = 'RegistrationApplicationSubmitted' THEN 1
                ELSE 0
            END AS IsProducer,
            CASE
                WHEN se.Decision = 'Cancelled' THEN 0
                ELSE upload.IsResubmission
            END AS IsResubmission,
            se.RegistrationReferenceNumber,
            se.SubmissionId,
            se.SubmissionEventId,
            se.UserId,
            CASE 
                WHEN se.Decision = 'Cancelled' THEN se.DecisionDate
                ELSE NULL
            END AS CancellationDate
        FROM rpd.SubmissionEvents AS se
            INNER JOIN rpd.Submissions AS us ON se.SubmissionId = us.SubmissionId
            CROSS APPLY (
                SELECT TOP(1) s.FileId,
                    ISNULL(s.IsResubmission, 0) AS IsResubmission
                FROM rpd.SubmissionEvents AS s
                WHERE s.SubmissionId = se.SubmissionId
                    AND s.Type = 'Submitted'
                    AND s.Created <= se.Created
                ORDER BY s.Created DESC
            ) AS upload
        WHERE se.Type IN (
                'RegistrationApplicationSubmitted',
                'RegulatorRegistrationDecision'
            )
            AND us.AppReferenceNumber IS NOT NULL
            AND us.SubmissionType = 'Registration'
            AND us.SubmissionPeriod like 'January to Dec%'
            AND us.IsSubmitted = 1
--AND se.SubmissionId = 'cbbb1e55-3e41-4f35-a38b-e65f6b2c808a'
    )
    ,Base AS (
        SELECT
            SubmissionId,
            SubmissionEventId,
            DecisionDate,
            IsProducer,
            IsRegulator,
            IsResubmission,
            SubmissionStatus,
            ResubmissionStatus,
            FileId,
            Comment,
            StatusPendingDate,
            RegistrationReferenceNumber,
            UserId,
            CancellationDate,

            -- latest producer/no-resubmission
            (
                ROW_NUMBER() OVER (
                PARTITION BY SubmissionId
                ORDER BY 
                    CASE WHEN IsProducer = 1 AND IsResubmission = 0 
                        THEN DecisionDate 
                    END DESC
                )
                * CASE WHEN IsProducer = 1 AND IsResubmission = 0 THEN 1 ELSE 0 END
            ) AS ProdLatest,

            -- **first** producer/no-resub (earliest real date first; sentinel pushes non-producers to the back)
            (
                ROW_NUMBER() OVER (
                PARTITION BY SubmissionId
                ORDER BY 
                    CASE 
                    WHEN IsProducer = 1 AND IsResubmission = 0 
                    THEN DecisionDate 
                    ELSE CAST('9999-12-31' AS datetime2) 
                    END ASC
                )
                * CASE WHEN IsProducer = 1 AND IsResubmission = 0 THEN 1 ELSE 0 END
            ) AS ProdFirst,

            -- latest regulator/no-resub (masked)
            (
                ROW_NUMBER() OVER (
                PARTITION BY SubmissionId
                ORDER BY 
                    CASE WHEN IsRegulator = 1 AND IsResubmission = 0 
                        THEN DecisionDate 
                    END DESC
                )
                * CASE WHEN IsRegulator = 1 AND IsResubmission = 0 THEN 1 ELSE 0 END
            ) AS RegLatestNoResub,
            -- Granted Decisions
            (
                ROW_NUMBER() OVER (
                PARTITION BY SubmissionId
                ORDER BY
                    -- grants first…
                    CASE 
                    WHEN IsRegulator = 1 
                    AND IsResubmission = 0 
                    AND SubmissionStatus = 'Granted' 
                    THEN 0 
                    ELSE 1 
                    END,
                    -- …then by date
                    DecisionDate ASC
                )
                * CASE 
                    WHEN IsRegulator = 1 
                    AND IsResubmission = 0 
                    AND SubmissionStatus = 'Granted' 
                    THEN 1 
                    ELSE 0 
                END
            ) AS RegFirstGrant,
            -- latest producer resubmission (masked)
            (
                ROW_NUMBER() OVER (
                PARTITION BY SubmissionId
                ORDER BY 
                    CASE WHEN IsProducer = 1 AND IsResubmission = 1 
                        THEN DecisionDate 
                    END DESC
                )
                * CASE WHEN IsProducer = 1 AND IsResubmission = 1 THEN 1 ELSE 0 END
            ) AS ResubLatest,

            -- latest regulator resubmission decision (masked)
            (
                ROW_NUMBER() OVER (
                PARTITION BY SubmissionId
                ORDER BY 
                    CASE WHEN IsRegulator = 1 AND IsResubmission = 1 
                        THEN DecisionDate 
                    END DESC
                )
                * CASE WHEN IsRegulator = 1 AND IsResubmission = 1 THEN 1 ELSE 0 END
            ) AS ResubDecisionLatest
        FROM ReconciledCTE
    )
--select * from Base
    ,Aggregates AS (
        SELECT
                SubmissionId,

                -- initial producer submission
                MAX(CASE WHEN ProdLatest        = 1 THEN DecisionDate END)        AS InitialSubmissionDate,
                MAX(CASE WHEN ProdLatest        = 1 THEN Comment      END)        AS InitialSubmissionComment,
                MAX(CASE WHEN ProdLatest        = 1 THEN FileId       END)        AS InitialSubmissionFileId,
                MAX(CASE WHEN ProdLatest        = 1 THEN UserId       END)        AS InitialSubmissionUserId,
                MAX(CASE WHEN ProdLatest        = 1 THEN SubmissionEventId END)    AS InitialSubmissionEventId,

                -- **first ever** submission (corrected)
                MAX(CASE WHEN ProdFirst         = 1 THEN DecisionDate END)        AS FirstSubmissionDate,

                -- initial regulator decision (no-resub)
                MAX(CASE WHEN RegLatestNoResub  = 1 THEN DecisionDate END)        AS InitialDecisionDate,
                MAX(CASE WHEN RegLatestNoResub  = 1 THEN StatusPendingDate END)   AS InitialDecisionPendingDate,

                -- latest regulator decision (no-resub)
                MAX(CASE WHEN RegLatestNoResub  = 1 THEN DecisionDate END)        AS LatestDecisionDate,
                MAX(CASE WHEN RegLatestNoResub  = 1 THEN SubmissionStatus END)    AS LatestDecisionStatus,
                MAX(CASE WHEN RegLatestNoResub  = 1 THEN Comment END)             AS LatestDecisionComment,
                MAX(CASE WHEN RegLatestNoResub  = 1 THEN UserId END)              AS LatestDecisionUserId,

                -- first “Granted” decision
                MAX(CASE WHEN RegFirstGrant     = 1 THEN DecisionDate END)        AS RegistrationDecisionDate,
                MAX(CASE WHEN RegFirstGrant     = 1 THEN SubmissionStatus END)    AS RegisteredStatus,
                MAX(CASE WHEN RegFirstGrant     = 1 THEN FileId END)              AS RegisteredFileId,
                MAX(CASE WHEN RegFirstGrant     = 1 THEN SubmissionEventId END)   AS RegistrationDecisionEventId,
                MAX(CASE WHEN RegFirstGrant     = 1 THEN RegistrationReferenceNumber END)
                                                                                    AS RegistrationReferenceNumber,

                -- latest producer resubmission
                MAX(CASE WHEN ResubLatest       = 1 THEN DecisionDate END)        AS ResubmissionDate,
                MAX(CASE WHEN ResubLatest       = 1 THEN Comment END)             AS ResubmissionComment,
                MAX(CASE WHEN ResubLatest       = 1 THEN FileId END)              AS ResubmittedFileId,
                MAX(CASE WHEN ResubLatest       = 1 THEN UserId END)              AS ResubmittedUserId,
                MAX(CASE WHEN ResubLatest       = 1 THEN SubmissionEventId END)   AS ResubmissionEventId,

                -- latest regulator resubmission decision
                MAX(CASE WHEN ResubDecisionLatest = 1 THEN DecisionDate END)      AS ResubmissionDecisionDate,
                MAX(CASE WHEN ResubDecisionLatest = 1 THEN ResubmissionStatus END)AS ResubmissionDecisionStatus,
                MAX(CASE WHEN ResubDecisionLatest = 1 THEN SubmissionEventId END) AS ResubmissionDecisionEventId,
                MAX(CASE WHEN ResubDecisionLatest = 1 THEN Comment END)           AS ResubmissionDecisionComment,
                MAX(CASE WHEN ResubDecisionLatest = 1 THEN UserId END)            AS ResubmissionDecisionUserId,
                MAX(CancellationDate)                                             AS CancellationDate
        FROM Base
        GROUP BY SubmissionId
    )
--select * from Aggregates;
    ,SubmissionStatusAndDetailsCTE as (
        SELECT 
            a.SubmissionId,                                                      -- SubmissionId
            o.ExternalId AS OrganisationId,                                      -- OrganisationId
            o.Id as OrganisationInternalId,                                      -- OrganisationInternalId (you may need to join or add if available)
            o.Name AS OrganisationName,                                          -- OrganisationName
            org.UploadOrgName AS UploadedOrganisationName,                       -- UploadedOrganisationName (not present in source, placeholder)
            o.ReferenceNumber AS OrganisationReference,                          -- OrganisationReference
            COALESCE(a.ResubmittedUserId, a.InitialSubmissionUserId) AS SubmittedUserId, -- SubmittedUserId
            CASE WHEN NULLIF(s.ComplianceSchemeId,'') IS NOT NULL THEN 
                 CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS IsComplianceScheme, -- IsComplianceScheme
            CASE 
				WHEN s.ComplianceSchemeId IS NOT NULL THEN 'Compliance'
				ELSE CASE UPPER(TRIM(org.organisationsize))
					WHEN 'S' THEN 'Small'
					WHEN 'L' THEN 'Large'
				 END 
			END AS OrganisationType,
            CASE UPPER(TRIM(org.organisationsize))
                WHEN 'S' THEN 'Small'
                WHEN 'L' THEN 'Large'
                END 
            as ProducerSize,
            s.AppReferenceNumber AS ApplicationReferenceNumber,                  -- ApplicationReferenceNumber
            a.RegistrationReferenceNumber,                                       -- RegistrationReferenceNumber
            a.InitialSubmissionDate AS SubmittedDateTime,                        -- SubmittedDateTime
            a.RegistrationDecisionDate AS RegistrationDate,                      -- RegistrationDate
            CASE WHEN a.ResubmissionDate IS NOT NULL THEN 
                 CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS IsResubmission, -- IsResubmission
            a.ResubmissionDate,                                                  -- ResubmissionDate
            CAST(RIGHT(RTRIM(s.SubmissionPeriod), 4) AS INT) AS RelevantYear,    -- RelevantYear
            s.SubmissionPeriod,                                                  -- SubmissionPeriod
            dbo.fn_IsSubmissionLate(TRY_CONVERT(DATETIME2(7), a.InitialSubmissionDate),
                                 s.SubmissionPeriod,
                                 CASE 
                                     WHEN s.ComplianceSchemeId IS NOT NULL THEN 'Compliance'
                                     ELSE CASE UPPER(TRIM(org.organisationsize))
                                         WHEN 'S' THEN 'Small'
                                         WHEN 'L' THEN 'Large'
                                     END 
                                 END)
            as IsLateSubmission,
            CASE                                                                  -- SubmissionStatus
                WHEN a.InitialSubmissionDate > a.InitialDecisionDate THEN 'Pending'
                ELSE COALESCE(a.LatestDecisionStatus, a.RegisteredStatus, 'Pending')
            END AS SubmissionStatus,
            CASE                                                                  -- ResubmissionStatus
                WHEN a.ResubmissionDate IS NOT NULL AND a.ResubmissionDecisionDate IS NOT NULL THEN a.ResubmissionDecisionStatus
                WHEN a.ResubmissionDate IS NOT NULL THEN 'Pending'
                ELSE NULL
            END AS ResubmissionStatus,
            a.ResubmissionDecisionDate as RegulatorResubmissionDecisionDate,     -- RegulatorResubmissionDecisionDate (inserted next to ResubmissionStatus)
            a.LatestDecisionDate AS RegulatorDecisionDate,                       -- RegulatorDecisionDate
            a.InitialDecisionPendingDate AS StatusPendingDate,                   -- StatusPendingDate
            CASE 
                WHEN cs.NationId IS NOT NULL THEN cs.NationId
                ELSE
                CASE UPPER(org.NationCode)
                    WHEN 'EN' THEN 1
                    WHEN 'NI' THEN 2
                    WHEN 'SC' THEN 3
                    WHEN 'WS' THEN 4
                    WHEN 'WA' THEN 4
                    END
                END AS NationId,
            CASE
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
                END AS NationCode,

            -- === new columns ===
            s.ComplianceSchemeId,
            a.FirstSubmissionDate, -- new column
            SUBSTRING(a.InitialSubmissionComment,0, 4000) AS SubmissionComment,                     -- new column
            a.RegisteredFileId,                                                  -- new column
            COALESCE(a.ResubmittedFileId, a.InitialSubmissionFileId) AS SubmittedFileId, -- new column
            a.RegistrationDecisionDate,                                          
            SUBSTRING(a.ResubmissionComment,0,4000) as ResubmissionComment,      -- new column
            a.ResubmissionDecisionEventId,                                       -- new column
            SUBSTRING(COALESCE(a.ResubmissionDecisionComment, a.LatestDecisionComment),0, 4000) AS RegulatorComment, -- new column
            a.InitialSubmissionEventId AS SubmissionEventId,                     -- new column
            a.ResubmissionEventId,                                               -- new column
            a.RegistrationDecisionEventId,                                       -- new column
            a.ResubmittedUserId,                                                 -- new column
            COALESCE(a.ResubmissionDecisionUserId, a.LatestDecisionUserId) AS RegulatorUserId, -- new column
            COALESCE(a.ResubmittedUserId, a.InitialSubmissionUserId) AS LatestProducerUserId, -- new column
            CancellationDate
            ,org.CompanyFileId
            ,org.CompanyUploadFileName
            ,org.CompanyBlobName
            ,org.BrandFileId
            ,org.BrandUploadFileName
            ,org.BrandBlobName
            ,org.PartnerUploadFileName
            ,org.PartnerFileId
            ,org.PartnerBlobName

            ,CONVERT(bit, ISNULL(ppp.IsOnlineMarketplace, 0)) AS IsOnlineMarketplace
            ,ISNULL(ppp.NumberOfSubsidiaries, 0) AS NumberOfSubsidiaries
            ,ISNULL(ppp.OnlineMarketPlaceSubsidiaries,0) AS NumberOfSubsidiariesBeingOnlineMarketPlace

            ,o.CompaniesHouseNumber
            ,o.BuildingName
            ,o.SubBuildingName
            ,o.BuildingNumber
            ,o.Street
            ,o.Locality
            ,o.DependentLocality
            ,o.Town
            ,o.County
            ,o.Country
            ,o.Postcode

        FROM Aggregates a
        INNER JOIN rpd.Submissions s ON s.SubmissionId = a.SubmissionId
        LEFT JOIN [rpd].[ComplianceSchemes] cs on cs.ExternalId = s.ComplianceSchemeId 
        INNER JOIN [dbo].[v_UploadedRegistrationDataBySubmissionPeriod_resub] org 
            ON org.UploadingOrgExternalId = s.OrganisationId 
            and org.SubmissionPeriod = s.SubmissionPeriod
            and (s.ComplianceSchemeId is NULL OR org.ComplianceSchemeId = s.ComplianceSchemeId)
            and org.CompanyFileId = COALESCE(a.ResubmittedFileId, a.InitialSubmissionFileId)
        INNER JOIN rpd.Organisations o ON o.ExternalId = s.OrganisationId
        INNER JOIN [dbo].[v_ProducerPaycalParameters_resub] AS ppp on ppp.FileId = COALESCE(a.ResubmittedFileId, a.InitialSubmissionFileId)
        WHERE 
            s.AppReferenceNumber IS NOT NULL
            AND s.SubmissionType = 'Registration'
            AND s.SubmissionPeriod like 'January to Dec%'
            AND s.IsSubmitted = 1
            AND a.InitialSubmissionDate IS NOT NULL
    )
    -- ,ComplianceSchemeMembersCTE as (
    --     select csm.*
    --             ,s.SubmittedDateTime as SubmittedOn
    --             ,s.IsLateSubmission
    --             ,s.SubmittedFileId
    --             ,CASE WHEN s.RegistrationDecisionDate IS NULL THEN 1
    --                     WHEN csm.SubmittedDate <= s.RegistrationDecisionDate AND csm.joiner_date is null THEN 1
    --                     WHEN csm.joiner_date is null THEN 1
    --                     ELSE 0 END
    --             AS IsOriginal
    --             ,CASE WHEN s.RegistrationDecisionDate IS NULL THEN 0
    --                     WHEN csm.SubmittedDate <= s.RegistrationDecisionDate THEN 0
    --                     WHEN ( csm.SubmittedDate > s.RegistrationDecisionDate and csm.joiner_date is not null) THEN 1
    --                     WHEN ( csm.SubmittedDate > s.RegistrationDecisionDate and csm.joiner_date is null) THEN 0
    --             END as IsNewJoiner
    --     from dbo.v_ComplianceSchemeMembers_resub csm
    --         inner join SubmissionStatusAndDetailsCTE s on s.ComplianceSchemeId = csm.ComplianceSchemeId
    --         and s.SubmissionPeriod = csm.SubmissionPeriod
    --         and s.SubmittedFileId = csm.FileId
    -- )
    -- ,CompliancePaycalCTE
    -- AS
    -- (
    --     SELECT
    --         CSOReference
    --         ,csm.ComplianceSchemeId
    --         ,csm.ReferenceNumber
    --         ,csm.RelevantYear
    --         ,ppp.ProducerSize
    --         ,csm.SubmittedDate
    --         ,CASE WHEN csm.IsNewJoiner = 1 THEN csm.IsLateFeeApplicable
    --                 ELSE csm.IsLateSubmission END 
    --             AS IsLateFeeApplicable
    --         ,csm.OrganisationName
    --         ,csm.leaver_code
    --         ,csm.leaver_date
    --         ,csm.joiner_date
    --         ,csm.organisation_change_reason
    --         ,ppp.IsOnlineMarketPlace
    --         ,ppp.NumberOfSubsidiaries
    --         ,ppp.OnlineMarketPlaceSubsidiaries as NumberOfSubsidiariesBeingOnlineMarketPlace
    --         ,csm.submissionperiod
    --     FROM
    --         ComplianceSchemeMembersCTE csm
    --         INNER JOIN dbo.v_ProducerPayCalParameters_resub ppp ON ppp.OrganisationId = csm.ReferenceNumber
    --                     AND ppp.FileName = csm.FileName
    -- ) 
    -- ,JsonifiedCompliancePaycalCTE
    -- AS
    -- (
    --     SELECT
    --         ComplianceSchemeId
    --         ,ReferenceNumber
    --         ,'{"MemberId": "' + CAST(ReferenceNumber AS NVARCHAR(25)) + '", ' + '"MemberType": "' + ProducerSize + '", ' + '"IsOnlineMarketPlace": ' + 
    --         CASE
    --             WHEN IsOnlineMarketPlace = 1 THEN 'true'
    --             ELSE 'false'
    --         END + ', ' + '"NumberOfSubsidiaries": ' + CAST(NumberOfSubsidiaries AS NVARCHAR(6)) + ', ' + '"NumberOfSubsidiariesOnlineMarketPlace": ' + 
    --         CAST(NumberOfSubsidiariesBeingOnlineMarketPlace AS NVARCHAR(6)) + ', ' + 
    --         '"RelevantYear": ' + CAST(RelevantYear AS NVARCHAR(4)) + ', ' + '"SubmittedDate": "' + 
    --         CAST(SubmittedDate AS nvarchar(16)) + '", ' + '"IsLateFeeApplicable": ' + 
    --         CASE
    --             WHEN IsLateFeeApplicable = 1 THEN 'true'
    --             ELSE 'false'
    --         END + ', ' + '"SubmissionPeriodDescription": "' + submissionperiod + '"}' AS OrganisationDetailsJsonString
            
    --     FROM
    --         CompliancePaycalCTE
    -- )
    -- ,AllCompliancePaycalParametersAsJSONCTE AS
    -- (
    --     SELECT
    --         ComplianceSchemeId,
    --         Count(OrganisationDetailsJsonString) as MemberCount,
    --         '[' + STRING_AGG(CONVERT(nvarchar(max),OrganisationDetailsJsonString), ', ') + ']' AS FinalJson
    --     FROM
    --         JsonifiedCompliancePaycalCTE
    --     GROUP BY ComplianceSchemeId
    -- )
    -- ,SubmissionAndCSODataCTE AS (
    --     SELECT s.*
    --            ,csojson.MemberCount as CSOMemberCount
    --            ,csojson.FinalJson as CSOJson
    --     FROM SubmissionStatusAndDetailsCTE s
    --     LEFT join AllCompliancePaycalParametersAsJSONCTE csojson on csojson.ComplianceSchemeId = s.ComplianceSchemeId 
    -- )
    ,SubmissionAndOrgDataCTE AS (
        select s.*
                ,CONVERT(INT, NULL) as CSOMemberCount
                ,CONVERT(NVARCHAR(MAX), NULL) as CSOJson
                ,p.FirstName
                ,p.LastName
                ,p.Email
                ,p.Telephone
                ,sr.Name AS ServiceRole
                ,sr.Id AS ServiceRoleId
        FROM SubmissionStatusAndDetailsCTE s
        LEFT JOIN [rpd].[Users] u ON u.UserId = s.SubmittedUserId
        LEFT JOIN [rpd].[Persons] p ON p.UserId = u.Id
        LEFT JOIN [rpd].[PersonOrganisationConnections] poc ON poc.PersonId = p.Id
        LEFT JOIN [rpd].[ServiceRoles] sr ON sr.Id = poc.PersonRoleId
    )
--select * from SubmissionStatusAndDetailsCTE
    select * from SubmissionAndOrgDataCTE;