CREATE VIEW [analytics].[SurveyQuestionResponseFact]
AS
  SELECT
    sqr.SurveyResponseIdentifier AS SurveyResponseKey,
    srtca.TeacherCandidateIdentifier AS TeacherCandidateKey,
    sr.StudentUSI AS StudentKey,
    s.SurveyIdentifier,
    s.SurveyTitle,
    ss.SurveySectionTitle,
    sq.QuestionText,
    sqr.TextResponse,
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
  WHERE d.CodeValue NOT IN ('Ranking')
    AND s.SurveyTitle LIKE 'Student Perception - K-%'
GO
