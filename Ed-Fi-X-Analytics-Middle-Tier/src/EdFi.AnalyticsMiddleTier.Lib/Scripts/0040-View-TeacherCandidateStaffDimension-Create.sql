
CREATE  View [analytics].[TeacherCandidateStaffDimension]
AS
  WITH
    TeacherCandidateStaffDimension
    AS
    (
      SELECT
        seoaa.EducationOrganizationId AS SchoolKey
   , s1.LocalEducationAgencyId AS LocalEducationAgencyKey
   , tc.TeacherCandidateIdentifier TeacherCandidateKey
   , seoaa.StaffUSI StaffKey
   , ssa.SchoolYear
   , seoaa.BeginDate
   , d1.CodeValue RaceDescriptor
   , d2.CodeValue SexDescriptor
   , seoaa.StaffClassificationDescriptorId
   , seoaa.PositionTitle
   , seoaa.EndDate
   , seoaa.OrderOfAssignment
   , seoaa.EmploymentEducationOrganizationId
   , d.CodeValue AS EmploymentStatus
   , seoaa.EmploymentHireDate
   , RetentionYears = DATEDIFF(YEAR, seoaa.EmploymentHireDate, GETDATE())

      FROM tpdm.TeacherCandidate tc
        INNER JOIN tpdm.StaffTeacherCandidateAssociation stca
        ON tc.TeacherCandidateIdentifier = stca.TeacherCandidateIdentifier
        INNER JOIN edfi.StaffSchoolAssociation ssa
        ON stca.StaffUSI = ssa.StaffUSI
        INNER JOIN edfi.Staff s
        ON s.StaffUSI = stca.StaffUSI
        INNER JOIN edfi.StaffEducationOrganizationAssignmentAssociation seoaa
        INNER JOIN edfi.School s1
        ON s1.SchoolId = seoaa.EducationOrganizationId
        LEFT JOIN edfi.EmploymentStatusDescriptor esd
        ON seoaa.EmploymentStatusDescriptorId = esd.EmploymentStatusDescriptorId
        LEFT JOIN edfi.Descriptor d
        ON esd.EmploymentStatusDescriptorId = d.DescriptorId
        ON s.StaffUSI = seoaa.StaffUSI
        LEFT JOIN edfi.StaffRace sr
        ON s.StaffUSI = sr.StaffUSI
        LEFT JOIN edfi.RaceDescriptor rd
        ON rd.RaceDescriptorId = sr.RaceDescriptorId
        LEFT JOIN edfi.Descriptor d1
        ON rd.RaceDescriptorId = d1.DescriptorId
        LEFT JOIN edfi.SexDescriptor sd
        ON sd.SexDescriptorId = s.SexDescriptorId
        LEFT JOIN edfi.Descriptor d2
        ON d2.DescriptorId = sd.SexDescriptorId
    )
  SELECT
    analytics.EntitySchoolYearInstanceSetKey(TeacherCandidateKey, SchoolYear) TeacherCandidateSchoolYearInstanceKey
 , analytics.EntitySchoolYearInstanceSetKey(StaffKey, SchoolYear) StaffSchoolYearInstanceKey
 , analytics.EntitySchoolYearInstanceSetKey(SchoolKey, SchoolYear) SchoolSchoolYearInstanceKey
 , TeacherCandidateKey
 , StaffKey
 , SchoolKey
 , LocalEducationAgencyKey
 , SchoolYear
 , BeginDate
 , RaceDescriptor
 , SexDescriptor
 , StaffClassificationDescriptorId
 , PositionTitle
 , EndDate
 , OrderOfAssignment
 , EmploymentEducationOrganizationId
 , EmploymentStatus
 , EmploymentHireDate
 , RetentionYears
 , CASE
    WHEN RetentionYears >= 1 AND
      RetentionYears < 3 THEN 'Retained After 1 Year'
    WHEN RetentionYears >= 3 AND
      RetentionYears < 5 THEN 'Retained After 3 Years'
    WHEN RetentionYears >=5 THEN 'Retained For 5+ Years'
	ELSE 'Retained Less Than a Year'
  END AS RetentionBand
  FROM TeacherCandidateStaffDimension;
GO


