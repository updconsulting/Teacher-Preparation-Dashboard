CREATE   VIEW [analytics].[LocalEducationAgencyDimension]
AS
  WITH
    LocalEducationAgencySuperIntendent
    AS
    (
      SELECT
        lea.LocalEducationAgencyId
   , s.FirstName + ' ' + s.LastSurname AS SuperIntendentFullName
      FROM edfi.StaffEducationOrganizationAssignmentAssociation seoaa
        INNER JOIN edfi.EducationOrganization eo
        ON seoaa.EducationOrganizationId = eo.EducationOrganizationId
        INNER JOIN edfi.LocalEducationAgency lea
        ON eo.EducationOrganizationId = lea.LocalEducationAgencyId
        INNER JOIN edfi.Staff s
        ON seoaa.StaffUSI = s.StaffUSI
      WHERE seoaa.PositionTitle LIKE 'Superintendent'
    )
  SELECT
    analytics.EntitySchoolYearInstanceSetKey([EducationOrganization].[EducationOrganizationId], (SELECT
      syt.SchoolYear
    FROM edfi.SchoolYearType syt
    WHERE syt.CurrentSchoolYear = 1)
  ) LocalEducationAgencySchoolYearInstanceKey
 , [EducationOrganization].[EducationOrganizationId] AS [LocalEducationAgencyKey]
 , SchoolYear = (SELECT
      syt.SchoolYear
    FROM edfi.SchoolYearType syt
    WHERE syt.CurrentSchoolYear = 1)
 , [EducationOrganization].[NameOfInstitution] AS [LocalEducationAgencyName]
 , ISNULL(lacd.[CodeValue], '') AS [LocalEducationAgencyType]
 , [LocalEducationAgency].[ParentLocalEducationAgencyId] AS [LocalEducationAgencyParentLocalEducationAgencyKey]
 , ISNULL([StateEducationAgency].[NameOfInstitution], '') AS [LocalEducationAgencyStateEducationAgencyName]
 , [LocalEducationAgency].[StateEducationAgencyId] AS [LocalEducationAgencyStateEducationAgencyKey]
 , ISNULL([EducationServiceCenter].[NameOfInstitution], '') AS [LocalEducationAgencyServiceCenterName]
 , [EducationServiceCenter].[EducationOrganizationId] AS [LocalEducationAgencyServiceCenterKey]
 , ISNULL(csd.[CodeValue], '') AS [LocalEducationAgencyCharterStatus]
 , SuperIntendentFullName
 , LocalEducationAgencyAddress.LocalEducationAgencyAddress
 , LocalEducationAgencyAddress.TelephoneNumber
 , (SELECT
      MAX([LastModifiedDate])
    FROM (VALUES
        ([EducationOrganization].[LastModifiedDate]),
        ([EducationServiceCenter].[LastModifiedDate])
    ) AS value ([LastModifiedDate]))
  AS [LastModifiedDate]
  FROM [edfi].[EducationOrganization]
    INNER JOIN [edfi].[LocalEducationAgency]
    ON [EducationOrganization].[EducationOrganizationId] = [LocalEducationAgency].[LocalEducationAgencyId]
    LEFT OUTER JOIN [edfi].[Descriptor] lacd
    ON [LocalEducationAgency].[LocalEducationAgencyCategoryDescriptorId] = lacd.DescriptorId
    LEFT OUTER JOIN [edfi].[EducationOrganization] AS [EducationServiceCenter]
    ON [LocalEducationAgency].[EducationServiceCenterId] = [EducationServiceCenter].[EducationOrganizationId]
    LEFT OUTER JOIN [edfi].[Descriptor] csd
    ON [LocalEducationAgency].[CharterStatusDescriptorId] = csd.DescriptorId
    LEFT OUTER JOIN [edfi].[EducationOrganization] AS [StateEducationAgency]
    ON [LocalEducationAgency].[StateEducationAgencyId] = [StateEducationAgency].[EducationOrganizationId]
    LEFT OUTER JOIN LocalEducationAgencySuperIntendent
    ON edfi.LocalEducationAgency.LocalEducationAgencyId = LocalEducationAgencySuperIntendent.LocalEducationAgencyId
OUTER APPLY (SELECT TOP 1
      CONCAT(
    [EducationOrganizationAddress].[StreetNumberName],
    ', ',
    ([EducationOrganizationAddress].[ApartmentRoomSuiteNumber] + ', '),
    [EducationOrganizationAddress].[City],
    [sad].[CodeValue],
    ' ',
    [EducationOrganizationAddress].[PostalCode]
    ) AS [LocalEducationAgencyAddress]
   , [EducationOrganizationAddress].[City] AS [LocalEducationAgencyCity]
   , [EducationOrganizationAddress].[NameOfCounty] AS [LocalEducationAgencyCounty]
   , [sad].[CodeValue] AS [LocalEducationAgencyState]
   , d.CodeValue AS TelephoneNumberType
   , eoit1.TelephoneNumber
   , [EducationOrganizationAddress].[CreateDate] AS [LastModifiedDate]
    FROM [edfi].[EducationOrganizationAddress]
      INNER JOIN [edfi].[Descriptor] atd
      ON [EducationOrganizationAddress].[AddressTypeDescriptorId] = atd.DescriptorId
      INNER JOIN [edfi].[Descriptor] sad
      ON [EducationOrganizationAddress].[StateAbbreviationDescriptorId] = sad.DescriptorId
      LEFT JOIN edfi.EducationOrganizationInstitutionTelephone eoit1
      ON edfi.EducationOrganizationAddress.EducationOrganizationId = eoit1.EducationOrganizationId
      LEFT JOIN edfi.Descriptor d
      ON atd.DescriptorId = d.DescriptorId
    WHERE edfi.EducationOrganization.EducationOrganizationId = [EducationOrganizationAddress].[EducationOrganizationId]
      AND [atd].[CodeValue] = 'Physical') AS [LocalEducationAgencyAddress];
GO


