/****** Object:  View [analytics].[ApplicantProgramFact]    Script Date: 4/23/2019 2:46:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE   VIEW [analytics].[ApplicantProgramFact]
AS
WITH ApplicantProgramAssociation AS ( 
SELECT tctpppa.ApplicantIdentifier AS [ApplicantKey],
       tctpppa.[EducationOrganizationId] AS [TeacherCandidatePreparationProviderKey],
       s.SchoolYear,
       tppp.ProgramId AS ProgramKey,
       tppp.ProgramName,
       MAX(a.AcceptedDate) AcceptedDate,
       MAX(WithdrawDate) WithdrawDate,
       CASE
           WHEN MAX(a.AcceptedDate) IS NOT NULL THEN
               'Accepted'
           WHEN MAX(a.WithdrawDate) IS NOT NULL THEN
               'Withddrawn'
           ELSE
               'Uknown'
       END AS Status,
       MAX(tctpppa.GPA) AS ApplicantGPA
FROM tpdm.ApplicantTeacherPreparationProgram tctpppa
    INNER JOIN tpdm.TeacherPreparationProviderProgram tppp
        ON tctpppa.EducationOrganizationId = tppp.EducationOrganizationId
    INNER JOIN tpdm.Application a
        ON a.EducationOrganizationId = tctpppa.EducationOrganizationId
           AND a.ApplicantIdentifier = tctpppa.ApplicantIdentifier
           AND tppp.ProgramName = tctpppa.TeacherPreparationProgramName
    INNER JOIN edfi.Session s
        ON a.ApplicationDate
           BETWEEN s.BeginDate AND s.EndDate
    INNER JOIN edfi.SchoolYearType syt
        ON syt.SchoolYear = s.SchoolYear
           AND syt.CurrentSchoolYear = 1
GROUP BY tctpppa.ApplicantIdentifier,
         tctpppa.[EducationOrganizationId],
         s.SchoolYear,
         tppp.ProgramId,
         tppp.ProgramName
		 )
		 SELECT [analytics].[EntitySchoolYearInstanceSetKey](ApplicantProgramAssociation.ApplicantKey, ApplicantProgramAssociation.SchoolYear) AS ApplicantSchoolYearInstanceKey,
      [analytics].[EntitySchoolYearInstanceSetKey](ApplicantProgramAssociation.ProgramKey, ApplicantProgramAssociation.SchoolYear) AS ProgramSchoolYearInstanceKey,
				ApplicantProgramAssociation.ApplicantKey,
                ApplicantProgramAssociation.TeacherCandidatePreparationProviderKey,
                ApplicantProgramAssociation.SchoolYear,
                ApplicantProgramAssociation.ProgramKey,
                ApplicantProgramAssociation.ProgramName,
                ApplicantProgramAssociation.AcceptedDate,
                ApplicantProgramAssociation.WithdrawDate,
                ApplicantProgramAssociation.Status,
                ApplicantProgramAssociation.ApplicantGPA
		 FROM ApplicantProgramAssociation
GO