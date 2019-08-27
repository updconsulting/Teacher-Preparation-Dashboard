CREATE VIEW [analytics].[TeacherCandidateCourseTranscriptFact]
AS
    WITH
        TeacherCandidateCourseTranscirpt
        AS
        (
            SELECT tcct.EducationOrganizationId AS TeacherPreparationProviderkey,
                tcct.TeacherCandidateIdentifier AS TeacherCandidateKey,
                SchoolYear =
          (
              SELECT SchoolYear
                FROM edfi.SchoolYearType
                WHERE CurrentSchoolYear = 1
          ),
                tcct.CourseCode AS CourseCodeKey,
                tcct.FinalLetterGradeEarned,
                CAST(CAST(tcct.FinalNumericGradeEarned AS INT) AS NVARCHAR(10)) FinalNumericGradeEarned,
                CAST(tcct.SchoolYear AS NVARCHAR(10)) + ' ' + d.CodeValue AS Term
            FROM tpdm.TeacherCandidateCourseTranscript tcct
                LEFT JOIN edfi.TermDescriptor td
                ON tcct.TermDescriptorId = td.TermDescriptorId
                LEFT JOIN edfi.Descriptor d
                ON td.TermDescriptorId = d.DescriptorId
            WHERE tcct.SchoolYear <=
   (
       SELECT SchoolYear
            FROM edfi.SchoolYearType
            WHERE CurrentSchoolYear = 1
   )
        )
    SELECT [analytics].[EntitySchoolYearInstanceSetKey](
                                                       TeacherCandidateCourseTranscirpt.TeacherCandidateKey,
                                                       TeacherCandidateCourseTranscirpt.SchoolYear
                                                   ) AS TeacherCandidateSchoolYearInstanceKey,
        TeacherCandidateCourseTranscirpt.TeacherPreparationProviderkey,
        TeacherCandidateCourseTranscirpt.TeacherCandidateKey,
        TeacherCandidateCourseTranscirpt.SchoolYear,
        TeacherCandidateCourseTranscirpt.CourseCodeKey,
        TeacherCandidateCourseTranscirpt.FinalLetterGradeEarned,
        TeacherCandidateCourseTranscirpt.FinalNumericGradeEarned,
        TeacherCandidateCourseTranscirpt.Term
    FROM TeacherCandidateCourseTranscirpt;
GO



