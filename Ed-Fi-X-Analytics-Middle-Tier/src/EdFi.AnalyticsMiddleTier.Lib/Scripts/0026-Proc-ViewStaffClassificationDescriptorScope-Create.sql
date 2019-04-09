CREATE PROC [analytics_config].[ViewStaffClassificationDescriptorScope] AS
BEGIN 

	SET NOCOUNT ON

	SELECT 
		[AuthorizationScope].[AuthorizationScopeName],
		[Descriptor].[CodeValue]
	FROM 
		[analytics_config].[StaffClassificationDescriptorScope]
	INNER JOIN
		[analytics_config].[AuthorizationScope] ON
			[StaffClassificationDescriptorScope].[AuthorizationScopeId] = [AuthorizationScope].[AuthorizationScopeId]
	INNER JOIN
		[edfi].[Descriptor] ON
			[StaffClassificationDescriptorScope].[StaffClassificationDescriptorId] = [Descriptor].[DescriptorId]


END