/*
 * These queries work best in a "datamart" database with materialized views. The last
 * query in this file relies on one of the queries in the EwsViews script.
 */

-- Number of days a student is enrolled in a special program
CREATE VIEW [analytics].[StudentProgramParticipation] AS

	SELECT
		[Enter].[StudentKey],
		[LocalEducationAgencyDimension].[LocalEducationAgencyName],
		[ProgramTypeDimension].[ProgramType],
		DATEDIFF(d, MIN([DateDimension].[Date]), MAX([DateDimension].[DateKey])) as [Duration]
	FROM
		[analytics].[StudentProgramEvent] as [Enter]
	INNER JOIN
		[analytics].[ProgramTypeDimension] ON
			[Enter].[ProgramTypeKey] = [ProgramTypeDimension].[ProgramTypeKey]
	INNER JOIN
		[analytics].[LocalEducationAgencyDimension] ON
			[Enter].[LocalEducationAgencyKey] = [LocalEducationAgencyDimension].[LocalEducationAgencyKey]
	LEFT OUTER JOIN
		[analytics].[StudentProgramEvent] as [Exit] ON
			[Enter].[StudentKey] = [Exit].[StudentKey]
		AND [Enter].[LocalEducationAgencyKey] = [Exit].[LocalEducationAgencyKey]
		AND [Enter].[ProgramTypeKey] = [Exit].[ProgramTypeKey]
		AND [Exit].[ProgramEventType] = 'Exit'
	INNER JOIN
		[analytics].[DateDimension] ON
			[Enter].[DateKey] <= [DateDimension].[DateKey]
		AND (
				([Exit].[DateKey] IS NULL AND [DateDimension].[Date] <= GETDATE())
			OR  ([Exit].[DateKey] >= [DateDimension].[DateKey])
		)	
	WHERE
		[Enter].[ProgramEventType] = 'Enter'
	GROUP BY
		[Enter].[StudentKey],
		[LocalEducationAgencyDimension].[LocalEducationAgencyName],
		[ProgramTypeDimension].[ProgramType]
GO

-- Count and average duration of students in programs by district
CREATE VIEW [analytics].[DistrictProgramParticipation] AS

	SELECT
		[LocalEducationAgencyName],
		[ProgramType],
		COUNT([StudentKey]) as [NumberOfStudents],
		AVG([Duration]) as [AverageDuration]
	FROM
		[analytics].[StudentProgramParticipation]
	GROUP BY
		[LocalEducationAgencyName],
		[ProgramType]

GO

-- Students at risk who are not already in an intervention-related program
CREATE VIEW [analytics].[StudentsAtRiskWhoAreNotInAnInterventionYet] AS

	SELECT
		CONCAT([StudentDimension].[StudentFirstName],' ', [StudentDimension].[StudentMiddleName], ' ', [StudentDimension].[StudentLastName]) as [StudentName],
		[SchoolDimension].[SchoolName],
		[StudentIndicators].[MathGrade],
		[StudentIndicators].[EnglishGrade],
		[StudentIndicators].[OverallGrade],
		[StudentIndicators].[AttendanceRate],
		[StudentIndicators].[GradeIndicator],
		[StudentIndicators].[AttendanceIndicator],
		[StudentIndicators].[BehaviorIndicator]
	FROM
		[analytics].[StudentIndicators]
	INNER JOIN
		[analytics].[StudentDimension] ON
			[StudentIndicators].[StudentKey] = [StudentDimension].[StudentKey]
	INNER JOIN
		[analytics].[SchoolDimension] ON
			[StudentIndicators].[SchoolKey] = [SchoolDimension].[SchoolKey]
	WHERE
		[StudentIndicators].[GradeIndicator] = 'At risk'
	OR	[StudentIndicators].[AttendanceIndicator]  = 'At risk'
	OR  [StudentIndicators].[BehaviorIndicator]  = 'At risk'
	AND EXISTS (
		SELECT
			1
		FROM
			[analytics].[StudentProgramEvent]
		INNER JOIN
			[analytics].[ProgramTypeDimension] ON
				[StudentProgramEvent].[ProgramTypeKey] = [ProgramTypeDimension].[ProgramTypeKey]
		WHERE
			[StudentIndicators].[StudentKey] = [StudentProgramEvent].[StudentKey]
		AND [SchoolDimension].[LocalEducationAgencyKey] = [StudentProgramEvent].[LocalEducationAgencyKey]
		AND [ProgramTypeDimension].[ProgramType] NOT IN ('Counseling Services', 'Student Retention/Dropout Prevention', 'Early Intervention Services Part C')
	)

GO
