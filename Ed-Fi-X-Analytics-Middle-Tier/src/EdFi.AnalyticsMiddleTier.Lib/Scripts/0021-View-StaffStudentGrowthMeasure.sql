/****** Object:  View [analytics].[StaffStudentGrowthMeasure]    Script Date: 4/23/2019 2:46:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [analytics].[StaffStudentGrowthMeasure] as
SELECT
  [StaffUSI] AS StaffKey,
  [FactAsOfDate],
  [SchoolYear],
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
GO
