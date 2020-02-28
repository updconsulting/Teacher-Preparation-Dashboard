using EdFi.AnalyticsMiddleTier.Lib;
using FluentAssertions;
using NUnit.Framework;

namespace EdFi.AnalyticsMiddleTier.Tests
{
    [TestFixture]
    public class RunningTheUninstallShould
    {


        private (bool Successful, string ErrorMessage) _result;

        // The action of running the migration is in the InitializeAndRun() method, so that we can
        // run the migration once and then have each object covered in a separate test

        [OneTimeSetUp]
        public void InitializeAndRun()
        {
            DbHelper.PrepareDatabase();

            // Act
            // .. install both the views and indexes

            // ReSharper disable once RedundantArgumentDefaultValue
            // ReSharper disable ArgumentsStyleLiteral - leaving in place for greater transparency as to what is occurring
            _result = MigrationUtility.Run(Constants.ConnectionString, includeIndexes: true, includeViews: true);
            // ReSharper restore ArgumentsStyleLiteral

            // .. now uninstall everything
            _result = Uninstall.Run(Constants.ConnectionString);
        }

        [Test]
        public void NotEncounterAnyErrors()
        {
            _result.ErrorMessage.Should().BeNullOrEmpty();
            _result.Successful.Should().BeTrue();
        }

        [Test]
        public void RemoveAllAnalyticsViews()
        {
            const string sql = "SELECT COUNT(1) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'analytics' AND TABLE_TYPE = 'VIEW'";

            DbHelper.ExecuteQuery<int>(sql)
                .Should()
                .Be(0);
        }

        [Test]
        public void NotRemoveScopeTables()
        {
            const string sql = "SELECT COUNT(1) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'analytics_config' AND TABLE_TYPE = 'BASE TABLE' AND TABLE_NAME <> 'IndexJournal'";

            DbHelper.ExecuteQuery<int>(sql)
                .Should()
                .Be(2);
        }


        [TestCase("IX_Grade_SectionKey")]
        public void RemoveIndex(string indexName)
        {
            var sql = $"select 1 from sys.indexes where [name] = '{indexName}'";

            DbHelper.ExecuteQuery<int>(sql)
                .Should()
                .Be(0);
        }

        [Test]
        public void RemoveTheIndexTable()
        {
            DbHelper.ObjectExists("analytics", "IndexJournal")
                .Should()
                .BeFalse();
        }

        [Test]
        public void RemoveTheDbUpJournalTable()
        {
            DbHelper.ObjectExists("dbo", "AnalyticsMiddleTierSchemaVersion")
                .Should()
                .BeFalse();
        }

        [TestCase("ViewStaffClassificationDescriptorScope")]
        [TestCase("InsertStaffClassificationDescriptorScope")]
        [TestCase("RemoveStaffClassificationDescriptorScope")]
        public void RemoveConfigStoredProcedure(string procedureName)
        {
            DbHelper.ObjectExists("analytics_config", procedureName)
                .Should()
                .BeFalse();

        }
    }
}
