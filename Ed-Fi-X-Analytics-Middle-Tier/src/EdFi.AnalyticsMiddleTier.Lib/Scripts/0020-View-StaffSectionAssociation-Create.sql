CREATE   VIEW [analytics].[StaffSectionAssociation]
AS
  SELECT DISTINCT analytics.EntitySchoolYearInstanceSetKey(ssa.StaffUSI, ssa.SchoolYear) AS StaffSchoolYearInstanceKey,
    analytics.EntitySchoolYearInstanceSetKey(ssa.SectionIdentifier, ssa.SchoolYear) AS SectionSchoolYearInstanceKey,
    ssa.SectionIdentifier AS SectionKey,
    ssa.StaffUSI AS StaffKey,
    ssa.LocalCourseCode,
    ssa.SchoolId,
    ssa.SchoolYear,
    ssa.SessionName,
    ssa.BeginDate,
    ssa.EndDate
  FROM edfi.StaffSectionAssociation ssa
    INNER JOIN tpdm.StaffTeacherCandidateAssociation stca on ssa.StaffUSI = stca.StaffUSI
GO
