/****** Object:  View [analytics].[StudentDimension]    Script Date: 4/23/2019 2:46:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [analytics].[StudentDimension]
AS
WITH StudentRaces
AS (SELECT
  seoar.StudentUSI,
  COUNT(DISTINCT seoar.RaceDescriptorId) AS RaceCount,
  MAX(seoar.RaceDescriptorId) AS RaceDescriptorId
FROM edfi.StudentEducationOrganizationAssociationRace seoar
GROUP BY seoar.StudentUSI)

SELECT
  [Student].[StudentUSI] AS [StudentKey],
  [Student].[FirstName] AS [StudentFirstName],
  ISNULL([Student].[MiddleName], '') AS [StudentMiddleName],
  ISNULL([Student].[LastSurname], '') AS [StudentLastName],
  [StudentSchoolAssociation].[SchoolId] AS [SchoolKey],
  [StudentSchoolAssociation].[EntryDate] AS [EnrollmentDate],
  [Descriptor].[CodeValue] AS [GradeLevel],
   CASE
    WHEN StudentRaces.RaceCount > 1 THEN 'Two or more'
    ELSE d.CodeValue
  END AS RaceDescriptor,
  ISNULL([LimitedEnglishDescriptor].[CodeValue], 'Not applicable') AS [LimitedEnglishProficiency],
  --[Student].[EconomicDisadvantaged] AS [IsEconomicallyDisadvantaged], 
  CASE
    WHEN [FoodServicesDescriptor].[CodeValue] <> 'FullPrice' THEN 1
    ELSE 0
  END AS IsEligibleForSchoolFoodService,
  [StudentEducationOrganizationAssociation].[HispanicLatinoEthnicity] AS [IsHispanic],
  std.[CodeValue] AS [Sex] ,
  [PrimaryContact].[ContactName],
  [PrimaryContact].[ContactRelationship],
  [PrimaryContact].[ContactAddress],
  [PrimaryContact].[ContactMobilePhoneNumber],
  [PrimaryContact].[ContactWorkPhoneNumber],
  [PrimaryContact].[ContactEmailAddress],
  (SELECT
    MAX([LastModifiedDate])
  FROM (
  VALUES
  ([Student].[LastModifiedDate]),
  ([PrimaryContact].[LastModifiedDate])
  ) AS value ([LastModifiedDate]))
  AS [LastModifiedDate]
FROM [edfi].[Student]
INNER JOIN [edfi].[StudentSchoolAssociation]
  ON [Student].[StudentUSI] = [StudentSchoolAssociation].[StudentUSI]
INNER JOIN edfi.StudentEducationOrganizationAssociation
  ON StudentEducationOrganizationAssociation.StudentUSI = Student.StudentUSI
LEFT JOIN [edfi].[StudentSchoolFoodServiceProgramAssociationSchoolFoodServiceProgramService]
  ON StudentSchoolFoodServiceProgramAssociationSchoolFoodServiceProgramService.EducationOrganizationId = StudentEducationOrganizationAssociation.EducationOrganizationId
  AND StudentSchoolFoodServiceProgramAssociationSchoolFoodServiceProgramService.StudentUSI = Student.StudentUSI
INNER JOIN [edfi].[Descriptor]
  ON [StudentSchoolAssociation].[EntryGradeLevelDescriptorId] = [Descriptor].[DescriptorId]
LEFT OUTER JOIN [edfi].[Descriptor] AS [LimitedEnglishDescriptor]
  ON [edfi].[StudentEducationOrganizationAssociation].[LimitedEnglishProficiencyDescriptorId] = [LimitedEnglishDescriptor].[DescriptorId]
LEFT JOIN [edfi].[Descriptor] std
  ON [Student].[BirthSexDescriptorId] = std.DescriptorId
LEFT OUTER JOIN [edfi].[Descriptor] AS [FoodServicesDescriptor]
  ON [StudentSchoolFoodServiceProgramAssociationSchoolFoodServiceProgramService].SchoolFoodServiceProgramServiceDescriptorId = [FoodServicesDescriptor].[DescriptorId]
LEFT OUTER JOIN StudentRaces ON edfi.Student.StudentUSI = StudentRaces.StudentUSI
LEFT OUTER JOIN edfi.RaceDescriptor rd ON rd.RaceDescriptorId = StudentRaces.RaceDescriptorId
LEFT OUTER JOIN edfi.Descriptor d ON rd.RaceDescriptorId = d.DescriptorId
OUTER APPLY (
-- It is possible for more than one person to be marked as primary contact, therefore 
-- we have to carefully restrict to just one record.
SELECT TOP 1
  [ContactFirstName] + ' ' + [ContactLastName] AS [ContactName],
  [RelationshipToStudent] AS [ContactRelationship],
  COALESCE(
  NULLIF([ContactHomeAddress], ''),
  NULLIF([ContactPhysicalAddress], ''),
  NULLIF([ContactMailingAddress], ''),
  NULLIF([ContactWorkAddress], ''),
  NULLIF([ContactTemporaryAddress], '')
  ) AS [ContactAddress],
  [WorkPhoneNumber] AS [ContactWorkPhoneNumber],
  [MobilePhoneNumber] AS [ContactMobilePhoneNumber],
  CASE
    WHEN [PrimaryEmailAddress] = 'Work' THEN [WorkEmailAddress]
    ELSE [PersonalEmailAddress]
  END AS [ContactEmailAddress],
  [analytics].[ContactPersonDimension].LastModifiedDate
FROM [analytics].[ContactPersonDimension]
WHERE [Student].[StudentUSI] = [ContactPersonDimension].[StudentKey]
AND [ContactPersonDimension].[IsPrimaryContact] = 1) AS [PrimaryContact]
--WHERE [StudentSchoolAssociation].[ExitWithdrawDate] IS NULL;
GO
