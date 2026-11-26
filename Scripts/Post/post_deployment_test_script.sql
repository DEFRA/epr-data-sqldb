-- EMR-541: test post-deployment script. Safe to re-run; leaves nothing behind
-- (uses a session temp table, dropped at the end).
--
-- Runs on the Synapse dedicated SQL pool, which doesn't support @@ROWCOUNT, and
-- SqlPackage doesn't show result sets - so rows affected are measured as a
-- before/after count and reported with PRINT.
PRINT CONCAT('post deployment script test - running on ', DB_NAME(), ' at ', CONVERT(varchar(19), SYSUTCDATETIME(), 120), ' UTC');

CREATE TABLE #post_deploy_test
(
    id   int          NOT NULL,
    note varchar(100) NOT NULL
)
WITH (DISTRIBUTION = ROUND_ROBIN, HEAP);

DECLARE @before int, @after int;
SET @before = (SELECT COUNT(*) FROM #post_deploy_test);

-- Dedicated SQL pools allow only one row per INSERT ... VALUES, so use INSERT ... SELECT for several rows.
INSERT INTO #post_deploy_test (id, note)
SELECT 1, 'post deployment script test - row 1'
UNION ALL
SELECT 2, 'post deployment script test - row 2';

SET @after = (SELECT COUNT(*) FROM #post_deploy_test);
PRINT CONCAT(@after - @before, ' row(s) inserted into #post_deploy_test');

DROP TABLE #post_deploy_test;
PRINT 'post deployment script test - completed';
