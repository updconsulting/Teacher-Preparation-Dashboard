CREATE   VIEW [analytics].[StaffStudentGrowthMeasure]
as
  SELECT analytics.EntitySchoolYearInstanceSetKey(StaffUSI, MaxSchoolYear.SchoolYear) StaffSchoolYearInstanceKey,
    [StaffUSI] AS StaffKey,
    MaxSchoolYear.SchoolYear,
    [FactAsOfDate],
    --[SchoolYear],
    [StudentGrowthMeasureDate],
    d.CodeValue [ResultDatatypeType],
    d1.CodeValue AS [StudentGrowthType],
    [StudentGrowthTargetScore],
    [StudentGrowthActualScore],
    [StudentGrowthMet],
    [StudentGrowthNCount]
  FROM [tpdm].[StaffStudentGrowthMeasure]
    INNER JOIN edfi.ResultDatatypeTypeDescriptor rdtd
    ON tpdm.StaffStudentGrowthMeasure.ResultDatatypeTypeDescriptorId = rdtd.ResultDatatypeTypeDescriptorId
    INNER JOIN edfi.Descriptor d
    ON d.DescriptorId = rdtd.ResultDatatypeTypeDescriptorId
    INNER JOIN tpdm.StudentGrowthTypeDescriptor sgtd
    ON tpdm.StaffStudentGrowthMeasure.StudentGrowthTypeDescriptorId = sgtd.StudentGrowthTypeDescriptorId
    INNER JOIN edfi.Descriptor d1
    ON d1.DescriptorId = sgtd.StudentGrowthTypeDescriptorId
CROSS APPLY
(   
SELECT syt.SchoolYear
    FROM edfi.SchoolYearType syt
    WHERE syt.CurrentSchoolYear = 1 

) MaxSchoolYear
GO

