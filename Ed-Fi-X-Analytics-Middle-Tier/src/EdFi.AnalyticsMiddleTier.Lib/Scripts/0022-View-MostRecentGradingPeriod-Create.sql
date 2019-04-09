CREATE VIEW [analytics].[MostRecentGradingPeriod] AS

	SELECT
		[SchoolKey],
		MAX([GradingPeriodBeginDateKey]) as [GradingPeriodBeginDateKey]
	FROM 
		[analytics].[GradingPeriodDimension]
	GROUP BY
		[SchoolKey]