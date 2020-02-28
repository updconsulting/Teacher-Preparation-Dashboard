using EdFi.AnalyticsMiddleTier.Lib;
using FluentAssertions;
using NUnit.Framework;

namespace EdFi.AnalyticsMiddleTier.Tests
{
    [TestFixture]
    public class RunningTheMigrationWithIndexesShould
    {
        private (bool Successful, string ErrorMessage) _result;

        // The action of running the migration is in the InitializeAndRun() method, so that we can
        // run the migration once and then have each object covered in a separate test

        [OneTimeSetUp]
        public void InitializeAndRun()
        {
            DbHelper.PrepareDatabase();

            // Act
            // ReSharper disable ArgumentsStyleLiteral - leaving in place for greater transparency as to what is occurring
            _result = MigrationUtility.Run(Constants.ConnectionString, includeIndexes: true, includeViews: false);
            // ReSharper restore ArgumentsStyleLiteral
        }

        [Test]
        public void NotEncounterAnyErrors()
        {
            _result.ErrorMessage.Should().BeNullOrEmpty();
            _result.Successful.Should().BeTrue();
        }

        [TestCase("Grade", "IX_AMT_Grade_SectionKey")]
        [TestCase("AcademicSubjectType", "IX_AMT_AcademicSubjectType_CodeValue")]
        [TestCase("StudentSectionAssociation", "IX_AMT_StudentSectionAssociation_StudentSectionDimension")]
        public void CreateIndexes(string table, string index)
        {
            DbHelper.ExecuteQuery<int>($"select 1 from sys.indexes where [name] = '{index}'")
                .Should()
                .Be(1);


            DbHelper.ExecuteQuery<int>($"select 1 from [analytics_config].[indexjournal] where [FullyQualifiedIndexName] = '[edfi].[{table}].[{index}]'")
                .Should()
                .Be(1);
        }

        [Test]
        public void CreateTheIndexJournalTable()
        {
            DbHelper.ObjectExists("analytics_config", "IndexJournal").Should().BeTrue();
        }

        [Test]
        public void NotInstallViews()
        {
            const string sql = "SELECT count(1) FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_SCHEMA = 'analytics'";

            DbHelper.ExecuteQuery<int>(sql)
                .Should()
                .Be(0);
        }
    }
}
