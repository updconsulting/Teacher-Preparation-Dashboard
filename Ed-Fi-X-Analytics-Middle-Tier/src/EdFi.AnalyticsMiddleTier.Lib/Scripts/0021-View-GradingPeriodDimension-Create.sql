CREATE VIEW [analytics].[GradingPeriodDimension]
AS
SELECT CAST([GradingPeriod].[GradingPeriodDescriptorId] AS NVARCHAR) + '-'
       + CAST([GradingPeriod].[SchoolId] AS NVARCHAR) + '-' + CONVERT(NVARCHAR, [GradingPeriod].[BeginDate], 112) AS [GradingPeriodKey],
       CONVERT(NVARCHAR, [GradingPeriod].[BeginDate], 112) AS [GradingPeriodBeginDateKey],
       CONVERT(NVARCHAR, [GradingPeriod].[EndDate], 112) AS [GradingPeriodEndDateKey],
       [GradingPeriodDescriptor].[CodeValue] AS [GradingPeriodDescription],
       [GradingPeriod].[TotalInstructionalDays],
       [GradingPeriod].[PeriodSequence],
       [GradingPeriod].[SchoolId] AS [SchoolKey],
       [GradingPeriod].[LastModifiedDate]
FROM [edfi].[GradingPeriod]
    INNER JOIN [edfi].[Descriptor] AS [GradingPeriodDescriptor]
        ON [GradingPeriod].[GradingPeriodDescriptorId] = [GradingPeriodDescriptor].[DescriptorId];
GO


