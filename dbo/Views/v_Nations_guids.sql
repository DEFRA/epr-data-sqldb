CREATE VIEW [dbo].[v_Nations_guids]
AS WITH cte_nat_guid AS (

SELECT 1 Id, '9BuHTU99u0eHRgknpDuq4g' GU_Id UNION ALL
SELECT 2 Id, '6mWnIVbcPkeaJselmXINKw' GU_Id UNION ALL
SELECT 3 Id, 'pvo3bP6ifE2dvdOEWt60Eg' GU_Id UNION ALL
SELECT 4 Id, 'w80pLdPPEE2Nke58xak8ng' GU_Id

)
SELECT 
	n.Id, 
	n.Name,
	ng.GU_Id
FROM cte_nat_guid ng
JOIN rpd.Nations n ON n.Id = ng.Id;