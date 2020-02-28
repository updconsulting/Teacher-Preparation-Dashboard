CREATE VIEW [analytics].[StudentSectionGradeFact]
AS
    SELECT [Grade].[StudentUSI] AS [StudentKey],
        [Grade].[SchoolId] AS [SchoolKey],
        CAST([Grade].[GradingPeriodDescriptorId] AS NVARCHAR) + '-' + CAST([Grade].[SchoolId] AS NVARCHAR) + '-'
       + CONVERT(NVARCHAR, [Grade].[BeginDate], 112) AS [GradingPeriodKey],
        CAST([Grade].[StudentUSI] AS NVARCHAR) + '-' + CAST([Grade].[SchoolId] AS NVARCHAR) + '-'
       + [Grade].[SessionName] + '-' + [Grade].[SectionIdentifier] + '-' + [Grade].[LocalCourseCode] + '-'
       + CAST([Grade].[SchoolYear] AS NVARCHAR) + '-' + CONVERT(NVARCHAR, [Grade].[BeginDate], 112) AS [StudentSectionKey],
        CAST([Grade].[SchoolId] AS NVARCHAR) + '-' + [Grade].[SessionName] + '-' + [Grade].[SectionIdentifier] + '-'
       + [Grade].[LocalCourseCode] + '-' + CAST([Grade].[SchoolYear] AS NVARCHAR) AS [SectionKey],
        [Grade].[NumericGradeEarned]
    FROM [edfi].[Grade]
        INNER JOIN [edfi].[Descriptor]
        ON [Grade].[GradeTypeDescriptorId] = [edfi].[Descriptor].[DescriptorId]
        INNER JOIN [edfi].[GradingPeriod]
        ON [Grade].[GradingPeriodDescriptorId] = [GradingPeriod].[GradingPeriodDescriptorId]
            AND [Grade].[SchoolId] = [GradingPeriod].[SchoolId]
            AND [Grade].[BeginDate] = [GradingPeriod].[BeginDate]
        INNER JOIN [edfi].[Descriptor] AS [GradingPeriodDescriptor]
        ON [GradingPeriod].[GradingPeriodDescriptorId] = [GradingPeriodDescriptor].[DescriptorId]
    WHERE [edfi].[Descriptor].[CodeValue] = 'Grading Period';
GO
