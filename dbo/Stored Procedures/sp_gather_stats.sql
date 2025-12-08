CREATE PROC [dbo].[sp_gather_stats] AS
begin
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
end;