CREATE   VIEW [analytics].[TeacherCandidateProgramFact]
AS

    WITH
        TeacherCandidateAcademicRecord
        AS
        (
            SELECT tcar.TeacherCandidateIdentifier,
                tcar.EducationOrganizationId,
                tcar.ProjectedGraduationDate,
                ROW_NUMBER() OVER (PARTITION BY tcar.TeacherCandidateIdentifier,
                                           tcar.EducationOrganizationId
                              ORDER BY tcar.SchoolYear,
                                       tcar.TermDescriptorId
                             ) AS LatestAcademicRecord
            FROM tpdm.TeacherCandidateAcademicRecord tcar
        )
    SELECT [analytics].[EntitySchoolYearInstanceSetKey](x.TeacherCandidateKey, x.Schoolyear) TeacherCandidateSchoolyearInstaceKey,
        [analytics].[EntitySchoolYearInstanceSetKey](x.ProgramKey, x.Schoolyear) ProgramSchoolyearInstaceKey,
        [analytics].[EntitySchoolYearInstanceSetKey](x.TeacherPreparationProviderKey, x.Schoolyear) TeacherPreparationProviderSchoolYearInstanceKey,
        x.TeacherCandidateKey,
        x.TeacherPreparationProviderKey,
        x.ProgramKey,
        x.Schoolyear,
        x.ReasonExitedDescriptor,
        x.ProgramName,
        x.ProgramStatus
    FROM
        (
    SELECT tctpppa.TeacherCandidateIdentifier AS [TeacherCandidateKey],
            tctpppa.[EducationOrganizationId] AS [TeacherPreparationProviderKey],
            tppp.ProgramId AS ProgramKey,
            tctpppa.ProgramName AS ProgramName,
            d.CodeValue AS ReasonExitedDescriptor,
            CASE
               WHEN d.Description LIKE '%Graduat%'
                AND tctpppa.EndDate <= tcar.ProjectedGraduationDate THEN
                   'Completed on time'
               WHEN d.Description LIKE '%Graduat%'
                AND tctpppa.EndDate > tcar.ProjectedGraduationDate THEN
                   'Completed not on time'
               WHEN tctpppa.EndDate IS NULL
                AND d.Description IS NOT NULL THEN
                   'Discontiued'
               ELSE
                   'Still Enrolled'
           END AS ProgramStatus,
            ROW_NUMBER() OVER (PARTITION BY tctpppa.TeacherCandidateIdentifier,
                                           tctpppa.EducationOrganizationId
                              ORDER BY tctpppa.BeginDate
                             ) AS LatestProgramAssociation, pa.SchoolYear

        FROM tpdm.TeacherCandidateTeacherPreparationProviderProgramAssociation tctpppa
            LEFT JOIN tpdm.TeacherPreparationProviderProgram tppp
            ON tctpppa.EducationOrganizationId = tppp.EducationOrganizationId
                AND tctpppa.ProgramName = tppp.ProgramName
            INNER JOIN tpdm.TeacherCandidateTeacherPreparationProviderAssociation pa ON pa.TeacherCandidateIdentifier = tctpppa.TeacherCandidateIdentifier
            LEFT JOIN TeacherCandidateAcademicRecord tcar
            ON tctpppa.TeacherCandidateIdentifier = tcar.TeacherCandidateIdentifier
                AND tctpppa.EducationOrganizationId = tcar.EducationOrganizationId AND tcar.LatestAcademicRecord = 1
            LEFT JOIN edfi.ReasonExitedDescriptor red
            ON tctpppa.ReasonExitedDescriptorId = red.ReasonExitedDescriptorId
            LEFT JOIN edfi.Descriptor d
            ON red.ReasonExitedDescriptorId = d.DescriptorId

) x
    WHERE x.LatestProgramAssociation = 1;

GO
