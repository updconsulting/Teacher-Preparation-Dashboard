/****** Object:  View [analytics].[SchoolNetworkAssociationDimension]    Script Date: 4/23/2019 2:46:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [analytics].[SchoolNetworkAssociationDimension] AS

	SELECT
		[School].[SchoolId]AS [SchoolKey],
		[EducationOrganization].[NameOfInstitution] AS [NetworkName],
		[EducationOrganizationNetworkAssociation].[EducationOrganizationNetworkId] AS [NetworkKey],
		[npd].[CodeValue] AS [NetworkPurpose],
		[EducationOrganizationNetworkAssociation].[BeginDate],
		[EducationOrganizationNetworkAssociation].[EndDate]
	FROM
		[edfi].[EducationOrganizationNetworkAssociation]
	INNER JOIN
		[edfi].[EducationOrganizationNetwork] ON
			[EducationOrganizationNetworkAssociation].[EducationOrganizationNetworkId] = [EducationOrganizationNetwork].[EducationOrganizationNetworkId]
	INNER JOIN
		[edfi].[School] ON
			[EducationOrganizationNetworkAssociation].[MemberEducationOrganizationId] = [School].[SchoolId]
	INNER JOIN
		[edfi].[EducationOrganization] ON
			[EducationOrganizationNetworkAssociation].[EducationOrganizationNetworkId] = [EducationOrganization].[EducationOrganizationId]
	INNER JOIN
		[edfi].[Descriptor] npd ON
			[EducationOrganizationNetwork].[NetworkPurposeDescriptorId] = [npd].DescriptorId
GO
