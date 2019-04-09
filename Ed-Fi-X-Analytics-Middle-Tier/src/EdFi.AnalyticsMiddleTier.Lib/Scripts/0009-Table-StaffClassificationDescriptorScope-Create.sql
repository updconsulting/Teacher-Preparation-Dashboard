/*
 * This script is optimized for running multiple times, in order to support
 * the uninstall / reinstall process. Uninstall leaves the new tables in 
 * place so that the DBA will not lose any existing scope mappings. However,
 * the journal table is deleted. Thus if you then re-run the migration utility,
 * this script will run it again. The script name will be add to the 
 * re-created journal table, but no error will occur due to the existing
 * table and the existing table's data will be preserved.
 */

IF (SELECT OBJECT_ID('[analytics_config].[StaffClassificationDescriptorScope]')) IS NULL
BEGIN
	CREATE TABLE [analytics_config].[StaffClassificationDescriptorScope] (
		[AuthorizationScopeId] INT NOT NULL,
		[StaffClassificationDescriptorId] INT NOT NULL,
		CONSTRAINT [PK_StaffClassificationDescriptorScope] PRIMARY KEY CLUSTERED (
			[AuthorizationScopeId],
			[StaffClassificationDescriptorId]
		) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY],
		CONSTRAINT [FK_StaffClassificationDescriptorScope_AuthorizationScopeId] FOREIGN KEY (
			[AuthorizationScopeId]
		) REFERENCES [analytics_config].[AuthorizationScope] ([AuthorizationScopeId]),
		CONSTRAINT [FK_StaffClassificationDescriptorScope_StaffClassificationDescriptorId] FOREIGN KEY (
			[StaffClassificationDescriptorId]
		) REFERENCES [edfi].[StaffClassificationDescriptor] ([StaffClassificationDescriptorId])
	) ON [PRIMARY];
END
GO

 