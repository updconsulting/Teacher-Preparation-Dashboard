# Installing the Ed-Fi Analytics Middle Tier

* [Migration Utility](#migration-utility)
* [Execution Instructions](#execution-instructions)
  * [Download Binaries](#download-binaries)
  * [Run](#run)
  * [Options](#options)
* [Next Steps](#next-steps)
  * [Managing Database User Roles](#managing-database-user-roles)
  * [Managing Staff Authorization Scope](#managing-staff-authorization-scope)
    * [View Existing Mappings](#view-existing-mappings)
    * [Insert a New Mapping](#insert-a-new-mapping)
    * [Remove a Mapping](#remove-a-mapping)

*[Back to main readme](../readme.md)*

## Migration Utility

The views, indexes, and tables are packaged into an executable migration
utility, which was created in order to facilitate deployment automation. The
utility uses [DbUp](https://dbup.readthedocs.io) to manage database
_transitions_: each script in the project is treated as a transition from one
state to another. Scripts run sequentially (natural sort order), and they only
run once. The framework creates table `dbo.AnalyticsMiddleTierSchemaVersion` to
track which scripts have been run once and do not need to run again. This is the
only object installed into the `dbo` schema. Other objects are placed in a new
`analytics` schema for easy identification in an object explorer.

Because each script builds on the prior scripts, this framework is not developed
for supporting uninstall processes. A custom [uninstall](#uninstall) process was
added, which deletes nearly all objects in the `analytics` schema. There are
some exceptions: tables `analytics_config.AuthorizationScope` and
`analytics_config.StaffClassificationDescriptorScope`, and security role
`analytics_middle_tier`. Generally, users will not need to run the install. The
functionality is provided primarily for support when testing modifications to
the solution. If any customization has been done for the staff classification to
scope mapping, then dropping these tables would be rather tedious. Likewise for
the security role.

Indexes do not have their own schema - they are all installed directly on tables
they modify. As such the uninstall cannot issue a blanket SQL statement to drop
all indexes. Instead it needs to know which indexes, if any, have been
installed. To support their uninstallation, each index is listed in an
additional custom tracking table, `analytics_config.IndexJournal`.

The installation uses transaction management so that if part of the install
fails, then the entire install should be rolled back.

## Execution Instructions

### Download Binaries

[Releases](https://github.com/Ed-Fi-Alliance/Analytics-Middle-Tier/releases)
are available in several flavors:

* Raw source code (see build instructions below)
* `EdFi.AnalyticsMiddleTier.zip` (approx 2 MB) is a .NET Core
  framework-dependent deployment, meaning that you must have the [.NET Core 2.1
  SDK and Runtime](https://www.microsoft.com/net/download) installed on the
  system on which you wish to run the application.
* `EdFi.AnalyticsMiddleTier-win10.x64.zip` (approx 30 MB) is a self-contained
  deployment, meaning that you can run it without downloading and installing
  .NET Core 2.1.

Choose an appropriate version, download, and unzip the files.

### Run

The framework-dependent download (smaller) contains a DLL instead of an EXE. Run
it using the `dotnet` command with appropriate [options](#options). When running
this way, you must use the "long flag" options instead of the "short flag"
variants. For example, to install all views and indexes in the `EdFi_Glendale`
database on the localhost, open a command line and change to the unzipped
directory, and then run:

```powershell
dotnet EdFi.AnalyticsMiddleTier.Console.dll --connectionString "Server=.;Database=EdFi_Glendale;Trusted_connection=true" --includeIndexes --includeViews
```

If you have downloaded the self-contained EXE, then run the following command:

```powershell
.\EdFi.AnalyticsMiddleTier.Console.exe --connectionString "Server=.;Database=EdFi_Glendale;Trusted_connection=true" --includeIndexes --includeViews
```

or

```powershell
.\EdFi.AnalyticsMiddleTier.Console.exe -c "Server=.;Database=EdFi_Glendale;Trusted_connection=true" -i -v
```

### Options

| Short Flag | Long Flag | Description |
| ---------- | --------- | ----------- |
| -c | --connectionString | Full connection string for the SQL server database on which to install the solution. |
| -i | --includeIndexes | Default: false. Install optional indexes for improved query performance, at the possible expense of degraded insert/update performance. |
| -v | --includeViews | Default: true. Install the views and supporting tables. Only set this to false if trying to install indexes without installing views. |
| -u | --uninstall | Default: false. Removes all views and indexes, leaving in place the tables `AuthorizationScope` and `StaffClassificationDescriptorScope` and role `analytics_middle_tier` |

## Next Steps

### Managing Database User Roles

If all goes well, then all views will be installed successfully. A new security
role, `analytics_middle_tier`, will have been created. Users in this role will
have select permission on all views in the `analytics` schema, but not on the
new tables, which are in the `analytics_config` schema. The system administrator
will need to assign user(s) to this role as appropriate. This can be done by
issuing a command like:

```sql
ALTER ROLE [analytics_middle_tier] ADD MEMBER [someUserName]
```

### Managing Staff Authorization Scope

In addition, staff classification-to-scope mappings need to be setup. These
mappings are critical for setting up proper row-level security, authorizing
users to view only the students appropriate to that user's job. Initially, the
following assignments are made in
`analytics_config.StaffClassificationDescriptorScope`:

| AuthorizationScopeName | CodeValue |
| ---------------------- | --------- |
| Section | Teacher |
| Section | Substitute Teacher |
| School | Principal |
| District | Superintendent |

A series of stored procedures are provided to help manage these mappings.

#### View Existing Mappings

```sql
exec [analytics_config].[ViewStaffClassificationDescriptorScope]
```

#### Insert a New Mapping

```sql
exec [analytics_config].[InsertStaffClassificationDescriptorScope] (@StaffDescriptor = 'Counselor', @Scope = 'Section')

-- alternate, using Id values
exec [analytics_config].[InsertStaffClassificationDescriptorScope] (@StaffDescriptorId = 154, @ScopeId = 1)
```

If invalid values are provided as parameters, the stored procedure will return a
list of valid options.

#### Remove a Mapping

```sql
exec [analytics_config].[RemoveStaffClassificationDescriptorScope] (@StaffDescriptor = 'Counselor', @Scope = 'Section')

-- alternate, using Id values
exec [analytics_config].[RemoveStaffClassificationDescriptorScope] (@StaffDescriptorId = 154, @ScopeId = 1)
```
