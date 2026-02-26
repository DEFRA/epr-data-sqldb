CREATE PROC [dbo].[sp_backup_table] @schema_name [NVARCHAR](128),@table_name [NVARCHAR](128) AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @backup_table NVARCHAR(258);
    DECLARE @sql NVARCHAR(MAX);
    DECLARE @today NVARCHAR(20);
    DECLARE @timestamp NVARCHAR(20);

    SET @today = CONVERT(VARCHAR(14), GETDATE(), 112);
    SET @timestamp = CONVERT(VARCHAR(14), DATEDIFF(SECOND, '1970-01-01', GETDATE()), 112);

    SET @backup_table = QUOTENAME(@schema_name) + '.' + QUOTENAME(@table_name + '_backup_' + @today + '_' + @timestamp);

    SET @sql = N'SELECT * INTO ' + @backup_table + N' FROM '
               + QUOTENAME(@schema_name) + '.' + QUOTENAME(@table_name) + N';';

    print @sql;

    EXEC(@sql);

    PRINT 'Backup table created: ' + @backup_table;
END;
GO

