CREATE VIEW [analytics].[ProgramTypeDimension]
AS

	SELECT
		[ptd].[ProgramTypeDescriptorId] AS [ProgramTypeKey],
		[CodeValue] AS [ProgramType]
	FROM
		[edfi].[ProgramTypeDescriptor] ptd
		INNER JOIN edfi.Descriptor d ON d.DescriptorId = ptd.ProgramTypeDescriptorId
GO
