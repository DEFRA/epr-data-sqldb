CREATE VIEW [superseeded_status_pom_org]
AS WITH cancelledsubmissionids AS (
    SELECT submissionid	
    FROM [dbo].[v_submitted_pom_org_file_status] 
    WHERE [Regulator_Status] = 'cancelled'
),

cancelledsubmissionallstatus AS (
    SELECT *,
        CASE 
            WHEN Regulator_Status = 'Cancelled' THEN 'rejected'
            WHEN Regulator_Status = 'Granted' THEN 'Cancelled'
            ELSE Regulator_Status 
        END AS Superseeded_regulator_status
    FROM [dbo].[v_submitted_pom_org_file_status]
    WHERE submissionid IN (SELECT submissionid FROM cancelledsubmissionids)
),

notcancelledsubmissionids AS (
    SELECT submissionid	
    FROM [dbo].[v_submitted_pom_org_file_status] 
    WHERE [Regulator_Status] <> 'cancelled'
),

notcancelledsubmissionallstatus AS (
    SELECT *,
        Regulator_Status AS Superseeded_regulator_status
    FROM [dbo].[v_submitted_pom_org_file_status]
    WHERE submissionid IN (SELECT submissionid FROM notcancelledsubmissionids)
)

SELECT * FROM cancelledsubmissionallstatus
UNION
SELECT * FROM notcancelledsubmissionallstatus;