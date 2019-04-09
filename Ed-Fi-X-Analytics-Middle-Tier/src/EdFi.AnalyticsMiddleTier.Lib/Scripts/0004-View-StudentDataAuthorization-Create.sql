CREATE VIEW [analytics].[StudentDataAuthorization] AS

		SELECT 
		[Student].[StudentUSI] as [StudentKey],
		[Section].[SchoolId] as [SchoolKey],
		CAST([Section].[SchoolId] as NVARCHAR)
			+ '-' + [Section].SectionIdentifier
			+ '-' + [Section].[LocalCourseCode]
			+ '-' + CAST([Section].SessionName as NVARCHAR)
			+ '-' + CAST([Section].[SchoolYear] as NVARCHAR)
			as [SectionKey],
		[StudentSectionAssociation].[BeginDate],
		[StudentSectionAssociation].[EndDate]
	FROM 
		[edfi].[Student]
	INNER JOIN 
		[edfi].[StudentSectionAssociation] ON
			[Student].[StudentUSI] = [StudentSectionAssociation].[StudentUSI]
	INNER JOIN 
		[edfi].[Section] ON
			[StudentSectionAssociation].[SchoolId] = [Section].[SchoolId]
		AND [StudentSectionAssociation].SectionIdentifier = edfi.StudentSectionAssociation.SectionIdentifier
		AND [StudentSectionAssociation].SessionName = [Section].SessionName
		AND [StudentSectionAssociation].[LocalCourseCode] = [Section].[LocalCourseCode]
		AND [StudentSectionAssociation].[SchoolYear] = [Section].[SchoolYear]
