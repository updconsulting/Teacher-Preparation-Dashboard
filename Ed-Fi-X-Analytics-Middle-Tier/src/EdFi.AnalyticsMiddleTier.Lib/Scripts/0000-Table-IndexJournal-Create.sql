CREATE TABLE [analytics_config].[IndexJournal]
(
    [FullyQualifiedIndexName] NVARCHAR(400) NOT NULL,
    CONSTRAINT [PK_IndexJournal]
        PRIMARY KEY CLUSTERED ([FullyQualifiedIndexName])
) ON [PRIMARY];
