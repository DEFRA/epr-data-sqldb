CREATE PROC [dbo].[sp_insert_log] @process [NVARCHAR](4000),@subprocess [NVARCHAR](4000),@cnt [INT],@start_time [datetime],@end_time [datetime],@msg [NVARCHAR](100) AS
begin
declare @max_id INT
select @max_id = ISNULL(max(ID),0)+1 from [dbo].[batch_log]
print @max_id
	INSERT INTO [dbo].[batch_log]
           ([ID]
           ,[ProcessName]
           ,[SubProcessName]
           ,[Count]
           ,[start_time_stamp]
           ,[end_time_stamp]
           ,[Comments]
           ,[batch_id])
	select 
           @max_id
           ,@process
           ,@subprocess
           ,@cnt
           ,@start_time
           ,@end_time
           ,@msg
           ,NULL

end;