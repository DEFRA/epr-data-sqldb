CREATE PROC [dbo].[sp_gather_stats] AS
/****************************************************************************************************************************
	History:
	Created: 2025-12-08:	AA001:	Ticket - 646706:	To gather stats and to rebuild the table index for better performance
******************************************************************************************************************************/
begin

    SET NOCOUNT ON;
	DECLARE @start_dt datetime;
	DECLARE @batch_id INT;


begin try
	select @batch_id  = ISNULL(max(batch_id),0)+1 from [dbo].[batch_log]
	
	set @start_dt = getdate()

	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'sp_gather_stats','procedure', NULL, @start_dt, getdate(), 'Started',@batch_id
	--
	UPDATE STATISTICS rpd.organisations;
	UPDATE STATISTICS rpd.pom;
	UPDATE STATISTICS rpd.companydetails;
	UPDATE STATISTICS rpd.cosmos_file_metadata;
	UPDATE STATISTICS rpd.enrolments;
	--
	ALTER INDEX ALL 
	ON rpd.organisations
	REBUILD;
	--
	ALTER INDEX ALL 
	ON rpd.pom
	REBUILD;
	--
	ALTER INDEX ALL 
	ON rpd.companydetails
	REBUILD;
	--
	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'sp_gather_stats','procedure', NULL, @start_dt, getdate(), 'Completed',@batch_id

end try
begin catch 
	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'sp_gather_stats','procedure', NULL, @start_dt, getdate(), 'Error',@batch_id

end catch

end;