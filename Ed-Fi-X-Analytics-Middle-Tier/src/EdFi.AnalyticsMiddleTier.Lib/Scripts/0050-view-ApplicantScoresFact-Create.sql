CREATE     VIEW [analytics].[ApplicantScoresFact]
AS
    SELECT
        *
    FROM (SELECT
            [analytics].[EntitySchoolYearInstanceSetKey](asr.ApplicantIdentifier, s.SchoolYear) AS ApplicantSchoolYearInstanceKey,
            asr.ApplicantIdentifier ApplicantKey
	   , s.SchoolYear
	   , asr.EducationOrganizationId
	   , ROUND(CAST(asr.Result AS DOUBLE PRECISION), 2) Result
	   , d.CodeValue AS AssessmentTitle
	   , ROW_NUMBER() OVER (PARTITION BY ap.ApplicationIdentifier, s.SchoolYear, ap.EducationOrganizationId, d.CodeValue ORDER BY asr.Result DESC) MostRecent
        FROM tpdm.ApplicantScoreResult asr
            INNER JOIN tpdm.Application ap
            ON ap.ApplicantIdentifier = asr.ApplicantIdentifier
                AND ap.EducationOrganizationId = asr.EducationOrganizationId
            INNER JOIN edfi.AssessmentReportingMethodDescriptor armd
            ON asr.AssessmentReportingMethodDescriptorId = armd.AssessmentReportingMethodDescriptorId
            INNER JOIN edfi.Descriptor d
            ON armd.AssessmentReportingMethodDescriptorId = d.DescriptorId
	CROSS APPLY (SELECT TOP 1
                s.SchoolYear
		   , s.SessionName
		   , s.BeginDate
		   , s.TotalInstructionalDays
            FROM edfi.Session s
            WHERE ap.ApplicationDate
		BETWEEN s.BeginDate AND s.EndDate) s
            INNER JOIN edfi.SchoolYearType syt
            ON syt.SchoolYear = s.SchoolYear
                AND syt.CurrentSchoolYear = 1)  CurrentYear
    WHERE CurrentYear.MostRecent = 1
GO

