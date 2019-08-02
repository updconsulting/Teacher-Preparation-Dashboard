/****** Object:  View [analytics].[StaffDimension]    Script Date: 4/23/2019 2:46:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   VIEW [analytics].[StaffDimension]
AS
SELECT analytics.EntitySchoolYearInstanceSetKey(a.StaffUSI, ssa.SchoolYear) AS StaffSchoolYearInstanceKey,
  a.StaffUSI AS StaffKey, ssa.SchoolYear,
  
  a.FirstName + ' ' + a.LastSurname AS StaffFullName,
  d.CodeValue AS RaceDescriptor,
  d1.CodeValue AS Sex
FROM edfi.Staff a
INNER JOIN edfi.StaffSchoolAssociation ssa ON a.StaffUSI = ssa.StaffUSI
LEFT JOIN edfi.StaffRace sr
  ON a.StaffUSI = sr.StaffUSI
LEFT JOIN edfi.RaceDescriptor rd
  ON sr.RaceDescriptorId = rd.RaceDescriptorId
LEFT JOIN edfi.Descriptor d
  ON rd.RaceDescriptorId = d.DescriptorId
LEFT JOIN edfi.SexDescriptor sd
  ON a.SexDescriptorId = sd.SexDescriptorId
LEFT JOIN edfi.Descriptor d1
  ON sd.SexDescriptorId = d1.DescriptorId
WHERE a.StaffUSI IN (SELECT
  a.StaffUSI
FROM edfi.StaffEducationOrganizationAssignmentAssociation seoaa
INNER JOIN edfi.StaffClassificationDescriptor scd
  ON seoaa.StaffClassificationDescriptorId = scd.StaffClassificationDescriptorId
INNER JOIN edfi.Descriptor d2
  ON scd.StaffClassificationDescriptorId = d2.DescriptorId
WHERE d2.CodeValue LIKE 'Mentor Teacher'
OR d2.CodeValue LIKE 'Site Coordinator')
GO



