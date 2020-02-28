CREATE VIEW [analytics].[TeacherCandidateProgressionSummary]
AS

                SELECT
            tpppd.ProgramName
   , tpppd.TeacherPreparationProviderKey
   , tpppd.ProgramSchoolYearInstanceKey
   , tppd.TeacherPreparationProviderName
   , COUNT(DISTINCT ad.ApplicantKey) AS 'Count of  Progression'
   , 'Applied' AS Status
   , 1 AS SortOrder
        FROM analytics.TeacherPreparationProviderProgramDimension tpppd
            INNER JOIN analytics.TeacherPreparationProviderDimension tppd
            ON tppd.TeacherPreparationProviderKey = tppd.TeacherPreparationProviderKey
            INNER JOIN analytics.ApplicantProgramFact apf
            ON tppd.TeacherPreparationProviderKey = apf.TeacherPreparationProviderKey
                AND apf.ProgramName = tpppd.ProgramName
                AND apf.SchoolYear = tpppd.SchoolYear
                AND tpppd.TeacherPreparationProviderKey = apf.TeacherPreparationProviderKey
            INNER JOIN analytics.ApplicantDimension ad
            ON apf.ApplicantKey = ad.ApplicantKey
                AND tpppd.SchoolYear = ad.SchoolYear

        GROUP BY tpppd.ProgramName
		,tpppd.TeacherPreparationProviderKey
		,tpppd.ProgramSchoolYearInstanceKey
		,tppd.TeacherPreparationProviderName
    UNION

        SELECT
            tpppd.ProgramName
   , tpppd.TeacherPreparationProviderKey
   , tpppd.ProgramSchoolYearInstanceKey
   , tppd.TeacherPreparationProviderName
   , COUNT(DISTINCT ad.ApplicantKey) AS 'Count of  Progression'
   , 'Accepted' AS Status
   , 2 AS SortOrder
        FROM analytics.TeacherPreparationProviderProgramDimension tpppd
            INNER JOIN analytics.TeacherPreparationProviderDimension tppd
            ON tppd.TeacherPreparationProviderKey = tppd.TeacherPreparationProviderKey
            INNER JOIN analytics.ApplicantProgramFact apf
            ON tppd.TeacherPreparationProviderKey = apf.TeacherPreparationProviderKey
                AND apf.ProgramName = tpppd.ProgramName
                AND apf.SchoolYear = tpppd.SchoolYear
                AND tpppd.TeacherPreparationProviderKey = apf.TeacherPreparationProviderKey
            INNER JOIN analytics.ApplicantDimension ad
            ON apf.ApplicantKey = ad.ApplicantKey
                AND tpppd.SchoolYear = ad.SchoolYear
        WHERE apf.Status = 'Accepted'
        GROUP BY tpppd.ProgramName
		,tpppd.TeacherPreparationProviderKey
		,tpppd.ProgramSchoolYearInstanceKey
		,tppd.TeacherPreparationProviderName
    UNION


        SELECT
            tpppd.ProgramName
   , tpppd.TeacherPreparationProviderKey
   , tpppd.ProgramSchoolYearInstanceKey
   , tppd.TeacherPreparationProviderName
   , COUNT(DISTINCT ad.ApplicantKey) AS 'Count of  Progression'
   , 'Enrolled' AS Status
   , 3 AS SortOrder
        FROM analytics.TeacherPreparationProviderProgramDimension tpppd
            INNER JOIN analytics.TeacherPreparationProviderDimension tppd
            ON tppd.TeacherPreparationProviderKey = tppd.TeacherPreparationProviderKey
            INNER JOIN analytics.ApplicantProgramFact apf
            ON tppd.TeacherPreparationProviderKey = apf.TeacherPreparationProviderKey
                AND apf.ProgramName = tpppd.ProgramName
                AND apf.SchoolYear = tpppd.SchoolYear
                AND tpppd.TeacherPreparationProviderKey = apf.TeacherPreparationProviderKey
            INNER JOIN analytics.ApplicantDimension ad
            ON apf.ApplicantKey = ad.ApplicantKey
                AND tpppd.SchoolYear = ad.SchoolYear
            INNER JOIN analytics.TeacherCandidateDimension tcd
            ON ad.TeacherCandidateKey = tcd.TeacherCandidateKey
                AND tppd.SchoolYear = tcd.SchoolYear
        WHERE apf.Status = 'Accepted'
        GROUP BY tpppd.ProgramName
		,tpppd.TeacherPreparationProviderKey
		,tpppd.ProgramSchoolYearInstanceKey
		,tppd.TeacherPreparationProviderName
GO


