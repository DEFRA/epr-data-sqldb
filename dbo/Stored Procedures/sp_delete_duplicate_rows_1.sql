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
    [SubmissionId], [FileId], [UserId], [BlobName], [BlobContainerName], [FileType], [Created], [OriginalFileName], [RegistrationSetId], [OrganisationId], [DataSourceType], [SubmissionPeriod],
    [IsSubmitted], [SubmissionType], [ComplianceSchemeId], [TargetDirectoryName], [TargetContainerName], [SourceContainerName], [FileName],
    ROW_NUMBER() OVER (PARTITION BY [FileName] ORDER BY created,load_ts DESC) AS rnk
  FROM
    rpd.cosmos_file_metadata
)

DELETE a

FROM  rpd.cosmos_file_metadata a
left JOIN RowsToDelete b
  ON isnull(a.[SubmissionId],'') = isnull(b.[SubmissionId],'')
  AND isnull(a.[FileId],'') = isnull(b.[FileId],'')
  AND isnull(a.[UserId],'') = isnull(b.[UserId],'')
  AND isnull(a.[BlobName],'') = isnull(b.[BlobName],'')
  AND isnull(a.[BlobContainerName],'') = isnull(b.[BlobContainerName],'')
  AND isnull(a.[FileType] ,'')= isnull(b.[FileType],'')
  AND isnull(a.[Created],'') = isnull(b.[Created],'')
  AND isnull(a.[OriginalFileName],'') = isnull(b.[OriginalFileName],'')
  AND isnull(a.[RegistrationSetId],'') = isnull(b.[RegistrationSetId],'')
  AND isnull(a.[OrganisationId] ,'')= isnull(b.[OrganisationId],'')
  AND isnull(a.[DataSourceType],'') = isnull(b.[DataSourceType],'')
  AND isnull(a.[SubmissionPeriod],'') = isnull(b.[SubmissionPeriod],'')
  AND isnull(a.[IsSubmitted],'') = isnull(b.[IsSubmitted],'')
  AND isnull(a.[SubmissionType],'') = isnull(b.[SubmissionType],'')
  AND isnull(a.[ComplianceSchemeId],'') = isnull(b.[ComplianceSchemeId],'')
  AND isnull(a.[TargetDirectoryName],'') = isnull(b.[TargetDirectoryName],'')
  AND isnull(a.[TargetContainerName],'') = isnull(b.[TargetContainerName],'')
  AND isnull(a.[SourceContainerName],'') = isnull(b.[SourceContainerName],'')
  AND isnull(a.[FileName],'') = isnull(b.[FileName],'')
WHERE b.rnk > 1;



--submissions
WITH RowsToDelete_submissions AS (
  SELECT
		--OrganisationMembers,
		Created,OrganisationId
		,IsSubmitted,
		--Comments,
		--IsResubmissionRequired,
		AppReferenceNumber,DataSourceType,
		--SubmissionEventId,
		SubmissionPeriod,SubmissionType,SubmissionId,
		--Decision,
		--RegulatorDecision,
		--FileId,
		--RejectionComments,
		id,UserId,
		--SubmittedBy,
		--IsResubmission,
		--Type,
		ComplianceSchemeId,load_ts
    ,Rank() OVER (PARTITION BY 
			--OrganisationMembers,
		Created,OrganisationId
		--,IsSubmitted
		
		--Comments,
		--IsResubmissionRequired,
		--,AppReferenceNumber
		,DataSourceType,
		--SubmissionEventId,
		SubmissionPeriod,SubmissionType,SubmissionId,
		--Decision,
		--RegulatorDecision,
		--FileId,
		--RejectionComments,
		id,UserId,
		--SubmittedBy,
		--IsResubmission,
		--Type,
		ComplianceSchemeId
	ORDER BY load_ts DESC) AS rnk
  FROM
    rpd.submissions
)



DELETE a
FROM  rpd.submissions a
left JOIN RowsToDelete_submissions b
  ON   --isnull(a.OrganisationMembers,'') = isnull(b.OrganisationMembers,'')
	--and 
	isnull(a.Created,'') = isnull(b.Created,'')
	and isnull(a.OrganisationId,'') = isnull(b.OrganisationId,'')
	and isnull(a.IsSubmitted,'') = isnull(b.IsSubmitted,'')
	--and isnull(a.Comments,'') = isnull(b.Comments,'')
	--and isnull(a.IsResubmissionRequired,'') = isnull(b.IsResubmissionRequired,'')
	and isnull(a.AppReferenceNumber,'') = isnull(b.AppReferenceNumber,'')
	and isnull(a.DataSourceType,'') = isnull(b.DataSourceType,'')
	--and isnull(a.SubmissionEventId,'') = isnull(b.SubmissionEventId,'')
	and isnull(a.SubmissionPeriod,'') = isnull(b.SubmissionPeriod,'')
	and isnull(a.SubmissionType,'') = isnull(b.SubmissionType,'')
	and isnull(a.SubmissionId,'') = isnull(b.SubmissionId,'')
	--and isnull(a.Decision,'') = isnull(b.Decision,'')
	--and isnull(a.RegulatorDecision,'') = isnull(b.RegulatorDecision,'')
	--and isnull(a.FileId,'') = isnull(b.FileId,'')
	--and isnull(a.RejectionComments,'') = isnull(b.RejectionComments,'')
	and isnull(a.id,'') = isnull(b.id,'')
	and isnull(a.UserId,'') = isnull(b.UserId,'')
	--and isnull(a.SubmittedBy,'') = isnull(b.SubmittedBy,'')
	--and isnull(a.IsResubmission,'') = isnull(b.IsResubmission,'')
	--and isnull(a.Type,'') = isnull(b.Type,'')
	and isnull(a.ComplianceSchemeId,'') = isnull(b.ComplianceSchemeId,'')
	and isnull(a.load_ts,'') = isnull(b.load_ts,'')
WHERE b.rnk > 1;
 

 --submissionevents
--submissionevents
WITH RowsToDelete_submissionsevents AS (
  SELECT
		--IsPackagingResubmissionFeeViewed,
		PaidAmount,
		--OrganisationMembers,
		--DecisionDate,
		RequiresRowValidation,
		--IsResubmitted,
		PaymentStatus,Created,
		--OrganisationId,
		RequiresBrandsFile,ErrorCount,WarningCount,OrganisationMemberCount,UserEmail,RegistrationReferenceNumber,Comments,RegistrationSetId,IsResubmissionRequired,AppReferenceNumber,
		--DataSourceType,
		ApplicationReferenceNumber,SubmissionDate,SubmissionEventId,DataCount,
		--SubmissionPeriod,
		RowErrorCount,
		--SubmissionType,
		HasMaxRowErrors,
		--RequiresValidation,
		ContentScan,
		--CompanyDetailsFileId,
		SubmissionId,Decision,
		--RegulatorDecision,
		--PackagingResubmissionReferenceNumber,
		FileId,
		--RejectionComments,
		IsValid,BlobName,AntivirusScanResult,id,RequiresPartnershipsFile,Errors,FileName,AntivirusScanTrigger,
		--ResubmissionRequired,
		FileType,UserId,ProducerId,SubmittedBy,
		--HasWarnings,
		--OrganisationMembersCount,
		--RegulatorUserId,
		PaymentMethod,
		--IsResubmission,
		Type,BlobContainerName,load_ts
    ,Rank() OVER (PARTITION BY 
			--IsPackagingResubmissionFeeViewed,
			PaidAmount,
			--OrganisationMembers,
			--DecisionDate,
			RequiresRowValidation,
			--IsResubmitted,
			PaymentStatus,Created,
			--OrganisationId,
			RequiresBrandsFile,ErrorCount,WarningCount,OrganisationMemberCount,UserEmail,RegistrationReferenceNumber,Comments,RegistrationSetId,IsResubmissionRequired,AppReferenceNumber,
			--DataSourceType,
			ApplicationReferenceNumber,SubmissionDate,SubmissionEventId,DataCount,
			--SubmissionPeriod,
			RowErrorCount,
			--SubmissionType,
			HasMaxRowErrors,
			--RequiresValidation,
			ContentScan,
			--CompanyDetailsFileId,
			SubmissionId,Decision,
			--RegulatorDecision,
			--PackagingResubmissionReferenceNumber,
			FileId,
			--RejectionComments,
			IsValid,BlobName,AntivirusScanResult,id,RequiresPartnershipsFile,Errors,FileName,AntivirusScanTrigger,
			--ResubmissionRequired,
			FileType,UserId,ProducerId,SubmittedBy,
			--HasWarnings,
			--OrganisationMembersCount,
			--RegulatorUserId,
			PaymentMethod,
			--IsResubmission,
			Type,BlobContainerName ORDER BY load_ts DESC) AS rnk
  FROM
    rpd.SubmissionEvents
)


DELETE a
FROM  rpd.SubmissionEvents a
inner JOIN RowsToDelete_submissionsevents b
  ON  
--	  isnull(a.IsPackagingResubmissionFeeViewed,'')  = isnull(b.IsPackagingResubmissionFeeViewed,'')
--and   
isnull(a.PaidAmount,'')  = isnull(b.PaidAmount,'')
--and   isnull(a.OrganisationMembers,'')  = isnull(b.OrganisationMembers,'')
--and   isnull(a.DecisionDate,'')  = isnull(b.DecisionDate,'')
and   isnull(a.RequiresRowValidation,'')  = isnull(b.RequiresRowValidation,'')
--and   isnull(a.IsResubmitted,'')  = isnull(b.IsResubmitted,'')
and   isnull(a.PaymentStatus,'')  = isnull(b.PaymentStatus,'')
and   isnull(a.Created,'')  = isnull(b.Created,'')
--and   isnull(a.OrganisationId,'')  = isnull(b.OrganisationId,'')
and   isnull(a.RequiresBrandsFile,'')  = isnull(b.RequiresBrandsFile,'')
and   isnull(a.ErrorCount,'')  = isnull(b.ErrorCount,'')
and   isnull(a.WarningCount,'')  = isnull(b.WarningCount,'')
and   isnull(a.OrganisationMemberCount,'')  = isnull(b.OrganisationMemberCount,'')
and   isnull(a.UserEmail,'')  = isnull(b.UserEmail,'')
and   isnull(a.RegistrationReferenceNumber,'')  = isnull(b.RegistrationReferenceNumber,'')
and   isnull(a.Comments,'')  = isnull(b.Comments,'')
and   isnull(a.RegistrationSetId,'')  = isnull(b.RegistrationSetId,'')
and   isnull(a.IsResubmissionRequired,'')  = isnull(b.IsResubmissionRequired,'')
and   isnull(a.AppReferenceNumber,'')  = isnull(b.AppReferenceNumber,'')
--and   isnull(a.DataSourceType,'')  = isnull(b.DataSourceType,'')
and   isnull(a.ApplicationReferenceNumber,'')  = isnull(b.ApplicationReferenceNumber,'')
and   isnull(a.SubmissionDate,'')  = isnull(b.SubmissionDate,'')
and   isnull(a.SubmissionEventId,'')  = isnull(b.SubmissionEventId,'')
and   isnull(a.DataCount,'')  = isnull(b.DataCount,'')
--and   isnull(a.SubmissionPeriod,'')  = isnull(b.SubmissionPeriod,'')
and   isnull(a.RowErrorCount,'')  = isnull(b.RowErrorCount,'')
--and   isnull(a.SubmissionType,'')  = isnull(b.SubmissionType,'')
and   isnull(a.HasMaxRowErrors,'')  = isnull(b.HasMaxRowErrors,'')
--and   isnull(a.RequiresValidation,'')  = isnull(b.RequiresValidation,'')
and   isnull(a.ContentScan,'')  = isnull(b.ContentScan,'')
--and   isnull(a.CompanyDetailsFileId,'')  = isnull(b.CompanyDetailsFileId,'')
and   isnull(a.SubmissionId,'')  = isnull(b.SubmissionId,'')
and   isnull(a.Decision,'')  = isnull(b.Decision,'')
--and   isnull(a.RegulatorDecision,'')  = isnull(b.RegulatorDecision,'')
--and   isnull(a.PackagingResubmissionReferenceNumber,'')  = isnull(b.PackagingResubmissionReferenceNumber,'')
and   isnull(a.FileId,'')  = isnull(b.FileId,'')
--and   isnull(a.RejectionComments,'')  = isnull(b.RejectionComments,'')
and   isnull(a.IsValid,'')  = isnull(b.IsValid,'')
and   isnull(a.BlobName,'')  = isnull(b.BlobName,'')
and   isnull(a.AntivirusScanResult,'')  = isnull(b.AntivirusScanResult,'')
and   isnull(a.id,'')  = isnull(b.id,'')
and   isnull(a.RequiresPartnershipsFile,'')  = isnull(b.RequiresPartnershipsFile,'')
and   isnull(a.Errors,'')  = isnull(b.Errors,'')
and   isnull(a.FileName,'')  = isnull(b.FileName,'')
and   isnull(a.AntivirusScanTrigger,'')  = isnull(b.AntivirusScanTrigger,'')
--and   isnull(a.ResubmissionRequired,'')  = isnull(b.ResubmissionRequired,'')
and   isnull(a.FileType,'')  = isnull(b.FileType,'')
and   isnull(a.UserId,'')  = isnull(b.UserId,'')
and   isnull(a.ProducerId,'')  = isnull(b.ProducerId,'')
and   isnull(a.SubmittedBy,'')  = isnull(b.SubmittedBy,'')
--and   isnull(a.HasWarnings,'')  = isnull(b.HasWarnings,'')
--and   isnull(a.OrganisationMembersCount,'')  = isnull(b.OrganisationMembersCount,'')
--and   isnull(a.RegulatorUserId,'')  = isnull(b.RegulatorUserId,'')
and   isnull(a.PaymentMethod,'')  = isnull(b.PaymentMethod,'')
--and   isnull(a.IsResubmission,'')  = isnull(b.IsResubmission,'')
and   isnull(a.Type,'')  = isnull(b.Type,'')
and   isnull(a.BlobContainerName,'')  = isnull(b.BlobContainerName,'')
and		a.load_ts = b.load_ts
WHERE b.rnk > 1;




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