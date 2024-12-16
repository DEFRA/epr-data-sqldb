CREATE PROC [dbo].[Generate_t_POM_Extract] AS
BEGIN
    -- Disable row count for performance
    SET NOCOUNT ON;
	DECLARE @start_dt datetime;
	DECLARE @batch_id INT;
	DECLARE @cnt int;

	select @batch_id  = ISNULL(max(batch_id),0)+1 from [dbo].[batch_log]

set @start_dt = getdate()
INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'Generate_t_POM_Extract','procedure', NULL, @start_dt, getdate(), 'Started',@batch_id

set @start_dt = getdate()

    IF OBJECT_ID('dbo.t_POM_Extract_Fix', 'U') IS NOT NULL
    BEGIN
        DROP TABLE dbo.t_POM_Extract_Fix;
    END;	

    SELECT *
    INTO dbo.t_POM_Extract_Fix
    FROM dbo.v_POM_Extract_Fix;

INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'Generate_t_POM_Extract','t_POM_Extract_Fix', NULL, @start_dt, getdate(), 'Completed',@batch_id

--Recording count from each table
set @start_dt = getdate()
select @cnt =count(1) from dbo.t_POM_Extract_Fix;
INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'Generate_t_POM_Extract','t_POM_Extract_Fix', @cnt, @start_dt, getdate(), 'Completed',@batch_id

set @start_dt = getdate()
INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'Generate_t_POM_Extract','procedure', NULL, @start_dt, getdate(), 'Completed',@batch_id

END;