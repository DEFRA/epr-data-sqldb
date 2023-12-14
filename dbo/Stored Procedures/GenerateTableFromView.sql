CREATE PROC [dbo].[GenerateTableFromView] AS
BEGIN
 
--select top 10 * from POM_Filters
IF OBJECT_ID('dbo.t_POM_Submissions', 'U') IS NOT NULL
BEGIN
    -- Drop the table if it exists
    DROP TABLE dbo.t_POM_Submissions;
END
 
select * 
into dbo.t_POM_Submissions
from dbo.v_POM_Submissions
 
 
end