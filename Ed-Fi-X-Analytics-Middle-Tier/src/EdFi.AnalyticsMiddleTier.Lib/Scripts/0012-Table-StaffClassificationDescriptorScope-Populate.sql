WITH [classifications] as (
	SELECT [DescriptorId], [CodeValue]
	FROM [edfi].[StaffClassificationDescriptor]
	INNER JOIN [edfi].[Descriptor] ON 
		[StaffClassificationDescriptor].[StaffClassificationDescriptorId] = [Descriptor].[DescriptorId]
)
MERGE INTO [analytics_config].[StaffClassificationDescriptorScope] AS [Target]
USING (
	SELECT
		[AuthorizationScopeId],
		[DescriptorId]
	FROM [classifications]
	CROSS JOIN [analytics_config].[AuthorizationScope]
	WHERE 
			([AuthorizationScopeName] = 'Section' AND [CodeValue] IN ('Teacher', 'Substitute Teacher'))
		OR	([AuthorizationScopeName] = 'School' AND [CodeValue] IN ('Principal'))
		OR	([AuthorizationScopeName] = 'District' AND [CodeValue] IN ('Superintendent'))
) AS [Source] ([AuthorizationScopeId], [DescriptorId])
ON 
		[Target].[AuthorizationScopeId] = [Source].[AuthorizationScopeId]
	AND	[Target].StaffClassificationDescriptorId = [Source].[DescriptorId]
WHEN NOT MATCHED BY TARGET THEN
INSERT ([AuthorizationScopeId], StaffClassificationDescriptorId) VALUES ([AuthorizationScopeId], [DescriptorId])
OUTPUT $action, inserted.*;
