CREATE VIEW [enrolment_RLS] AS SELECT TOP (100) [organisation_id]
,[brand_name]

,[brand_type_code]
,[load_ts]
,[filename]
,'England'  As Region
 FROM [rpd].[brands]
 where organisation_id = '546574'

 union 
 SELECT TOP (100) [organisation_id]
,[brand_name]
,[brand_type_code]
,[load_ts]
,[filename]
,'Scotland'  As Region
 FROM [rpd].[brands]
 where organisation_id != '546574';