/****** Object:  View [analytics].[StaffSectionAssociation]    Script Date: 4/23/2019 2:46:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [analytics].[StaffSectionAssociation]
AS
SELECT DISTINCT
  ssa.SectionIdentifier AS SectionKey,
  ssa.StaffUSI AS StaffKey,
  ssa.LocalCourseCode,
  ssa.SchoolId,
  ssa.SchoolYear,
  ssa.SessionName,
  ssa.BeginDate,
  ssa.EndDate
FROM edfi.StaffSectionAssociation ssa
INNER JOIN edfi.Staff
  ON ssa.StaffUSI = edfi.Staff.StaffUSI
INNER JOIN tpdm.TeacherCandidate tc
  ON tc.TeacherCandidateIdentifier = Staff.StaffUniqueId
GO
