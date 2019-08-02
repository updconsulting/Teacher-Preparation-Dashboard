/****** Object:  View [analytics].[SchoolFacts]    Script Date: 4/23/2019 2:46:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE VIEW [analytics].[SchoolFacts]
AS
WITH EducationOrganizationFactsMaxDate
AS
(SELECT
    eof.EducationOrganizationId
   ,MAX(eof.FactsAsOfDate) AS FactsAsOfDate
  FROM tpdm.EducationOrganizationFacts eof
  GROUP BY eof.EducationOrganizationId),
RaceTypeAggregate
AS
(SELECT
    EducationOrganizationId
   ,FactAsOfDate
   ,ValueTypeDescriptor
   ,[American Indian - Alaska Native]
   ,[Asian]
   ,[Black - African American]
   ,[Choose Not to Respond]
   ,[Native Hawaiian - Pacific Islander]
   ,[White]
   ,[Other]
   ,[Two or More]
   ,[Hispanic/Latino]
  FROM (SELECT
      eosfar.EducationOrganizationId
     ,eosfar.FactAsOfDate
     ,eosfar.ValueTypeDescriptorId
     ,eosfar.RaceTypeNumber
     ,eosfar.RaceTypePercentage
     ,d.CodeValue RaceTypeDescriptor
     ,d1.CodeValue AS ValueTypeDescriptor
    FROM tpdm.EducationOrganizationStudentFactsAggregatedRace eosfar
    INNER JOIN EducationOrganizationFactsMaxDate
      ON eosfar.EducationOrganizationId = EducationOrganizationFactsMaxDate.EducationOrganizationId
      AND EducationOrganizationFactsMaxDate.FactsAsOfDate = eosfar.FactAsOfDate
    INNER JOIN edfi.RaceDescriptor rd
      ON eosfar.RaceDescriptorId = rd.RaceDescriptorId
    INNER JOIN edfi.Descriptor d
      ON rd.RaceDescriptorId = d.DescriptorId
    LEFT JOIN tpdm.ValueTypeDescriptor vtd
      ON eosfar.ValueTypeDescriptorId = vtd.ValueTypeDescriptorId
    LEFT JOIN edfi.Descriptor d1
      ON vtd.ValueTypeDescriptorId = d1.DescriptorId
    WHERE d1.CodeValue LIKE 'Actual') t
  PIVOT (
  MAX(t.RaceTypePercentage)
  FOR RaceTypeDescriptor IN ([American Indian - Alaska Native], [Asian], [Black - African American], [Choose Not to Respond], [Native Hawaiian - Pacific Islander], [White], [Other], [Two or More], [Hispanic/Latino])
  ) p),

EnrolledTeacherCandidates
AS
(SELECT
    tcfe.SchoolId
   ,COUNT(DISTINCT tc.TeacherCandidateIdentifier) AS CandidatesPlaced
  FROM tpdm.TeacherCandidate tc
  INNER JOIN tpdm.TeacherCandidateFieldworkExperience tcfe
    ON tc.TeacherCandidateIdentifier = tcfe.TeacherCandidateIdentifier
  GROUP BY tcfe.SchoolId),
EmployeedTeacherCandidates
AS
(SELECT
    seoaa.EducationOrganizationId
   ,COUNT(DISTINCT s.StaffUSI) AS CandidatesEmployeed
  FROM edfi.StaffEducationOrganizationAssignmentAssociation seoaa
  INNER JOIN edfi.Staff s
    ON seoaa.StaffUSI = s.StaffUSI
  INNER JOIN tpdm.TeacherCandidate tc
    ON tc.TeacherCandidateIdentifier = s.StaffUniqueId
  GROUP BY seoaa.EducationOrganizationId),
HomlessStudents
AS
(SELECT
    shpa.EducationOrganizationId
   ,(COUNT(DISTINCT shpa.StudentUSI) * 1.0 / COUNT(DISTINCT ssa.StudentUSI)) AS HomelessStudentPercentage
  FROM edfi.StudentSchoolAssociation ssa
  LEFT JOIN edfi.StudentHomelessProgramAssociation shpa
    ON ssa.EducationOrganizationId = shpa.EducationOrganizationId
  GROUP BY shpa.EducationOrganizationId)

SELECT
  analytics.EntitySchoolYearInstanceSetKey(s.SchoolId, eosf.SchoolYear) AS SchoolSchoolYearInstanceSetKey
 ,s.SchoolId AS SchoolKey
 ,eosf.FactsAsOfDate
 ,eosf.SchoolYear
 ,eosf.NumberAdministratorsEmployed
 ,eosf.NumberStudentsEnrolled
 ,eosf.NumberTeachersEmployed
 ,CandidatesEmployeed
 ,CandidatesPlaced
 ,eosf.PercentStudentsFreeReducedLunch
 ,eosf.PercentStudentsLimitedEnglishProficiency
 ,eosf.PercentStudentsSpecialEducation
 ,HomelessStudentPercentage
 ,eosf.HiringRate
 ,eosf.RetentionRate
 ,eosf.RetirementRate
 ,eosf.AverageYearsInDistrictEmployed
 ,[American Indian - Alaska Native]
 ,[Asian]
 ,[Black - African American]
 ,[Choose Not to Respond]
 ,[Native Hawaiian - Pacific Islander]
 ,[White]
 ,[Other]
 ,[Two or More]
 ,[Hispanic/Latino]
 ,CASE
    WHEN eosf.PercentStudentsLimitedEnglishProficiency > 0.2 OR
      eosf.PercentStudentsFreeReducedLunch > 0.6 OR
      eosf.PercentStudentsSpecialEducation > 0.15 THEN 'Yes'
    ELSE 'No'
  END AS HighNeed
FROM tpdm.EducationOrganizationFacts eosf
INNER JOIN edfi.EducationOrganization eo
  ON eosf.EducationOrganizationId = eo.EducationOrganizationId
INNER JOIN edfi.School s
  ON eo.EducationOrganizationId = s.SchoolId
INNER JOIN EducationOrganizationFactsMaxDate lef
  ON eosf.EducationOrganizationId = lef.EducationOrganizationId
    AND eosf.FactsAsOfDate = lef.FactsAsOfDate
LEFT JOIN RaceTypeAggregate
  ON eosf.EducationOrganizationId = RaceTypeAggregate.EducationOrganizationId
    AND eosf.FactsAsOfDate = RaceTypeAggregate.FactAsOfDate
LEFT JOIN EmployeedTeacherCandidates
  ON eosf.EducationOrganizationId = EmployeedTeacherCandidates.EducationOrganizationId
    AND eosf.FactsAsOfDate = RaceTypeAggregate.FactAsOfDate
LEFT JOIN EnrolledTeacherCandidates
  ON s.SchoolId = EnrolledTeacherCandidates.SchoolId
LEFT JOIN HomlessStudents
  ON eosf.EducationOrganizationId = HomlessStudents.EducationOrganizationId
GO


