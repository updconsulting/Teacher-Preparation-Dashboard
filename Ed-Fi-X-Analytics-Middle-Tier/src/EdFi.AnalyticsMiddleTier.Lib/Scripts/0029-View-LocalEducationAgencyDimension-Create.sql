CREATE VIEW [analytics].[LocalEducationAgencyDimension] AS

	SELECT
		[EducationOrganization].[EducationOrganizationId] AS [LocalEducationAgencyKey],
		[EducationOrganization].[NameOfInstitution] AS [LocalEducationAgencyName],
		ISNULL(lacd.[CodeValue], '') AS [LocalEducationAgencyType],
		[LocalEducationAgency].[ParentLocalEducationAgencyId] AS [LocalEducationAgencyParentLocalEducationAgencyKey],
		ISNULL([StateEducationAgency].[NameOfInstitution], '') AS [LocalEducationAgencyStateEducationAgencyName],
		[LocalEducationAgency].[StateEducationAgencyId] AS [LocalEducationAgencyStateEducationAgencyKey],
		ISNULL([EducationServiceCenter].[NameOfInstitution], '') AS [LocalEducationAgencyServiceCenterName],
		[EducationServiceCenter].[EducationOrganizationId] AS [LocalEducationAgencyServiceCenterKey],
		ISNULL(csd.[CodeValue], '') AS [LocalEducationAgencyCharterStatus],
		(
			SELECT
				MAX([LastModifiedDate])
			FROM (VALUES ([EducationOrganization].[LastModifiedDate])
						,([EducationServiceCenter].[LastModifiedDate])
			) AS value([LastModifiedDate])
		) AS [LastModifiedDate]
	FROM
		[edfi].[EducationOrganization]
	INNER JOIN
		[edfi].[LocalEducationAgency] ON
			[EducationOrganization].[EducationOrganizationId] = [LocalEducationAgency].[LocalEducationAgencyId]
	LEFT OUTER JOIN
		[edfi].[Descriptor] lacd ON
			[LocalEducationAgency].[LocalEducationAgencyCategoryDescriptorId] = lacd.DescriptorId
	LEFT OUTER JOIN
		[edfi].[EducationOrganization] AS [EducationServiceCenter] ON
			[LocalEducationAgency].[EducationServiceCenterId] = [EducationServiceCenter].[EducationOrganizationId]
	LEFT OUTER JOIN
		[edfi].[Descriptor] csd ON
			[LocalEducationAgency].[CharterStatusDescriptorId] = csd.DescriptorId
	LEFT OUTER JOIN
		[edfi].[EducationOrganization] AS [StateEducationAgency] ON
			[LocalEducationAgency].[StateEducationAgencyId] = [StateEducationAgency].[EducationOrganizationId]
GO