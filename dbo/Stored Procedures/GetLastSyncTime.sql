CREATE PROC [dbo].[GetLastSyncTime] AS
BEGIN
    SELECT MAX(load_ts) as LastSyncTime
    from apps.SubmissionEvents
END