/****** Object:  View [analytics_config].[Security]    Script Date: 4/23/2019 2:46:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  VIEW [analytics].[Security]
AS
WITH TeacherCandidateStaffSectionAssociation
AS (SELECT DISTINCT
  seoaa.StaffUSI,
  tc.TeacherCandidateIdentifier as TeacherCandidateKey,
  d.CodeValue AS StaffClassificationDescriptor,
  s2.LoginId
FROM tpdm.TeacherCandidate tc
INNER JOIN edfi.Student s
  ON tc.StudentUSI = s.StudentUSI
INNER JOIN edfi.StudentSectionAssociation ssa
  ON s.StudentUSI = ssa.StudentUSI
INNER JOIN edfi.Section s1
  ON ssa.LocalCourseCode = s1.LocalCourseCode
  AND ssa.SchoolId = s1.SchoolId
  AND ssa.SchoolYear = s1.SchoolYear
  AND ssa.SectionIdentifier = s1.SectionIdentifier
  AND ssa.SessionName = s1.SessionName
INNER JOIN edfi.StaffSectionAssociation ssa1
  ON s1.LocalCourseCode = ssa1.LocalCourseCode
  AND s1.SchoolId = ssa1.SchoolId
  AND s1.SchoolYear = ssa1.SchoolYear
  AND s1.SectionIdentifier = ssa1.SectionIdentifier
  AND s1.SessionName = ssa1.SessionName
INNER JOIN edfi.StaffEducationOrganizationAssignmentAssociation seoaa
  ON seoaa.StaffUSI = ssa1.StaffUSI
INNER JOIN edfi.Staff s2 ON s2.StaffUSI = seoaa.StaffUSI
INNER JOIN edfi.StaffClassificationDescriptor scd
  ON seoaa.StaffClassificationDescriptorId = scd.StaffClassificationDescriptorId
INNER JOIN edfi.Descriptor d
  ON scd.StaffClassificationDescriptorId = d.DescriptorId),

TeacherCandidateStaffAssociation
AS (SELECT DISTINCT
  seoaa.StaffUSI,
  tcs.TeacherCandidateIdentifier as TeacherCandidatekey,
  d.CodeValue AS StaffClassificationDescriptor,
  s.LoginId
FROM tpdm.TeacherCandidateStaffAssociation tcs
INNER JOIN edfi.StaffEducationOrganizationAssignmentAssociation seoaa
  ON tcs.StaffUSI = seoaa.StaffUSI
INNER JOIN edfi.StaffClassificationDescriptor scd
  ON seoaa.StaffClassificationDescriptorId = scd.StaffClassificationDescriptorId
INNER JOIN edfi.Descriptor d
  ON scd.StaffClassificationDescriptorId = d.DescriptorId
INNER JOIN edfi.Staff s
  ON s.StaffUSI = seoaa.StaffUSI
WHERE d.CodeValue IN ('Site Coordinator')),
TeacherCandidates
AS (SELECT
  tc.TeacherCandidateIdentifier AS StaffUSI,
  tc.TeacherCandidateIdentifier,
  'Teacher Candidate' AS StaffClassificationDescriptor,
  tc.LoginId
FROM tpdm.TeacherCandidate tc)


SELECT
  *
FROM TeacherCandidateStaffAssociation
UNION
SELECT
  *
FROM TeacherCandidateStaffSectionAssociation
UNION
SELECT
  *
FROM TeacherCandidates
GO

