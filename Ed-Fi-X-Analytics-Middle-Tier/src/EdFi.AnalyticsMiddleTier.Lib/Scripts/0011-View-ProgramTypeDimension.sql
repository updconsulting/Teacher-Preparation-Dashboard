/****** Object:  View [analytics].[ProgramTypeDimension]    Script Date: 4/23/2019 2:46:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [analytics].[ProgramTypeDimension] AS

	SELECT 
		[ptd].[ProgramTypeDescriptorId] AS [ProgramTypeKey],
		[CodeValue] AS [ProgramType]
	FROM
		[edfi].[ProgramTypeDescriptor] ptd
		INNER JOIN edfi.Descriptor d ON d.DescriptorId = ptd.ProgramTypeDescriptorId
GO
