CREATE VIEW [View_C]
AS SELECT * 
FROM (
    SELECT rv.*, 
           row_number() OVER (PARTITION BY organisation_id, subsidiary_id ORDER BY se.created DESC) AS rn
    FROM rpd.CompanyDetails rv
    JOIN v_cosmos_file_metadata cs ON cs.filename = rv.[FileName]
    INNER JOIN [rpd].[SubmissionEvents] se 
        ON se.fileid = cs.fileid 
       AND se.[type] = 'RegulatorRegistrationDecision'
) A
WHERE rn = 1
AND NOT EXISTS (
    SELECT 1
    FROM (
        SELECT rv.*, 
               row_number() OVER (PARTITION BY organisation_id, subsidiary_id ORDER BY se.created DESC) AS rn
        FROM rpd.CompanyDetails rv
        JOIN v_cosmos_file_metadata cs ON cs.filename = rv.[FileName]
        INNER JOIN [rpd].[SubmissionEvents] se 
            ON se.fileid = cs.fileid 
           AND se.[type] = 'RegulatorRegistrationDecision' 
           AND se.[Decision] = 'Accepted'
    ) B
    WHERE B.organisation_id = A.organisation_id 
      AND B.subsidiary_id = A.subsidiary_id 
      AND B.rn = 1
);