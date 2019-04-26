/****** Object:  View [analytics].[TeacherCandidatePerformanceMeasureFact]    Script Date: 4/23/2019 2:46:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE VIEW [analytics].[TeacherCandidatePerformanceMeasureFact]
AS
WITH MaxPerformanceDate
AS (SELECT
  rlr.RubricTitle,
  rlr.RubricLevelCode,
  pmpbr.TeacherCandidateIdentifier,
  MAX(pm.ActualDateOfPerformanceMeasure) ActualDateOfPerformanceMeasure
FROM tpdm.PerformanceMeasure pm
INNER JOIN tpdm.RubricLevelResponse rlr
  ON pm.PerformanceMeasureIdentifier = rlr.PerformanceMeasureIdentifier
INNER JOIN tpdm.PerformanceMeasurePersonBeingReviewed pmpbr
  ON pm.PerformanceMeasureIdentifier = pmpbr.PerformanceMeasureIdentifier
GROUP BY rlr.RubricTitle,
         rlr.RubricLevelCode,
         pmpbr.TeacherCandidateIdentifier)

SELECT DISTINCT
  pmpbr.TeacherCandidateIdentifier TeacherCandidateKey,
  pm.PerformanceMeasureIdentifier PerformanceMeasureKey,
  d.CodeValue AS PerformanceMeasureType,
  rli.RubricLevelCode,
  rlr.NumericResponse,
  d1.CodeValue AS Term,
  r.RubricTitle,
  rli.LevelTitle,
  rlr.AreaOfRefinement,
  rlr.AreaOfReinforcement,
  pmr.StaffUSI AS StaffKey,
  CASE
    WHEN AreaOfRefinement = 1 THEN 'Refinement'
    WHEN AreaOfReinforcement = 1 THEN 'Reinforcement'
    ELSE ''
  END AS [Status],
  CASE
    WHEN tc.FirstName = pmr.FirstName AND
      tc.LastSurname = pmr.LastSurname AND
      pmr.StaffUSI IS NULL THEN 'Yes'
    ELSE 'No'
  END AS SelfRefelction,
  'Assessment #' + CAST(ROW_NUMBER() OVER (PARTITION BY pmpbr.TeacherCandidateIdentifier, d.CodeValue, rl.RubricLevelCode ORDER BY pm.ActualDateOfPerformanceMeasure) AS NVARCHAR(4)) AS Assessment
FROM tpdm.PerformanceMeasure pm
INNER JOIN tpdm.PerformanceMeasurePersonBeingReviewed pmpbr
  ON pm.PerformanceMeasureIdentifier = pmpbr.PerformanceMeasureIdentifier
INNER JOIN tpdm.PerformanceMeasureReviewer pmr
  ON pm.PerformanceMeasureIdentifier = pmr.PerformanceMeasureIdentifier
INNER JOIN tpdm.PerformanceMeasureReviewer pmr1
  ON pm.PerformanceMeasureIdentifier = pmr1.PerformanceMeasureIdentifier
INNER JOIN tpdm.TeacherCandidate tc
  ON pmpbr.TeacherCandidateIdentifier = tc.TeacherCandidateIdentifier
INNER JOIN tpdm.Rubric r
  ON pmpbr.EducationOrganizationId = r.EducationOrganizationId
INNER JOIN tpdm.RubricLevel rl
  ON r.EducationOrganizationId = rl.EducationOrganizationId
  AND r.RubricTitle = rl.RubricTitle
  AND r.RubricTypeDescriptorId = rl.RubricTypeDescriptorId
INNER JOIN tpdm.RubricLevelInformation rli
  ON rl.EducationOrganizationId = rli.EducationOrganizationId
  AND rl.RubricLevelCode = rli.RubricLevelCode
  AND rl.RubricTitle = rli.RubricTitle
  AND rl.RubricTypeDescriptorId = rli.RubricTypeDescriptorId
INNER JOIN tpdm.RubricLevelResponse rlr
  ON pm.PerformanceMeasureIdentifier = rlr.PerformanceMeasureIdentifier
  AND rl.EducationOrganizationId = rlr.EducationOrganizationId
  AND rl.RubricLevelCode = rlr.RubricLevelCode
  AND rl.RubricTitle = rlr.RubricTitle
  AND rl.RubricTypeDescriptorId = rlr.RubricTypeDescriptorId
INNER JOIN tpdm.PerformanceMeasureTypeDescriptor pmtd
  ON pm.PerformanceMeasureTypeDescriptorId = pmtd.PerformanceMeasureTypeDescriptorId
INNER JOIN tpdm.RubricLevelInformation rli1
  ON rl.EducationOrganizationId = rli1.EducationOrganizationId
  AND rl.RubricLevelCode = rli1.RubricLevelCode
  AND rl.RubricTitle = rli1.RubricTitle
  AND rl.RubricTypeDescriptorId = rli1.RubricTypeDescriptorId
--INNER JOIN MaxPerformanceDate
--ON  rl.RubricLevelCode = MaxPerformanceDate.RubricLevelCode
--  AND pmpbr.TeacherCandidateIdentifier = MaxPerformanceDate.TeacherCandidateIdentifier
--  AND pm.ActualDateOfPerformanceMeasure = MaxPerformanceDate.ActualDateOfPerformanceMeasure
--  AND r.RubricTitle = MaxPerformanceDate.RubricTitle
INNER JOIN edfi.Descriptor d
  ON pmtd.PerformanceMeasureTypeDescriptorId = d.DescriptorId
INNER JOIN edfi.TermDescriptor td
  ON pm.TermDescriptorId = td.TermDescriptorId
INNER JOIN edfi.Descriptor d1
  ON d1.DescriptorId = td.TermDescriptorId
GO
