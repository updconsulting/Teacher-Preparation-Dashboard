using EdFi.AnalyticsMiddleTier.Lib;
using FluentAssertions;
using NUnit.Framework;

namespace EdFi.AnalyticsMiddleTier.Tests
{
    [TestFixture]
    public class RunningTheMigrationShould
    {
        private (bool Successful, string ErrorMessage) _result;

        // The action of running the migration is in the InitializeAndRun() method, so that we can
        // run the migration once and then have each object covered in a separate test

        [OneTimeSetUp]
        public void InitializeAndRun()
        {
            DbHelper.PrepareDatabase();

            // Act
            _result = MigrationUtility.Run(Constants.ConnectionString);
        }

        [Test]
        public void CreateASchemaVersionTableInTheAnalyticsSchema()
        {
            DbHelper.ObjectExists("dbo", "AnalyticsMiddleTierSchemaVersion").Should().BeTrue();
        }

        [Test]
        public void NotEncounterAnyErrors()
        {
            _result.ErrorMessage.Should().BeNullOrEmpty();
            _result.Successful.Should().BeTrue();
        }

        [Test]
        public void CreateTheAnalyticsSchema()
        {
            using (var db = new DbHelper(Constants.ConnectionString))
            {
                var result = db.ExecuteScalar<int>("select 1 from sys.schemas where [name] = 'analytics'");

                result.Should().Be(1, "Analytics schema should exist");
            }
        }

        [Test]
        public void CreateTheDateDimensionView()
        {
            const string table = "DateDimension";
            DbHelper.ObjectExists("analytics", table).Should().BeTrue();

            DbHelper.GetColumnNamesFor(table).Should().Contain(new[]
            {
                "DateKey",
                "Date",
                "Day",
                "Month",
                "MonthName",
                "CalendarQuarter",
                "CalendarQuarterName",
                "CalendarYear"
            });
        }

        [Test]
        public void CreateTheSchoolDimensionView()
        {
            const string table = "SchoolDimension";
            DbHelper.ObjectExists("analytics", table).Should().BeTrue();

            DbHelper.GetColumnNamesFor(table).Should().Contain(new[]
            {
                "SchoolKey",
                "SchoolName",
                "SchoolType",
                "SchoolAddress",
                "SchoolCity",
                "SchoolCounty",
                "SchoolState",
                "LocalEducationAgencyName",
                "LocalEducationAgencyKey",
                "StateEducationAgencyName",
                "StateEducationAgencyKey",
                "EducationServiceCenterName",
                "EducationServiceCenterKey",
                "LastModifiedDate"
            });
        }

        [Test]
        public void CreateTheStudentDimensionView()
        {
            const string table = "StudentDimension";
            DbHelper.ObjectExists("analytics", table).Should().BeTrue();

            DbHelper.GetColumnNamesFor(table).Should().Contain(new[]
            {
                "EnrollmentDate",
                "GradeLevel",
                "LimitedEnglishProficiency",
                "IsEconomicallyDisadvantaged",
                "IsEligibleForSchoolFoodService",
                "IsHispanic",
                "SchoolKey",
                "StudentKey",
                "Sex",
                "StudentFirstName",
                "StudentMiddleName",
                "StudentLastName",
                "ContactName",
                "ContactRelationship",
                "ContactAddress",
                "ContactMobilePhoneNumber",
                "ContactWorkPhoneNumber",
                "ContactEmailAddress",
                "LastModifiedDate"
            });
        }

        [Test]
        public void CreateTheUserDimensionView()
        {
            const string table = "UserDimension";
            DbHelper.ObjectExists("analytics", table).Should().BeTrue();

            DbHelper.GetColumnNamesFor(table).Should().Contain(new[]
            {
                "UserKey",
                "UserEmail",
                "LastModifiedDate"
            });
        }


        [Test]
        public void CreateTheStudentDataAuthorizationView()
        {
            const string table = "StudentDataAuthorization";
            DbHelper.ObjectExists("analytics", table).Should().BeTrue();

            DbHelper.GetColumnNamesFor(table).Should().Contain(new[]
            {
                "StudentKey",
                "SchoolKey",
                "SectionKey",
                "BeginDate",
                "EndDate"
            });
        }

        [Test(Description = "This ensures that the scripts are idempotent")]
        public void RunASecondTimeWithoutError()
        {
            MigrationUtility.Run(Constants.ConnectionString)
                .Successful.Should().BeTrue();
        }

        [Test]
        public void CreateTheStudentEarlyWarningFactView()
        {
            const string table = "StudentEarlyWarningFact";
            DbHelper.ObjectExists("analytics", table).Should().BeTrue();

            DbHelper.GetColumnNamesFor(table).Should().Contain(new[]
            {
                "StudentKey",
                "SchoolKey",
                "DateKey",
                "IsInstructionalDay",
                "IsEnrolled",
                "IsPresentSchool",
                "IsAbsentFromSchoolExcused",
                "IsAbsentFromSchoolUnexcused",
                "IsTardyToSchool",
                "IsPresentHomeroom",
                "IsAbsentFromHomeroomExcused",
                "IsAbsentFromHomeroomUnexcused",
                "IsTardyToHomeroom",
                "IsPresentAnyClass",
                "IsAbsentFromAnyClassExcused",
                "IsAbsentFromAnyClassUnexcused",
                "IsTardyToAnyClass",
                "CountByDayOfStateOffenses",
                "CountByDayOfConductOffenses"
            });
        }

        [Test]
        public void CreateTheAuthorizationScopeTable()
        {
            const string table = "AuthorizationScope";
            DbHelper.ObjectExists("analytics_config", table).Should().BeTrue();

            DbHelper.GetColumnNamesFor("analytics_config", table).Should().Contain(new[]
            {
                "AuthorizationScopeId",
                "AuthorizationScopeName"
            });
        }

        [Test]
        public void AddDefaultRowsToAuthorizationScopeTable()
        {
            var queryResult = DbHelper.ExecuteQuery("SELECT * FROM [analytics_config].[AuthorizationScope]");

            queryResult.Should().NotBeNull();

            queryResult.RowCount.Should().Be(3);

            var columnValues = queryResult.GetValues<string>("AuthorizationScopeName");

            columnValues.Should().Contain("Section");
            columnValues.Should().Contain("School");
            columnValues.Should().Contain("District");
        }

        [Test]
        public void CreateTheStaffClassificationDescriptorScopeTable()
        {
            const string table = "StaffClassificationDescriptorScope";
            DbHelper.ObjectExists("analytics_config", table).Should().BeTrue();

            DbHelper.GetColumnNamesFor("analytics_config", table).Should().Contain(new[]
            {
                "AuthorizationScopeId",
                "StaffClassificationDescriptorId"
            });
        }


        /*
Leaving the following dead code as an illustration of how to use queryResult.HasRowWith().

        [Test]
        [Ignore("This is a nice test but for one problem - the initial data set has no staff classifications, therefore the insert query generates no results")]
        public void PreloadTheStaffClassificationDescriptorScopeTable()
        {
            const string sql = @"SELECT [AuthorizationScope].[AuthorizationScopeName], [Descriptor].[CodeValue]
FROM [analytics_config].[StaffClassificationDescriptorScope]
INNER JOIN [analytics_config].[AuthorizationScope] ON
    [StaffClassificationDescriptorScope].[AuthorizationScopeId] = [AuthorizationScope].[AuthorizationScopeId]
INNER JOIN [edfi].[Descriptor] ON
    [StaffClassificationDescriptorScope].[StaffClassificationDescriptorId] = [Descriptor].[DescriptorId]";


            var queryResult = DbHelper.ExecuteQuery(sql);

            queryResult.Should().NotBeNull();

            queryResult.RowCount.Should().Be(4);

            queryResult.HasRowWith(new[] { ("AuthorizationScopeName", "Section"), ("CodeValue", "Teacher") }).Should().BeTrue();
            queryResult.HasRowWith(new[] { ("AuthorizationScopeName", "Section"), ("CodeValue", "Substitute Teacher") }).Should().BeTrue();
            queryResult.HasRowWith(new[] { ("AuthorizationScopeName", "School"), ("CodeValue", "Principal") }).Should().BeTrue();
            queryResult.HasRowWith(new[] { ("AuthorizationScopeName", "District"), ("CodeValue", "Superintendent") }).Should().BeTrue();
        }
        */

        [Test]
        public void CreateTheUserAuthorizationView()
        {
            const string table = "UserAuthorization";
            DbHelper.ObjectExists("analytics", table).Should().BeTrue();

            DbHelper.GetColumnNamesFor(table).Should().Contain(new[]
            {
                "UserKey",
                "UserScope",
                "StudentPermission",
                "SectionPermission",
                "SchoolPermission"
            });
        }

        [Test]
        public void NotInstallIndexes()
        {
            const string sql = "select * from sys.indexes where [name] = 'IX_Grade_SectionKey'";

            var queryResult = DbHelper.ExecuteQuery(sql);

            queryResult.Should().NotBeNull();
            queryResult.RowCount.Should().Be(0);
        }

        [Test]
        public void CreateTheStudentSectionDimensionView()
        {
            const string table = "StudentSectionDimension";
            DbHelper.ObjectExists("analytics", table).Should().BeTrue();

            DbHelper.GetColumnNamesFor(table).Should().Contain(new[]
            {
                "StudentSectionKey",
                "SectionKey",
                "Subject",
                "LocalCourseCode",
                "CourseTitle",
                "TeacherName",
                "StudentSectionStartDateKey",
                "StudentSectionEndDateKey",
                "LastModifiedDate"
            });
        }


        [Test]
        public void CreateTheStudentSectionGradeFactView()
        {
            const string table = "StudentSectionGradeFact";
            DbHelper.ObjectExists("analytics", table).Should().BeTrue();

            DbHelper.GetColumnNamesFor(table).Should().Contain(new[]
            {
                "StudentKey",
                "SchoolKey",
                "SectionKey",
                "GradingPeriodKey",
                "StudentSectionKey",
                "NumericGradeEarned"
            });
        }


        [Test]
        public void CreateTheProgramTypeDimensionView()
        {
            const string table = "ProgramTypeDimension";
            DbHelper.ObjectExists("analytics", table).Should().BeTrue();

            DbHelper.GetColumnNamesFor(table).Should().Contain(new[]
            {
                "ProgramTypeKey",
                "ProgramType"
            });
        }


        [Test]
        public void CreateTheStudentProgramEventView()
        {
            const string table = "StudentProgramEvent";
            DbHelper.ObjectExists("analytics", table).Should().BeTrue();

            DbHelper.GetColumnNamesFor(table).Should().Contain(new[]
            {
                "StudentKey",
                "LocalEducationAgencyKey",
                "DateKey",
                "ProgramTypeKey",
                "ProgramEventType"
            });
        }


        [Test]
        public void CreateTheSchoolNetworkAssociationDimensionView()
        {
            const string table = "SchoolNetworkAssociationDimension";
            DbHelper.ObjectExists("analytics", table).Should().BeTrue();

            DbHelper.GetColumnNamesFor(table).Should().Contain(new[]
            {
                "SchoolKey",
                "NetworkName",
                "NetworkKey",
                "NetworkPurpose",
                "BeginDate",
                "EndDate"
            });
        }


        [Test]
        public void CreateTheContactPersonDimensionView()
        {
            const string table = "ContactPersonDimension";
            DbHelper.ObjectExists("analytics", table).Should().BeTrue();

            DbHelper.GetColumnNamesFor(table).Should().Contain(new[]
            {
                "ContactPersonKey",
                "StudentKey",
                "ContactFirstName",
                "ContactLastName",
                "RelationshipToStudent",
                "ContactHomeAddress",
                "ContactPhysicalAddress",
                "ContactMailingAddress",
                "ContactWorkAddress",
                "ContactTemporaryAddress",
                "HomePhoneNumber",
                "MobilePhoneNumber",
                "WorkPhoneNumber",
                "PrimaryEmailAddress",
                "PersonalEmailAddress",
                "WorkEmailAddress",
                "IsPrimaryContact",
                "StudentLivesWith",
                "IsEmergencyContact",
                "ContactPriority",
                "ContactRestrictions",
                "LastModifiedDate"
            });
        }

        [Test]
        public void CreateTheStudentProgramFactView()
        {
            const string table = "StudentProgramFact";
            DbHelper.ObjectExists("analytics", table).Should().BeTrue();

            DbHelper.GetColumnNamesFor(table).Should().Contain(new[]
            {
                "StudentKey",
                "LocalEducationAgencyKey",
                "DateKey",
                "ProgramTypeKey",
                "IsEnrolled"
            });
        }

        [Test]
        public void CreateTheGradingPeriodView()
        {
            const string table = "GradingPeriodDimension";
            DbHelper.ObjectExists("analytics", table).Should().BeTrue();

            DbHelper.GetColumnNamesFor(table).Should().Contain(new[]
            {
                "GradingPeriodKey",
                "GradingPeriodBeginDateKey",
                "GradingPeriodEndDateKey",
                "GradingPeriodDescription",
                "TotalInstructionalDays",
                "PeriodSequence",
                "SchoolKey",
                "LastModifiedDate"
            });
        }

        [Test]
        public void CreateTheMostRecentGradingPeriodView()
        {
            const string table = "MostRecentGradingPeriod";
            DbHelper.ObjectExists("analytics", table).Should().BeTrue();

            DbHelper.GetColumnNamesFor(table).Should().Contain(new[]
            {
                "GradingPeriodBeginDateKey",
                "SchoolKey"
            });
        }

        [Test]
        public void CreateTheAnalyticsMiddleTierRole()
        {
            const string sql = "SELECT 1 FROM sys.database_principals WHERE [type] = 'R' AND [name] = 'analytics_middle_tier'";

            DbHelper.ExecuteQuery<int>(sql)
                .Should().
                Be(1);
        }

        [TestCase("analytics_config", "ViewStaffClassificationDescriptorScope")]
        [TestCase("analytics_config", "InsertStaffClassificationDescriptorScope")]
        [TestCase("analytics_config", "RemoveStaffClassificationDescriptorScope")]
        public void CreateStoredProcedure(string schema, string procedureName)
        {
            var sql = $"SELECT 1 FROM INFORMATION_SCHEMA.ROUTINES WHERE [ROUTINE_SCHEMA] = '{schema}' AND ROUTINE_NAME = '{procedureName}'";

            DbHelper.ExecuteQuery<int>(sql)
                .Should().
                Be(1);
        }

        [Test]
        public void CreateTheLocalEducationAgencyDimensionView()
        {
            const string table = "LocalEducationAgencyDimension";
            DbHelper.ObjectExists("analytics", table).Should().BeTrue();

            DbHelper.GetColumnNamesFor(table).Should().Contain(new[]
            {
                "LocalEducationAgencyKey",
                "LocalEducationAgencyName",
                "LocalEducationAgencyType",
                "LocalEducationAgencyParentLocalEducationAgencyKey",
                "LocalEducationAgencyStateEducationAgencyName",
                "LocalEducationAgencyStateEducationAgencyKey",
                "LocalEducationAgencyServiceCenterName",
                "LocalEducationAgencyServiceCenterKey",
                "LocalEducationAgencyCharterStatus",
                "LastModifiedDate"
            });
        }

    }
}
