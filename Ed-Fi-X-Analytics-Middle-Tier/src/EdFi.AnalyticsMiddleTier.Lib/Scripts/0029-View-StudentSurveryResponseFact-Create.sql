/****** Object:  View [analytics].[SurveyQuestionResponseFact]    Script Date: 4/23/2019 2:46:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE    VIEW analytics.StudentSurveyResponseFact
AS
SELECT analytics.EntitySchoolYearInstanceSetKey(sr.StudentUSI,CurrentSchoolYear.SchoolYear) StudentSchoolYearInstanceKey , 
  analytics.EntitySchoolYearInstanceSetKey(sr.SurveyResponseIdentifier, CurrentSchoolYear.SchoolYear) SurveyResponseSchoolYearInstanceKey , 
  analytics.EntitySchoolYearInstanceSetKey(sr.TeacherCandidateIdentifier,CurrentSchoolYear.SchoolYear) TeacherCandidateSchoolYearInstanceKey , 
  sqr.SurveyResponseIdentifier AS SurveyResponseKey,
  srtca.TeacherCandidateIdentifier AS TeacherCandidateKey,
  sr.StudentUSI AS StudentKey,
  s.SurveyIdentifier,
CurrentSchoolYear.SchoolYear,
  s.SurveyTitle,
  ss.SurveySectionTitle,
  sq.QuestionText,
  sqr.TextResponse,
  sqr.NumericResponse,
  sqr.NoResponse
FROM tpdm.Survey s
INNER JOIN tpdm.SurveySection ss
  ON s.SurveyIdentifier = ss.SurveyIdentifier
INNER JOIN tpdm.SurveyQuestion sq
  ON s.SurveyIdentifier = sq.SurveyIdentifier
INNER JOIN tpdm.SurveyQuestionResponse sqr
  ON sq.QuestionCode = sqr.QuestionCode
  AND sq.SurveyIdentifier = sqr.SurveyIdentifier
INNER JOIN tpdm.SurveyResponse sr
  ON sqr.SurveyIdentifier = sr.SurveyIdentifier
  AND sqr.SurveyResponseIdentifier = sr.SurveyResponseIdentifier
INNER JOIN tpdm.SurveyResponseTeacherCandidateAssociation srtca
  ON sqr.SurveyResponseIdentifier = srtca.SurveyResponseIdentifier
  AND s.SurveyIdentifier = srtca.SurveyIdentifier
INNER JOIN tpdm.QuestionFormDescriptor qfd
  ON sq.QuestionFormDescriptorId = qfd.QuestionFormDescriptorId
INNER JOIN edfi.Descriptor d
  ON qfd.QuestionFormDescriptorId = d.DescriptorId
  CROSS APPLY (
            SELECT syt.SchoolYear FROM edfi.SchoolYearType syt WHERE syt.CurrentSchoolYear =1
  ) CurrentSchoolYear
WHERE d.CodeValue NOT IN ('Ranking')
AND s.SurveyTitle LIKE 'Student Perception - K-%'
GO
