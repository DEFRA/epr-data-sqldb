CREATE PROC [dbo].[sp_delete_duplicate_rows] AS

-- delete Duplicates From Cosmosdb
IF OBJECT_ID('rpd.cosmos_file_metadata', 'u') IS NOT NULL 
DELETE t1
FROM rpd.cosmos_file_metadata t1
JOIN rpd.cosmos_file_metadata t2
  ON t1.filename = t2.filename
  AND t1.load_ts < t2.load_ts;