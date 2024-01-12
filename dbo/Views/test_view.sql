CREATE VIEW [dbo].[test_view]
AS SELECT TOP (1000) [organisation_id]
      ,[subsidiary_id]
      ,[brand_name]
      ,[brand_type_code]
      ,[load_ts]
      ,[FileName]
  FROM [rpd].[Brands];