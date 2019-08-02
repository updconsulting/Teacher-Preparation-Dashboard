/****** Object:  View [analytics].[SchoolDimension]    Script Date: 4/23/2019 2:46:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE   VIEW [analytics].[SchoolDimension]
AS
WITH AccountablityRating
AS
(SELECT
    s.SchoolId
   ,ar.Rating
   ,ar.SchoolYear
  FROM edfi.School s
  INNER JOIN edfi.EducationOrganization eo
    ON s.SchoolId = eo.EducationOrganizationId
  INNER JOIN edfi.AccountabilityRating ar
    ON eo.EducationOrganizationId = ar.EducationOrganizationId
  WHERE ar.SchoolYear = (SELECT
      MAX(SchoolYear)
    FROM edfi.AccountabilityRating))
SELECT
  analytics.EntitySchoolYearInstanceSetKey(School.SchoolId, CurrentSchoolYear.SchoolYear
  ) AS SchoolSchoolYearInstaceKey, 
 analytics.EntitySchoolYearInstanceSetKey(LocalEducationAgency.LocalEducationAgencyId,CurrentSchoolYear.SchoolYear
  ) AS LocalEducationAgencySchoolYearInstaceKey
 ,[School].[SchoolId] AS [SchoolKey]
 ,CurrentSchoolYear.SchoolYear
 ,[EducationOrganization].[NameOfInstitution] AS [SchoolName]
 ,ISNULL([std].[CodeValue], '') AS [SchoolType]
 ,ISNULL(AccountablityRating.Rating, '') Rating
 ,ISNULL(d.CodeValue, '') AS SchoolCategoryType
 ,ISNULL([SchoolAddress].[SchoolAddress], '') AS [SchoolAddress]
 ,ISNULL([SchoolAddress].[SchoolCity], '') AS [SchoolCity]
 ,ISNULL([SchoolAddress].[SchoolCounty], '') AS [SchoolCounty]
 ,ISNULL([SchoolAddress].[SchoolState], '') AS [SchoolState]
 ,ISNULL([EdOrgLocal].[NameOfInstitution], '') AS [LocalEducationAgencyName]
 ,[EdOrgLocal].[EducationOrganizationId] AS [LocalEducationAgencyKey]
 ,ISNULL([EdOrgState].[NameOfInstitution], '') AS [StateEducationAgencyName]
 ,[EdOrgState].[EducationOrganizationId] AS [StateEducationAgencyKey]
 ,ISNULL([EdOrgServiceCenter].[NameOfInstitution], '') AS [EducationServiceCenterName]
 ,[EdOrgServiceCenter].[EducationOrganizationId] AS [EducationServiceCenterKey]
 ,d1.Description FederalLocaleCode
 ,(SELECT
      MAX([LastModifiedDate])
    FROM (VALUES ([EducationOrganization].[LastModifiedDate]),
    ([std].[LastModifiedDate]),
    ([EdOrgLocal].[LastModifiedDate]),
    ([EdOrgState].[LastModifiedDate]),
    ([EdOrgServiceCenter].[LastModifiedDate]),
    ([SchoolAddress].[LastModifiedDate])) AS value ([LastModifiedDate]))
  AS [LastModifiedDate]
FROM [edfi].[School]
INNER JOIN [edfi].[EducationOrganization]
  ON [School].[SchoolId] = [EducationOrganization].[EducationOrganizationId]
LEFT OUTER JOIN [edfi].[Descriptor] std
  ON [School].[SchoolTypeDescriptorId] = std.DescriptorId
LEFT OUTER JOIN [edfi].[LocalEducationAgency]
  ON [School].[LocalEducationAgencyId] = [LocalEducationAgency].[LocalEducationAgencyId]
LEFT OUTER JOIN [edfi].[EducationOrganization] AS [EdOrgLocal]
  ON [School].[LocalEducationAgencyId] = [EdOrgLocal].[EducationOrganizationId]
LEFT OUTER JOIN [edfi].[EducationOrganization] AS [EdOrgState]
  ON [LocalEducationAgency].[StateEducationAgencyId] = [EdOrgState].[EducationOrganizationId]
LEFT OUTER JOIN [edfi].[EducationOrganization] AS [EdOrgServiceCenter]
  ON [LocalEducationAgency].[EducationServiceCenterId] = [EdOrgServiceCenter].EducationOrganizationId
LEFT OUTER JOIN AccountablityRating
  ON School.SchoolId = AccountablityRating.SchoolId
LEFT OUTER JOIN edfi.SchoolCategory sc
  ON School.SchoolId = sc.SchoolId
LEFT OUTER JOIN edfi.SchoolCategoryDescriptor scd
  ON sc.SchoolCategoryDescriptorId = scd.SchoolCategoryDescriptorId
LEFT OUTER JOIN edfi.Descriptor d
  ON scd.SchoolCategoryDescriptorId = d.DescriptorId
LEFT JOIN tpdm.SchoolExtension se
  ON se.SchoolId = [School].SchoolId
LEFT JOIN edfi.Descriptor d1
  ON se.FederalLocaleCodeDescriptorId = d1.DescriptorId
OUTER APPLY (SELECT TOP 1
    CONCAT([EducationOrganizationAddress].[StreetNumberName],
    ', ',
    ([EducationOrganizationAddress].[ApartmentRoomSuiteNumber]
    + ', '),
    [EducationOrganizationAddress].[City],
    [sad].[CodeValue], ' ',
    [EducationOrganizationAddress].[PostalCode]) AS [SchoolAddress]
   ,[EducationOrganizationAddress].[City] AS [SchoolCity]
   ,[EducationOrganizationAddress].[NameOfCounty] AS [SchoolCounty]
   ,[sad].[CodeValue] AS [SchoolState]
   ,[EducationOrganizationAddress].[CreateDate] AS [LastModifiedDate]
  FROM [edfi].[EducationOrganizationAddress]
  INNER JOIN [edfi].[Descriptor] atd
    ON [EducationOrganizationAddress].[AddressTypeDescriptorId] = atd.DescriptorId
  INNER JOIN [edfi].[Descriptor] sad
    ON [EducationOrganizationAddress].[StateAbbreviationDescriptorId] = sad.DescriptorId
  WHERE [School].[SchoolId] = [EducationOrganizationAddress].[EducationOrganizationId]
  AND [atd].[CodeValue] = 'Physical') AS [SchoolAddress]
CROSS APPLY ( SELECT syt.SchoolYear FROM edfi.SchoolYearType syt WHERE syt.CurrentSchoolYear = 1 ) CurrentSchoolYear
WHERE [School].[SchoolId] NOT IN (SELECT
    tpp.TeacherPreparationProviderId
  FROM tpdm.TeacherPreparationProvider tpp)
GO


