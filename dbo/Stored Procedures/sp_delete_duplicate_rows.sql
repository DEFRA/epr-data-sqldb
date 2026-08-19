CREATE PROC [dbo].[sp_delete_duplicate_rows] AS
BEGIN TRY

	DECLARE @start_dt datetime;
	DECLARE @batch_id INT;
	DECLARE @cnt int;

	select @batch_id  = ISNULL(max(batch_id),0)+1 from [dbo].[batch_log]

	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'sp_delete_duplicate_rows','procedure', NULL, @start_dt, getdate(), 'Started',@batch_id;


	select @cnt =count(1) from rpd.cosmos_file_metadata;
	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'sp_delete_duplicate_rows','rpd.cosmos_file_metadata', @cnt, NULL, getdate(), 'count-before',@batch_id;

	select @cnt =count(1) from rpd.submissions;
	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'sp_delete_duplicate_rows','rpd.submissions', @cnt, NULL, getdate(), 'count-before',@batch_id;

	select @cnt =count(1) from rpd.submissionEvents;
	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'sp_delete_duplicate_rows','rpd.submissionEvents', @cnt, NULL, getdate(), 'count-before',@batch_id;

	select @cnt =count(distinct SubmissionEventId) from rpd.submissionEvents;
	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'sp_delete_duplicate_rows','rpd.submissionEvents-distinct-SubmissionEventId', @cnt, NULL, getdate(), 'count-before',@batch_id;

	select @cnt =count(distinct Id) from rpd.submissionEvents;
	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'sp_delete_duplicate_rows','rpd.submissionEvents-distinct-Id', @cnt, NULL, getdate(), 'count-before',@batch_id;

	select @cnt =count(1)
	from
	(
		select Id  from [rpd].[SubmissionEvents]
		group by ID
		having count(1) > 1
	) A
	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'sp_delete_duplicate_rows','rpd.submissionEvents-Duplicate-Id-count', @cnt, NULL, getdate(), 'count-before',@batch_id;

	select @cnt =count(distinct SubmissionId) from rpd.submissions;
	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'sp_delete_duplicate_rows','rpd.submissions-distinct-SubmissionId', @cnt, NULL, getdate(), 'count-before',@batch_id;

	select @cnt =count(distinct Id) from rpd.submissions;
	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'sp_delete_duplicate_rows','rpd.submissions-distinct-Id', @cnt, NULL, getdate(), 'count-before',@batch_id;

--rpd.cosmos_file_metadata
WITH RowsToDelete AS (
  SELECT
    ROW_NUMBER() OVER (PARTITION BY [FileName] ORDER BY created,load_ts DESC) AS rnk
  FROM
    rpd.cosmos_file_metadata
)
DELETE FROM RowsToDelete WHERE rnk > 1;


--submissions
WITH RowsToDelete_submissions AS (
  SELECT
    ROW_NUMBER() OVER (PARTITION BY
		Created,OrganisationId
		,DataSourceType,
		SubmissionPeriod,SubmissionType,SubmissionId,
		id,UserId,
		ComplianceSchemeId
	ORDER BY load_ts DESC) AS rnk
  FROM
    rpd.submissions
)
DELETE FROM RowsToDelete_submissions WHERE rnk > 1;


--submissionevents
WITH RowsToDelete_submissionsevents AS (
  SELECT
    ROW_NUMBER() OVER (PARTITION BY
			PaidAmount,
			RequiresRowValidation,
			PaymentStatus,Created,
			RequiresBrandsFile,ErrorCount,WarningCount,OrganisationMemberCount,UserEmail,RegistrationReferenceNumber,Comments,RegistrationSetId,IsResubmissionRequired,AppReferenceNumber,
			ApplicationReferenceNumber,SubmissionDate,SubmissionEventId,DataCount,
			RowErrorCount,
			HasMaxRowErrors,
			ContentScan,
			SubmissionId,Decision,
			FileId,
			IsValid,BlobName,AntivirusScanResult,id,RequiresPartnershipsFile,Errors,FileName,AntivirusScanTrigger,
			FileType,UserId,ProducerId,SubmittedBy,
			PaymentMethod,
			Type,BlobContainerName ORDER BY load_ts DESC) AS rnk
  FROM
    rpd.SubmissionEvents
)
DELETE FROM RowsToDelete_submissionsevents WHERE rnk > 1;


	select @cnt =count(1) from rpd.cosmos_file_metadata;
	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'sp_delete_duplicate_rows','rpd.cosmos_file_metadata', @cnt, NULL, getdate(), 'count-after',@batch_id;

	select @cnt =count(1) from rpd.submissions;
	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'sp_delete_duplicate_rows','rpd.submissions', @cnt, NULL, getdate(), 'count-after',@batch_id;

	select @cnt =count(1) from rpd.submissionEvents;
	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'sp_delete_duplicate_rows','rpd.submissionEvents', @cnt, NULL, getdate(), 'count-after',@batch_id;

	select @cnt =count(distinct SubmissionEventId) from rpd.submissionEvents;
	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'sp_delete_duplicate_rows','rpd.submissionEvents-distinct-SubmissionEventId', @cnt, NULL, getdate(), 'count-after',@batch_id;

	select @cnt =count(distinct Id) from rpd.submissionEvents;
	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'sp_delete_duplicate_rows','rpd.submissionEvents-distinct-Id', @cnt, NULL, getdate(), 'count-after',@batch_id;

	select @cnt =count(1)
	from
	(
		select Id  from [rpd].[SubmissionEvents]
		group by ID
		having count(1) > 1
	) A
	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'sp_delete_duplicate_rows','rpd.submissionEvents-Duplicate-Id-count', @cnt, NULL, getdate(), 'count-after',@batch_id;

	select @cnt =count(distinct SubmissionId) from rpd.submissions;
	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'sp_delete_duplicate_rows','rpd.submissions-distinct-SubmissionId', @cnt, NULL, getdate(), 'count-after',@batch_id;

	select @cnt =count(distinct Id) from rpd.submissions;
	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'sp_delete_duplicate_rows','rpd.submissions-distinct-Id', @cnt, NULL, getdate(), 'count-after',@batch_id;

	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'sp_delete_duplicate_rows','procedure', NULL, @start_dt, getdate(), 'Completed',@batch_id;

END TRY
BEGIN CATCH
	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'sp_delete_duplicate_rows','Error - ' + ISNULL(ERROR_MESSAGE(),'No msg 1'), NULL, @start_dt, getdate(), 'Error',@batch_id
END CATCH