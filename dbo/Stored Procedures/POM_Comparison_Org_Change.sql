CREATE PROC [dbo].[POM_Comparison_Org_Change] @fn1 [NVARCHAR](MAX),@fn2 [NVARCHAR](MAX) AS
BEGIN
WITH pom_org_details1
AS (
SELECT DISTINCT
    p.FileName, 
    p.organisation_id,
  --  p.subsidiary_id,
	o.Name Org_Name,
    o.[CompaniesHouseNumber] ch_number,
	p.organisation_size
FROM  rpd.Pom p
JOIN dbo.v_rpd_Organisations_Active o ON o.[ReferenceNumber] = p.organisation_id
WHERE p.FileName = @fn1
	AND @fn1 != @fn2
	  ),
pom_org_details2
AS (
SELECT DISTINCT
    p.FileName, 
    p.organisation_id,
  --  p.subsidiary_id,
	o.Name Org_Name,
    o.[CompaniesHouseNumber] ch_number,
	p.organisation_size
FROM  rpd.Pom p
JOIN dbo.v_rpd_Organisations_Active o ON o.[ReferenceNumber] = p.organisation_id
WHERE p.FileName = @fn2
	AND @fn1 != @fn2 
	  ),

pom_org_com
AS (
SELECT
    f1.FileName FileName1,
    f1.organisation_id organisation_id1,
  --  f1.subsidiary_id subsidiary_id1,
    f1.Org_Name Org_Name1,
    f1.ch_number ch_number1,
	f1.organisation_size organisation_size1,
    f2.FileName FileName2,
	f2.organisation_id organisation_id2,
  --  f2.subsidiary_id subsidiary_id2,
    f2.Org_Name Org_Name2,
    f2.ch_number ch_number2,
	f2.organisation_size organisation_size2
FROM pom_org_details1 f1
FULL JOIN pom_org_details2 f2 
	ON f1.organisation_id = f2.organisation_id
	--	AND ISNULL(f1.subsidiary_id, '') = ISNULL(f2.subsidiary_id, '')
)

SELECT 
    COALESCE(organisation_id1, organisation_id2, '') organisation_id,
  --  COALESCE(subsidiary_id1, subsidiary_id2, '') subsidiary_id,
    COALESCE(Org_Name1, Org_Name2, '') Org_Name,
    COALESCE(ch_number1, ch_number2, '') ch_number,
	ISNULL(organisation_size2, '') Current_Size,
	ISNULL(organisation_size1, '') Previous_Size,
	CASE
		WHEN organisation_id1 IS NULL 
			THEN 'Org Added'
		WHEN organisation_id2 IS NULL 
			THEN 'Org Removed'
		WHEN organisation_size2 = 'L' AND ISNULL(organisation_size1, 'S') = 'S'
			THEN 'Size Increased'
		WHEN organisation_size2 = 'S' AND ISNULL(organisation_size1, 'L') = 'L'
			THEN 'Size Decreased'
		WHEN organisation_size1 IS NOT NULL AND organisation_size2 IS NULL
			THEN 'Size Removed'
        ELSE 'No Change'
	END
	Org_Change
FROM pom_org_com;

END;