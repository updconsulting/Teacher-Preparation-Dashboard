/****** Object:  View [analytics].[TeacherCandidateStaffFact]    Script Date: 4/23/2019 2:46:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  CREATE VIEW [analytics].[TeacherCandidateStaffFact]
  AS

  WITH TeacherCandidateStaffFact
  AS (SELECT
    seoaa.EducationOrganizationId,
    tc.TeacherCandidateIdentifier TeacherCandidateKey,
    seoaa.StaffUSI StaffKey,
    seoaa.BeginDate,
    seoaa.StaffClassificationDescriptorId,
    seoaa.PositionTitle,
    seoaa.EndDate,
    seoaa.OrderOfAssignment,
    seoaa.EmploymentEducationOrganizationId,
    d.CodeValue AS EmploymentStatus,
    seoaa.EmploymentHireDate,
    RetentionYears = DATEDIFF(YEAR, seoaa.EmploymentHireDate, GETDATE())
  FROM tpdm.TeacherCandidate tc
  INNER JOIN edfi.Staff s
    ON s.StaffUniqueId = tc.TeacherCandidateIdentifier
  INNER JOIN edfi.StaffEducationOrganizationAssignmentAssociation seoaa
  LEFT JOIN edfi.EmploymentStatusDescriptor esd
    ON seoaa.EmploymentStatusDescriptorId = esd.EmploymentStatusDescriptorId
  LEFT JOIN edfi.Descriptor d
    ON esd.EmploymentStatusDescriptorId = d.DescriptorId
    ON s.StaffUSI = seoaa.StaffUSI)
  SELECT
    EducationOrganizationId AS Shoolkey,
    TeacherCandidateKey,
    StaffKey,
    BeginDate,

    StaffClassificationDescriptorId,
    PositionTitle,
    EndDate,
    OrderOfAssignment,
    EmploymentEducationOrganizationId,
    EmploymentStatus,
    EmploymentHireDate,
    RetentionYears,
    CASE
      WHEN RetentionYears >= 1 AND
        RetentionYears < 3 THEN '1 Year'
      WHEN RetentionYears >= 3 AND
        RetentionYears < 5 THEN '3 year'
      ELSE '5+ year'
    END AS RetentionBand
  FROM TeacherCandidateStaffFact
GO
