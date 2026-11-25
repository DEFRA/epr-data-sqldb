-- EMR-541: test post-deployment script. Safe to re-run; makes no changes.
-- SqlPackage doesn't show result sets or "(n rows affected)" in its log, so the
-- outcome is reported with PRINT instead.
PRINT CONCAT('post deployment script test - running on ', DB_NAME(), ' at ', CONVERT(varchar(19), SYSUTCDATETIME(), 120), ' UTC');

SELECT 'post deployment script test' AS post_deployment_test;
PRINT CONCAT(@@ROWCOUNT, ' row(s) affected');
