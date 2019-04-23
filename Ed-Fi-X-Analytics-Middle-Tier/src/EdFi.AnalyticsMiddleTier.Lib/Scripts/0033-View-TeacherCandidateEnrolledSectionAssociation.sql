/****** Object:  View [analytics].[TeacherCandidateEnrolledSectionAssociation]    Script Date: 4/23/2019 2:46:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [analytics].[TeacherCandidateEnrolledSectionAssociation]
AS
SELECT
  ssa.SectionIdentifier AS SectionKey,
  ssa.StudentUSI AS StudentKey,
  tc.TeacherCandidateIdentifier AS TeacherCandidateKey,
  s1.FirstName + ' ' + s1.LastSurname AS InstructorFullName,
  d.CodeValue as MediumOfInstruction, 
  c.CourseTitle AS CourseTitle,
  ssa.BeginDate,
  ssa.SchoolId,
  ssa.SchoolYear,
  ssa.SessionName,
  ssa.EndDate
FROM edfi.StudentSectionAssociation ssa
INNER JOIN edfi.Section s
  ON ssa.LocalCourseCode = s.LocalCourseCode
  AND ssa.SchoolId = s.SchoolId
  AND ssa.SchoolYear = s.SchoolYear
  AND ssa.SectionIdentifier = s.SectionIdentifier
  AND ssa.SessionName = s.SessionName
INNER JOIN edfi.CourseOffering co
  ON ssa.LocalCourseCode = co.LocalCourseCode
  AND s.LocalCourseCode = co.LocalCourseCode
  AND ssa.SchoolId = co.SchoolId
  AND ssa.SchoolYear = co.SchoolYear
  AND s.SessionName = co.SessionName
INNER JOIN edfi.Course c
  ON co.CourseCode = c.CourseCode
LEFT JOIN edfi.MediumOfInstructionDescriptor moid ON s.MediumOfInstructionDescriptorId = moid.MediumOfInstructionDescriptorId
LEFT JOIN edfi.Descriptor d ON d.DescriptorId = moid.MediumOfInstructionDescriptorId
INNER JOIN tpdm.TeacherCandidate tc
  ON tc.StudentUSI = ssa.StudentUSI
LEFT JOIN edfi.StaffSectionAssociation ssa1
  ON ssa1.LocalCourseCode = s.LocalCourseCode
  AND ssa1.SchoolId = s.SchoolId
  AND ssa1.SchoolYear = s.SchoolYear
  AND ssa1.SectionIdentifier = s.SectionIdentifier
  AND ssa1.SessionName = s.SessionName
LEFT JOIN edfi.Staff s1
  ON ssa1.StaffUSI = s1.StaffUSI
GO
