CREATE OR ALTER   PROC [dbo].[EmptyDatabase] (@BatchSize INTEGER = 1000000)
AS
BEGIN

	EXEC sp_MSforeachtable @command1 = "ALTER TABLE ? NOCHECK CONSTRAINT ALL"
	DECLARE TableCursor CURSOR FAST_FORWARD FOR SELECT
		TABLE_SCHEMA + '.' + table_name
	FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_TYPE = 'BASE TABLE'
	AND table_name NOT LIKE 'MSsql_TemporalHistoryFor%'
	AND table_name NOT LIKE '%Descriptor'
	AND table_name NOT LIKE '%Type'

	DECLARE @Size INTEGER = 0
	DECLARE @Iteration INTEGER = 0
	DECLARE @count INTEGER = 0
	DECLARE @Command NVARCHAR(MAX) = ''
	DECLARE @DeleteCommand NVARCHAR(MAX) = ''
	DECLARE @TableName SYSNAME
	OPEN TableCursor

	FETCH NEXT FROM TableCursor INTO @TableName

	WHILE @@fetch_status = 0
	BEGIN

	SET @Command = 'SELECT @Size =  COUNT(*) FROM	' + @TableName

	EXECUTE sp_executesql @Command
						 ,N'@Size INT OUTPUT'
						 ,@Size = @Size OUTPUT

	SET @Iteration = CEILING((@Size * 1.0) / @BatchSize)
	SET @count = 0

	WHILE @Iteration > @count
	BEGIN
	SET @DeleteCommand = 'DELETE TOP (' + CAST(@BatchSize AS NVARCHAR(256)) + ')  FROM ' + @TableName
	PRINT (@DeleteCommand)
	EXECUTE sp_executesql @DeleteCommand
	SET @count = @count + 1
	END

	FETCH NEXT FROM TableCursor INTO @TableName
	END

	CLOSE TableCursor
	DEALLOCATE TableCursor
	EXEC sp_MSforeachtable @command1 = "ALTER TABLE ? CHECK CONSTRAINT ALL"

END

GO


