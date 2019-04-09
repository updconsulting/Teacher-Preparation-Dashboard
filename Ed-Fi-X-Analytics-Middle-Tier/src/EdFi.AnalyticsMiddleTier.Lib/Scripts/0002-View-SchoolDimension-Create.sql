CREATE VIEW [analytics].[SchoolDimension]
AS
SELECT [School].[SchoolId] AS [SchoolKey],
       [EducationOrganization].[NameOfInstitution] AS [SchoolName],
       ISNULL([std].[CodeValue], '') AS [SchoolType],
       ISNULL([SchoolAddress].[SchoolAddress], '') AS [SchoolAddress],
       ISNULL([SchoolAddress].[SchoolCity], '') AS [SchoolCity],
       ISNULL([SchoolAddress].[SchoolCounty], '') AS [SchoolCounty],
       ISNULL([SchoolAddress].[SchoolState], '') AS [SchoolState],
       ISNULL([EdOrgLocal].[NameOfInstitution], '') AS [LocalEducationAgencyName],
       [EdOrgLocal].[EducationOrganizationId] AS [LocalEducationAgencyKey],
       ISNULL([EdOrgState].[NameOfInstitution], '') AS [StateEducationAgencyName],
       [EdOrgState].[EducationOrganizationId] AS [StateEducationAgencyKey],
       ISNULL([EdOrgServiceCenter].[NameOfInstitution], '') AS [EducationServiceCenterName],
       [EdOrgServiceCenter].[EducationOrganizationId] AS [EducationServiceCenterKey],
       (
           SELECT MAX([LastModifiedDate])
           FROM
           (
               VALUES
                   ([EducationOrganization].[LastModifiedDate]),
                   ([std].[LastModifiedDate]),
                   ([EdOrgLocal].[LastModifiedDate]),
                   ([EdOrgState].[LastModifiedDate]),
                   ([EdOrgServiceCenter].[LastModifiedDate]),
                   ([SchoolAddress].[LastModifiedDate])
           ) AS value ([LastModifiedDate])
       ) AS [LastModifiedDate]
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
    OUTER APPLY
(
    SELECT TOP 1
           CONCAT(
                     [EducationOrganizationAddress].[StreetNumberName],
                     ', ',
                     ([EducationOrganizationAddress].[ApartmentRoomSuiteNumber] + ', '),
                     [EducationOrganizationAddress].[City],
                     [sad].[CodeValue],
                     ' ',
                     [EducationOrganizationAddress].[PostalCode]
                 ) AS [SchoolAddress],
           [EducationOrganizationAddress].[City] AS [SchoolCity],
           [EducationOrganizationAddress].[NameOfCounty] AS [SchoolCounty],
           [sad].[CodeValue] AS [SchoolState],
           [EducationOrganizationAddress].[CreateDate] AS [LastModifiedDate]
    FROM [edfi].[EducationOrganizationAddress]
        INNER JOIN [edfi].[Descriptor] atd
            ON [EducationOrganizationAddress].[AddressTypeDescriptorId] = atd.DescriptorId
        INNER JOIN [edfi].[Descriptor] sad
            ON [EducationOrganizationAddress].[StateAbbreviationDescriptorId] = sad.DescriptorId
    WHERE [School].[SchoolId] = [EducationOrganizationAddress].[EducationOrganizationId]
          AND [atd].[CodeValue] = 'Physical'
) AS [SchoolAddress];
GO

