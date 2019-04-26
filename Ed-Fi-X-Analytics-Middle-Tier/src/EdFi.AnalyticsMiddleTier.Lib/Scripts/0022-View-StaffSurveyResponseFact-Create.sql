/****** Object:  View [analytics].[StaffSurveyResponseFact]    Script Date: 4/23/2019 2:46:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [analytics].[StaffSurveyResponseFact]
AS
SELECT
  sqr.SurveyResponseIdentifier AS SurveyResponseKey,
  sr.StaffUSI AS Staffkey,
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
INNER JOIN tpdm.QuestionFormDescriptor qfd
  ON sq.QuestionFormDescriptorId = qfd.QuestionFormDescriptorId
INNER JOIN edfi.Descriptor d
  ON qfd.QuestionFormDescriptorId = d.DescriptorId
WHERE s.SurveyTitle LIKE 'Mentor Teacher Self Reflection Survey'
OR s.SurveyTitle LIKE 'Principal Feeback Survey'
OR s.SurveyTitle LIKE 'TPP Support Survey'
GO
