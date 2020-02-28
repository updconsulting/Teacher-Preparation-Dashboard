using Microsoft.SqlServer.Dac;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Reflection;


namespace EdFi.AnalyticsMiddleTier.Tests
{
    internal static class Constants
    {

        internal const string DatabaseName = "EdFi_AnalyticsMiddleTier_Testing";

        internal static string SnapshotName = $"{DatabaseName}_snapshot";

        internal static string ConnectionString = $"Server=.; Database={DatabaseName}; Trusted_connection=true";

        internal static string MasterConnectionString = "Server=.; Database=master; Trusted_connection=true";

        internal static string DatabaseExists = $@"
SELECT 1 FROM sys.databases WHERE [name] = '{DatabaseName}'
";

        internal static string CreateOrReplaceSnapshotTemplate = $@"
CREATE DATABASE {SnapshotName} ON
  (Name = {DatabaseName}, FileName = '{{0}}\{SnapshotName}.ss')
AS SNAPSHOT OF {DatabaseName}
";

        internal static string SetToSingleUserMode = $@"
ALTER DATABASE [{DatabaseName}] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
";

        internal static string SetToMultiUserMode = $@"
ALTER DATABASE [{DatabaseName}] SET MULTI_USER
";

        internal static string RestoreSnapshot = $@"
IF EXISTS(SELECT 1 FROM sys.databases WHERE [name] = '{SnapshotName}')
BEGIN
    RESTORE DATABASE {DatabaseName} FROM DATABASE_SNAPSHOT = '{SnapshotName}'
END
";

        internal static string SelectDefaultFilePathForSqlDbFiles = $@"
WITH pathname as (
    SELECT [physical_name]
    FROM [{DatabaseName}].[sys].[database_files]
    WHERE [type_desc] = 'ROWS'
)
SELECT REPLACE([physical_name], '{DatabaseName}_Primary.mdf', '') as FilePath
FROM pathname
";

        internal static string DropSnapshotHistory = $"EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'{SnapshotName}'";

        internal static string SnapShotExists = $"SELECT 1 FROM sys.databases WHERE [name] = '{SnapshotName}'";

        internal static string DropSnapshot = $@"DROP DATABASE {SnapshotName}";
    }


    internal class DbHelper : IDisposable
    {

        private readonly SqlConnection _sqlConnection;

        public DbHelper(string connectionString)
        {
            _sqlConnection = new SqlConnection(connectionString);
            _sqlConnection.Open();
        }


        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Security", "CA2100:Review SQL queries for security vulnerabilities")]
        public void Execute(string sqlCommand)
        {
            using (var command = new SqlCommand(sqlCommand, _sqlConnection))
            {
                command.ExecuteNonQuery();
            }
        }

        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Security", "CA2100:Review SQL queries for security vulnerabilities")]
        public T ExecuteScalar<T>(string sqlCommand)
        {
            using (var command = new SqlCommand(sqlCommand, _sqlConnection))
            {
                var result = command.ExecuteScalar();

                if (result is DBNull || result == null)
                {
                    return default(T);
                }

                return (T)result;
            }
        }


        public IDataReader ExecuteReader(string sqlCommand)
        {
            using (var command = new SqlCommand(sqlCommand, _sqlConnection))
            {
                return command.ExecuteReader();
            }
        }


        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2213:DisposableFieldsShouldBeDisposed", MessageId = "_sqlConnection")]
        public void Dispose()
        {
            _sqlConnection?.Dispose();
        }

        public static void PrepareDatabase()
        {
            using (var db = new DbHelper(Constants.MasterConnectionString))
            {
#if DEBUG
                if (TestDatabaseExists() && SnapshotExists())
                {
                    ReloadFromSnapshotBackup();
                }
                else
                {
                    DeployEdFiOdsDacPac();
                    CreateOrReplaceSnapshot();
                }
#else
                DropSnapshotIfItExists();
                DeployEdFiOdsDacPac();
#endif

                bool TestDatabaseExists()
                {
                    return db.ExecuteScalar<int>(Constants.DatabaseExists) == 1;
                }


                void CreateOrReplaceSnapshot()
                {
                    var filePath = db.ExecuteScalar<string>(Constants.SelectDefaultFilePathForSqlDbFiles);

                    db.Execute(string.Format(Constants.CreateOrReplaceSnapshotTemplate, filePath));
                }

#pragma warning disable CS8321 // Local function is declared but never used
                void DropSnapshotIfItExists()
#pragma warning restore CS8321 // Local function is declared but never used
                {
                    // ReSharper disable once InvertIf - easier to read this way
                    if (SnapshotExists())
                    {
                        db.Execute(Constants.DropSnapshotHistory);
                        db.Execute(Constants.DropSnapshot);
                    }
                }

                bool SnapshotExists()
                {
                    return db.ExecuteScalar<int>(Constants.SnapShotExists) == 1;
                }


                void DeployEdFiOdsDacPac()
                {
                    var deployOptions = new DacDeployOptions
                    {
                        CreateNewDatabase = true

                    };
                    var dacService = new DacServices(Constants.ConnectionString);
                    using (var dacpac = DacPackage.Load(GetDacFilePath()))
                    {
                        dacService.Deploy(dacpac, Constants.DatabaseName, true, deployOptions);
                    }

                }

                string GetDacFilePath()
                {
                    // ReSharper disable once AssignNullToNotNullAttribute
                    return Path.Combine(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location), "EdFi_Ods_2.0.dacpac");
                }

                void ReloadFromSnapshotBackup()
                {
                    db.Execute(Constants.SetToSingleUserMode);
                    db.Execute(Constants.RestoreSnapshot);
                    db.Execute(Constants.SetToMultiUserMode);
                }
            }
        }

        public static bool ObjectExists(string schema, string sqlObject)
        {
            using (var db = new DbHelper(Constants.ConnectionString))
            {
                var sql = $"SELECT object_id('[{schema}].[{sqlObject}]')";

                return db.ExecuteScalar<object>(sql) != null;
            }
        }

        public static List<string> GetColumnNamesFor(string viewOrTableName)
        {
            return GetColumnNamesFor("analytics", viewOrTableName);
        }

        public static List<string> GetColumnNamesFor(string schema, string viewOrTableName)
        {
            var sqlCommand = $"SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = '{schema}' AND TABLE_NAME = '{viewOrTableName}'";

            var columns = new List<string>();

            using (var db = new DbHelper(Constants.ConnectionString))
            {

                using (var reader = db.ExecuteReader(sqlCommand))
                {

                    while (reader.Read())
                    {
                        columns.Add(reader.GetString(0));
                    }
                }

                return columns;
            }
        }

        public static QueryResults ExecuteQuery(string sqlCommand)
        {
            var queryResults = new QueryResults();

            using (var db = new DbHelper(Constants.ConnectionString))
            {

                using (var reader = db.ExecuteReader(sqlCommand))
                {
                    for (var columnNumber = 0; columnNumber < reader.FieldCount; columnNumber++)
                    {
                        queryResults.AddColumn(columnNumber, reader.GetName(columnNumber));
                    }

                    while (reader.Read())
                    {
                        var row = queryResults.NewRow();

                        for (var columnNumber = 0; columnNumber < reader.FieldCount; columnNumber++)
                        {
                            row.Add(columnNumber, reader.GetValue(columnNumber));
                        }
                    }
                }

                return queryResults;
            }
        }

        public static T ExecuteQuery<T>(string sqlCommand)
        {
            using (var db = new DbHelper(Constants.ConnectionString))
            {
                return db.ExecuteScalar<T>(sqlCommand);
            }
        }

    }


    internal class QueryResults : IEnumerable<QueryRow>
    {
        private readonly Dictionary<string, int> _columnNameIndexMap = new Dictionary<string, int>();
        private readonly List<QueryRow> _rows = new List<QueryRow>();

        public int RowCount => _rows.Count;


        public QueryRow NewRow()
        {
            var row = new QueryRow();
            _rows.Add(row);
            return row;
        }

        public void AddColumn(int columnNumber, string columnName)
        {
            _columnNameIndexMap.Add(columnName, columnNumber);
        }

        public IEnumerator<QueryRow> GetEnumerator()
        {
            return _rows.GetEnumerator();
        }

        IEnumerator IEnumerable.GetEnumerator()
        {
            return _rows.GetEnumerator();
        }

        public List<T> GetValues<T>(string columnName)
        {
            var columnIndex = _columnNameIndexMap[columnName];

            return _rows.Select(x => x.Get<T>(columnIndex)).ToList();
        }


        public bool HasRowWith((string columnName, string value)[] columnValuesToFind)
        {
            if (columnValuesToFind == null)
            {
                throw new ArgumentNullException(nameof(columnValuesToFind));
            }

            var found = new bool[columnValuesToFind.Length];

            for (var i = 0; i < columnValuesToFind.Length; i++)
            {
                var (columnname, value) = columnValuesToFind[i];
                var columnIndex = _columnNameIndexMap[columnname];

                found[i] = _rows.Any(x => x[columnIndex] == (object)value);
            }

            return found.All(x => x);
        }
    }

    internal class QueryRow : Dictionary<int, object>
    {
        public T Get<T>(int columnNumber)
        {
            return (T)this[columnNumber];
        }
    }
}
