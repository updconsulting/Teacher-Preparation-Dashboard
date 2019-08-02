/****** Object:  View [analytics].[ApplicantDimension]    Script Date: 4/23/2019 2:46:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE   VIEW analytics.ApplicantDimension
AS
WITH ApplicantRaces
AS
(SELECT
		ar.ApplicantIdentifier
	   ,ar.EducationOrganizationId
	   ,COUNT(*) AS NumberOfRaces
	   ,MAX(d.CodeValue) AS RaceDescriptor
	FROM tpdm.ApplicantRace ar
	INNER JOIN edfi.RaceDescriptor rd
		ON ar.RaceDescriptorId = rd.RaceDescriptorId
	INNER JOIN edfi.Descriptor d
		ON rd.RaceDescriptorId = d.DescriptorId
	GROUP BY ar.ApplicantIdentifier
			,ar.EducationOrganizationId)
SELECT DISTINCT
	[analytics].[EntitySchoolYearInstanceSetKey](a.ApplicantIdentifier, s.SchoolYear) AS ApplicantSchoolYearInstanceKey
   ,a.ApplicantIdentifier AS ApplicantKey
   ,syt.SchoolYear AS SchoolYear
   ,a.TeacherCandidateIdentifier AS TeacherCandidateKey
   ,a.FirstName + ' ' + a.LastSurname AS ApplicantFullName
   ,d.CodeValue AS Sex
   ,CASE
		WHEN ar.NumberOfRaces > 1 THEN 'Two or more'
		ELSE ar.RaceDescriptor
	END RaceDescriptor
FROM tpdm.Applicant a
LEFT OUTER JOIN tpdm.TeacherCandidate tc
	ON a.TeacherCandidateIdentifier = tc.TeacherCandidateIdentifier
LEFT OUTER JOIN edfi.SexDescriptor sd
	ON a.SexDescriptorId = sd.SexDescriptorId
LEFT OUTER JOIN edfi.Descriptor d
	ON sd.SexDescriptorId = d.DescriptorId
LEFT JOIN ApplicantRaces ar
	ON a.ApplicantIdentifier = ar.ApplicantIdentifier
		AND a.EducationOrganizationId = ar.EducationOrganizationId
LEFT JOIN tpdm.Application ap
	ON ap.ApplicantIdentifier = a.ApplicantIdentifier
		AND ap.EducationOrganizationId = a.EducationOrganizationId
INNER JOIN edfi.Session s
	ON ap.ApplicationDate
		BETWEEN s.BeginDate AND s.EndDate
		AND s.SchoolId = a.EducationOrganizationId
INNER JOIN edfi.SchoolYearType syt
	ON syt.SchoolYear = s.SchoolYear
		AND syt.CurrentSchoolYear = 1;

GO
