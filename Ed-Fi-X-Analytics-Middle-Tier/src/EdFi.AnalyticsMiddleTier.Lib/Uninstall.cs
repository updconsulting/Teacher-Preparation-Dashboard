using System;
using System.Data.SqlClient;

namespace EdFi.AnalyticsMiddleTier.Lib
{
	public static class Uninstall
	{
		private const string RemoveAllAnalyticsViews = @"
DECLARE @tableName NVARCHAR(128), @statement NVARCHAR(1000)

DECLARE analyticsViews CURSOR FOR 
	SELECT TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_SCHEMA = 'Analytics'
	
OPEN analyticsViews

FETCH NEXT FROM analyticsViews INTO @tableName

WHILE @@FETCH_STATUS = 0
BEGIN
	SELECT @statement = N'DROP VIEW [analytics].[' + @tableName + N']'

	EXEC sp_executesql @statement;

	FETCH NEXT FROM analyticsViews INTO @tableName
END

CLOSE analyticsViews
DEALLOCATE analyticsViews";

        private const string RemoveAllAnalyticsIndexes = @"
IF (SELECT OBJECT_ID('[analytics_config].[IndexJournal]')) IS NOT NULL
BEGIN
    DECLARE @indexName NVARCHAR(128), @statement NVARCHAR(1000)

    DECLARE analyticsIndexes CURSOR FOR 
	    SELECT [FullyQualifiedIndexName] FROM [analytics_config].[IndexJournal]
	    
    OPEN analyticsIndexes

    FETCH NEXT FROM analyticsIndexes INTO @indexName

    WHILE @@FETCH_STATUS = 0
    BEGIN
	    SELECT @statement = N'DROP INDEX ' + @indexName
	    
	    EXEC sp_executesql @statement;

	    FETCH NEXT FROM analyticsIndexes INTO @indexName
    END

    CLOSE analyticsIndexes
    DEALLOCATE analyticsIndexes
END
";

        private const string DropIndexJournalTable = @"
IF (SELECT OBJECT_ID('[analytics_config].[IndexJournal]')) IS NOT NULL
BEGIN
    DROP TABLE [analytics_config].[IndexJournal]
END
";

        private const string DropDbUpJournalTable = @"
IF (SELECT OBJECT_ID('[dbo].[AnalyticsMiddleTierSchemaVersion]')) IS NOT NULL
BEGIN
    DROP TABLE [dbo].[AnalyticsMiddleTierSchemaVersion]
END
";
        private const string SchoolYearHistoricalSnapShotDates = @"
IF (SELECT OBJECT_ID('[analytics_config].[SchoolYearHistoricalSnapShotDates]')) IS NOT NULL
BEGIN
DROP TABLE [analytics_config].[SchoolYearHistoricalSnapShotDates]
END
";
        private const string EntitySchoolYearInstanceSetKey = @"
IF (SELECT OBJECT_ID('[analytics].[EntitySchoolYearInstanceSetKey]')) IS NOT NULL
BEGIN
DROP FUNCTION [analytics].[EntitySchoolYearInstanceSetKey]
END
";

        private const string DropStoredProcedures = @"DECLARE @procName NVARCHAR(128), @statement NVARCHAR(1000)

DECLARE sprocs CURSOR FOR 
	SELECT ROUTINE_NAME FROM INFORMATION_SCHEMA.ROUTINES WHERE [ROUTINE_SCHEMA] = 'analytics_config'
	
OPEN sprocs

FETCH NEXT FROM sprocs INTO @procName

WHILE @@FETCH_STATUS = 0
BEGIN
	SELECT @statement = N'DROP PROCEDURE [analytics_config].[' + @procName + ']'
	
	EXEC sp_executesql @statement;

	FETCH NEXT FROM sprocs INTO @procName
END

CLOSE sprocs
DEALLOCATE sprocs
";
       

        public static (bool Successful, string ErrorMessage) Run(string connectionString)
		{
			if (connectionString == null) throw new ArgumentNullException(nameof(connectionString));
			if (string.IsNullOrWhiteSpace(connectionString)) throw new ArgumentException("connection string cannot be empty", nameof(connectionString));

            try
            {
                ExecuteSqlStatement(RemoveAllAnalyticsViews);
                ExecuteSqlStatement(RemoveAllAnalyticsIndexes);
                ExecuteSqlStatement(DropIndexJournalTable);
                ExecuteSqlStatement(DropDbUpJournalTable);
                ExecuteSqlStatement(DropStoredProcedures);
                ExecuteSqlStatement(SchoolYearHistoricalSnapShotDates);
                ExecuteSqlStatement(EntitySchoolYearInstanceSetKey);
           

                return (true, string.Empty);
            }
            catch (Exception ex)
            {
                return (false, MigrationUtility.ConcatenateExceptionMessages(ex));
            }

		    void ExecuteSqlStatement(string commandText)
		    {
		        using (var sqlConnection = new SqlConnection(connectionString))
		        {
		            sqlConnection.Open();

		            using (var command = sqlConnection.CreateCommand())
		            {
		                command.CommandType = System.Data.CommandType.Text;
		                command.CommandText = commandText;

		                command.ExecuteNonQuery();
		            }
		        }
		    }
		}
	}
}
