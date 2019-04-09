CREATE VIEW [analytics].[StudentProgramFact] AS

	SELECT
		[StudentProgramAssociation].[StudentUSI] AS [StudentKey],
		[StudentProgramAssociation].[EducationOrganizationId] AS [LocalEducationAgencyKey],
		MAX([DateDimension].[DateKey]) AS [DateKey],
		[StudentProgramAssociation].[ProgramTypeDescriptorId] AS [ProgramTypeKey],
		1 AS [IsEnrolled]
	FROM
		[edfi].[StudentProgramAssociation]
	INNER JOIN
		[analytics].[DateDimension] ON
			[StudentProgramAssociation].[BeginDate] <= [DateDimension].[Date]
	
	GROUP BY
		[StudentProgramAssociation].[StudentUSI],
		[StudentProgramAssociation].[EducationOrganizationId],
		[StudentProgramAssociation].[ProgramTypeDescriptorId]
GO