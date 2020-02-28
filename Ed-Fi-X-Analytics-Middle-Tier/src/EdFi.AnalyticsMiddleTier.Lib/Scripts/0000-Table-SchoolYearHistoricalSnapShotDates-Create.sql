CREATE TABLE [analytics_config].[SchoolYearHistoricalSnapShotDates]
(
	[SchoolYear] [smallint] NOT NULL,
	[SchoolYearDescription] [nvarchar](50) NOT NULL,
	[SnapShotDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	CONSTRAINT [SchoolYearType_PK] PRIMARY KEY CLUSTERED 
(
	[SchoolYear] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [analytics_config].[SchoolYearHistoricalSnapShotDates] ADD  CONSTRAINT [SchoolYearType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO

ALTER TABLE [analytics_config].[SchoolYearHistoricalSnapShotDates] ADD  CONSTRAINT [SchoolYearType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO

ALTER TABLE [analytics_config].[SchoolYearHistoricalSnapShotDates] ADD  CONSTRAINT [SchoolYearType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO