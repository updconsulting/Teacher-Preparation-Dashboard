/****** Object:  View [analytics].[TeacherCandidateCourseTranscriptFact]    Script Date: 4/23/2019 2:46:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [analytics].[TeacherCandidateCourseTranscriptFact]
AS
SELECT
  tcct.EducationOrganizationId AS TeacherCandidatePreparationProviderkey,
  tcct.TeacherCandidateIdentifier AS TeacherCandidateKey,
  tcct.CourseCode AS CourseCodeKey,
  tcct.FinalLetterGradeEarned,
  cast(cast(tcct.FinalNumericGradeEarned AS int ) AS nvarchar(10)) FinalNumericGradeEarned,
 cast( tcct.SchoolYear AS nvarchar(10)) + ' ' +d.CodeValue AS Term
FROM tpdm.TeacherCandidateCourseTranscript tcct
LEFT JOIN edfi.TermDescriptor td
  ON tcct.TermDescriptorId = td.TermDescriptorId
LEFT JOIN edfi.Descriptor d
  ON td.TermDescriptorId = d.DescriptorId
GO
