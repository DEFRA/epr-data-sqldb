CREATE PROC [dbo].[sp_LoopStatisticsUpdate] @FilterSchema [NVARCHAR](128),@FilterTable [NVARCHAR](128),@ForceRefresh [BIT] AS
BEGIN
    SET NOCOUNT ON;
	-- DROP AND RE-CREATE THE TABLE
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[StatisticsMaintenanceQueue]') AND type in (N'U'))
	DROP TABLE [dbo].[StatisticsMaintenanceQueue]

	-- Insert into the table
	SELECT 
	    s.name AS schema_name,
	    t.name AS table_name,
	    cast(NULL AS DATETIME) AS last_updated,
	    'PENDING' AS status,
		cast(Null as int) AS duration_seconds,
	    t.object_id
	INTO dbo.StatisticsMaintenanceQueue
	FROM sys.tables t
	JOIN sys.schemas s ON t.schema_id = s.schema_id
	WHERE 
	    t.is_external = 0 -- exclude external tables
	    AND t.name NOT LIKE '[_]%' -- optional: skip system/internal tables
	

    DECLARE @schema NVARCHAR(128), @table NVARCHAR(128),
            @updateSql NVARCHAR(MAX), @createStatsSql NVARCHAR(MAX),
            @startTime DATETIME2, @endTime DATETIME2;

    -- If force refresh requested, reset statuses to NULL for matching tables
    IF @ForceRefresh = 1
    --BEGIN
    --    UPDATE dbo.StatisticsMaintenanceQueue
    --    SET status = NULL, last_updated = NULL, duration_seconds = NULL
    --    WHERE (@FilterSchema IS NULL OR schema_name = @FilterSchema)
    --      AND (@FilterTable IS NULL OR table_name = @FilterTable);
    --END

    WHILE EXISTS (
        SELECT 1 
        FROM dbo.StatisticsMaintenanceQueue 
        WHERE (status IS NULL OR status = 'PENDING')
          AND (@FilterSchema IS NULL OR schema_name = @FilterSchema)
          AND (@FilterTable IS NULL OR table_name = @FilterTable)
    )
    BEGIN
        -- Pick next pending table with filters
        SELECT TOP 1 
            @schema = schema_name,
            @table = table_name
        FROM dbo.StatisticsMaintenanceQueue
        WHERE (status IS NULL OR status = 'PENDING')
          AND (@FilterSchema IS NULL OR schema_name = @FilterSchema)
          AND (@FilterTable IS NULL OR table_name = @FilterTable);

        BEGIN TRY
            SET @startTime = SYSUTCDATETIME();

            -- Update existing statistics
            SET @updateSql = 'UPDATE STATISTICS ' + QUOTENAME(@schema) + '.' + QUOTENAME(@table) + ';';
            EXEC sp_executesql @updateSql;

            -- Create missing statistics with FULLSCAN
            ;WITH MissingStats AS (
                SELECT 
                    c.name AS column_name,
                    'Stat_' + t.name + '_' + c.name AS stat_name
                FROM sys.columns c
                JOIN sys.tables t ON c.object_id = t.object_id
                JOIN sys.schemas s ON t.schema_id = s.schema_id
                LEFT JOIN sys.stats_columns sc 
                    ON sc.object_id = c.object_id AND sc.column_id = c.column_id
                LEFT JOIN sys.stats st 
                    ON st.object_id = c.object_id AND st.stats_id = sc.stats_id
                WHERE 
                    s.name = @schema AND t.name = @table
                    AND st.stats_id IS NULL
                    AND c.is_identity = 0
                    AND c.is_computed = 0
                    AND c.system_type_id IN (56, 127, 61, 62, 104, 106, 108, 167, 231) -- Codes for Common data types 
            )
            SELECT @createStatsSql = STRING_AGG(
                'IF NOT EXISTS (SELECT 1 FROM sys.stats WHERE name = ''' + stat_name + ''' AND object_id = OBJECT_ID(''' + @schema + '.' + @table + ''')) ' +
                'CREATE STATISTICS ' + QUOTENAME(stat_name) + 
                ' ON ' + QUOTENAME(@schema) + '.' + QUOTENAME(@table) + 
                ' (' + QUOTENAME(column_name) + ') WITH FULLSCAN;', CHAR(13)
            )
            FROM MissingStats;

            IF @createStatsSql IS NOT NULL
                EXEC sp_executesql @createStatsSql;

            SET @endTime = SYSUTCDATETIME();

            -- Mark success with duration
            UPDATE dbo.StatisticsMaintenanceQueue
            SET status = 'SUCCESS',
                last_updated = @endTime,
                duration_seconds = DATEDIFF(SECOND, @startTime, @endTime)
            WHERE schema_name = @schema AND table_name = @table;

        END TRY
        BEGIN CATCH
            SET @endTime = SYSUTCDATETIME();

            UPDATE dbo.StatisticsMaintenanceQueue
            SET status = 'FAILED',
                last_updated = @endTime,
                duration_seconds = DATEDIFF(SECOND, @startTime, @endTime)
            WHERE schema_name = @schema AND table_name = @table;

            PRINT 'Failed on ' + @schema + '.' + @table;
            PRINT 'Error: ' + ERROR_MESSAGE();
        END CATCH;
    END
END;