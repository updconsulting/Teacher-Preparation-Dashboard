using System;
using System.Reflection;
using DbUp;
using DbUp.Engine;

namespace EdFi.AnalyticsMiddleTier.Lib
{
    public static class MigrationUtility
    {
        private const string JournalingSchema = "dbo";
        private const string JournalingVersionsTable = "AnalyticsMiddleTierSchemaVersion";

        public static (bool Successful, string ErrorMessage) Run(string connectionString, bool includeIndexes = false, bool includeViews = true)
        {
            if (connectionString == null) throw new ArgumentNullException(nameof(connectionString));
            if (string.IsNullOrWhiteSpace(connectionString)) throw new ArgumentException("connection string cannot be empty", nameof(connectionString));


            if (includeViews)
            {
                var result = InstallViews();

                if (!result.Successful)
                {
                    return (false, ConcatenateExceptionMessages(result.Error));
                }
            }

            // ReSharper disable once InvertIf - easier to read this way
            if (includeIndexes)
            {
                var result = InstallIndexes();

                if (!result.Successful)
                {
                    // Repackaging the result so that other referring projects don't need to install
                    // DbUp, which would be required if returning a `DatabaseUpgradeResult` object.
                    return (result.Successful, ConcatenateExceptionMessages(result.Error));
                }
            }

            
            return (true, string.Empty);


            DatabaseUpgradeResult InstallViews()
            {
                return
                    DeployChanges.To
                        .SqlDatabase(connectionString)
                        // Get all scripts from this library _except_ for index scripts
                        .WithScriptsEmbeddedInAssembly(Assembly.GetExecutingAssembly(), s => !s.Contains("Index"))
                        .JournalToSqlTable(JournalingSchema, JournalingVersionsTable)
                        .WithTransaction()
                        .LogToConsole()
                        .Build()
                        .PerformUpgrade();
            }

            DatabaseUpgradeResult InstallIndexes()
            {
                return
                    DeployChanges.To
                        .SqlDatabase(connectionString)
                        // Get the _index_ scripts from this library as well as the analytics schema
                        .WithScriptsEmbeddedInAssembly(Assembly.GetExecutingAssembly(), s => s.Contains("Schema-Analytics-Create") || s.Contains("Index"))
                        .JournalToSqlTable(JournalingSchema, JournalingVersionsTable)
                        .WithTransaction()
                        .LogToConsole()
                        .Build()
                        .PerformUpgrade();
            }
        }


        public static string ConcatenateExceptionMessages(Exception outer)
        {
            if (outer == null) return string.Empty;

            var message = outer.Message;

            if (outer.InnerException != null)
            {
                message += "\r\nInner exception: " + ConcatenateExceptionMessages(outer.InnerException);
            }

            return message;
        }
    }
}
