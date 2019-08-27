CREATE   VIEW [analytics].[StudentSectionDimension]
AS
  SELECT analytics.EntitySchoolYearInstanceSetKey(StudentUSI,CourseOffering.SchoolYear) AS StudentSchoolYearInstanceKey,
    analytics.EntitySchoolYearInstanceSetKey(SectionIdentifier,CourseOffering.SchoolYear) AS SectionSchoolYearInstanceKey,
    analytics.EntitySchoolYearInstanceSetKey(Course.CourseCode,CourseOffering.SchoolYear) AS CourseSchoolYearInstanceKey,
    SectionIdentifier AS SectionKey,
    StudentUSI as StudentKey,
    Course.CourseCode as CourseKey,
    asd.CodeValue as AcademicSubject,
    CourseOffering.SchoolYear,
    CourseOffering.SessionName
  FROM [edfi].[StudentSectionAssociation]
    INNER JOIN [edfi].[CourseOffering]
    ON [CourseOffering].[SchoolId] = [StudentSectionAssociation].[SchoolId]
      AND [CourseOffering].[LocalCourseCode] = [StudentSectionAssociation].[LocalCourseCode]
      AND [CourseOffering].[SessionName] = [StudentSectionAssociation].[SessionName]
      AND [CourseOffering].[SchoolYear] = [StudentSectionAssociation].[SchoolYear]
    INNER JOIN [edfi].[Course]
    ON [Course].[CourseCode] = [CourseOffering].[CourseCode]
      AND [Course].[EducationOrganizationId] = [CourseOffering].[EducationOrganizationId]
    LEFT OUTER JOIN [edfi].[AcademicSubjectDescriptor]
    ON [AcademicSubjectDescriptor].[AcademicSubjectDescriptorId] = [Course].[AcademicSubjectDescriptorId]
    LEFT OUTER JOIN [edfi].[Descriptor] asd
    ON asd.[DescriptorId] = [AcademicSubjectDescriptor].[AcademicSubjectDescriptorId];
GO


