CREATE   VIEW [analytics].[TeacherPreparationProviderProgramDimension]
AS
    WITH
        TeacherPreparationProviderDimension
        AS
        (
            SELECT tppp.ProgramId AS ProgramKey,
                tppp.EducationOrganizationId AS [TeacherPreparationProviderKey],
                tppp.ProgramName AS ProgramName,
                d.CodeValue AS ProgramType,
                SchoolYear =
           (
               SELECT SchoolYear
                FROM edfi.SchoolYearType
                WHERE CurrentSchoolYear = 1
           )
            FROM tpdm.TeacherPreparationProviderProgram tppp
                LEFT JOIN tpdm.TeacherPreparationProgramTypeDescriptor tpptd
                ON tppp.TeacherPreparationProgramTypeDescriptorId = tpptd.TeacherPreparationProgramTypeDescriptorId
                INNER JOIN edfi.Descriptor d
                ON d.DescriptorId = tpptd.TeacherPreparationProgramTypeDescriptorId
        )
    SELECT [analytics].[EntitySchoolYearInstanceSetKey](
                                                       TeacherPreparationProviderDimension.ProgramKey,
                                                       TeacherPreparationProviderDimension.SchoolYear
                                                   ) AS ProgramSchoolYearInstanceKey,
        TeacherPreparationProviderDimension.ProgramKey,
        TeacherPreparationProviderDimension.TeacherPreparationProviderKey,
        TeacherPreparationProviderDimension.SchoolYear,
        TeacherPreparationProviderDimension.ProgramName,
        TeacherPreparationProviderDimension.ProgramType
    FROM TeacherPreparationProviderDimension;
GO
