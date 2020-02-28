CREATE   VIEW [analytics].[StaffCredential]
AS
  SELECT analytics.EntitySchoolYearInstanceSetKey(s.StaffUSI,CurrentSchoolYear.SchoolYear) StaffSchoolYearInstanceKey,
    analytics.EntitySchoolYearInstanceSetKey(c.CredentialIdentifier,CurrentSchoolYear.SchoolYear) CredentialSchoolYearInstanceKey,
    CurrentSchoolYear.SchoolYear AS SchoolYear,
    s.StaffUSI AS StaffKey,
    c.CredentialIdentifier CredentialKey,
    d1.CodeValue AS StateOfIssue,
    d.CodeValue AS CredentialField
  FROM edfi.Staff s
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
CROSS APPLY
  (  
       SELECT syt.SchoolYear
    FROM edfi.SchoolYearType syt
    WHERE syt.CurrentSchoolYear = 1
  ) CurrentSchoolYear


GO



