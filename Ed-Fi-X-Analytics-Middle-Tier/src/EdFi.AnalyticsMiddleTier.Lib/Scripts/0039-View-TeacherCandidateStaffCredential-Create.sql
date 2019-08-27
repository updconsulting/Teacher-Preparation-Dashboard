CREATE     VIEW [analytics].[TeacherCandidateStaffCredential]
AS
  SELECT analytics.EntitySchoolYearInstanceSetKey(a.StaffKey, SchoolYear)  AS StaffSchoolYearInstanceKey,
    StaffKey,
    CredentialKey,
    SchoolYear,
    StateOfIssue,
    CredentialField,
    CertificationStatus,
    CASE
    WHEN CertificationExamPassFail = 1 AND
      Attempt = 1 THEN '1st Attempt'
    WHEN CertificationExamPassFail = 1 AND
      Attempt = 2 THEN '2nd Attempt'
    WHEN CertificationExamPassFail = 1 AND
      Attempt = 3 THEN '3rd Attempt'
    WHEN CertificationExamPassFail = 1 AND
      Attempt >= 4 THEN 'More than 3 attempts'
    ELSE 'Unknown'
  END AttemptStatus
  FROM (SELECT
      s.StaffUSI AS StaffKey,
      ssa.SchoolYear,
      c.CredentialIdentifier CredentialKey,
      d1.CodeValue AS StateOfIssue,
      d.CodeValue AS CredentialField,
      --COALESCE(d.Description, '') + ' ' + COALESCE(m.Description, '') CertificationAreaName ,
      CASE
    WHEN c.IssuanceDate IS NOT NULL THEN 'Certified'
    WHEN n.CertificationExamDate IS NOT NULL AND
        c.IssuanceDate IS NULL THEN 'In Progress'
    WHEN n.CertificationExamDate IS NULL AND
        c.IssuanceDate IS NULL THEN 'Not Attempted'
  END CertificationStatus,
      CertificationExamPassFail,
      ROW_NUMBER() OVER (PARTITION BY tc.TeacherCandidateIdentifier,
  n.CertificationExamTitle ORDER BY n.CertificationExamDate ASC) Attempt
    FROM tpdm.TeacherCandidate tc
      INNER JOIN tpdm.StaffTeacherCandidateAssociation stca ON tc.TeacherCandidateIdentifier = stca.TeacherCandidateIdentifier
      INNER JOIN edfi.Staff s ON stca.StaffUSI = s.StaffUSI
      INNER JOIN edfi.StaffSchoolAssociation ssa ON s.StaffUSI = ssa.StaffUSI
      INNER JOIN edfi.StaffCredential sc
      ON s.StaffUSI = sc.StaffUSI
      INNER JOIN edfi.Credential c
      ON sc.CredentialIdentifier = c.CredentialIdentifier
        AND sc.StateOfIssueStateAbbreviationDescriptorId = c.StateOfIssueStateAbbreviationDescriptorId
      INNER JOIN edfi.CredentialFieldDescriptor cfd
      ON c.CredentialFieldDescriptorId = cfd.CredentialFieldDescriptorId
      INNER JOIN edfi.Descriptor d
      ON cfd.CredentialFieldDescriptorId = d.DescriptorId
      INNER JOIN edfi.StateAbbreviationDescriptor sad
      ON c.StateOfIssueStateAbbreviationDescriptorId = sad.StateAbbreviationDescriptorId
      INNER JOIN edfi.Descriptor d1
      ON d1.DescriptorId = c.StateOfIssueStateAbbreviationDescriptorId
      LEFT JOIN edfi.CredentialGradeLevel k
      ON sc.CredentialIdentifier = k.CredentialIdentifier
      LEFT JOIN edfi.Descriptor m
      ON k.GradeLevelDescriptorId = m.DescriptorId
      LEFT JOIN tpdm.CredentialCertificationExam n
      ON sc.CredentialIdentifier = n.CredentialIdentifier) a
GO


