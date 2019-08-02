CREATE   VIEW [analytics].[TeacherPreparationProviderDimension]
AS
WITH TeacherPreparationProvider
AS (
   SELECT tpp.TeacherPreparationProviderId TeacherPreparationProviderKey,
          tpp.UniversityId UniversityKey,
          Schoolyear =
          (
              SELECT SchoolYear FROM edfi.SchoolYearType WHERE CurrentSchoolYear = 1
          ),
          d.CodeValue FederalLocaleCodeType,
          TeacherPreparationProvider.NameOfInstitution TeacherPreparationProviderName,
          TeacherPreparationProvider.WebSite TeacherPreparationProviderWebSite,
          University.NameOfInstitution UniversityName,
          University.WebSite UniversityWebSite,
          (
              SELECT MAX([LastModifiedDate])
              FROM
              (
                  VALUES
                      (TeacherPreparationProvider.[LastModifiedDate]),
                      (University.[LastModifiedDate]),
                      ([TeacherPreparationProviderAddress].[LastModifiedDate])
              ) AS value ([LastModifiedDate])
          ) AS [LastModifiedDate]
   FROM tpdm.TeacherPreparationProvider tpp
       LEFT JOIN tpdm.FederalLocaleCodeDescriptor flcd
           ON tpp.FederalLocaleCodeDescriptorId = flcd.FederalLocaleCodeDescriptorId
       LEFT JOIN edfi.Descriptor d
           ON flcd.FederalLocaleCodeDescriptorId = d.DescriptorId
       LEFT JOIN tpdm.University u
           ON flcd.FederalLocaleCodeDescriptorId = u.FederalLocaleCodeDescriptorId
       LEFT JOIN edfi.EducationOrganization TeacherPreparationProvider
           ON tpp.TeacherPreparationProviderId = TeacherPreparationProvider.EducationOrganizationId
       LEFT JOIN edfi.EducationOrganization University
           ON u.UniversityId = University.EducationOrganizationId
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
       WHERE tpp.TeacherPreparationProviderId = [EducationOrganizationAddress].[EducationOrganizationId]
             AND [atd].[CodeValue] = 'Physical'
   ) AS [TeacherPreparationProviderAddress] )
SELECT [analytics].[EntitySchoolYearInstanceSetKey](
                                                       TeacherPreparationProvider.TeacherPreparationProviderKey,
                                                       TeacherPreparationProvider.Schoolyear
                                                   ) AS TeacherPreparationProviderSchoolYearInstanceKey,
       TeacherPreparationProvider.TeacherPreparationProviderKey,
       TeacherPreparationProvider.UniversityKey,
       TeacherPreparationProvider.Schoolyear,
       TeacherPreparationProvider.FederalLocaleCodeType,
       TeacherPreparationProvider.TeacherPreparationProviderName,
       TeacherPreparationProvider.TeacherPreparationProviderWebSite,
       TeacherPreparationProvider.UniversityName,
       TeacherPreparationProvider.UniversityWebSite,
       TeacherPreparationProvider.LastModifiedDate
FROM TeacherPreparationProvider;
GO
