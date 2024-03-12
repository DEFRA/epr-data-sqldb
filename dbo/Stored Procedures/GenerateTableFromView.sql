CREATE PROC [dbo].[GenerateTableFromView] AS
BEGIN
    -- Disable row count for performance
    SET NOCOUNT ON;


    -- Variables for SQL query generation
    DECLARE @SqlQuery NVARCHAR(MAX) = ' ',
            @tableviews NVARCHAR(MAX) = 'v_pom_codes,
                                         v_POM,
										 v_Producer_CS_Lookup,
										 v_Producer_CS_Lookup_Pivot,
										 v_Producer_CS_Lookup_Unpivot,
										 v_rpd_data_SECURITY_FIX,
										 v_POM_Submissions,
										 v_registration_latest,
										 v_POM_Filters,
										 v_POM_Com_Landing_Filter,
										 v_POM_Submissions_POM_Comparison,
										 v_registration_with_brandandpartner,
										 v_POM_Submissions_pm_250363',
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
             FROM STRING_SPLIT(REPLACE
			                  (REPLACE
							  (REPLACE
							  (REPLACE
							  (REPLACE
								(@tableviews, 
								 ' ', ''), 
							     CHAR(10), ''), 
								 CHAR(13), ''),
								 CHAR(14), ''),
								 CHAR(9), ''), 
							  ',')
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
	SELECT 
		column_name,
		data_type
    FROM   information_schema.columns
    WHERE  table_name = ''v_' + @ObjName + '''
            AND table_schema = ''dbo''
    EXCEPT
	SELECT 
		column_name,
		data_type
    FROM   information_schema.columns
    WHERE  table_name = ''t_' + @ObjName + '''
            AND table_schema = ''dbo''
			)
    UNION ALL
	(
	SELECT 
		column_name,
		data_type
    FROM   information_schema.columns
    WHERE  table_name = ''t_' + @ObjName + '''
            AND table_schema = ''dbo''
    EXCEPT
	SELECT 
		column_name,
		data_type
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
		 END;

		 SELECT *
		 INTO dbo.t_' + @ObjName + '
		 FROM dbo.v_' + @ObjName + ';
	END;
 ELSE 
	BEGIN
	/*Insert new records into temp tables*/
	SELECT * INTO tempdb..#n_' + @ObjName + ' FROM dbo.v_' + @ObjName + ' EXCEPT SELECT * FROM dbo.t_' + @ObjName + ';

	/*2. If records have been added to v_ view*/
		IF EXISTS (SELECT TOP 1 1 FROM tempdb..#n_' + @ObjName + ')
		   BEGIN
			  /*Insert the new records into t_' + @ObjName + '*/
			  INSERT INTO dbo.t_' + @ObjName + '
			  SELECT *
			  FROM tempdb..#n_' + @ObjName + ';
	       END;
	END;

/*3. If records count does not match*/
IF (
	(SELECT COUNT(1) FROM dbo.t_' + @ObjName + ') 
		> (SELECT COUNT(1) FROM dbo.v_' + @ObjName + ')
	)
	/*Drop and recreate t_ table from v_ view*/
	BEGIN 
			DROP TABLE dbo.t_' + @ObjName + ';
			SELECT *
			INTO dbo.t_' + @ObjName + '
			FROM dbo.v_' + @ObjName + ';
END;

/*4. If t_ table exists, and structures are the same and the data is exactly the same, do nothing*/
/*No action needed in this case*/

/*Cleanup temporary tables*/
IF OBJECT_ID(''tempdb..#c_' + @ObjName + ''', ''U'') IS NOT NULL BEGIN DROP TABLE tempdb..#c_' + @ObjName + ' END;
IF OBJECT_ID(''tempdb..#n_' + @ObjName + ''', ''U'') IS NOT NULL BEGIN DROP TABLE tempdb..#n_' + @ObjName + ' END;
';



        SET @Counter = @Counter + 1;
    END;


    -- Drop the temporary table outside of any transaction
    IF OBJECT_ID('tempdb..#TableList', 'U') IS NOT NULL
        DROP TABLE #TableList;


    -- Output the generated SQL query (commented out for production)
    --SELECT @SqlQuery AS 'GeneratedSQLQuery';


    -- Execute the dynamic SQL query
    BEGIN TRY
        EXEC sp_executesql @SqlQuery;
    END TRY
    BEGIN CATCH
        -- Error handling
        PRINT 'An error occurred during execution.';
    END CATCH;
END;