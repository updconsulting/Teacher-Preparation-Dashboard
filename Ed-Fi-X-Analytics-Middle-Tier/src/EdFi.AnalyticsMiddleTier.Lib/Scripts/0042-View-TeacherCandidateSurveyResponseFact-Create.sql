CREATE   VIEW [analytics].[TeacherCandidateSurveyResponseFact]
AS
WITH MaxSessionDates
AS (SELECT se.SchoolYear,
           MIN(se.BeginDate) AS BeginDate,
           MAX(se.EndDate) AS EndDate
    FROM edfi.Session se
        INNER JOIN edfi.SchoolYearType syt
            ON syt.SchoolYear = se.SchoolYear
    WHERE syt.CurrentSchoolYear = 1
    GROUP BY se.SchoolYear)
SELECT [analytics].[EntitySchoolYearInstanceSetKey](sr.TeacherCandidateIdentifier, MaxSessionDates.SchoolYear) TeacherCandidateSchoolYearInstanceKey,
       sqr.SurveyResponseIdentifier AS SurveyResponseKey,
       sr.TeacherCandidateIdentifier AS TeacherCandidateKey,
       MaxSessionDates.SchoolYear,
       s.SurveyIdentifier,
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
    INNER JOIN tpdm.QuestionFormDescriptor qfd
        ON sq.QuestionFormDescriptorId = qfd.QuestionFormDescriptorId
    INNER JOIN edfi.Descriptor d
        ON qfd.QuestionFormDescriptorId = d.DescriptorId
    INNER JOIN MaxSessionDates
        ON sr.ResponseDate
           BETWEEN MaxSessionDates.BeginDate AND MaxSessionDates.EndDate
WHERE s.SurveyTitle LIKE 'Program Satisfaction%'
      OR s.SurveyTitle LIKE 'Mentor Teacher Feedback Survey'
      OR s.SurveyTitle LIKE 'Course Evaluation';
GO
