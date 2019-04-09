CREATE VIEW [analytics].[UserAuthorization]
AS
WITH [staffToScopeMap]
AS (
   SELECT [Staff].[StaffUSI],
          [AuthorizationScope].[AuthorizationScopeName] AS [UserScope],
          [StaffEducationOrganizationAssignmentAssociation].[EducationOrganizationId]
   FROM [edfi].[Staff]
       INNER JOIN [edfi].[StaffEducationOrganizationAssignmentAssociation]
           ON [Staff].[StaffUSI] = [StaffEducationOrganizationAssignmentAssociation].[StaffUSI]
       INNER JOIN [analytics_config].[StaffClassificationDescriptorScope]
           ON [StaffEducationOrganizationAssignmentAssociation].[StaffClassificationDescriptorId] = [StaffClassificationDescriptorScope].[StaffClassificationDescriptorId]
       INNER JOIN [analytics_config].[AuthorizationScope]
           ON [StaffClassificationDescriptorScope].[AuthorizationScopeId] = [AuthorizationScope].[AuthorizationScopeId]
   WHERE
       -- Only current associations
       [StaffEducationOrganizationAssignmentAssociation].[EndDate] IS NULL)
SELECT DISTINCT
       [staffToScopeMap].[StaffUSI] AS [UserKey],
       [staffToScopeMap].[UserScope],
       'ALL' AS [StudentPermission],
       CASE [staffToScopeMap].[UserScope]
           WHEN 'District' THEN
               'ALL'
           WHEN 'School' THEN
               'ALL'
           ELSE
               CAST([Section].[Id] AS VARCHAR(50))
       END AS [SectionPermission],
       CASE [staffToScopeMap].[UserScope]
           WHEN 'District' THEN
               'ALL'
           ELSE
               CAST([staffToScopeMap].[EducationOrganizationId] AS VARCHAR)
       END AS [SchoolPermission]
FROM [staffToScopeMap]
    LEFT OUTER JOIN [edfi].[StaffSectionAssociation]
        ON [staffToScopeMap].[StaffUSI] = [StaffSectionAssociation].[StaffUSI]
           AND [staffToScopeMap].[EducationOrganizationId] = [StaffSectionAssociation].[SchoolId]
    LEFT OUTER JOIN [edfi].[Section]
        ON [StaffSectionAssociation].[SchoolId] = [Section].[SchoolId]
           AND [StaffSectionAssociation].SectionIdentifier = [Section].SectionIdentifier
           AND [StaffSectionAssociation].SessionName = [Section].SessionName
           AND [StaffSectionAssociation].[LocalCourseCode] = [Section].[LocalCourseCode]
           AND [StaffSectionAssociation].[SchoolYear] = [Section].[SchoolYear]
WHERE ([staffToScopeMap].[UserScope] IN ( 'District', 'School' ))
      OR ([StaffSectionAssociation].[Id] IS NOT NULL);