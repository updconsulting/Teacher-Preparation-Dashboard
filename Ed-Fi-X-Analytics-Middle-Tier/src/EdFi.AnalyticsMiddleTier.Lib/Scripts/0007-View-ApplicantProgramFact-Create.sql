CREATE   VIEW [analytics].[ApplicantProgramFact]
AS
    WITH
        ApplicantProgramAssociation
        AS
        (
            SELECT tctpppa.ApplicantIdentifier AS [ApplicantKey],
                tctpppa.[EducationOrganizationId] AS [TeacherPreparationProviderKey],
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
        ApplicantProgramAssociation.TeacherPreparationProviderKey,
        ApplicantProgramAssociation.SchoolYear,
        ApplicantProgramAssociation.ProgramKey,
        ApplicantProgramAssociation.ProgramName,
        ApplicantProgramAssociation.AcceptedDate,
        ApplicantProgramAssociation.WithdrawDate,
        ApplicantProgramAssociation.Status,
        ApplicantProgramAssociation.ApplicantGPA
    FROM ApplicantProgramAssociation
GO