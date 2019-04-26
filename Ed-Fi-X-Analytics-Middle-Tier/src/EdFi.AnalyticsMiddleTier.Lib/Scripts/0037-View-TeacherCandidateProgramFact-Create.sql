/****** Object:  View [analytics].[TeacherCandidateProgramFact]    Script Date: 4/23/2019 2:46:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [analytics].[TeacherCandidateProgramFact]
AS

WITH TeacherCandidateAcademicRecord
AS (SELECT
  tcar.TeacherCandidateIdentifier,
  tcar.EducationOrganizationId,
  tcar.ProjectedGraduationDate,
  ROW_NUMBER() OVER (PARTITION BY tcar.TeacherCandidateIdentifier, tcar.EducationOrganizationId ORDER BY tcar.SchoolYear, tcar.TermDescriptorId) AS LatestAcademicRecord
FROM tpdm.TeacherCandidateAcademicRecord tcar)

SELECT
  x.TeacherCandidateKey,
  x.TeacherCandidatePreparationProviderKey,
  x.ProgramKey,
  x.ReasonExitedDescriptor,
  x.ProgramName, 
  x.ProgramStatus
FROM (SELECT
  tctpppa.TeacherCandidateIdentifier AS [TeacherCandidateKey],
  tctpppa.[EducationOrganizationId] AS [TeacherCandidatePreparationProviderKey],
  tppp.ProgramId AS ProgramKey,
  tctpppa.ProgramName AS ProgramName,
  d.CodeValue AS ReasonExitedDescriptor,
  CASE
    WHEN d.Description LIKE '%Graduat%' AND
      tctpppa.EndDate <= tcar.ProjectedGraduationDate THEN 'Completed on time'
    WHEN d.Description LIKE '%Graduat%' AND
      tctpppa.EndDate > tcar.ProjectedGraduationDate THEN 'Completed not on time'
    WHEN tctpppa.EndDate IS NULL AND
      d.Description IS NOT NULL THEN 'Discontiued'
    ELSE 'Still Enrolled'
  END AS ProgramStatus,
  ROW_NUMBER() OVER (PARTITION BY tcar.TeacherCandidateIdentifier, tcar.EducationOrganizationId ORDER BY tctpppa.BeginDate) AS LatestProgramAssociation
FROM tpdm.TeacherCandidateTeacherPreparationProviderProgramAssociation tctpppa
INNER JOIN tpdm.TeacherPreparationProviderProgram tppp
  ON tctpppa.EducationOrganizationId = tppp.EducationOrganizationId
  AND tctpppa.ProgramName = tppp.ProgramName
INNER JOIN TeacherCandidateAcademicRecord tcar
  ON tctpppa.TeacherCandidateIdentifier = tcar.TeacherCandidateIdentifier
  AND tctpppa.EducationOrganizationId = tcar.EducationOrganizationId
LEFT JOIN edfi.ReasonExitedDescriptor red
  ON tctpppa.ReasonExitedDescriptorId = red.ReasonExitedDescriptorId
LEFT JOIN edfi.Descriptor d
  ON red.ReasonExitedDescriptorId = d.DescriptorId
WHERE tcar.LatestAcademicRecord = 1) x
WHERE x.LatestProgramAssociation = 1
GO
