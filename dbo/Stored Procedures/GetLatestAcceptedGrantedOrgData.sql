CREATE PROC [dbo].[GetLatestAcceptedGrantedOrgData]
    @approvedAfter DATETIME,
    @relativeYear INT
AS
BEGIN
	DECLARE @start_dt datetime;
	DECLARE @batch_id INT;
	DECLARE @cnt int;

	select @batch_id  = ISNULL(max(batch_id),0)+1 from [dbo].[batch_log]
	set @start_dt = getdate();
    IF @approvedAfter IS NOT NULL
    BEGIN
    WITH CTE AS (SELECT *
        FROM [rpd].[LatestAcceptedGrantedOrg]
        where CONVERT(DATETIME,substring(Decision_Date,1,23)) >= @approvedAfter
        AND (@relativeYear IS NULL OR relative_year = @relativeYear))

        SELECT * FROM rpd.LatestAcceptedGrantedOrg lago
        WHERE EXISTS (SELECT organisation_id FROM CTE WHERE lago.[organisation_id] = CTE.organisation_id)
        AND (@relativeYear IS NULL OR lago.relative_year = @relativeYear)
        END
    ELSE
    BEGIN
        SELECT *
        FROM [rpd].[LatestAcceptedGrantedOrg]
        WHERE (@relativeYear IS NULL OR relative_year = @relativeYear);
        END

	INSERT INTO [dbo].[batch_log] ([ID],[ProcessName],[SubProcessName],[Count],[start_time_stamp],[end_time_stamp],[Comments],batch_id)
	select (select ISNULL(max(id),1)+1 from [dbo].[batch_log]),'dbo.GetLatestAcceptedGrantedOrgData',@approvedAfter, NULL, @start_dt, getdate(), 'approvedAfter',@batch_id
END
