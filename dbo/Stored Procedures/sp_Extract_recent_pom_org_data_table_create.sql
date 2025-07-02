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

--Table 1
set @start_dt = getdate()

		IF OBJECT_ID('dbo.t_rptRegistrationRegistered', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.t_rptRegistrationRegistered;
		END;	
 
		with rptRegistrationRegistered as
		(
			select distinct organisation_id, 'Y' as Is_Present_in_Reg_report
			from [dbo].[registration]
		)
		SELECT *
		INTO dbo.t_rptRegistrationRegistered
		FROM rptRegistrationRegistered

INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'sp_Extract_recent_pom_org_data_table_create','t_rptRegistrationRegistered', NULL, @start_dt, getdate(), 'Completed',@batch_id


--Table 2
set @start_dt = getdate()

		IF OBJECT_ID('dbo.t_rptPOM_All_Submissions', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.t_rptPOM_All_Submissions;
		END;	
 
		with rptPOM_All_Submissions as
		(
			select distinct OrganisationID as organisation_id, 'Y' as Is_Present_in_POM_report
			from [dbo].[t_POM_All_Submissions]
			where OrganisationID is not null
		)
		SELECT *
		INTO dbo.t_rptPOM_All_Submissions
		FROM rptPOM_All_Submissions

INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'sp_Extract_recent_pom_org_data_table_create','t_rptPOM_All_Submissions', NULL, @start_dt, getdate(), 'Completed',@batch_id

--Table 3
set @start_dt = getdate()

		IF OBJECT_ID('dbo.t_submission_count', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.t_submission_count;
		END;	
 
		SELECT *
		INTO dbo.t_submission_count
		FROM dbo.v_submission_count

INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'sp_Extract_recent_pom_org_data_table_create','t_submission_count', NULL, @start_dt, getdate(), 'Completed',@batch_id

--Table 4
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