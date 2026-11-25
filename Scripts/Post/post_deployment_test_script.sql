-- EMR-541: test post-deployment script. Safe to re-run; makes no changes.
-- Runs on the Synapse dedicated SQL pool, which doesn't support @@ROWCOUNT, and
-- SqlPackage doesn't show result sets - so the outcome is reported with PRINT.
PRINT CONCAT('post deployment script test - running on ', DB_NAME(), ' at ', CONVERT(varchar(19), SYSUTCDATETIME(), 120), ' UTC');

DECLARE @rows int;
SET @rows = (SELECT COUNT(*) FROM (SELECT 'post deployment script test' AS post_deployment_test) AS t);
PRINT CONCAT(@rows, ' row(s) returned');
