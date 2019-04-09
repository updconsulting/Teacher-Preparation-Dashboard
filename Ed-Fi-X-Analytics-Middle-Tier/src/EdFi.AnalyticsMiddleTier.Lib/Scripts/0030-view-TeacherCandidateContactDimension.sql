
CREATE VIEW [analytics].[TeacherCandidateContactDimension]
AS
WITH [TeacherCandidateAddress]
AS (
   SELECT [TeacherCandidateAddress].TeacherCandidateIdentifier,
          ISNULL([TeacherCandidateAddress].[StreetNumberName], '')
          + COALESCE(', ' + [TeacherCandidateAddress].[ApartmentRoomSuiteNumber], '')
          + COALESCE(', ' + [TeacherCandidateAddress].[City], '') + COALESCE(' ' + [sad].[CodeValue], '')
          + COALESCE(' ' + [TeacherCandidateAddress].[PostalCode], '') AS [Address],
          pad.[CodeValue] AS [AddressType],
          [TeacherCandidateAddress].[CreateDate] AS [LastModifiedDate]
   FROM [tpdm].[TeacherCandidateAddress]
       INNER JOIN [edfi].[Descriptor] pad
           ON [TeacherCandidateAddress].[AddressTypeDescriptorId] = pad.[DescriptorId]
       INNER JOIN [edfi].[Descriptor] sad
           ON [TeacherCandidateAddress].[StateAbbreviationDescriptorId] = sad.[DescriptorId]),
     [ParentTelephone]
AS (SELECT [TeacherCandidateTelephone].TeacherCandidateIdentifier,
           [TeacherCandidateTelephone].[TelephoneNumber],
           ttd.[CodeValue] AS [TelephoneNumberType],
           [TeacherCandidateTelephone].[CreateDate]
    FROM [tpdm].[TeacherCandidateTelephone]
        INNER JOIN [edfi].[Descriptor] ttd
            ON [TeacherCandidateTelephone].TelephoneNumberTypeDescriptorId = ttd.DescriptorId),
     [ParentEmail]
AS (SELECT [TeacherCandidateElectronicMail].[TeacherCandidateIdentifier],
           [TeacherCandidateElectronicMail].[ElectronicMailAddress],
           [TeacherCandidateElectronicMail].[PrimaryEmailAddressIndicator],
           [HomeEmailType].[CodeValue] AS [EmailType],
           [TeacherCandidateElectronicMail].[CreateDate]
    FROM [tpdm].[TeacherCandidateElectronicMail]
        LEFT OUTER JOIN [edfi].[Descriptor] AS [HomeEmailType]
            ON [TeacherCandidateElectronicMail].[ElectronicMailTypeDescriptorId] = [HomeEmailType].[DescriptorId])
SELECT [TeacherCandidate].[TeacherCandidateIdentifier] AS [TeacherCandidateKey],
       [TeacherCandidate].[StudentUSI] AS [StudentKey],
       [TeacherCandidate].[FirstName] AS [FirstName],
       [TeacherCandidate].[LastSurname] AS [LastName],
   
       ISNULL([HomeAddress].[Address], '') AS [HomeAddress],
       ISNULL([PhysicalAddress].[Address], '') AS [PhysicalAddress],
       ISNULL([MailingAddress].[Address], '') AS [MailingAddress],
       ISNULL([WorkAddress].[Address], '') AS [WorkAddress],
       ISNULL([TemporaryAddress].[Address], '') AS [TemporaryAddress],
       ISNULL([HomeTelephone].[TelephoneNumber], '') AS [HomePhoneNumber],
       ISNULL([MobileTelephone].[TelephoneNumber], '') AS [MobilePhoneNumber],
       ISNULL([WorkTelephone].[TelephoneNumber], '') AS [WorkPhoneNumber],
       CASE
           WHEN [HomeEmail].[PrimaryEmailAddressIndicator] = 1 THEN
               N'Personal'
           WHEN [WorkEmail].[PrimaryEmailAddressIndicator] = 1 THEN
               N'Work'
           ELSE
               N'Not specified'
       END AS [PrimaryEmailAddress],
       ISNULL([HomeEmail].[ElectronicMailAddress], '') AS [PersonalEmailAddress],
       ISNULL([WorkEmail].[ElectronicMailAddress], '') AS [WorkEmailAddress],
 
       (
           SELECT MAX([LastModifiedDate])
           FROM
           (
               VALUES
          
                   ([TeacherCandidate].[LastModifiedDate]),
                   ([HomeAddress].[LastModifiedDate]),
                   ([PhysicalAddress].[LastModifiedDate]),
                   ([MailingAddress].[LastModifiedDate]),
                   ([WorkAddress].[LastModifiedDate]),
                   ([TemporaryAddress].[LastModifiedDate]),
                   ([HomeTelephone].[CreateDate]),
                   ([MobileTelephone].[CreateDate]),
                   ([WorkTelephone].[CreateDate]),
                   ([HomeEmail].[CreateDate]),
                   ([WorkEmail].[CreateDate])
           ) AS value ([LastModifiedDate])
       ) AS [LastModifiedDate]
FROM [tpdm].[TeacherCandidate] [TeacherCandidate] 
    LEFT OUTER JOIN [TeacherCandidateAddress] HomeAddress ON [TeacherCandidate].[TeacherCandidateIdentifier] = [HomeAddress].[TeacherCandidateIdentifier] 
           AND [HomeAddress].[AddressType] = 'Home'
    LEFT OUTER JOIN [TeacherCandidateAddress] AS [PhysicalAddress]
        ON [TeacherCandidate].[TeacherCandidateIdentifier] = [PhysicalAddress].[TeacherCandidateIdentifier]
           AND [HomeAddress].[AddressType] = 'Physical'
    LEFT OUTER JOIN [TeacherCandidateAddress] AS [MailingAddress]
        ON [TeacherCandidate].[TeacherCandidateIdentifier] = [MailingAddress].[TeacherCandidateIdentifier]
           AND [HomeAddress].[AddressType] = 'Mailing'
    LEFT OUTER JOIN [TeacherCandidateAddress] AS [WorkAddress]
        ON [TeacherCandidate].[TeacherCandidateIdentifier] = [WorkAddress].[TeacherCandidateIdentifier]
           AND [HomeAddress].[AddressType] = 'Work'
    LEFT OUTER JOIN [TeacherCandidateAddress] AS [TemporaryAddress]
        ON [TeacherCandidate].[TeacherCandidateIdentifier] = [TemporaryAddress].[TeacherCandidateIdentifier]
           AND [HomeAddress].[AddressType] = 'Temporary'
    LEFT OUTER JOIN [ParentTelephone] AS [HomeTelephone]
        ON [TeacherCandidate].[TeacherCandidateIdentifier] = [HomeTelephone].[TeacherCandidateIdentifier]
           AND [HomeTelephone].[TelephoneNumberType] = 'Home'
    LEFT OUTER JOIN [ParentTelephone] AS [MobileTelephone]
        ON [TeacherCandidate].[TeacherCandidateIdentifier] = [MobileTelephone].[TeacherCandidateIdentifier]
           AND [MobileTelephone].[TelephoneNumberType] = 'Mobile'
    LEFT OUTER JOIN [ParentTelephone] AS [WorkTelephone]
        ON [TeacherCandidate].[TeacherCandidateIdentifier] = [WorkTelephone].[TeacherCandidateIdentifier]
           AND [WorkTelephone].[TelephoneNumberType] = 'Work'
    LEFT OUTER JOIN [ParentEmail] AS [HomeEmail]
        ON [TeacherCandidate].[TeacherCandidateIdentifier] = [HomeEmail].[TeacherCandidateIdentifier]
           AND [HomeEmail].[EmailType] = 'Home/Personal'
    LEFT OUTER JOIN [ParentEmail] AS [WorkEmail]
        ON [TeacherCandidate].[TeacherCandidateIdentifier] = [WorkEmail].[TeacherCandidateIdentifier]
           AND [WorkEmail].[EmailType] = 'Work';
GO


