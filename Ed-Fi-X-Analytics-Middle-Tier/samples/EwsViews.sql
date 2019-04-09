/*
 * Ideally, queries like this will built in an analytics data model and not in the 
 * source ODS. These extra views are not part of the standard analytics middle
 * tier because they are prescriptive of a particular approach to EWS. They 
 * could be useful for reporting/BI tools when querying a SQL Server datamart 
 * (perhaps using materialized views from EwsViews.sql) instead of an analytics 
 * engine database (e.g. alternative to Microsoft Tabular Data Model.
 */


CREATE VIEW [analytics].[StudentIndicators] AS

	WITH [thresholds] as (

		SELECT
			65.0 as [GradeAtRisk],
			72.0 as [GradeEarlyWarning],
			0.8 as [AttendanceAtRisk],
			0.88 as [AttendanceEarlyWarning],
			0 as [OffenseAtRisk],
			5 as [ConductAtRisk],
			2 as [ConductEarlyWarning]

	), [grades] as (

		SELECT
			[StudentSectionDimension].[StudentKey],
			CASE WHEN [StudentSectionDimension].[Subject] = 'Mathematics' THEN 'Math' 
				 WHEN [StudentSectionDimension].[Subject] IN ('English Language Arts', 'Reading', 'Writing') THEN 'English' END as [Subject],
			[StudentSectionGradeFact].[NumericGradeEarned],
			[StudentSectionDimension].[SchoolKey]
		FROM
			[analytics].[StudentSectionDimension] 
		INNER JOIN
			[analytics].[MostRecentGradingPeriod] ON
				[StudentSectionDimension].[SchoolKey] = [MostRecentGradingPeriod].[SchoolKey]	
		INNER JOIN
			[analytics].[StudentSectionGradeFact] ON
				[StudentSectionGradeFact].[StudentSectionKey] = [StudentSectionDimension].[StudentSectionKey]
		INNER JOIN
			[analytics].[GradingPeriodDimension] ON
				[StudentSectionGradeFact].[GradingPeriodKey] = [GradingPeriodDimension].[GradingPeriodKey]
			AND [MostRecentGradingPeriod].[GradingPeriodBeginDateKey] = [GradingPeriodDimension].[GradingPeriodBeginDateKey]

	), [averages] as (

		SELECT
			[StudentKey],
			[SchoolKey],
			AVG(CASE WHEN [Subject] = 'Math' THEN [NumericGradeEarned] ELSE NULL END) as [MathGrade],
			AVG(CASE WHEN [Subject] = 'English' THEN [NumericGradeEarned] ELSE NULL END) as [EnglishGrade],
			AVG([NumericGradeEarned]) as [OverallGrade]
		FROM
			[grades]
		GROUP BY
			[StudentKey],
			[SchoolKey]

	), [attendanceData] as (

		SELECT 
			[StudentKey],
			[SchoolKey],
			(
				SELECT 
					MAX(Absent)
				FROM (VALUES
						 ([StudentEarlyWarningFact].[IsAbsentFromSchoolExcused])
						,([StudentEarlyWarningFact].[IsAbsentFromSchoolUnexcused])
						,([StudentEarlyWarningFact].[IsAbsentFromHomeroomExcused])
						,([StudentEarlyWarningFact].[IsAbsentFromHomeroomUnexcused])
						-- For EWS demo system, only looking at: either marked as absent from school, or from home room.
						-- Those who are customizing may wish to change from home room to any class.
						--,([StudentEarlyWarningFact].[IsAbsentFromAnyClassExcused])
						--,([StudentEarlyWarningFact].[IsAbsentFromAnyClassUnexcused])
					) as value(Absent)
			) as [IsAbsent],
			[IsEnrolled],
			[DateKey]
		FROM 
			[analytics].[StudentEarlyWarningFact]
		WHERE 
			[IsInstructionalDay] = 1
		AND [IsEnrolled] = 1

	), [rate] as (

		SELECT
			[StudentKey],
			[SchoolKey],
			(CAST(SUM([IsEnrolled]) as DECIMAL) - CAST(SUM([IsAbsent]) as DECIMAL)) / CAST(SUM([IsEnrolled]) as DECIMAL) as [AttendanceRate]
		FROM 
			[attendanceData] 
		GROUP BY
			[StudentKey],
			[SchoolKey]

	), [totalcounts] as (

		SELECT
			[StudentKey],
			[SchoolKey],
			SUM(ISNULL([CountByDayOfStateOffenses],0)) as [StateOffenses],
			SUM(ISNULL([CountByDayOfConductOffenses],0)) as [CodeOfConductOffenses]
		FROM
			[analytics].[StudentEarlyWarningFact]
		GROUP BY
			[StudentKey],
			[SchoolKey]

	)
	SELECT
	
		[rate].[StudentKey],
		[rate].[SchoolKey],
		[MathGrade],
		[EnglishGrade],
		[OverallGrade],
		[AttendanceRate],

		CASE WHEN [MathGrade] < [thresholds].[GradeAtRisk] OR [EnglishGrade] < [thresholds].[GradeAtRisk] THEN 'At risk'
			WHEN [MathGrade] < [thresholds].[GradeEarlyWarning] OR [EnglishGrade] < [thresholds].[GradeEarlyWarning] Then 'Early warning'
			ELSE 'On track'
		END as [GradeIndicator],

		CASE WHEN [AttendanceRate] < [thresholds].[AttendanceAtRisk] THEN 'At risk'
			 WHEN [AttendanceRate] < [thresholds].[AttendanceEarlyWarning] THEN 'Early warning'
			 ELSE 'On track'
		END as [AttendanceIndicator],

		CASE WHEN [StateOffenses] > [thresholds].[OffenseAtRisk] OR [CodeOfConductOffenses] > [thresholds].[ConductAtRisk] THEN 'At risk'
			 WHEN [CodeOfConductOffenses] > [thresholds].[ConductEarlyWarning] THEN 'Early warning'
			 ELSE 'On track'
		End as [BehaviorIndicator]

	FROM
		[rate] 
	LEFT OUTER JOIN
		[averages] ON
			[rate].[StudentKey] = [averages].[StudentKey] 
		AND [rate].[SchoolKey] = [averages].[SchoolKey]
	LEFT OUTER JOIN
		[totalcounts] ON
			[rate].[StudentKey] = [totalcounts].[StudentKey]
		AND [rate].[SchoolKey] = [totalcounts].[SchoolKey]
	CROSS APPLY
		[thresholds]

GO




CREATE VIEW [analytics].[StudentEnrolledSectionGrade] AS

	SELECT
		[StudentSectionGradeFact].[StudentKey],
		[StudentSectionDimension].[Subject],
		[StudentSectionDimension].[LocalCourseCode],
		[StudentSectionDimension].[CourseTitle],
		[StudentSectionDimension].[TeacherName],
		AVG([StudentSectionGradeFact].[NumericGradeEarned]) as [NumericGradeEarned]
	FROM
		[analytics].[StudentSectionDimension]
	INNER JOIN
		[analytics].[StudentSectionGradeFact] ON
			[StudentSectionGradeFact].[StudentSectionKey] = [StudentSectionDimension].[StudentSectionKey]
	INNER JOIN
		[analytics].[GradingPeriodDimension] ON
			[StudentSectionGradeFact].[GradingPeriodKey] = [GradingPeriodDimension].[GradingPeriodKey]
	INNER JOIN
		[analytics].[MostRecentGradingPeriod] ON
			[StudentSectionGradeFact].[SchoolKey] = [MostRecentGradingPeriod].[SchoolKey]
		AND [GradingPeriodDimension].[GradingPeriodBeginDateKey] = [MostRecentGradingPeriod].[GradingPeriodBeginDateKey]
	GROUP BY
		[StudentSectionGradeFact].[StudentKey],
		[StudentSectionDimension].[Subject],
		[StudentSectionDimension].[LocalCourseCode],
		[StudentSectionDimension].[CourseTitle],
		[StudentSectionDimension].[TeacherName]

GO



CREATE VIEW [analytics].[StudentEnrolledSectionGradeTrend] AS 

	WITH [grades] as (

		SELECT
			[StudentSectionDimension].[StudentKey],
			CASE WHEN [StudentSectionDimension].[Subject] = 'Mathematics' THEN 'Math' 
				 WHEN [StudentSectionDimension].[Subject] IN ('English Language Arts', 'Reading', 'Writing') THEN 'English' END as [Subject],
			CAST([DateDimension].[CalendarYear] as NVARCHAR) + N'-' + FORMAT([DateDimension].[Month], '00') as [Month],
			[StudentSectionGradeFact].[NumericGradeEarned]
		FROM
			[analytics].[StudentSectionDimension] 
		INNER JOIN
			[analytics].[StudentSectionGradeFact] ON
				[StudentSectionGradeFact].[StudentSectionKey] = [StudentSectionDimension].[StudentSectionKey]
		INNER JOIN
			[analytics].[GradingPeriodDimension] ON
				[StudentSectionGradeFact].[GradingPeriodKey] = [GradingPeriodDimension].[GradingPeriodKey]
		INNER JOIN
			[analytics].[DateDimension] ON
				[GradingPeriodDimension].[GradingPeriodBeginDateKey] = [DateDimension].[DateKey]

	)
	SELECT
		[grades].[StudentKey],
		[StudentDimension].[StudentFirstName] 
			+ ' ' + [StudentDimension].[StudentMiddleName]
			+ ' ' + [StudentDimension].[StudentLastName]
			as [StudentName],
		[grades].[Month],
		AVG(CASE WHEN [grades].[Subject] = 'Math' THEN [grades].[NumericGradeEarned] ELSE NULL END) as [MathGrade],
		AVG(CASE WHEN [grades].[Subject] = 'English' THEN [grades].[NumericGradeEarned] ELSE NULL END) as [EnglishGrade],
		AVG([grades].[NumericGradeEarned]) as [OverallGrade]
	FROM
		[grades]
	INNER JOIN
		[analytics].[StudentDimension] ON
			[grades].[StudentKey] = [StudentDimension].[StudentKey]
	GROUP BY
		[grades].[StudentKey],
		[StudentDimension].[StudentFirstName],
		[StudentDimension].[StudentMiddleName],
		[StudentDimension].[StudentLastName],
		[grades].[Month]

GO



CREATE VIEW [analytics].[StudentAttendanceTrend] AS 

	WITH [attendanceData] as (
		SELECT
			[StudentKey],
			(
				SELECT 
					MAX(Absent)
				FROM (VALUES
						 ([StudentEarlyWarningFact].[IsAbsentFromSchoolExcused])
						,([StudentEarlyWarningFact].[IsAbsentFromSchoolUnexcused])
						,([StudentEarlyWarningFact].[IsAbsentFromHomeroomExcused])
						,([StudentEarlyWarningFact].[IsAbsentFromHomeroomUnexcused])
						-- For EWS demo system, only looking at: either marked as absent from school, or from home room.
						-- Those who are customizing may wish to change from home room to any class.
						--,([StudentEarlyWarningFact].[IsAbsentFromAnyClassExcused])
						--,([StudentEarlyWarningFact].[IsAbsentFromAnyClassUnexcused])
					) as value(Absent)
			) as [IsAbsent],
			[IsEnrolled],
			[DateKey]
		FROM 
			[analytics].[StudentEarlyWarningFact]
		WHERE 
			[IsInstructionalDay] = 1
		AND [IsEnrolled] = 1
	)
	SELECT
		[attendanceData].[StudentKey],
		[StudentDimension].[StudentFirstName] 
			+ ' ' + [StudentDimension].[StudentMiddleName]
			+ ' ' + [StudentDimension].[StudentLastName]
			as [StudentName],
		CAST([DateDimension].[CalendarYear] as NVARCHAR) + N'-' + FORMAT([DateDimension].[Month], '00') as [Month],
		(CAST(SUM([IsEnrolled]) as DECIMAL) - CAST(SUM([IsAbsent]) as DECIMAL)) / CAST(SUM([IsEnrolled]) as DECIMAL) as AttendanceRate
	FROM 
		[attendanceData]
	INNER JOIN
		[analytics].[DateDimension] ON
			[attendanceData].[DateKey] = [DateDimension].[DateKey]
	INNER JOIN
		[analytics].[StudentDimension] ON
			[attendanceData].[StudentKey] = [StudentDimension].[StudentKey]
	GROUP BY
		[attendanceData].[StudentKey],
		[StudentDimension].[StudentFirstName],
		[StudentDimension].[StudentMiddleName],
		[StudentDimension].[StudentLastName],
		[DateDimension].[CalendarYear],
		[DateDimension].[Month]

GO
