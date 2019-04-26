/****** Object:  View [analytics].[MentorTeacherGradeLevelAcademicSubject]    Script Date: 4/23/2019 2:46:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [analytics].[MentorTeacherGradeLevelAcademicSubject]
AS
SELECT DISTINCT
  ssa.StaffUSI AS StaffKey,
  CASE
    WHEN d.CodeValue IN ('Kindergarten', 'First grade', 'Second grade', 'Third grade', 'Fourth grade', 'Fifth grade') THEN 'Grades k-5'
    WHEN d.CodeValue IN ('Sixth grade', 'Seventh grade', 'Eighth grade') THEN 'Grades 6-8'
    WHEN d.CodeValue IN ('Ninth grade', 'Tenth grade', 'Eleventh grade', 'Twelfth grade') THEN 'Grades 9-12'
  END AS GradeLevelBand,
   CASE WHEN d.CodeValue IN ('Kindergarten', 'First grade', 'Second grade', 'Third grade', 'Fourth grade', 'Fifth grade') THEN 1 
                                               WHEN d.CodeValue  IN ('Sixth grade', 'Seventh grade', 'Eighth grade') THEN 2
                                               WHEN d.CodeValue IN ('Ninth grade', 'Tenth grade', 'Eleventh grade', 'Twelfth grade') THEN 3 END AS DisplayOrder,
  CASE
    WHEN d1.CodeValue = 'English Language Arts' THEN 'ELA'
    WHEN d1.CodeValue = 'Mathematics' THEN 'Math'
    ELSE d1.CodeValue
  END AS AcademicSubjectDescriptor, co.SessionName
FROM edfi.StaffSectionAssociation ssa
INNER JOIN edfi.Section s
  ON ssa.LocalCourseCode = s.LocalCourseCode
  AND ssa.SchoolId = s.SchoolId
  AND ssa.SchoolYear = s.SchoolYear
  AND ssa.SectionIdentifier = s.SectionIdentifier
  AND ssa.SessionName = s.SessionName
INNER JOIN edfi.StudentSectionAssociation ssa1
  ON s.LocalCourseCode = ssa1.LocalCourseCode
  AND s.SchoolId = ssa1.SchoolId
  AND s.SchoolYear = ssa1.SchoolYear
  AND s.SectionIdentifier = ssa1.SectionIdentifier
  AND s.SessionName = ssa1.SessionName
INNER JOIN edfi.Student s1
  ON ssa1.StudentUSI = s1.StudentUSI
INNER JOIN edfi.StudentSchoolAssociation ssa2
  ON s1.StudentUSI = ssa2.StudentUSI
INNER JOIN edfi.GradeLevelDescriptor gld
  ON ssa2.EntryGradeLevelDescriptorId = gld.GradeLevelDescriptorId
INNER JOIN edfi.Descriptor d
  ON gld.GradeLevelDescriptorId = d.DescriptorId
INNER JOIN edfi.CourseOffering co
  ON s.LocalCourseCode = co.LocalCourseCode
  AND s.SchoolId = co.SchoolId
  AND s.SchoolYear = co.SchoolYear
  AND s.SessionName = co.SessionName
INNER JOIN edfi.Course c
  ON co.CourseCode = c.CourseCode
  AND co.EducationOrganizationId = c.EducationOrganizationId
INNER JOIN edfi.AcademicSubjectDescriptor asd
  ON c.AcademicSubjectDescriptorId = asd.AcademicSubjectDescriptorId
INNER JOIN edfi.Descriptor d1
  ON d1.DescriptorId = asd.AcademicSubjectDescriptorId
LEFT JOIN edfi.Session s2 ON co.SchoolId = s2.SchoolId AND co.SchoolYear = s2.SchoolYear AND co.SessionName = s2.SessionName


WHERE d1.CodeValue IN ('Mathematics', 'English Language Arts', 'Science', 'Social Studies')
GO
