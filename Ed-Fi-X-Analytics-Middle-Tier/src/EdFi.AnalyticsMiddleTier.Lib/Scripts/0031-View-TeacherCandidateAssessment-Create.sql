CREATE VIEW [analytics].[TeacherCandidateAssessment]
AS
  WITH
    TeacherCandidateAssessmentMaxAdministrationDate
    AS
    (
      SELECT
        tc.TeacherCandidateIdentifier,
        sa.AssessmentTitle,
        sa.StudentUSI,
        MAX(sa.AdministrationDate) AS MaxAdminstrationDate
      FROM edfi.StudentAssessment sa
        INNER JOIN tpdm.TeacherCandidate tc
        ON sa.StudentUSI = tc.StudentUSI
      GROUP BY sa.AssessmentTitle,
         tc.TeacherCandidateIdentifier,
         sa.StudentUSI
    ),

    TeacherCandidateAssessment
    AS
    (
      SELECT
        TeacherCandidateIdentifier,
        sa.SchoolYear,

        sa.StudentUSI,
        sa.AssessmentTitle,
        sasr.Result,
        d.CodeValue AS PerformanceLevel,
        sapl.PerformanceLevelMet,
        ROW_NUMBER() OVER (PARTITION BY TeacherCandidateIdentifier, sa.AssessmentTitle ORDER BY sa.AdministrationDate DESC) Latest
      FROM edfi.StudentAssessment sa
        INNER JOIN edfi.StudentAssessmentScoreResult sasr
        ON sa.AcademicSubjectDescriptorId = sasr.AcademicSubjectDescriptorId
          AND sa.AdministrationDate = sasr.AdministrationDate
          AND sa.AssessedGradeLevelDescriptorId = sasr.AssessedGradeLevelDescriptorId
          AND sa.AssessmentTitle = sasr.AssessmentTitle
          AND sa.AssessmentVersion = sasr.AssessmentVersion
          AND sa.StudentUSI = sasr.StudentUSI
        INNER JOIN edfi.StudentAssessmentPerformanceLevel sapl
        ON sa.AcademicSubjectDescriptorId = sapl.AcademicSubjectDescriptorId
          AND sa.AdministrationDate = sapl.AdministrationDate
          AND sa.AssessedGradeLevelDescriptorId = sapl.AssessedGradeLevelDescriptorId
          AND sa.AssessmentTitle = sapl.AssessmentTitle
          AND sa.AssessmentVersion = sapl.AssessmentVersion
          AND sa.StudentUSI = sapl.StudentUSI
        INNER JOIN edfi.PerformanceLevelDescriptor pld ON sapl.PerformanceLevelDescriptorId = pld.PerformanceLevelDescriptorId
        INNER JOIN edfi.Descriptor d ON pld.PerformanceLevelDescriptorId = d.DescriptorId
        INNER JOIN TeacherCandidateAssessmentMaxAdministrationDate tcamad
        ON sa.AssessmentTitle = tcamad.AssessmentTitle
          AND sa.StudentUSI = tcamad.StudentUSI
          AND sa.AdministrationDate = tcamad.MaxAdminstrationDate
    )
  SELECT [analytics].[EntitySchoolYearInstanceSetKey](TeacherCandidateAssessment.TeacherCandidateIdentifier, TeacherCandidateAssessment.SchoolYear) AS TeacherCandidateSchoolYearInstanceKey,
    TeacherCandidateIdentifier TeacherCandidateKey,
    StudentUSI StudentKey,
    TeacherCandidateAssessment.SchoolYear,

    AssessmentTitle,
    Result,
    PerformanceLevelMet,
    Latest,
    PerformanceLevel
  FROM TeacherCandidateAssessment
GO


