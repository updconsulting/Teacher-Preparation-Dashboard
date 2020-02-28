
/*
This script will create a data mart with the views materialized into tables.
Run this with sqlcmd or in SSMS with "sqlcmd mode" turned on. Adjust the two 
variables immediately below as needed. Assumes that the destination database 
already exists and is on the same server as the ODS. Run the script 
periodically to refresh the data.
*/


:setvar DataMartDB EdFi_AMT_DataMart
:setvar OdsDb EdFi_Glendale


USE [$(DataMartDB)]
GO

IF NOT EXISTS (SELECT 1 FROM [INFORMATION_SCHEMA].[SCHEMATA] WHERE SCHEMA_NAME = 'analytics')
BEGIN
	EXEC sp_executesql N'CREATE SCHEMA [analytics]';
END

----------------------------
-- Populate Staging Tables
----------------------------
PRINT 'Creating staging tables...'

SELECT * 
INTO [$(DataMartDB)].[analytics].[stg_ContactPersonDimension]
FROM [$(OdsDb)].[analytics].[ContactPersonDimension]

SELECT *
INTO [$(DataMartDB)].[analytics].[stg_DateDimension]
FROM [$(OdsDb)].[analytics].[DateDimension]

SELECT *
INTO [$(DataMartDB)].[analytics].[stg_GradingPeriodDimension]
FROM [$(OdsDb)].[analytics].[GradingPeriodDimension]

SELECT *
INTO [$(DataMartDB)].[analytics].[stg_MostRecentGradingPeriod]
FROM [$(OdsDb)].[analytics].[MostRecentGradingPeriod]

SELECT *
INTO [$(DataMartDB)].[analytics].[stg_SchoolDimension]
FROM [$(OdsDb)].[analytics].[SchoolDimension]

SELECT *
INTO [$(DataMartDB)].[analytics].[stg_SchoolNetworkAssociationDimension]
FROM [$(OdsDb)].[analytics].[SchoolNetworkAssociationDimension]

SELECT *
INTO [$(DataMartDB)].[analytics].[stg_StudentDataAuthorization]
FROM [$(OdsDb)].[analytics].[StudentDataAuthorization]

SELECT *
INTO [$(DataMartDB)].[analytics].[stg_StudentDimension]
FROM [$(OdsDb)].[analytics].[StudentDimension]

SELECT *
INTO [$(DataMartDB)].[analytics].[stg_StudentEarlyWarningFact]
FROM [$(OdsDb)].[analytics].[StudentEarlyWarningFact]

SELECT *
INTO [$(DataMartDB)].[analytics].[stg_StudentSectionDimension]
FROM [$(OdsDb)].[analytics].[StudentSectionDimension]

SELECT *
INTO [$(DataMartDB)].[analytics].[stg_StudentSectionGradeFact]
FROM [$(OdsDb)].[analytics].[StudentSectionGradeFact]

SELECT *
INTO [$(DataMartDB)].[analytics].[stg_UserAuthorization]
FROM [$(OdsDb)].[analytics].[UserAuthorization]

SELECT *
INTO [$(DataMartDB)].[analytics].[stg_UserDimension]
FROM [$(OdsDb)].[analytics].[UserDimension]

SELECT *
INTO [$(DataMartDB)].[analytics].[stg_UserStudentDataAuthorization]
FROM [$(OdsDb)].[analytics].[UserStudentDataAuthorization]

SELECT *
INTO [$(DataMartDB)].[analytics].[stg_ProgramTypeDimension]
FROM [$(OdsDb)].[analytics].[ProgramTypeDimension]

SELECT *
INTO [$(DataMartDB)].[analytics].[stg_StudentProgramFact]
FROM [$(OdsDb)].[analytics].[StudentProgramFact]

SELECT *
INTO [$(DataMartDB)].[analytics].[stg_StudentProgramEvent]
FROM [$(OdsDb)].[analytics].[StudentProgramEvent]

SELECT *
INTO [$(DataMartDB)].[analytics].[stg_LocalEducationAgencyDimension]
FROM [$(OdsDb)].[analytics].[LocalEducationAgencyDimension]
GO

----------------------------
-- Add Indexes to Staging Tables
----------------------------
PRINT 'Adding indexes to staging tables...'

CREATE NONCLUSTERED INDEX [IX_ContactPersonDimension_StudentKey] 
ON [analytics].[stg_ContactPersonDimension] (
	[StudentKey]
) ON [Primary]


CREATE UNIQUE CLUSTERED INDEX [UCX_DateDimension]
ON [analytics].[stg_DateDimension] (
	[DateKey]
) ON [Primary]


CREATE UNIQUE CLUSTERED INDEX [UCX_GradingPeriodDimension]
ON [analytics].[stg_GradingPeriodDimension] (
	[GradingPeriodKey]
) ON [Primary]

CREATE NONCLUSTERED INDEX [IX_GradingPeriodDimension_SchoolKey]
ON [analytics].[stg_GradingPeriodDimension] (
	[SchoolKey]
) ON [Primary]

CREATE UNIQUE CLUSTERED INDEX [UCX_MostRecentGradingPeriod]
ON [analytics].[stg_MostRecentGradingPeriod] (
	[SchoolKey]
) ON [Primary]


CREATE UNIQUE CLUSTERED INDEX [UCX_SchoolDimension]
ON [analytics].[stg_SchoolDimension] (
	[SchoolKey]
) ON [Primary]

CREATE NONCLUSTERED INDEX [IX_SchoolNetworkAssociationDimension_SchoolKey]
ON [analytics].[stg_SchoolNetworkAssociationDimension] (
	[SchoolKey]
) ON [Primary]

CREATE UNIQUE CLUSTERED INDEX [UCX_StudentDataAuthorization]
ON [analytics].[stg_StudentDataAuthorization] (
	[StudentKey],
	[SchoolKey],
	[SectionKey],
	[BeginDate],
	[EndDate]
) ON [Primary]

CREATE UNIQUE CLUSTERED INDEX [UCX_StudentDimension]
ON [analytics].[stg_StudentDimension] (
	[StudentKey],
	[SchoolKey]
) ON [Primary]


CREATE UNIQUE CLUSTERED INDEX [UCX_StudentEarlyWarningFact]
ON [analytics].[stg_StudentEarlyWarningFact] (
	[StudentKey],
	[SchoolKey],
	[DateKey]
) ON [Primary]


CREATE UNIQUE CLUSTERED INDEX [UCX_StudentSectionDimension]
ON [analytics].[stg_StudentSectionDimension] (
	[StudentSectionKey]
) ON [Primary]


CREATE INDEX [IX_StudentSectionDimension_StudentSectionKey] ON
	[analytics].[stg_StudentSectionDimension]
(
	[StudentKey],
	[StudentSectionKey],
	[Subject],
	[SchoolKey]
) ON [Primary]


CREATE NONCLUSTERED INDEX [IX_StudentSectionDimension_SchoolKey]
ON [analytics].[stg_StudentSectionDimension] (
	[SchoolKey]
) ON [Primary]

CREATE NONCLUSTERED INDEX [IX_StudentSectionDimension_SectionKey]
ON [analytics].[stg_StudentSectionDimension] (
	[SectionKey]
) ON [Primary]

CREATE UNIQUE CLUSTERED INDEX [UCX_StudentSectionGradeFact]
ON [analytics].[stg_StudentSectionGradeFact] (
	[StudentSectionKey],
	[GradingPeriodKey]
) ON [Primary]

CREATE NONCLUSTERED INDEX [IX_StudentSectionGradeFact_StudentKey]
ON [analytics].[stg_StudentSectionGradeFact] (
	[StudentKey]
) ON [Primary]

CREATE NONCLUSTERED INDEX [IX_StudentSectionGradeFact_SchoolKey]
ON [analytics].[stg_StudentSectionGradeFact] (
	[SchoolKey]	
) ON [Primary]

CREATE NONCLUSTERED INDEX [IX_StudentSectionGradeFact_SectionKey]
ON [analytics].[stg_StudentSectionGradeFact] (
	[SectionKey]
) ON [Primary]


CREATE UNIQUE CLUSTERED INDEX [UCX_UserAuthorization]
ON [analytics].[stg_UserAuthorization] (
	[UserKey],
	[UserScope],
	[StudentPermission],
	[SectionPermission],
	[SchoolPermission]
) ON [Primary]

CREATE UNIQUE CLUSTERED INDEX [UCX_UserDimension]
ON [analytics].[stg_UserDimension] (
	[UserKey]
) ON [Primary]


CREATE UNIQUE CLUSTERED INDEX [UCX_UserStudentDataAuthorization]
ON [analytics].[stg_UserStudentDataAuthorization] (
	[UserKey],
	[StudentKey]
) ON [Primary]

CREATE UNIQUE CLUSTERED INDEX [UCX_ProgramTypeDimension]
ON [analytics].[stg_ProgramTypeDimension] (
	[ProgramTypeKey]
) ON [Primary]

CREATE UNIQUE CLUSTERED INDEX [UCX_StudentProgramFact]
ON [analytics].[stg_StudentProgramFact] (
	[StudentKey],
	[LocalEducationAgencyKey],
	[DateKey],
	[ProgramTypeKey]
) ON [Primary]

CREATE UNIQUE CLUSTERED INDEX [UCX_StudentProgramEvent]
ON [analytics].[stg_StudentProgramEvent] (
	[StudentKey],
	[LocalEducationAgencyKey],
	[DateKey],
	[ProgramTypeKey],
	[ProgramEventType]
) ON [Primary]
GO

----------------------------
-- Drop real tables so they can be replaced by the staging ones
-- (Dropping and then renaming staging tables is much faster
-- than merging records into the real tables)
----------------------------
PRINT 'Dropping live tables...'

DECLARE [AnalyticsTables] CURSOR READ_ONLY FORWARD_ONLY FOR
	SELECT 
		[TABLE_NAME] 
	FROM 
		[INFORMATION_SCHEMA].[TABLES] 
	WHERE 
		[TABLE_SCHEMA] = 'Analytics' 
	AND [TABLE_TYPE] = 'Base Table' 
	AND [TABLE_NAME] NOT LIKE 'stg_%'

DECLARE @TableToDelete as NVARCHAR(128)

OPEN [AnalyticsTables]

FETCH NEXT FROM [AnalyticsTables] INTO @TableToDelete

WHILE @@FETCH_STATUS = 0
BEGIN

	DECLARE @sql NVARCHAR(200) = N'DROP TABLE [analytics].[' + @TableToDelete + N']';
	EXEC sp_executesql @sql;

	--SET @sql = N'ALTER TABLE [analytics].[stg_' + @TableToDelete + N'] TO [analytics].['

	FETCH NEXT FROM [AnalyticsTables] INTO @TableToDelete
END

CLOSE [AnalyticsTables]
DEALLOCATE [AnalyticsTables]
GO

----------------------------
-- Rename staging tables to be the real tables
----------------------------
PRINT 'Renaming staging to real tables...'

DECLARE [StagingTables] CURSOR READ_ONLY FORWARD_ONLY FOR
	SELECT 
		[TABLE_NAME] 
	FROM 
		[INFORMATION_SCHEMA].[TABLES] 
	WHERE 
		[TABLE_SCHEMA] = 'Analytics' 
	AND [TABLE_TYPE] = 'Base Table' 
	AND [TABLE_NAME] LIKE 'stg_%'

DECLARE @StagingTable as NVARCHAR(128)

OPEN [StagingTables]

FETCH NEXT FROM [StagingTables] INTO @StagingTable

WHILE @@FETCH_STATUS = 0
BEGIN

	DECLARE @source NVARCHAR(300) = '[analytics].' + @StagingTable
	DECLARE @dest NVARCHAR(128) = REPLACE(@StagingTable, 'stg_', '')
	
	EXEC sp_rename @source, @dest

	FETCH NEXT FROM [StagingTables] INTO @StagingTable
END

CLOSE [StagingTables]
DEALLOCATE [StagingTables]

PRINT 'All operations complete.'
GO