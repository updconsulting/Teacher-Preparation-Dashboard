CREATE NONCLUSTERED INDEX [IX_AMT_StudentSectionAssociation_StudentSectionDimension] ON [edfi].[StudentSectionAssociation] (
	[SchoolId],
	[LocalCourseCode],
	[SchoolYear],
	[SessionName]
)
INCLUDE (
	[EndDate],
	[LastModifiedDate]
)
GO

INSERT INTO [analytics_config].[IndexJournal] VALUES ('[edfi].[StudentSectionAssociation].[IX_AMT_StudentSectionAssociation_StudentSectionDimension]')
