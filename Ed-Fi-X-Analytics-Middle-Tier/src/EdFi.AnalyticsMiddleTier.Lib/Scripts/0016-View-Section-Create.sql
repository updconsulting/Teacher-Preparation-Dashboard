
CREATE   VIEW [analytics].[Section]
AS
  SELECT
    analytics.EntitySchoolYearInstanceSetKey(s.SectionIdentifier, co.SchoolYear) AS SectionSchoolYearInstanceKey
 , analytics.EntitySchoolYearInstanceSetKey(c.CourseCode, co.SchoolYear) AS CourseSchoolYearInstanceKey
 , analytics.EntitySchoolYearInstanceSetKey(s.SchoolId, s.SchoolYear) AS SchoolSchoolYearInstanceKey
 , c.CourseCode AS CourseKey
 , s.SchoolId SchoolKey
 , s.SectionIdentifier SectionKey
 , s.SchoolYear
 , s.SessionName
  FROM edfi.Section s
    INNER JOIN edfi.CourseOffering co
    ON s.LocalCourseCode = co.LocalCourseCode
      AND s.SchoolId = co.SchoolId
      AND s.SessionName = co.SessionName
    INNER JOIN edfi.Course c
    ON co.CourseCode = c.CourseCode
      AND co.EducationOrganizationId = c.EducationOrganizationId
GO


