/*
 * This script is optimized for running multiple times, in order to support
 * the uninstall / reinstall process. Uninstall leaves the new tables in 
 * place so that the DBA will not lose any existing scope mappings. However,
 * the journal table is deleted. Thus if you then re-run the migration utility,
 * this script will run it again. The script name will be add to the 
 * re-created journal table, but no error will occur due to the existing
 * table and the existing table's data will be preserved.
 */

IF (SELECT OBJECT_ID('[analytics_config].[AuthorizationScope]')) IS NULL
BEGIN
	CREATE TABLE [analytics_config].[AuthorizationScope] (
		[AuthorizationScopeId] INT NOT NULL IDENTITY(1,1),
		[AuthorizationScopeName] VARCHAR(50),
		CONSTRAINT [PK_AuthorizationScope] PRIMARY KEY CLUSTERED (
			[AuthorizationScopeId]
		) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
	) ON [PRIMARY]
END