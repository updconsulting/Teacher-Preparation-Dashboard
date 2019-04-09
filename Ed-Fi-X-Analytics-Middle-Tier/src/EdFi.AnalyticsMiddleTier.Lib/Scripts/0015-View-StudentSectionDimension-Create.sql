CREATE VIEW [analytics].[StudentSectionDimension]
AS
SELECT CAST([StudentSectionAssociation].[StudentUSI] AS NVARCHAR) + '-'
       + CAST([StudentSectionAssociation].[SchoolId] AS NVARCHAR) + '-' + [StudentSectionAssociation].[SessionName]
       + '-' + [StudentSectionAssociation].[SectionIdentifier] + '-' + [StudentSectionAssociation].[LocalCourseCode]
       + '-' + CONVERT(NVARCHAR, [StudentSectionAssociation].[BeginDate], 112) AS [StudentSectionKey],
       [StudentSectionAssociation].[StudentUSI] AS [StudentKey],
       CAST([StudentSectionAssociation].[SchoolId] AS NVARCHAR) + '-' + [StudentSectionAssociation].[SessionName] + '-'
       + [StudentSectionAssociation].[SectionIdentifier] + '-' + [StudentSectionAssociation].[LocalCourseCode] + '-'
       + CAST([StudentSectionAssociation].[SchoolYear] AS NVARCHAR) AS [SectionKey],
       [StudentSectionAssociation].[LocalCourseCode],
       ISNULL(asd.[CodeValue], '') AS [Subject],
       ISNULL([Course].[CourseTitle], '') AS [CourseTitle],

       -- There could be multiple teachers for a section - reduce those to a single string.
       -- Unfortunately this means that the [Staff] and [StaffSectionAssociation]
       -- [LastModifiedDate] values can't be used to calculate this record's [LastModifiedDate]
       ISNULL(
                 STUFF(
                          (
                              SELECT N', ' + ISNULL([Staff].[FirstName], '') + ' ' + ISNULL([Staff].[LastSurname], '')
                              FROM [edfi].[StaffSectionAssociation]
                                  LEFT OUTER JOIN [edfi].[Staff]
                                      ON [StaffSectionAssociation].[StaffUSI] = [Staff].[StaffUSI]
                              WHERE [StudentSectionAssociation].[SchoolId] = [StaffSectionAssociation].[SchoolId]
                                    AND [StudentSectionAssociation].[SectionIdentifier] = [StaffSectionAssociation].[SectionIdentifier]
                                    AND [StudentSectionAssociation].[SessionName] = [StaffSectionAssociation].[SessionName]
                                    AND [StudentSectionAssociation].[LocalCourseCode] = [StaffSectionAssociation].[LocalCourseCode]
                                    AND [StudentSectionAssociation].[SchoolYear] = [StaffSectionAssociation].[SchoolYear]
                              FOR XML PATH(''), TYPE
                          ).value(N'.[1]', N'nvarchar(max)'),
                          1,
                          2,
                          N''
                      ),
                 ''
             ) AS [TeacherName],
       CONVERT(NVARCHAR, [StudentSectionAssociation].[BeginDate], 112) AS [StudentSectionStartDateKey],
       CONVERT(NVARCHAR, [StudentSectionAssociation].[EndDate], 112) AS [StudentSectionEndDateKey],
       [StudentSectionAssociation].[SchoolId] AS [SchoolKey],
       (
           SELECT MAX([LastModifiedDate])
           FROM
           (
               VALUES
                   ([StudentSectionAssociation].[LastModifiedDate]),
                   ([Course].[LastModifiedDate]),
                   ([CourseOffering].[LastModifiedDate]),
                   (asd.[LastModifiedDate])
           ) AS value ([LastModifiedDate])
       ) AS [LastModifiedDate]
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


