CREATE PROCEDURE [apps].[sp_GetActualSubmissionPeriod]
    @SubmissionId [nvarchar](50),
    @SubmissionPeriod [nvarchar](50)
AS
BEGIN
	SELECT TOP 1 ActualSubmissionPeriod 
	FROM apps.SubmissionsSummaries 
	WHERE SubmissionId=@SubmissionId AND SubmissionPeriod=@SubmissionPeriod
END
