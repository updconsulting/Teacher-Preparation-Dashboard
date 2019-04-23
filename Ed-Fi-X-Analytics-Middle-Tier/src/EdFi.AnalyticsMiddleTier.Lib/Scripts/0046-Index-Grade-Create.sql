CREATE NONCLUSTERED INDEX [IX_AMT_Grade_SectionKey]
ON [edfi].[Grade] ([StudentUSI],[SchoolId],SessionName,[LocalCourseCode],SectionIdentifier,[SchoolYear])
INCLUDE ([NumericGradeEarned])
GO

INSERT INTO [analytics_config].[IndexJournal] VALUES ('[edfi].[Grade].[IX_AMT_Grade_SectionKey]')
