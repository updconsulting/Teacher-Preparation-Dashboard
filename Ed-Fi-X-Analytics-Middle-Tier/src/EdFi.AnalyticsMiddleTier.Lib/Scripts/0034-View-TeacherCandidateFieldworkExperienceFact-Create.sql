/****** Object:  View [analytics].[TeacherCandidateFieldworkExperienceFact]    Script Date: 4/23/2019 2:46:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE VIEW [analytics].[TeacherCandidateFieldworkExperienceFact]
AS


SELECT
DISTINCT
  tcfe.TeacherCandidateIdentifier TeacherCandidateKey,
  tcfe.SchoolId AS SchoolKey,
  lea.LocalEducationAgencyId AS LocalEducationAgencyKey,
  eo.NameOfInstitution PlacementSchool,
  eo1.NameOfInstitution PlacementDistrict,
  tcfesa.SessionName AS Semester,
  SUM(tcfe.HoursPerWeek) AS HoursPerWeek
FROM tpdm.TeacherCandidateFieldworkExperience tcfe
INNER JOIN edfi.School s
  ON tcfe.SchoolId = s.SchoolId
INNER JOIN edfi.EducationOrganization eo
  ON s.SchoolId = eo.EducationOrganizationId
INNER JOIN edfi.LocalEducationAgency lea
  ON s.LocalEducationAgencyId = lea.LocalEducationAgencyId
INNER JOIN edfi.EducationOrganization eo1
  ON lea.LocalEducationAgencyId = eo1.EducationOrganizationId
LEFT JOIN tpdm.TeacherCandidateTeacherPreparationProviderAssociation tctppa
  ON tcfe.TeacherCandidateIdentifier = tctppa.TeacherCandidateIdentifier
LEFT JOIN tpdm.TeacherCandidateFieldworkExperienceSectionAssociation tcfesa
  ON tcfe.BeginDate = tcfesa.BeginDate
  AND tcfe.FieldworkIdentifier = tcfesa.FieldworkIdentifier
  AND tcfe.SchoolId = tcfesa.SchoolId
  AND tcfe.TeacherCandidateIdentifier = tcfesa.TeacherCandidateIdentifier
GROUP BY tcfe.TeacherCandidateIdentifier,
         tcfe.SchoolId,
         lea.LocalEducationAgencyId,
         eo.NameOfInstitution,
         eo1.NameOfInstitution,
         tcfesa.SessionName

GO
