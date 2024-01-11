﻿CREATE PROC [dbo].[GenerateTableFromView] AS
BEGIN
    -- Disable row count for performance
    SET NOCOUNT ON;


    -- Variables for SQL query generation
    DECLARE @SqlQuery NVARCHAR(MAX) = ' ',
            @tableviews NVARCHAR(MAX) = 'v_POM,v_rpd_data_SECURITY_FIX,v_POM_Submissions,v_POM_Filters,v_POM_Submissions_POM_Comparison',
            @Counter INT = 1,
            @TotalRows INT;


    -- Drop the temporary table if it already exists
    IF OBJECT_ID('tempdb..#TableList', 'U') IS NOT NULL
        DROP TABLE #TableList;


    -- Populate the temporary table
    SELECT 
		REPLACE(viewname, 'v_', '') AS ObjName,
		ROW_NUMBER() OVER (ORDER BY CHARINDEX(viewname, @tableviews)) AS ProcessOrder
    INTO #TableList
    FROM (
             SELECT CAST(value AS NVARCHAR(100)) ViewName
             FROM STRING_SPLIT(REPLACE(@tableviews, ' ', ''), ',')
         ) tl
         JOIN information_schema.views vw ON vw.table_name = tl.viewname
    WHERE vw.table_schema = 'dbo';


    -- Set @TotalRows to the count of rows in #TableList
    SELECT @TotalRows = COUNT(1)
    FROM #TableList;


    -- Iterate over the rows in #TableList to build the dynamic SQL
    WHILE @Counter <= @TotalRows
    BEGIN
        DECLARE @ObjName NVARCHAR(MAX);


        SELECT @ObjName = ObjName
		FROM #TableList
		WHERE ProcessOrder = @Counter;;


        -- Build dynamic SQL for table creation and data insertion
        SET @SqlQuery = @SqlQuery + '		   
/*Load column structural changes in temp table, this also works for missing t_ table*/  
SELECT * 
INTO tempdb..#c_' + @ObjName + '
FROM (
    (
	SELECT column_name
    FROM   information_schema.columns
    WHERE  table_name = ''v_' + @ObjName + '''
            AND table_schema = ''dbo''
    EXCEPT
    SELECT column_name
    FROM   information_schema.columns
    WHERE  table_name = ''t_' + @ObjName + '''
            AND table_schema = ''dbo''
			)
    UNION ALL
	(
    SELECT column_name
    FROM   information_schema.columns
    WHERE  table_name = ''t_' + @ObjName + '''
            AND table_schema = ''dbo''
    EXCEPT
    SELECT column_name
    FROM   information_schema.columns
    WHERE  table_name = ''v_' + @ObjName + '''
            AND table_schema = ''dbo''
		)
) c;

/*1. If t_ table does not exist or structure is different, create t_ table from v_ view*/
IF EXISTS (SELECT TOP 1 1 FROM tempdb..#c_' + @ObjName + ') 
	/*Drop and recreate t_ table from v_ view*/
	BEGIN 
		IF OBJECT_ID(''dbo.t_' + @ObjName + ''', ''U'') IS NOT NULL
		 BEGIN
			DROP TABLE dbo.t_' + @ObjName + ';
		 END

		 SELECT *
		 INTO dbo.t_' + @ObjName + '
		 FROM dbo.v_' + @ObjName + ';
	END
ELSE 
	BEGIN
	/*Load all records into temp tables*/
	SELECT * INTO tempdb..#v_' + @ObjName + ' FROM dbo.v_' + @ObjName + ';
	SELECT * INTO tempdb..#t_' + @ObjName + ' FROM dbo.t_' + @ObjName + ';

	/*Insert new and deleted records into temp tables*/
	SELECT * INTO tempdb..#n_' + @ObjName + ' FROM tempdb..#v_' + @ObjName + ' EXCEPT SELECT * FROM tempdb..#t_' + @ObjName + ';
	SELECT * INTO tempdb..#m_' + @ObjName + ' FROM tempdb..#t_' + @ObjName + ' EXCEPT SELECT * FROM tempdb..#v_' + @ObjName + ';

	/*2. If records have been removed from v_ view*/
	IF EXISTS (SELECT TOP 1 1 FROM tempdb..#m_' + @ObjName + ') 
		/*Drop and recreate t_ table from v_ view*/
		BEGIN 
			 DROP TABLE dbo.t_' + @ObjName + ';
			 SELECT *
			 INTO dbo.t_' + @ObjName + '
			 FROM tempdb..#v_' + @ObjName + ';
		END

	/*3. If records have been added to v_ view*/
	IF EXISTS (SELECT TOP 1 1 FROM tempdb..#n_' + @ObjName + ')
	   BEGIN
		  /*Insert the new records into t_' + @ObjName + '*/
		  INSERT INTO dbo.t_' + @ObjName + '
		  SELECT *
		  FROM tempdb..#n_' + @ObjName + ';
	   END
	END

/*4. If t_ table exists, and structures are the same and the data is exactly the same, do nothing*/
/*No action needed in this case*/

/*Cleanup temporary tables*/
IF OBJECT_ID(''tempdb..#c_' + @ObjName + ''', ''U'') IS NOT NULL BEGIN DROP TABLE tempdb..#c_' + @ObjName + ' END;
IF OBJECT_ID(''tempdb..#v_' + @ObjName + ''', ''U'') IS NOT NULL BEGIN DROP TABLE tempdb..#v_' + @ObjName + ' END;
IF OBJECT_ID(''tempdb..#t_' + @ObjName + ''', ''U'') IS NOT NULL BEGIN DROP TABLE tempdb..#t_' + @ObjName + ' END;
IF OBJECT_ID(''tempdb..#n_' + @ObjName + ''', ''U'') IS NOT NULL BEGIN DROP TABLE tempdb..#n_' + @ObjName + ' END;
IF OBJECT_ID(''tempdb..#m_' + @ObjName + ''', ''U'') IS NOT NULL BEGIN DROP TABLE tempdb..#m_' + @ObjName + ' END;
';



        SET @Counter = @Counter + 1;
    END


    -- Drop the temporary table outside of any transaction
    IF OBJECT_ID('tempdb..#TableList', 'U') IS NOT NULL
        DROP TABLE #TableList;


    -- Output the generated SQL query (commented out for production)
    -- SELECT @SqlQuery AS 'GeneratedSQLQuery';


    -- Execute the dynamic SQL query
    BEGIN TRY
        EXEC sp_executesql @SqlQuery;
    END TRY
    BEGIN CATCH
        -- Error handling
        PRINT 'An error occurred during execution.';
    END CATCH;
END;