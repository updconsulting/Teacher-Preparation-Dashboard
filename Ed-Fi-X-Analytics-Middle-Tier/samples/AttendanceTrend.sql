--select * from edfi.student where FirstName = 'Anne' and LastSurname = 'Goulet' --100106833

USE [EdFi_Glendale]
GO


-- Original PowerBI solution does not use "AnyClass" in its calculations - only (School, Homeroom).

WITH attendanceData as (
	SELECT 
		(
			SELECT 
				MAX(Absent)
			FROM (VALUES
					([StudentEarlyWarningFact].[IsAbsentFromSchoolUnexcused])
					,([StudentEarlyWarningFact].[IsAbsentFromHomeroomUnexcused])
					--,([StudentEarlyWarningFact].[IsAbsentFromAnyClassUnexcused])
				) as value(Absent)
		) as [IsUnexcused],
		(
			SELECT 
				MAX(Absent)
			FROM (VALUES
					([StudentEarlyWarningFact].[IsAbsentFromSchoolExcused])
					,([StudentEarlyWarningFact].[IsAbsentFromHomeroomExcused])
					--,([StudentEarlyWarningFact].[IsAbsentFromAnyClassExcused])
				) as value(Absent)
		) as [IsExcused],
		(
			SELECT 
				MAX(Absent)
			FROM (VALUES
					([StudentEarlyWarningFact].[IsTardyToSchool])
					,([StudentEarlyWarningFact].[IsTardyToHomeroom])
					--,([StudentEarlyWarningFact].[IsAbsentFromAnyClassExcused])
				) as value(Absent)
		) as [IsTardy],
		(
			SELECT 
				MAX(Absent)
			FROM (VALUES
					 ([StudentEarlyWarningFact].[IsAbsentFromSchoolExcused])
					,([StudentEarlyWarningFact].[IsAbsentFromSchoolUnexcused])
					,([StudentEarlyWarningFact].[IsAbsentFromHomeroomExcused])
					,([StudentEarlyWarningFact].[IsAbsentFromHomeroomUnexcused])
					--,([StudentEarlyWarningFact].[IsAbsentFromAnyClassExcused])
					--,([StudentEarlyWarningFact].[IsAbsentFromAnyClassUnexcused])
				) as value(Absent)
		) as [IsAbsent],
		[IsEnrolled],
		[DateKey]
	FROM 
		[analytics].[StudentEarlyWarningFact]
	WHERE 
			[StudentKey] = 100106833
		AND [IsInstructionalDay] = 1
		AND [IsEnrolled] = 1
		AND [DateKey] <= '20111031'
		--AND [DateKey] <= '20110908'
)
SELECT
	SUM([IsUnexcused]) as [UnexcusedAbsences],
	SUM([IsExcused]) as [ExcusedAbsences],
	SUM([IsTardy]) as [Tardies],
	SUM([IsAbsent]) as [DaysAbsent],
	SUM(CASE WHEN [DateKey] <= '20111031' THEN [IsAbsent] ELSE 0 END) as [DaysAbsentPowerBI],
	SUM([IsEnrolled]) as [DaysEnrolled],
	(CAST(SUM([IsEnrolled]) as DECIMAL) - CAST(SUM([IsAbsent]) as DECIMAL)) / CAST(SUM([IsEnrolled]) as DECIMAL) as AttendanceRate,
	-- This is how PowerBI calculats, but this is not right. It is calculating days absent for a month and dividing by 
	-- total number of days in the year.
	(CAST(SUM([IsEnrolled]) as DECIMAL) - CAST(SUM(CASE WHEN [DateKey] <= '20111031' THEN [IsAbsent] ELSE 0 END) as DECIMAL)) / CAST(SUM([IsEnrolled]) as DECIMAL) as AttendanceRatePowerBi
FROM attendanceData 


