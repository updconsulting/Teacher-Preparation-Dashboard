CREATE VIEW [analytics].[UserDimension]
AS
SELECT [Staff].[StaffUSI] AS [UserKey],
       [StaffElectronicMail].ElectronicMailAddress AS [UserEmail],
       (
           SELECT MAX([LastModifiedDate])
           FROM
           (
               VALUES
                   ([Staff].[LastModifiedDate]),
                   -- [StaffElectronicMail] does not have a [LastModifiedDate]
                   ([StaffElectronicMail].[CreateDate]),
                   ([Descriptor].[LastModifiedDate])
           ) AS value ([LastModifiedDate])
       ) AS [LastModifiedDate],
       CodeValue
FROM [edfi].[Staff]
    INNER JOIN [edfi].[StaffElectronicMail]
        ON [Staff].[StaffUSI] = [StaffElectronicMail].StaffUSI
    INNER JOIN [edfi].[Descriptor]
        ON [StaffElectronicMail].[ElectronicMailTypeDescriptorId] = [Descriptor].[DescriptorId]
WHERE [Descriptor].[CodeValue] = 'Organization';
GO
