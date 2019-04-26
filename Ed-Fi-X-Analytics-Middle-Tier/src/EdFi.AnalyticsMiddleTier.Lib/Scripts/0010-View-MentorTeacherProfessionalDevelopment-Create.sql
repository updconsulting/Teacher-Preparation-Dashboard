/****** Object:  View [analytics].[MentorTeacherProfessionalDevelopment]    Script Date: 4/23/2019 2:46:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [analytics].[MentorTeacherProfessionalDevelopment]
AS
WITH StaffProfessionalDevelopmentEvent AS 
  (
SELECT
  spdea.StaffUSI AS StaffKey,
  spdea.AttendanceDate,
  spdea.ProfessionalDevelopmentTitle,
  d.CodeValue AS StaffCassificationDescriptor,
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
SELECT  StaffKey,
        AttendanceDate,
        ProfessionalDevelopmentTitle,
        StaffCassificationDescriptor, CASE WHEN ProfessionalDevelopmentTitle LIKE 'Classroom Management' THEN 'Completed' ELSE 'Not Completed' END AS Status
  FROM StaffProfessionalDevelopmentEvent
  WHERE Recent = 1
 
GO
