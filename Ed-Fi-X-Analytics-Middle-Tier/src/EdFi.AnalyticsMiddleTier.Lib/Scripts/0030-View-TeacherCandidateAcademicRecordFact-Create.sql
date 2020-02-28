CREATE VIEW [analytics].[TeacherCandidateAcademicRecordFact]
AS

    WITH
        MostCurrentGPA
        AS
        (
            SELECT tcargpa.TeacherCandidateIdentifier,
                tcargpa.GPATypeDescriptorId,
                MAX(tcargpa.SchoolYear) SchoolYear,
                MAX(tcargpa.TermDescriptorId) AS TermDescriptorId
            FROM tpdm.TeacherCandidateAcademicRecordGradePointAverage tcargpa
            GROUP BY tcargpa.TeacherCandidateIdentifier,
             tcargpa.GPATypeDescriptorId
        )
    SELECT [analytics].[EntitySchoolYearInstanceSetKey](
                                                       MostCurrentGPA.TeacherCandidateIdentifier,
                                                       MostCurrentGPA.SchoolYear
                                                   ) AS TeacherCandidateSchoolYearInstanceKey,
        tcargpa.TeacherCandidateIdentifier TeacherCandidateKey,
        tcargpa.SchoolYear,
        tcargpa.TermDescriptorId,
        tcargpa.CumulativeGradePointAverage,
        d.CodeValue AS GPAType
    FROM tpdm.TeacherCandidateAcademicRecordGradePointAverage tcargpa
        INNER JOIN MostCurrentGPA
        ON tcargpa.TeacherCandidateIdentifier = MostCurrentGPA.TeacherCandidateIdentifier
            AND tcargpa.GPATypeDescriptorId = MostCurrentGPA.GPATypeDescriptorId
            AND tcargpa.SchoolYear = MostCurrentGPA.SchoolYear
        LEFT JOIN tpdm.GPATypeDescriptor gd
        ON tcargpa.GPATypeDescriptorId = gd.GPATypeDescriptorId
        LEFT OUTER JOIN edfi.Descriptor d
        ON gd.GPATypeDescriptorId = d.DescriptorId;
GO


