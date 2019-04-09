using EdFi.AnalyticsMiddleTier.Lib;
using FluentAssertions;
using NUnit.Framework;

namespace EdFi.AnalyticsMiddleTier.Tests
{
    [TestFixture]
    public class WhenAnErrorOccursDuringInstallationItShould
    {
        [OneTimeSetUp]
        public void InitializeAndRun()
        {
            // Arrange
            DbHelper.PrepareDatabase();

            // .. drop a column from one of the tables used by a view, so that the view installation will fail
            DbHelper.ExecuteQuery("ALTER TABLE [edfi].[GradingPeriod] DROP COLUMN [TotalInstructionalDays]");


            // Act
            (var success, _) = MigrationUtility.Run(Constants.ConnectionString);

            // Assert
            success.Should().BeFalse();
        }

        [Test]
        public void NotInstallAnyViews()
        {
            const string sql = "SELECT count(1) FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_SCHEMA = 'analytics'";

            DbHelper.ExecuteQuery<int>(sql)
                .Should()
                .Be(0);
        }

        [Test]
        public void NotInstallAnyIndexes()
        {
            DbHelper.ExecuteQuery<int>("select 1 from sys.indexes where [name] LIKE 'IX_AMT_%'")
                .Should()
                .Be(0);
        }

        [TestCase("AnalyticsMiddleTierSchemaVersion")]
        [TestCase("IndexJournal")]
        [TestCase("AuthorizationScope")]
        [TestCase("StaffClassificationDescriptorScope")]
        public void NotInstallAnyNewTables(string tableName)
        {
            var sql = $"SELECT count(1) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '{tableName}'";

            DbHelper.ExecuteQuery<int>(sql)
                .Should()
                .Be(0);
        }

    }
}
