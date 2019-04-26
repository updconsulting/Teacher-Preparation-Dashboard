/****** Object:  View [analytics].[TeacherCandidateDimension]    Script Date: 4/23/2019 2:46:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [analytics].[TeacherCandidateDimension]
AS
WITH TeacherCandidateRaces
AS (SELECT
  tc.TeacherCandidateIdentifier,
  COUNT(DISTINCT tcr.RaceDescriptorId) AS RaceCount,
  MAX(tcr.RaceDescriptorId) AS RaceDescriptorId
FROM tpdm.TeacherCandidate tc
INNER JOIN tpdm.TeacherCandidateRace tcr
  ON tc.TeacherCandidateIdentifier = tcr.TeacherCandidateIdentifier
GROUP BY tc.TeacherCandidateIdentifier)

SELECT
  tc.TeacherCandidateIdentifier TeacherCandidateKey,
  [tc].[StudentUSI] AS [StudentKey],
  [tctppa].TeacherPreparationProviderId AS [TeacherPreparationProviderKey],
  tc.[FirstName] AS [TeacherCandidateFirstName],
  ISNULL(tc.[MiddleName], '') AS [TeacherCandidateMiddleName],
  ISNULL(tc.[LastSurname], '') AS [TeacherCandidateLastName],
  [tctppa].[EntryDate] AS [EnrollmentDate],
  d1.[CodeValue] AS [Sex],
  CASE
    WHEN TeacherCandidateRaces.RaceCount > 1 THEN 'Two or more'
    ELSE d3.CodeValue
  END AS RaceDescriptor,
  [PrimaryContact].[TeacherCandidateName],
  [PrimaryContact].[TeacherCandidateAddress],
  [PrimaryContact].[TeacherCandidateMobilePhoneNumber],
  [PrimaryContact].[TeacherCandidateWorkPhoneNumber],
  [PrimaryContact].[ContactEmailAddress],
  d.CodeValue AS TPPDegreeType,
  d2.[CodeValue] AS [GradeLevel],
  tcds.MajorSpecialization,
  tcds.MinorSpecialization,
  tc.ProgramComplete AS ProgramComplete,
  tccy.SchoolYear AS CohortYear,
  tc.EconomicDisadvantaged,
  tc.FirstGenerationStudent,
  (SELECT
    MAX([LastModifiedDate])
  FROM (VALUES ([tc].[LastModifiedDate])
  ) AS value ([LastModifiedDate]))
  AS [LastModifiedDate]
FROM tpdm.TeacherCandidate tc
LEFT JOIN tpdm.TeacherCandidateCohortYear tccy
  ON tc.TeacherCandidateIdentifier = tccy.TeacherCandidateIdentifier
INNER JOIN tpdm.TeacherCandidateTPPProgramDegree tctd
  ON tc.TeacherCandidateIdentifier = tctd.TeacherCandidateIdentifier
INNER JOIN edfi.GradeLevelDescriptor gld
  ON tctd.GradeLevelDescriptorId = gld.GradeLevelDescriptorId
INNER JOIN edfi.Descriptor d2
  ON gld.GradeLevelDescriptorId = d2.DescriptorId
LEFT JOIN tpdm.TeacherCandidateDegreeSpecialization tcds
  ON tc.TeacherCandidateIdentifier = tcds.TeacherCandidateIdentifier
INNER JOIN tpdm.TPPDegreeTypeDescriptor ttd
  ON tctd.TPPDegreeTypeDescriptorId = ttd.TPPDegreeTypeDescriptorId
INNER JOIN edfi.Descriptor d
  ON ttd.TPPDegreeTypeDescriptorId = d.DescriptorId
LEFT JOIN edfi.Descriptor d1
  ON tc.BirthSexDescriptorId = d1.DescriptorId
INNER JOIN tpdm.TeacherCandidateTeacherPreparationProviderAssociation tctppa
  ON tc.TeacherCandidateIdentifier = tctppa.TeacherCandidateIdentifier
INNER JOIN tpdm.TeacherPreparationProvider tpp
  ON tctppa.TeacherPreparationProviderId = tpp.TeacherPreparationProviderId
INNER JOIN edfi.EducationOrganization eo
  ON tpp.TeacherPreparationProviderId = eo.EducationOrganizationId
LEFT JOIN TeacherCandidateRaces
  ON tc.TeacherCandidateIdentifier = TeacherCandidateRaces.TeacherCandidateIdentifier
LEFT JOIN edfi.Descriptor d3
  ON d3.DescriptorId = TeacherCandidateRaces.RaceDescriptorId
OUTER APPLY (
-- It is possible for more than one person to be marked as primary contact, therefore 
-- we have to carefully restrict to just one record.
SELECT TOP 1
  [FirstName] + ' ' + [LastName] AS [TeacherCandidateName],
  COALESCE(
  NULLIF([HomeAddress], ''),
  NULLIF([PhysicalAddress], ''),
  NULLIF([MailingAddress], ''),
  NULLIF([WorkAddress], ''),
  NULLIF([TemporaryAddress], '')
  ) AS [TeacherCandidateAddress],
  [WorkPhoneNumber] AS [TeacherCandidateWorkPhoneNumber],
  [MobilePhoneNumber] AS [TeacherCandidateMobilePhoneNumber],
  CASE
    WHEN [PrimaryEmailAddress] = 'Work' THEN [WorkEmailAddress]
    ELSE [PersonalEmailAddress]
  END AS [ContactEmailAddress],
  tccd.LastModifiedDate
FROM [analytics].[TeacherCandidateContactDimension] tccd
WHERE tc.TeacherCandidateIdentifier = tccd.TeacherCandidateKey) AS [PrimaryContact]
WHERE tctppa.[ExitWithdrawDate] IS NULL;
GO
