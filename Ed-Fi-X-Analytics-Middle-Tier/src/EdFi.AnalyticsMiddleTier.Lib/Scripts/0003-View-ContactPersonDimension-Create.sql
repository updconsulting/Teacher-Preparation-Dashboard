CREATE VIEW [analytics].[ContactPersonDimension]
AS
WITH [ParentAddress]
AS (
   SELECT [ParentAddress].[ParentUSI],
          ISNULL([ParentAddress].[StreetNumberName], '')
          + COALESCE(', ' + [ParentAddress].[ApartmentRoomSuiteNumber], '')
          + COALESCE(', ' + [ParentAddress].[City], '') + COALESCE(' ' + [sad].[CodeValue], '')
          + COALESCE(' ' + [ParentAddress].[PostalCode], '') AS [Address],
          pad.[CodeValue] AS [AddressType],
          [ParentAddress].[CreateDate] AS [LastModifiedDate]
   FROM [edfi].[ParentAddress]
       INNER JOIN [edfi].[Descriptor] pad
           ON [ParentAddress].[AddressTypeDescriptorId] = pad.[DescriptorId]
       INNER JOIN [edfi].[Descriptor] sad
           ON [ParentAddress].[StateAbbreviationDescriptorId] = sad.[DescriptorId]),
     [ParentTelephone]
AS (SELECT [ParentTelephone].[ParentUSI],
           [ParentTelephone].[TelephoneNumber],
           ttd.[CodeValue] AS [TelephoneNumberType],
           [ParentTelephone].[CreateDate]
    FROM [edfi].[ParentTelephone]
        INNER JOIN [edfi].[Descriptor] ttd
            ON [ParentTelephone].TelephoneNumberTypeDescriptorId = ttd.DescriptorId),
     [ParentEmail]
AS (SELECT [ParentElectronicMail].[ParentUSI],
           [ParentElectronicMail].[ElectronicMailAddress],
           [ParentElectronicMail].[PrimaryEmailAddressIndicator],
           [HomeEmailType].[CodeValue] AS [EmailType],
           [ParentElectronicMail].[CreateDate]
    FROM [edfi].[ParentElectronicMail]
        LEFT OUTER JOIN [edfi].[Descriptor] AS [HomeEmailType]
            ON [ParentElectronicMail].[ElectronicMailTypeDescriptorId] = [HomeEmailType].[DescriptorId])
SELECT [Parent].[ParentUSI] AS [ContactPersonKey],
       [StudentParentAssociation].[StudentUSI] AS [StudentKey],
       [Parent].[FirstName] AS [ContactFirstName],
       [Parent].[LastSurname] AS [ContactLastName],
       [RD].[CodeValue] AS [RelationshipToStudent],
       ISNULL([HomeAddress].[Address], '') AS [ContactHomeAddress],
       ISNULL([PhysicalAddress].[Address], '') AS [ContactPhysicalAddress],
       ISNULL([MailingAddress].[Address], '') AS [ContactMailingAddress],
       ISNULL([WorkAddress].[Address], '') AS [ContactWorkAddress],
       ISNULL([TemporaryAddress].[Address], '') AS [ContactTemporaryAddress],
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
       ISNULL([StudentParentAssociation].[PrimaryContactStatus], 0) AS [IsPrimaryContact],
       ISNULL([StudentParentAssociation].[LivesWith], 0) AS [StudentLivesWith],
       ISNULL([StudentParentAssociation].[EmergencyContactStatus], 0) AS [IsEmergencyContact],
       ISNULL([StudentParentAssociation].[ContactPriority], 0) AS [ContactPriority],
       ISNULL([StudentParentAssociation].[ContactRestrictions], '') AS [ContactRestrictions],
       (
           SELECT MAX([LastModifiedDate])
           FROM
           (
               VALUES
                   ([StudentParentAssociation].[LastModifiedDate]),
                   ([Parent].[LastModifiedDate]),
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
FROM [edfi].[StudentParentAssociation]
    INNER JOIN [edfi].[Parent]
        ON [StudentParentAssociation].[ParentUSI] = [Parent].[ParentUSI]
    INNER JOIN [edfi].[Descriptor] RD
        ON [StudentParentAssociation].[RelationDescriptorId] = RD.DescriptorId
    LEFT OUTER JOIN [ParentAddress] AS [HomeAddress]
        ON [Parent].[ParentUSI] = [HomeAddress].[ParentUSI]
           AND [HomeAddress].[AddressType] = 'Home'
    LEFT OUTER JOIN [ParentAddress] AS [PhysicalAddress]
        ON [Parent].[ParentUSI] = [PhysicalAddress].[ParentUSI]
           AND [HomeAddress].[AddressType] = 'Physical'
    LEFT OUTER JOIN [ParentAddress] AS [MailingAddress]
        ON [Parent].[ParentUSI] = [MailingAddress].[ParentUSI]
           AND [HomeAddress].[AddressType] = 'Mailing'
    LEFT OUTER JOIN [ParentAddress] AS [WorkAddress]
        ON [Parent].[ParentUSI] = [WorkAddress].[ParentUSI]
           AND [HomeAddress].[AddressType] = 'Work'
    LEFT OUTER JOIN [ParentAddress] AS [TemporaryAddress]
        ON [Parent].[ParentUSI] = [TemporaryAddress].[ParentUSI]
           AND [HomeAddress].[AddressType] = 'Temporary'
    LEFT OUTER JOIN [ParentTelephone] AS [HomeTelephone]
        ON [Parent].[ParentUSI] = [HomeTelephone].[ParentUSI]
           AND [HomeTelephone].[TelephoneNumberType] = 'Home'
    LEFT OUTER JOIN [ParentTelephone] AS [MobileTelephone]
        ON [Parent].[ParentUSI] = [MobileTelephone].[ParentUSI]
           AND [MobileTelephone].[TelephoneNumberType] = 'Mobile'
    LEFT OUTER JOIN [ParentTelephone] AS [WorkTelephone]
        ON [Parent].[ParentUSI] = [WorkTelephone].[ParentUSI]
           AND [WorkTelephone].[TelephoneNumberType] = 'Work'
    LEFT OUTER JOIN [ParentEmail] AS [HomeEmail]
        ON [Parent].[ParentUSI] = [HomeEmail].[ParentUSI]
           AND [HomeEmail].[EmailType] = 'Home/Personal'
    LEFT OUTER JOIN [ParentEmail] AS [WorkEmail]
        ON [Parent].[ParentUSI] = [WorkEmail].[ParentUSI]
           AND [WorkEmail].[EmailType] = 'Work';
GO


