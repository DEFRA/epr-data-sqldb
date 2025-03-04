CREATE PROC [dbo].[GenerateTableFromView] AS
BEGIN
    -- Disable row count for performance
    SET NOCOUNT ON;
	DECLARE @start_dt datetime;
	DECLARE @batch_id INT;
	DECLARE @cnt int;
	DECLARE @recovery_checkpoint int;

	select @batch_id  = ISNULL(max(batch_id),0)+1 from [dbo].[batch_log]
	

INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','procedure', NULL, @start_dt, getdate(), 'Started',@batch_id

if not exists (select 1 from [dbo].[tblCheckpoint] where Module = 'GenerateTableFromView')
begin
	insert into [dbo].[tblCheckpoint] ([Module], [CheckPoint], [Timestamp])
	select 'GenerateTableFromView', 0, getdate()

	set @recovery_checkpoint = 0

	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','procedure', NULL, @start_dt, getdate(), 'check point 0 inserted',@batch_id
end
else
begin
	select @recovery_checkpoint = ISNULL([CheckPoint],0) from [dbo].[tblCheckpoint] where [Module] = 'GenerateTableFromView'

	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','procedure', NULL, @start_dt, getdate(), 'RC point '+cast(@recovery_checkpoint as varchar)+' identified',@batch_id
end

--Table 1
if (@recovery_checkpoint < 1)
begin
	set @start_dt = getdate()

		IF OBJECT_ID('dbo.t_cosmos_file_metadata', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.t_cosmos_file_metadata;
		END;	

		SELECT *
		INTO dbo.t_cosmos_file_metadata
		FROM dbo.v_cosmos_file_metadata;

	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_cosmos_file_metadata', NULL, @start_dt, getdate(), 'Tab 1 - Completed',@batch_id


	if exists (select 1 from [dbo].[tblCheckpoint] where Module = 'GenerateTableFromView')
	begin
		update [dbo].[tblCheckpoint] set [CheckPoint] = 1, [Timestamp] = getdate() where Module = 'GenerateTableFromView'
	end
	else
	begin
		insert into [dbo].[tblCheckpoint] ([Module], [CheckPoint], [Timestamp])
		select 'GenerateTableFromView', 1, getdate()
	end
end


--Table 2
if (@recovery_checkpoint < 2)
begin
	set @start_dt = getdate()

		IF OBJECT_ID('dbo.t_pom_codes', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.t_pom_codes;
		END;	

		SELECT *
		INTO dbo.t_pom_codes
		FROM dbo.v_pom_codes;

	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_pom_codes', NULL, @start_dt, getdate(), 'Tab 2 - Completed',@batch_id


	if exists (select 1 from [dbo].[tblCheckpoint] where Module = 'GenerateTableFromView')
	begin
		update [dbo].[tblCheckpoint] set [CheckPoint] = 2, [Timestamp] = getdate() where Module = 'GenerateTableFromView'
	end
	else
	begin
		insert into [dbo].[tblCheckpoint] ([Module], [CheckPoint], [Timestamp])
		select 'GenerateTableFromView', 2, getdate()
	end
end

--Table 3
if (@recovery_checkpoint<3)
begin
	set @start_dt = getdate()


		IF OBJECT_ID('dbo.t_POM', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.t_POM;
		END;	

		SELECT *
		INTO dbo.t_POM
		FROM dbo.v_POM;

	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_POM', NULL, @start_dt, getdate(), 'Tab 3 - Completed',@batch_id


	if exists (select 1 from [dbo].[tblCheckpoint] where Module = 'GenerateTableFromView')
	begin
		update [dbo].[tblCheckpoint] set [CheckPoint] = 3, [Timestamp] = getdate() where Module = 'GenerateTableFromView'
	end
	else
	begin
		insert into [dbo].[tblCheckpoint] ([Module], [CheckPoint], [Timestamp])
		select 'GenerateTableFromView', 3, getdate()
	end
end

--Table 4
if (@recovery_checkpoint < 4)
begin
	set @start_dt = getdate()

		IF OBJECT_ID('dbo.t_Producer_CS_Lookup', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.t_Producer_CS_Lookup;
		END;	

		SELECT *
		INTO dbo.t_Producer_CS_Lookup
		FROM dbo.v_Producer_CS_Lookup;


	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_Producer_CS_Lookup', NULL, @start_dt, getdate(), 'Tab 4 - Completed',@batch_id


	if exists (select 1 from [dbo].[tblCheckpoint] where Module = 'GenerateTableFromView')
	begin
		update [dbo].[tblCheckpoint] set [CheckPoint] = 4, [Timestamp] = getdate() where Module = 'GenerateTableFromView'
	end
	else
	begin
		insert into [dbo].[tblCheckpoint] ([Module], [CheckPoint], [Timestamp])
		select 'GenerateTableFromView', 4, getdate()
	end
end

--Table 5
if (@recovery_checkpoint < 5)
begin
	set @start_dt = getdate()

		IF OBJECT_ID('dbo.t_Producer_CS_Lookup_Pivot', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.t_Producer_CS_Lookup_Pivot;
		END;	

		SELECT *
		INTO dbo.t_Producer_CS_Lookup_Pivot
		FROM dbo.v_Producer_CS_Lookup_Pivot;

	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_Producer_CS_Lookup_Pivot', NULL, @start_dt, getdate(), 'Tab 5 - Completed',@batch_id

	if exists (select 1 from [dbo].[tblCheckpoint] where Module = 'GenerateTableFromView')
	begin
		update [dbo].[tblCheckpoint] set [CheckPoint] = 5, [Timestamp] = getdate() where Module = 'GenerateTableFromView'
	end
	else
	begin
		insert into [dbo].[tblCheckpoint] ([Module], [CheckPoint], [Timestamp])
		select 'GenerateTableFromView', 5, getdate()
	end
end


--Table 6
if (@recovery_checkpoint < 6)
begin
	set @start_dt = getdate()

		IF OBJECT_ID('dbo.t_Producer_CS_Lookup_Unpivot', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.t_Producer_CS_Lookup_Unpivot;
		END;	

		SELECT *
		INTO dbo.t_Producer_CS_Lookup_Unpivot
		FROM dbo.v_Producer_CS_Lookup_Unpivot;

	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_Producer_CS_Lookup_Unpivot', NULL, @start_dt, getdate(), 'Tab 6 - Completed',@batch_id

	if exists (select 1 from [dbo].[tblCheckpoint] where Module = 'GenerateTableFromView')
	begin
		update [dbo].[tblCheckpoint] set [CheckPoint] = 6, [Timestamp] = getdate() where Module = 'GenerateTableFromView'
	end
	else
	begin
		insert into [dbo].[tblCheckpoint] ([Module], [CheckPoint], [Timestamp])
		select 'GenerateTableFromView', 6, getdate()
	end
end

--Table 7
if (@recovery_checkpoint < 7)
begin
	set @start_dt = getdate()

		IF OBJECT_ID('dbo.t_rpd_data_SECURITY_FIX', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.t_rpd_data_SECURITY_FIX;
		END;	

		SELECT *
		INTO dbo.t_rpd_data_SECURITY_FIX
		FROM dbo.v_rpd_data_SECURITY_FIX;

	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_rpd_data_SECURITY_FIX', NULL, @start_dt, getdate(), 'Tab 7 - Completed',@batch_id


	if exists (select 1 from [dbo].[tblCheckpoint] where Module = 'GenerateTableFromView')
	begin
		update [dbo].[tblCheckpoint] set [CheckPoint] = 7, [Timestamp] = getdate() where Module = 'GenerateTableFromView'
	end
	else
	begin
		insert into [dbo].[tblCheckpoint] ([Module], [CheckPoint], [Timestamp])
		select 'GenerateTableFromView', 7, getdate()
	end
end

--Table 8
if (@recovery_checkpoint < 8)
begin
	set @start_dt = getdate()

		IF OBJECT_ID('dbo.t_POM_Submissions', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.t_POM_Submissions;
		END;	

		SELECT *
		INTO dbo.t_POM_Submissions
		FROM dbo.v_POM_Submissions;

	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_POM_Submissions', NULL, @start_dt, getdate(), 'Tab 8 - Completed',@batch_id


	if exists (select 1 from [dbo].[tblCheckpoint] where Module = 'GenerateTableFromView')
	begin
		update [dbo].[tblCheckpoint] set [CheckPoint] = 8, [Timestamp] = getdate() where Module = 'GenerateTableFromView'
	end
	else
	begin
		insert into [dbo].[tblCheckpoint] ([Module], [CheckPoint], [Timestamp])
		select 'GenerateTableFromView', 8, getdate()
	end
end

--Table 9
if (@recovery_checkpoint < 9)
begin
	set @start_dt = getdate()

		IF OBJECT_ID('dbo.t_POM_Operator_Submissions', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.t_POM_Operator_Submissions;
		END;	

		SELECT *
		INTO dbo.t_POM_Operator_Submissions
		FROM dbo.v_POM_Operator_Submissions;

	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_POM_Operator_Submissions', NULL, @start_dt, getdate(), 'Tab 9 - Completed',@batch_id


	if exists (select 1 from [dbo].[tblCheckpoint] where Module = 'GenerateTableFromView')
	begin
		update [dbo].[tblCheckpoint] set [CheckPoint] = 9, [Timestamp] = getdate() where Module = 'GenerateTableFromView'
	end
	else
	begin
		insert into [dbo].[tblCheckpoint] ([Module], [CheckPoint], [Timestamp])
		select 'GenerateTableFromView', 9, getdate()
	end
end

--Table 10
if (@recovery_checkpoint < 10)
begin
	set @start_dt = getdate()

		IF OBJECT_ID('dbo.t_POM_All_Submissions', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.t_POM_All_Submissions;
		END;	

		SELECT *
		INTO dbo.t_POM_All_Submissions
		FROM dbo.v_POM_All_Submissions;

	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_POM_All_Submissions', NULL, @start_dt, getdate(), 'Tab 10 - Completed',@batch_id


	if exists (select 1 from [dbo].[tblCheckpoint] where Module = 'GenerateTableFromView')
	begin
		update [dbo].[tblCheckpoint] set [CheckPoint] = 10, [Timestamp] = getdate() where Module = 'GenerateTableFromView'
	end
	else
	begin
		insert into [dbo].[tblCheckpoint] ([Module], [CheckPoint], [Timestamp])
		select 'GenerateTableFromView', 10, getdate()
	end
end

--Table 11
if (@recovery_checkpoint < 11)
begin
	set @start_dt = getdate()

		IF OBJECT_ID('dbo.t_registration_latest', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.t_registration_latest;
		END;	

		SELECT *
		INTO dbo.t_registration_latest
		FROM dbo.v_registration_latest;


	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_registration_latest', NULL, @start_dt, getdate(), 'Tab 11 - Completed',@batch_id


	if exists (select 1 from [dbo].[tblCheckpoint] where Module = 'GenerateTableFromView')
	begin
		update [dbo].[tblCheckpoint] set [CheckPoint] = 11, [Timestamp] = getdate() where Module = 'GenerateTableFromView'
	end
	else
	begin
		insert into [dbo].[tblCheckpoint] ([Module], [CheckPoint], [Timestamp])
		select 'GenerateTableFromView', 11, getdate()
	end
end

--Table 12
if (@recovery_checkpoint < 12)
begin
	set @start_dt = getdate()

		IF OBJECT_ID('dbo.t_POM_Filters', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.t_POM_Filters;
		END;	

		SELECT *
		INTO dbo.t_POM_Filters
		FROM dbo.v_POM_Filters;


	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_POM_Filters', NULL, @start_dt, getdate(), 'Tab 12 - Completed',@batch_id


	if exists (select 1 from [dbo].[tblCheckpoint] where Module = 'GenerateTableFromView')
	begin
		update [dbo].[tblCheckpoint] set [CheckPoint] = 12, [Timestamp] = getdate() where Module = 'GenerateTableFromView'
	end
	else
	begin
		insert into [dbo].[tblCheckpoint] ([Module], [CheckPoint], [Timestamp])
		select 'GenerateTableFromView', 12, getdate()
	end
end

--Table 13
if (@recovery_checkpoint < 13)
begin
	set @start_dt = getdate()

		IF OBJECT_ID('dbo.t_POM_Submissions_POM_Comparison', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.t_POM_Submissions_POM_Comparison;
		END;	

		SELECT *
		INTO dbo.t_POM_Submissions_POM_Comparison
		FROM dbo.v_POM_Submissions_POM_Comparison;

	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_POM_Submissions_POM_Comparison', NULL, @start_dt, getdate(), 'Tab 13 - Completed',@batch_id


	if exists (select 1 from [dbo].[tblCheckpoint] where Module = 'GenerateTableFromView')
	begin
		update [dbo].[tblCheckpoint] set [CheckPoint] = 13, [Timestamp] = getdate() where Module = 'GenerateTableFromView'
	end
	else
	begin
		insert into [dbo].[tblCheckpoint] ([Module], [CheckPoint], [Timestamp])
		select 'GenerateTableFromView', 13, getdate()
	end
end

--Table 14
if (@recovery_checkpoint < 14)
begin
	set @start_dt = getdate()

		IF OBJECT_ID('dbo.t_POM_Com_Landing_Filter', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.t_POM_Com_Landing_Filter;
		END;	

		SELECT *
		INTO dbo.t_POM_Com_Landing_Filter
		FROM dbo.v_POM_Com_Landing_Filter;

	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_POM_Com_Landing_Filter', NULL, @start_dt, getdate(), 'Tab 14 - Completed',@batch_id


	if exists (select 1 from [dbo].[tblCheckpoint] where Module = 'GenerateTableFromView')
	begin
		update [dbo].[tblCheckpoint] set [CheckPoint] = 14, [Timestamp] = getdate() where Module = 'GenerateTableFromView'
	end
	else
	begin
		insert into [dbo].[tblCheckpoint] ([Module], [CheckPoint], [Timestamp])
		select 'GenerateTableFromView', 14, getdate()
	end
end

--Table 15
if (@recovery_checkpoint < 15)
begin
	set @start_dt = getdate()

		IF OBJECT_ID('dbo.t_registration_with_brandandpartner', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.t_registration_with_brandandpartner;
		END;	

		SELECT *
		INTO dbo.t_registration_with_brandandpartner
		FROM dbo.v_registration_with_brandandpartner;

	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_registration_with_brandandpartner', NULL, @start_dt, getdate(), 'Tab 15 - Completed',@batch_id


	if exists (select 1 from [dbo].[tblCheckpoint] where Module = 'GenerateTableFromView')
	begin
		update [dbo].[tblCheckpoint] set [CheckPoint] = 15, [Timestamp] = getdate() where Module = 'GenerateTableFromView'
	end
	else
	begin
		insert into [dbo].[tblCheckpoint] ([Module], [CheckPoint], [Timestamp])
		select 'GenerateTableFromView', 15, getdate()
	end
end



--Table 16
if (@recovery_checkpoint < 16)
begin
	set @start_dt = getdate()

		IF OBJECT_ID('dbo.t_new_enrolment_report', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.t_new_enrolment_report;
		END;	

		SELECT *
		INTO dbo.t_new_enrolment_report
		FROM dbo.v_new_enrolment_report;

	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_new_enrolment_report', NULL, @start_dt, getdate(), 'Tab 16 - Completed',@batch_id


	if exists (select 1 from [dbo].[tblCheckpoint] where Module = 'GenerateTableFromView')
	begin
		update [dbo].[tblCheckpoint] set [CheckPoint] = 16, [Timestamp] = getdate() where Module = 'GenerateTableFromView'
	end
	else
	begin
		insert into [dbo].[tblCheckpoint] ([Module], [CheckPoint], [Timestamp])
		select 'GenerateTableFromView', 16, getdate()
	end
end

--Table 17
if (@recovery_checkpoint < 17)
begin
	set @start_dt = getdate()

		IF OBJECT_ID('dbo.t_enrolled_not_registered', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.t_enrolled_not_registered;
		END;	

		SELECT *
		INTO dbo.t_enrolled_not_registered
		FROM dbo.enrolled_not_registered;

	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_enrolled_not_registered', NULL, @start_dt, getdate(), 'Tab 17 - Completed',@batch_id

	if exists (select 1 from [dbo].[tblCheckpoint] where Module = 'GenerateTableFromView')
	begin
		update [dbo].[tblCheckpoint] set [CheckPoint] = 17, [Timestamp] = getdate() where Module = 'GenerateTableFromView'
	end
	else
	begin
		insert into [dbo].[tblCheckpoint] ([Module], [CheckPoint], [Timestamp])
		select 'GenerateTableFromView', 17, getdate()
	end
end

--Table 18
if (@recovery_checkpoint < 18)
begin
	set @start_dt = getdate()

		IF OBJECT_ID('dbo.t_CompanyBrandPartnerFileUploadSet', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.t_CompanyBrandPartnerFileUploadSet;
		END;

		SELECT *
		INTO dbo.t_CompanyBrandPartnerFileUploadSet
		FROM dbo.v_CompanyBrandPartnerFileUploadSet;

	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_CompanyBrandPartnerFileUploadSet', NULL, @start_dt, getdate(), 'Tab 18 - Completed',@batch_id

	if exists (select 1 from [dbo].[tblCheckpoint] where Module = 'GenerateTableFromView')
	begin
		update [dbo].[tblCheckpoint] set [CheckPoint] = 18, [Timestamp] = getdate() where Module = 'GenerateTableFromView'
	end
	else
	begin
		insert into [dbo].[tblCheckpoint] ([Module], [CheckPoint], [Timestamp])
		select 'GenerateTableFromView', 18, getdate()
	end
end


--Table 19
if (@recovery_checkpoint < 19)
begin
	set @start_dt = getdate()

		IF OBJECT_ID('dbo.t_Registration_Comparison_Landing_Page', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.t_Registration_Comparison_Landing_Page;
		END;	

		SELECT *
		INTO dbo.t_Registration_Comparison_Landing_Page
		FROM dbo.v_Registration_Comparison_Landing_Page;

	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_Registration_Comparison_Landing_Page', NULL, @start_dt, getdate(), 'Tab 19 - Completed',@batch_id

	if exists (select 1 from [dbo].[tblCheckpoint] where Module = 'GenerateTableFromView')
	begin
		update [dbo].[tblCheckpoint] set [CheckPoint] = 19, [Timestamp] = getdate() where Module = 'GenerateTableFromView'
	end
	else
	begin
		insert into [dbo].[tblCheckpoint] ([Module], [CheckPoint], [Timestamp])
		select 'GenerateTableFromView', 19, getdate()
	end
end

--Table 20
if (@recovery_checkpoint < 20)
begin
	set @start_dt = getdate()

		IF OBJECT_ID('dbo.t_latest_accepted_orgfile_by_year', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.t_latest_accepted_orgfile_by_year;
		END;	

		SELECT *
		INTO dbo.t_latest_accepted_orgfile_by_year
		FROM dbo.v_latest_accepted_orgfile_by_year;

	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_latest_accepted_orgfile_by_year', NULL, @start_dt, getdate(), 'Tab 20 - Completed',@batch_id

	if exists (select 1 from [dbo].[tblCheckpoint] where Module = 'GenerateTableFromView')
	begin
		update [dbo].[tblCheckpoint] set [CheckPoint] = 20, [Timestamp] = getdate() where Module = 'GenerateTableFromView'
	end
	else
	begin
		insert into [dbo].[tblCheckpoint] ([Module], [CheckPoint], [Timestamp])
		select 'GenerateTableFromView', 20, getdate()
	end
end

--Table 21
if (@recovery_checkpoint < 21)
begin
	set @start_dt = getdate()

		IF OBJECT_ID('dbo.t_latest_pending_or_accepted_orgfile_by_year', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.t_latest_pending_or_accepted_orgfile_by_year;
		END;	

		SELECT *
		INTO dbo.t_latest_pending_or_accepted_orgfile_by_year
		FROM dbo.v_latest_pending_or_accepted_orgfile_by_year;

	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_latest_pending_or_accepted_orgfile_by_year', NULL, @start_dt, getdate(), 'Tab 21 - Completed',@batch_id

	delete from [dbo].[tblCheckpoint] where Module = 'GenerateTableFromView'

	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','procedure', NULL, @start_dt, getdate(), 'check point removed',@batch_id
end

	--Recording count from each table
	select @cnt =count(1) from dbo.t_cosmos_file_metadata;
	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_cosmos_file_metadata', @cnt, NULL, getdate(), 'Completed',@batch_id

	select @cnt =count(1) from dbo.t_pom_codes;
	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_pom_codes', @cnt, NULL, getdate(), 'Completed',@batch_id

	select @cnt =count(1) from dbo.t_POM;
	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_POM', @cnt, NULL, getdate(), 'Completed',@batch_id

	select @cnt =count(1) from dbo.t_Producer_CS_Lookup;
	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_Producer_CS_Lookup', @cnt, NULL, getdate(), 'Completed',@batch_id

	select @cnt =count(1) from dbo.t_Producer_CS_Lookup_Pivot;
	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_Producer_CS_Lookup_Pivot', @cnt, NULL, getdate(), 'Completed',@batch_id

	select @cnt =count(1) from dbo.t_Producer_CS_Lookup_Unpivot;
	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_Producer_CS_Lookup_Unpivot', @cnt, NULL, getdate(), 'Completed',@batch_id

	select @cnt =count(1) from dbo.t_rpd_data_SECURITY_FIX;
	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_rpd_data_SECURITY_FIX', @cnt, NULL, getdate(), 'Completed',@batch_id

	select @cnt =count(1) from dbo.t_POM_Submissions;
	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_POM_Submissions', @cnt, NULL, getdate(), 'Completed',@batch_id

	select @cnt =count(1) from dbo.t_POM_Operator_Submissions;
	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_POM_Operator_Submissions', @cnt, NULL, getdate(), 'Completed',@batch_id

	select @cnt =count(1) from dbo.t_registration_latest;
	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_registration_latest', @cnt, NULL, getdate(), 'Completed',@batch_id

	select @cnt =count(1) from dbo.t_POM_Filters;
	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_POM_Filters', @cnt, NULL, getdate(), 'Completed',@batch_id

	select @cnt =count(1) from dbo.t_POM_Com_Landing_Filter;
	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_POM_Com_Landing_Filter', @cnt, NULL, getdate(), 'Completed',@batch_id

	select @cnt =count(1) from dbo.t_POM_Submissions_POM_Comparison;
	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_POM_Submissions_POM_Comparison', @cnt, NULL, getdate(), 'Completed',@batch_id

	select @cnt =count(1) from dbo.t_registration_with_brandandpartner;
	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_registration_with_brandandpartner', @cnt, NULL, getdate(), 'Completed',@batch_id

	select @cnt =count(1) from dbo.t_POM_All_Submissions;
	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_POM_All_Submissions', @cnt, NULL, getdate(), 'Completed',@batch_id

	select @cnt =count(1) from dbo.t_new_enrolment_report;
	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_new_enrolment_report', @cnt, NULL, getdate(), 'Completed',@batch_id

	select @cnt =count(1) from dbo.t_enrolled_not_registered;
	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_enrolled_not_registered', @cnt, NULL, getdate(), 'Completed',@batch_id

	select @cnt =count(1) from dbo.t_CompanyBrandPartnerFileUploadSet;
	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_CompanyBrandPartnerFileUploadSet', @cnt, NULL, getdate(), 'Completed',@batch_id

	select @cnt =count(1) from dbo.t_Registration_Comparison_Landing_Page;
	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_Registration_Comparison_Landing_Page', @cnt, NULL, getdate(), 'Completed',@batch_id


	select @cnt =count(1) from dbo.t_latest_accepted_orgfile_by_year;
	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_latest_accepted_orgfile_by_year', @cnt, NULL, getdate(), 'Completed',@batch_id

	select @cnt =count(1) from dbo.t_latest_pending_or_accepted_orgfile_by_year;
	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_latest_pending_or_accepted_orgfile_by_year', @cnt, NULL, getdate(), 'Completed',@batch_id

END;