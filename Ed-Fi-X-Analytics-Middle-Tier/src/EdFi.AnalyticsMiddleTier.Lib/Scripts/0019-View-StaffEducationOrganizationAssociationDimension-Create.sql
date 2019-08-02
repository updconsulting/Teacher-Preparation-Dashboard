/****** Object:  View [analytics].[StaffEducationOrganizationAssociationDimension]    Script Date: 4/23/2019 2:46:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   VIEW [analytics].[StaffEducationOrganizationAssociationDimension]
AS
SELECT DISTINCT analytics.EntitySchoolYearInstanceSetKey(seoaa.EducationOrganizationId, ssa.SchoolYear) EducationOrganizationSchoolYearInstanceKey,
  analytics.EntitySchoolYearInstanceSetKey(seoaa.StaffUSI, ssa.SchoolYear) StaffSchoolYearInstanceKey,
  ssa.SchoolYear,
  seoaa.EducationOrganizationId AS EducationOrganizationKey
 ,seoaa.StaffUSI StaffKey
 ,d.CodeValue AS StaffClassificationDescriptor
FROM edfi.StaffEducationOrganizationAssignmentAssociation seoaa
INNER JOIN edfi.StaffClassificationDescriptor scd
  ON seoaa.StaffClassificationDescriptorId = scd.StaffClassificationDescriptorId
INNER JOIN edfi.Descriptor d
  ON scd.StaffClassificationDescriptorId = d.DescriptorId
INNER JOIN edfi.StaffSchoolAssociation ssa
  ON seoaa.StaffUSI = ssa.StaffUSI
GO


