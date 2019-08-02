/****** Object:  View [analytics].[StudentAssessment]    Script Date: 4/23/2019 2:46:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE   VIEW [analytics].[StudentAssessment]
AS
WITH StudentAssessmentMaxAdministrationDate
AS (SELECT
  sa.AssessmentTitle,
  sa.StudentUSI,
  MAX(sa.AdministrationDate) AS MaxAdminstrationDate
FROM edfi.StudentAssessment sa
GROUP BY sa.AssessmentTitle,
         sa.StudentUSI),

StudentAssessment
AS (SELECT
  sa.StudentUSI,
  sa.AssessmentTitle,
  sasr.Result,
  d.CodeValue AS PerformanceLevel,
  sapl.PerformanceLevelMet,
  ROW_NUMBER() OVER (PARTITION BY sa.StudentUSI, sa.AssessmentTitle ORDER BY sa.AdministrationDate DESC) Latest
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
INNER JOIN edfi.PerformanceLevelDescriptor pld
  ON sapl.PerformanceLevelDescriptorId = pld.PerformanceLevelDescriptorId
INNER JOIN edfi.Descriptor d
  ON pld.PerformanceLevelDescriptorId = d.DescriptorId
INNER JOIN StudentAssessmentMaxAdministrationDate tcamad
  ON sa.AssessmentTitle = tcamad.AssessmentTitle
  AND sa.StudentUSI = tcamad.StudentUSI
  AND sa.AdministrationDate = tcamad.MaxAdminstrationDate)
SELECT  analytics.EntitySchoolYearInstanceSetKey(sa.StudentUSI,CurrentSchoolYear.SchoolYear) AS StudentSchoolYearInstanceKey,
  sa.StudentUSI StudentKey,
  CurrentSchoolYear.SchoolYear,
  AssessmentTitle,
  Result,
  PerformanceLevelMet,
  Latest,
  PerformanceLevel,
  d1.CodeValue AS GradeLevelDescriptor,
  CASE
    WHEN d1.CodeValue = 'First grade' THEN 1
    WHEN d1.CodeValue = 'Second grade' THEN 2
    WHEN d1.CodeValue = 'Third grade' THEN 3
    WHEN d1.CodeValue = 'Fourth grade' THEN 4
    WHEN d1.CodeValue = 'Fifth grade' THEN 5
    WHEN d1.CodeValue = 'Sixth grade' THEN 6
    WHEN d1.CodeValue = 'Seventh grade' THEN 7
    WHEN d1.CodeValue = 'Eighth grade' THEN 8
    WHEN d1.CodeValue = 'Ninth grade' THEN 9
    WHEN d1.CodeValue = 'Tenth grade' THEN 10
    WHEN d1.CodeValue = 'Eleventh grade' THEN 11
    WHEN d1.CodeValue = 'Twelfth grade' THEN 12
  END GradeLevelOrder
FROM StudentAssessment sa
LEFT JOIN edfi.StudentSchoolAssociation ssa
  ON sa.StudentUSI = ssa.StudentUSI
LEFT JOIN edfi.GradeLevelDescriptor gld
  ON gld.GradeLevelDescriptorId = ssa.EntryGradeLevelDescriptorId
LEFT JOIN edfi.Descriptor d1
  ON d1.DescriptorId = gld.GradeLevelDescriptorId
CROSS APPLY
  (
    SELECT syt.SchoolYear FROM edfi.SchoolYearType syt WHERE syt.CurrentSchoolYear = 1 


  ) CurrentSchoolYear
WHERE sa.AssessmentTitle LIKE '%State%'
GO



