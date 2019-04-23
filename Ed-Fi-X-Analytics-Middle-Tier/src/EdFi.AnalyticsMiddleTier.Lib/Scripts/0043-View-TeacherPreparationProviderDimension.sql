/****** Object:  View [analytics].[TeacherPreparationProviderDimension]    Script Date: 4/23/2019 2:46:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [analytics].[TeacherPreparationProviderDimension]
AS
SELECT
	tpp.TeacherPreparationProviderId TeacherPrepartionProviderKey
   ,tpp.UniversityId UniversityKey
   ,d.CodeValue FederalLocalCodeType
   ,TeacherPreparationProvider.NameOfInstitution TeacherPreparationProviderName
   ,TeacherPreparationProvider.WebSite TeacherPreparationProviderWebSite
   ,University.NameOfInstitution UniversityName
   ,University.WebSite UniversityWebSite
   ,(SELECT
			MAX([LastModifiedDate])
		FROM (VALUES(TeacherPreparationProvider.[LastModifiedDate]),

		(University.[LastModifiedDate]),

		([TeacherPreparationProviderAddress].[LastModifiedDate])
		) AS value ([LastModifiedDate]))
	AS [LastModifiedDate]
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
OUTER APPLY (SELECT TOP 1
		CONCAT(
		[EducationOrganizationAddress].[StreetNumberName],
		', ',
		([EducationOrganizationAddress].[ApartmentRoomSuiteNumber] + ', '),
		[EducationOrganizationAddress].[City],
		[sad].[CodeValue],
		' ',
		[EducationOrganizationAddress].[PostalCode]
		) AS [SchoolAddress]
	   ,[EducationOrganizationAddress].[City] AS [SchoolCity]
	   ,[EducationOrganizationAddress].[NameOfCounty] AS [SchoolCounty]
	   ,[sad].[CodeValue] AS [SchoolState]
	   ,[EducationOrganizationAddress].[CreateDate] AS [LastModifiedDate]
	FROM [edfi].[EducationOrganizationAddress]
	INNER JOIN [edfi].[Descriptor] atd
		ON [EducationOrganizationAddress].[AddressTypeDescriptorId] = atd.DescriptorId
	INNER JOIN [edfi].[Descriptor] sad
		ON [EducationOrganizationAddress].[StateAbbreviationDescriptorId] = sad.DescriptorId
	WHERE tpp.TeacherPreparationProviderId = [EducationOrganizationAddress].[EducationOrganizationId]
	AND [atd].[CodeValue] = 'Physical') AS [TeacherPreparationProviderAddress];
GO
