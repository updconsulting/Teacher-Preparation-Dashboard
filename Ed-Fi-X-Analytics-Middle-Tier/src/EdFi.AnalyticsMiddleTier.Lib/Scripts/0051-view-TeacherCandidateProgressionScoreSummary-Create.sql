CREATE   VIEW [analytics].[TeacherCandidateProgressionScoreSummary]
AS
                SELECT
            1 AS [Order]
   , 'Applied' AS Status
   , asf.AssessmentTitle
   , asf.Result AS Score
   , apf.ApplicantSchoolYearInstanceKey
   , apf.ProgramSchoolYearInstanceKey
        FROM analytics.ApplicantProgramFact apf
            INNER JOIN analytics.ApplicantScoresFact asf
            ON apf.ApplicantKey = asf.ApplicantKey
                AND apf.SchoolYear = asf.SchoolYear
    UNION
        SELECT
            2 AS [Order]
   , 'Accepted' AS Status
   , asf.AssessmentTitle
   , asf.Result AS Score
   , apf.ApplicantSchoolYearInstanceKey
   , apf.ProgramSchoolYearInstanceKey
        FROM analytics.ApplicantProgramFact apf
            INNER JOIN analytics.ApplicantScoresFact asf
            ON apf.ApplicantKey = asf.ApplicantKey
                AND apf.SchoolYear = asf.SchoolYear
        WHERE apf.Status = 'Accepted'
    UNION
        SELECT
            3 AS [Order]
   , 'Enrolled' AS Status
   , asf.AssessmentTitle
   , asf.Result AS Score
   , ad.ApplicantSchoolYearInstanceKey
   , apf.ProgramSchoolYearInstanceKey
        FROM analytics.ApplicantProgramFact apf
            INNER JOIN analytics.ApplicantScoresFact asf
            ON apf.ApplicantKey = asf.ApplicantKey
                AND apf.SchoolYear = asf.SchoolYear
            INNER JOIN analytics.ApplicantDimension ad
            ON apf.ApplicantKey = ad.ApplicantKey
                AND apf.SchoolYear = ad.SchoolYear
            INNER JOIN analytics.TeacherCandidateDimension tcd
            ON ad.TeacherCandidateKey = tcd.TeacherCandidateKey
                AND asf.SchoolYear = tcd.SchoolYear
        WHERE apf.Status = 'Accepted'
GO


