CREATE VIEW [dbo].[v_Multiple_Reg_Sumbissions] AS with cte_unique as(SElect organisation_id,filename  from registration group by  organisation_id,filename 
),

cte_start as(
    SELECT organisation_id
FROM cte_unique
GROUP BY organisation_id
HAVING COUNT(filename) > 1
)


SELECT distinct
    t.organisation_id,
    --t.organisation_name,
    t.FromOrganisation_Name as organisation_name,
    CASE
        WHEN t.[FromOrganisation_IsComplianceScheme] = 'True' THEN 'Compliance Scheme'
        ELSE 'Producer'
    END AS [PCS_Or_Direct_Producer],
    t.submittedby,
    t.filename,
    t.created,
    NULL as ServiceRoles_Role,
    t.SecurityQuery,
    t.ServiceRoles_Name,
    t.[OriginalFileName]
FROM registration t
join cte_start a on a.organisation_id = t.organisation_id;