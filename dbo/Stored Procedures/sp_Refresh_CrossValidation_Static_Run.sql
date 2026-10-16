CREATE PROC [dbo].[sp_Refresh_CrossValidation_Static_Run] AS
BEGIN
    SET NOCOUNT ON;
    EXEC dbo.sp_Refresh_CrossValidation_Static @BuildFromYear = 2025;
END;
