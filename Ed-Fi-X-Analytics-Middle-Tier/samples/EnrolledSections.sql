USE [EdFi_Glendale]
GO

-- Does not return precisely the same data as the PowerBI starter kit v1.
-- This appears to be due to bugs in the Tabular Data Model supporting 
-- the v1 starter kit. For example, there is no English grade in the PowerBI
-- section list, even when Power BI displays an overall English grade 
-- indicator. That indicator is matching with the result from the query
-- below; therefore the problem is clearly in the old solution and not
-- something about this query.


SELECT
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
	--AND [StudentSectionDimension].[Subject] = 'Mathematics'
	--AND [StudentSectionDimension].[Subject] IN ('English Language Arts', 'Reading', 'Writing')
INNER JOIN
	[analytics].[GradingPeriodDimension] ON
		[StudentSectionGradeFact].[GradingPeriodKey] = [GradingPeriodDimension].[GradingPeriodKey]
INNER JOIN
	[analytics].[MostRecentGradingPeriod] ON
		[StudentSectionGradeFact].[SchoolKey] = [MostRecentGradingPeriod].[SchoolKey]
	AND [GradingPeriodDimension].[GradingPeriodBeginDateKey] = [MostRecentGradingPeriod].[GradingPeriodBeginDateKey]

WHERE
	[StudentSectionGradeFact].[StudentKey] = 100085104

GROUP BY
	[StudentSectionDimension].[Subject],
	[StudentSectionDimension].[LocalCourseCode],
	[StudentSectionDimension].[CourseTitle],
	[StudentSectionDimension].[TeacherName]