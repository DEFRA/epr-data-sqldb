CREATE PROC [dbo].[GenerateTableFromView] AS
BEGIN
    -- Disable row count for performance
    SET NOCOUNT ON;
	DECLARE @start_dt datetime;
	DECLARE @batch_id INT;
	DECLARE @cnt int;

	select @batch_id  = ISNULL(max(batch_id),0)+1 from [dbo].[batch_log]

INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','procedure', NULL, @start_dt, getdate(), 'Started',@batch_id

set @start_dt = getdate()

    IF OBJECT_ID('dbo.t_pom_codes', 'U') IS NOT NULL
    BEGIN
        DROP TABLE dbo.t_pom_codes;
    END;	

    SELECT *
    INTO dbo.t_pom_codes
    FROM dbo.v_pom_codes;

INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_pom_codes', NULL, @start_dt, getdate(), 'Completed',@batch_id


set @start_dt = getdate()


    IF OBJECT_ID('dbo.t_POM', 'U') IS NOT NULL
    BEGIN
        DROP TABLE dbo.t_POM;
    END;	

    SELECT *
    INTO dbo.t_POM
    FROM dbo.v_POM;

INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_POM', NULL, @start_dt, getdate(), 'Completed',@batch_id

set @start_dt = getdate()

    IF OBJECT_ID('dbo.t_Producer_CS_Lookup', 'U') IS NOT NULL
    BEGIN
        DROP TABLE dbo.t_Producer_CS_Lookup;
    END;	

    SELECT *
    INTO dbo.t_Producer_CS_Lookup
    FROM dbo.v_Producer_CS_Lookup;


INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_Producer_CS_Lookup', NULL, @start_dt, getdate(), 'Completed',@batch_id


set @start_dt = getdate()

    IF OBJECT_ID('dbo.t_Producer_CS_Lookup_Pivot', 'U') IS NOT NULL
    BEGIN
        DROP TABLE dbo.t_Producer_CS_Lookup_Pivot;
    END;	

    SELECT *
    INTO dbo.t_Producer_CS_Lookup_Pivot
    FROM dbo.v_Producer_CS_Lookup_Pivot;

INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_Producer_CS_Lookup_Pivot', NULL, @start_dt, getdate(), 'Completed',@batch_id

set @start_dt = getdate()

    IF OBJECT_ID('dbo.t_Producer_CS_Lookup_Unpivot', 'U') IS NOT NULL
    BEGIN
        DROP TABLE dbo.t_Producer_CS_Lookup_Unpivot;
    END;	

    SELECT *
    INTO dbo.t_Producer_CS_Lookup_Unpivot
    FROM dbo.v_Producer_CS_Lookup_Unpivot;

INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_Producer_CS_Lookup_Unpivot', NULL, @start_dt, getdate(), 'Completed',@batch_id

set @start_dt = getdate()

    IF OBJECT_ID('dbo.t_rpd_data_SECURITY_FIX', 'U') IS NOT NULL
    BEGIN
        DROP TABLE dbo.t_rpd_data_SECURITY_FIX;
    END;	

    SELECT *
    INTO dbo.t_rpd_data_SECURITY_FIX
    FROM dbo.v_rpd_data_SECURITY_FIX;

INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_rpd_data_SECURITY_FIX', NULL, @start_dt, getdate(), 'Completed',@batch_id

set @start_dt = getdate()

    IF OBJECT_ID('dbo.t_POM_Submissions', 'U') IS NOT NULL
    BEGIN
        DROP TABLE dbo.t_POM_Submissions;
    END;	

    SELECT *
    INTO dbo.t_POM_Submissions
    FROM dbo.v_POM_Submissions;

INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_POM_Submissions', NULL, @start_dt, getdate(), 'Completed',@batch_id

set @start_dt = getdate()

    IF OBJECT_ID('dbo.t_registration_latest', 'U') IS NOT NULL
    BEGIN
        DROP TABLE dbo.t_registration_latest;
    END;	

    SELECT *
    INTO dbo.t_registration_latest
    FROM dbo.v_registration_latest;


INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_registration_latest', NULL, @start_dt, getdate(), 'Completed',@batch_id

set @start_dt = getdate()

    IF OBJECT_ID('dbo.t_POM_Filters', 'U') IS NOT NULL
    BEGIN
        DROP TABLE dbo.t_POM_Filters;
    END;	

    SELECT *
    INTO dbo.t_POM_Filters
    FROM dbo.v_POM_Filters;


INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_POM_Filters', NULL, @start_dt, getdate(), 'Completed',@batch_id

set @start_dt = getdate()

    IF OBJECT_ID('dbo.t_POM_Com_Landing_Filter', 'U') IS NOT NULL
    BEGIN
        DROP TABLE dbo.t_POM_Com_Landing_Filter;
    END;	

    SELECT *
    INTO dbo.t_POM_Com_Landing_Filter
    FROM dbo.v_POM_Com_Landing_Filter;

INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_POM_Com_Landing_Filter', NULL, @start_dt, getdate(), 'Completed',@batch_id

set @start_dt = getdate()

    IF OBJECT_ID('dbo.t_POM_Submissions_POM_Comparison', 'U') IS NOT NULL
    BEGIN
        DROP TABLE dbo.t_POM_Submissions_POM_Comparison;
    END;	

    SELECT *
    INTO dbo.t_POM_Submissions_POM_Comparison
    FROM dbo.v_POM_Submissions_POM_Comparison;

INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_POM_Submissions_POM_Comparison', NULL, @start_dt, getdate(), 'Completed',@batch_id

set @start_dt = getdate()

    IF OBJECT_ID('dbo.t_registration_with_brandandpartner', 'U') IS NOT NULL
    BEGIN
        DROP TABLE dbo.t_registration_with_brandandpartner;
    END;	

    SELECT *
    INTO dbo.t_registration_with_brandandpartner
    FROM dbo.v_registration_with_brandandpartner;

INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_registration_with_brandandpartner', NULL, @start_dt, getdate(), 'Completed',@batch_id

set @start_dt = getdate()

    IF OBJECT_ID('dbo.t_POM_All_Submissions', 'U') IS NOT NULL
    BEGIN
        DROP TABLE dbo.t_POM_All_Submissions;
    END;	

    SELECT *
    INTO dbo.t_POM_All_Submissions
    FROM dbo.v_POM_All_Submissions;

INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_POM_All_Submissions', NULL, @start_dt, getdate(), 'Completed',@batch_id

set @start_dt = getdate()

    IF OBJECT_ID('dbo.t_enrolment_report', 'U') IS NOT NULL
    BEGIN
        DROP TABLE dbo.t_enrolment_report;
    END;	

    SELECT *
    INTO dbo.t_enrolment_report
    FROM dbo.v_enrolment_report;

INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_enrolment_report', NULL, @start_dt, getdate(), 'Completed',@batch_id


set @start_dt = getdate()

    IF OBJECT_ID('dbo.t_enrolled_not_registered', 'U') IS NOT NULL
    BEGIN
        DROP TABLE dbo.t_enrolled_not_registered;
    END;	

    SELECT *
    INTO dbo.t_enrolled_not_registered
    FROM dbo.enrolled_not_registered;

INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_enrolled_not_registered', NULL, @start_dt, getdate(), 'Completed',@batch_id


--Recording count from each table
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

select @cnt =count(1) from dbo.t_enrolment_report;
INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_enrolment_report', @cnt, NULL, getdate(), 'Completed',@batch_id


select @cnt =count(1) from dbo.t_enrolled_not_registered;
INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'GenerateTableFromView','t_enrolled_not_registered', @cnt, NULL, getdate(), 'Completed',@batch_id



END;