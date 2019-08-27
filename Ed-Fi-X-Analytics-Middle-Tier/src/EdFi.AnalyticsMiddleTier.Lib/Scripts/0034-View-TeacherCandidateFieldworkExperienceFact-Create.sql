CREATE   VIEW [analytics].[TeacherCandidateFieldworkExperienceFact]
AS
    WITH
        TeacherCandidateFieldWorkExperienceFact
        AS
        (
            SELECT tcfe.TeacherCandidateIdentifier TeacherCandidateKey,
                tcfe.SchoolId AS SchoolKey,
                MAX(tcfesa.SchoolYear) AS SchoolYear,
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
                INNER JOIN tpdm.TeacherCandidateFieldworkExperienceSectionAssociation tcfesa
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
        )
    SELECT [analytics].[EntitySchoolYearInstanceSetKey](
                                                       TeacherCandidateFieldWorkExperienceFact.TeacherCandidateKey,
                                                       TeacherCandidateFieldWorkExperienceFact.SchoolYear
                                                   ) TeacherCandidateSchoolYearInstanceKey,
        [analytics].[EntitySchoolYearInstanceSetKey](
                                                       TeacherCandidateFieldWorkExperienceFact.SchoolKey,
                                                       TeacherCandidateFieldWorkExperienceFact.SchoolYear
                                                   ) SchoolSchoolYearInstanceKey,
        TeacherCandidateFieldWorkExperienceFact.TeacherCandidateKey,
        TeacherCandidateFieldWorkExperienceFact.SchoolKey,
        TeacherCandidateFieldWorkExperienceFact.SchoolYear,
        TeacherCandidateFieldWorkExperienceFact.LocalEducationAgencyKey,
        TeacherCandidateFieldWorkExperienceFact.PlacementSchool,
        TeacherCandidateFieldWorkExperienceFact.PlacementDistrict,
        TeacherCandidateFieldWorkExperienceFact.Semester,
        TeacherCandidateFieldWorkExperienceFact.HoursPerWeek
    FROM TeacherCandidateFieldWorkExperienceFact;


GO

