CREATE VIEW [analytics].[UserStudentDataAuthorization]
AS

-- distinct because a student could be enrolled at two schools in the same district
SELECT DISTINCT
       [StaffEducationOrganizationAssignmentAssociation].[StaffUSI] AS [UserKey],
       [StudentSchoolAssociation].[StudentUSI] AS [StudentKey]
FROM [edfi].[Staff]
    INNER JOIN [edfi].[StaffEducationOrganizationAssignmentAssociation]
        ON [Staff].[StaffUSI] = [StaffEducationOrganizationAssignmentAssociation].[StaffUSI]
    INNER JOIN [analytics_config].[StaffClassificationDescriptorScope]
        ON [StaffEducationOrganizationAssignmentAssociation].[StaffClassificationDescriptorId] = [StaffClassificationDescriptorScope].[StaffClassificationDescriptorId]
    INNER JOIN [analytics_config].[AuthorizationScope]
        ON [StaffClassificationDescriptorScope].[AuthorizationScopeId] = [AuthorizationScope].[AuthorizationScopeId]
    INNER JOIN [edfi].[School]
        ON [StaffEducationOrganizationAssignmentAssociation].[EducationOrganizationId] = [School].[LocalEducationAgencyId]
    INNER JOIN [edfi].[StudentSchoolAssociation]
        ON [School].[SchoolId] = [StudentSchoolAssociation].[SchoolId]
WHERE [AuthorizationScope].[AuthorizationScopeName] = 'District'
      AND [StaffEducationOrganizationAssignmentAssociation].[EndDate] IS NULL
      AND [StudentSchoolAssociation].[ExitWithdrawDate] IS NULL
UNION ALL
SELECT [StaffEducationOrganizationAssignmentAssociation].[StaffUSI] AS [UserKey],
       [StudentSchoolAssociation].[StudentUSI] AS [StudentKey]
FROM [edfi].[Staff]
    INNER JOIN [edfi].[StaffEducationOrganizationAssignmentAssociation]
        ON [Staff].[StaffUSI] = [StaffEducationOrganizationAssignmentAssociation].[StaffUSI]
    INNER JOIN [analytics_config].[StaffClassificationDescriptorScope]
        ON [StaffEducationOrganizationAssignmentAssociation].[StaffClassificationDescriptorId] = [StaffClassificationDescriptorScope].[StaffClassificationDescriptorId]
    INNER JOIN [analytics_config].[AuthorizationScope]
        ON [StaffClassificationDescriptorScope].[AuthorizationScopeId] = [AuthorizationScope].[AuthorizationScopeId]
    INNER JOIN [edfi].[StudentSchoolAssociation]
        ON [StaffEducationOrganizationAssignmentAssociation].[EducationOrganizationId] = [StudentSchoolAssociation].[SchoolId]
WHERE [AuthorizationScope].[AuthorizationScopeName] = 'School'
      AND [StaffEducationOrganizationAssignmentAssociation].[EndDate] IS NULL
      AND [StudentSchoolAssociation].[ExitWithdrawDate] IS NULL
UNION ALL

-- distinct because a student could be in two sections taught by same teacher
SELECT DISTINCT
       [StaffEducationOrganizationAssignmentAssociation].[StaffUSI] AS [UserKey],
       [StudentSectionAssociation].[StudentUSI] AS [StudentKey]
FROM [edfi].[Staff]
    INNER JOIN [edfi].[StaffEducationOrganizationAssignmentAssociation]
        ON [Staff].[StaffUSI] = [StaffEducationOrganizationAssignmentAssociation].[StaffUSI]
    INNER JOIN [analytics_config].[StaffClassificationDescriptorScope]
        ON [StaffEducationOrganizationAssignmentAssociation].[StaffClassificationDescriptorId] = [StaffClassificationDescriptorScope].[StaffClassificationDescriptorId]
    INNER JOIN [analytics_config].[AuthorizationScope]
        ON [StaffClassificationDescriptorScope].[AuthorizationScopeId] = [AuthorizationScope].[AuthorizationScopeId]
    INNER JOIN [edfi].[StaffSectionAssociation]
        ON [StaffEducationOrganizationAssignmentAssociation].[StaffUSI] = [StaffSectionAssociation].[StaffUSI]
           AND [StaffEducationOrganizationAssignmentAssociation].[EducationOrganizationId] = [StaffSectionAssociation].[SchoolId]
    INNER JOIN [edfi].[StudentSectionAssociation]
        ON [StudentSectionAssociation].[SchoolId] = [StaffSectionAssociation].[SchoolId]
           AND [StudentSectionAssociation].SectionIdentifier = [StaffSectionAssociation].SectionIdentifier
           AND [StudentSectionAssociation].SessionName = [StaffSectionAssociation].SessionName
           AND [StudentSectionAssociation].[LocalCourseCode] = [StaffSectionAssociation].[LocalCourseCode]
           AND [StudentSectionAssociation].[SchoolYear] = [StaffSectionAssociation].[SchoolYear]
WHERE [AuthorizationScope].[AuthorizationScopeName] = 'Section'
      AND [StaffEducationOrganizationAssignmentAssociation].[EndDate] IS NULL
      AND [StudentSectionAssociation].[EndDate] IS NULL;