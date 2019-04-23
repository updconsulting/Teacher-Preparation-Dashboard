/****** Object:  View [analytics].[StudentSectionDimension]    Script Date: 4/23/2019 2:46:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [analytics].[StudentSectionDimension]
AS
SELECT
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
