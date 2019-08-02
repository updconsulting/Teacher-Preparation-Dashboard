/****** Object:  View [analytics].[TeacherCandidateStaffAssociation]    Script Date: 4/23/2019 2:46:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   VIEW [analytics].[TeacherCandidateStaffAssociation]
AS
WITH TeacherCandidateMentorTeacher
AS (
   SELECT tcsa.TeacherCandidateIdentifier,
          s.StaffUSI,
          seoaa.EducationOrganizationId,
          s.FirstName + ' ' + s.LastSurname AS FullName,
          seoaa.PositionTitle,
          tctppa.SchoolYear
   FROM tpdm.TeacherCandidateStaffAssociation tcsa
       INNER JOIN tpdm.TeacherCandidateTeacherPreparationProviderAssociation tctppa
           ON tctppa.TeacherCandidateIdentifier = tcsa.TeacherCandidateIdentifier
       INNER JOIN edfi.StaffEducationOrganizationAssignmentAssociation seoaa
           ON tcsa.StaffUSI = seoaa.StaffUSI
       INNER JOIN edfi.Staff s
           ON tcsa.StaffUSI = s.StaffUSI
   WHERE seoaa.PositionTitle LIKE 'Mentor Teacher'
         OR seoaa.PositionTitle LIKE 'Site Coordinator')
SELECT [analytics].[EntitySchoolYearInstanceSetKey](
                                                       TeacherCandidateMentorTeacher.TeacherCandidateIdentifier,
                                                       TeacherCandidateMentorTeacher.SchoolYear
                                                   ) TeacherCandidateSchoolYearInstanceKey,
       [analytics].[EntitySchoolYearInstanceSetKey](
                                                       TeacherCandidateMentorTeacher.StaffUSI,
                                                       TeacherCandidateMentorTeacher.SchoolYear
                                                   )  StaffSchoolYearInstanceKey,
       TeacherCandidateIdentifier AS TeacherCandidateKey,
       StaffUSI AS StaffKey,
       TeacherCandidateMentorTeacher.SchoolYear,
       EducationOrganizationId,
       FullName,
       PositionTitle
FROM TeacherCandidateMentorTeacher;
GO