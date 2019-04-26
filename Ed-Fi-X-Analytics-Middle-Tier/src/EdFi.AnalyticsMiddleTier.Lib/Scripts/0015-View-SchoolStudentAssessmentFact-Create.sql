/****** Object:  View [analytics].[SchoolStudentAssessmentFact]    Script Date: 4/23/2019 2:46:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [analytics].[SchoolStudentAssessmentFact]
AS
/* This query has flaw that it doesn't look at the max date for the fact , the reason is the issue with the data model */
WITH SchoolStudentAssessmentFact

AS (SELECT
  eosaf.EducationOrganizationId,
 CASE WHEN  d1.CodeValue = 'English Language Arts' THEN 'ELA'
                    WHEN d1.CodeValue = 'Mathematics' THEN 'Math' ELSE d1.CodeValue END AS AcademicSubjectDescriptor,
  d.CodeValue GradeLevelDescriptor,
  CASE
    WHEN d.CodeValue IN ('Kindergarten', 'First grade', 'Second grade', 'Third grade', 'Fourth grade', 'Fifth grade') THEN 'Grades k-5'
    WHEN d.CodeValue IN ('Sixth grade', 'Seventh grade', 'Eighth grade') THEN 'Grades 6-8'
    WHEN d.CodeValue IN ('Ninth grade', 'Tenth grade', 'Eleventh grade', 'Twelfth grade') THEN 'Grades 9-12'
  END AS GradeLevels,
  eosafapl.PerformanceLevelMetPercentage
FROM tpdm.EducationOrganizationStudentAssessmentFacts eosaf
INNER JOIN tpdm.EducationOrganizationStudentAssessmentFactsAggregatedPerformanceLevel eosafapl
  ON eosaf.EducationOrganizationId = eosafapl.EducationOrganizationId
  AND eosaf.FactAsOfDate = eosafapl.FactAsOfDate
  AND eosaf.TakenSchoolYear = eosafapl.TakenSchoolYear
INNER JOIN edfi.GradeLevelDescriptor gld
  ON eosaf.GradeLevelDescriptorId = gld.GradeLevelDescriptorId
INNER JOIN edfi.Descriptor d
  ON gld.GradeLevelDescriptorId = d.DescriptorId
INNER JOIN edfi.AcademicSubjectDescriptor asd
  ON eosaf.AcademicSubjectDescriptorId = asd.AcademicSubjectDescriptorId
INNER JOIN edfi.Descriptor d1
  ON asd.AcademicSubjectDescriptorId = d1.DescriptorId
INNER JOIN edfi.School s
  ON s.SchoolId = eosaf.EducationOrganizationId)

SELECT
  EducationOrganizationId AS SchoolKey,
  GradeLevels, AcademicSubjectDescriptor,
  
  
   CASE WHEN GradeLevels = 'Grades k-5' THEN 1 
                                               WHEN GradeLevels = 'Grades 6-8' THEN 2
                                               WHEN GradeLevels = 'Grades 9-12' THEN 3 END AS DisplayOrder,
  AVG(PerformanceLevelMetPercentage) AS PerformanceLevelMetPercentage
FROM SchoolStudentAssessmentFact
WHERE GradeLevels IS NOT NULL 
GROUP BY EducationOrganizationId,
         GradeLevels, GradeLevels, AcademicSubjectDescriptor
GO
