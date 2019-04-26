/****** Object:  View [analytics].[ApplicantDimension]    Script Date: 4/23/2019 2:46:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [analytics].[ApplicantDimension]
AS
SELECT
  a.ApplicantIdentifier AS ApplicantKey,
  a.TeacherCandidateIdentifier AS TeacherCandidateKey,
  a.FirstName + ' ' + a.LastSurname AS ApplicantFullName,
  d.CodeValue AS Sex,
  d1.CodeValue AS RaceDescriptor
FROM tpdm.Applicant a
LEFT OUTER JOIN tpdm.TeacherCandidate tc
  ON a.TeacherCandidateIdentifier = tc.TeacherCandidateIdentifier
LEFT OUTER JOIN edfi.SexDescriptor sd
  ON a.SexDescriptorId = sd.SexDescriptorId
LEFT OUTER JOIN edfi.Descriptor d
  ON sd.SexDescriptorId = d.DescriptorId
LEFT JOIN tpdm.ApplicantRace ar
  ON a.ApplicantIdentifier = ar.ApplicantIdentifier
  AND a.EducationOrganizationId = ar.EducationOrganizationId
LEFT JOIN edfi.RaceDescriptor rd
  ON ar.RaceDescriptorId = rd.RaceDescriptorId
LEFT JOIN edfi.Descriptor d1
  ON rd.RaceDescriptorId = d1.DescriptorId
GO
