CREATE NONCLUSTERED INDEX [IX_AMT_Descriptor_CodeValue] ON [edfi].[Descriptor] (
	[CodeValue]
)
GO

INSERT INTO [analytics_config].[IndexJournal] VALUES ('[edfi].[Descriptor].[IX_AMT_Descriptor_CodeValue]')