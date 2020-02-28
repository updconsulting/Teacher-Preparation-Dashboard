CREATE   VIEW [analytics].[MentorTeacherProfessionalDevelopment]
AS
  WITH
    StaffProfessionalDevelopmentEvent
    AS
    (
      SELECT
        spdea.StaffUSI AS StaffKey,
        spdea.AttendanceDate,
        spdea.ProfessionalDevelopmentTitle,
        d.CodeValue AS StaffClassificationDescriptor,
        ROW_NUMBER() OVER (PARTITION BY s.StaffUSI, spdea.ProfessionalDevelopmentTitle ORDER BY spdea.AttendanceDate DESC) Recent

      FROM edfi.Staff s
        LEFT JOIN tpdm.StaffProfessionalDevelopmentEventAttendance spdea
        ON s.StaffUSI = spdea.StaffUSI
        LEFT JOIN edfi.StaffEducationOrganizationAssignmentAssociation seoaa
        ON spdea.StaffUSI = seoaa.StaffUSI
        LEFT JOIN edfi.StaffClassificationDescriptor scd
        ON seoaa.StaffClassificationDescriptorId = scd.StaffClassificationDescriptorId
        LEFT JOIN edfi.Descriptor d
        ON scd.StaffClassificationDescriptorId = d.DescriptorId
      WHERE d.CodeValue LIKE 'Mentor Teacher'
    )
  SELECT analytics.EntitySchoolYearInstanceSetKey(StaffKey,CurrentSchoolYear.SchoolYear) AS StaffSchoolYearInstancekey,
    StaffKey, CurrentSchoolYear.SchoolYear AS SchoolYear,
    AttendanceDate,
    ProfessionalDevelopmentTitle,
    StaffClassificationDescriptor, CASE WHEN ProfessionalDevelopmentTitle LIKE 'Classroom Management' THEN 'Completed' ELSE 'Not Completed' END AS Status
  FROM StaffProfessionalDevelopmentEvent
  CROSS APPLY
  (  
       SELECT syt.SchoolYear
    FROM edfi.SchoolYearType syt
    WHERE syt.CurrentSchoolYear = 1
  ) CurrentSchoolYear
  WHERE Recent = 1
GO


