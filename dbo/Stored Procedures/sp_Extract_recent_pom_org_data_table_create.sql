CREATE PROC [dbo].[sp_Extract_recent_pom_org_data_table_create] AS
BEGIN
    -- Disable row count for performance
    SET NOCOUNT ON;
	DECLARE @start_dt datetime;
	DECLARE @p_start_dt datetime;
	DECLARE @batch_id INT;
	DECLARE @cnt int;

	select @batch_id  = ISNULL(max(batch_id),0)+1 from [dbo].[batch_log]

set @p_start_dt = getdate()
INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'sp_Extract_recent_pom_org_data_table_create','procedure', NULL, @p_start_dt, getdate(), 'Started',@batch_id

set @start_dt = getdate()

		IF OBJECT_ID('dbo.t_extract_recent_pom_org_data', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.t_extract_recent_pom_org_data;
		END;	
 
		SELECT *
		INTO dbo.t_extract_recent_pom_org_data
		FROM dbo.v_extract_recent_pom_org_data

INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'sp_Extract_recent_pom_org_data_table_create','t_extract_recent_pom_org_data', NULL, @start_dt, getdate(), 'Completed',@batch_id

--Recording count from each table
set @start_dt = getdate()
select @cnt =count(1) from dbo.t_extract_recent_pom_org_data;
INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'sp_Extract_recent_pom_org_data_table_create','t_extract_recent_pom_org_data', @cnt, @start_dt, getdate(), 'Completed',@batch_id

INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'sp_Extract_recent_pom_org_data_table_create','procedure', NULL, @p_start_dt, getdate(), 'Completed',@batch_id

END;