# Release post-deployment scripts

One file per release, named after the release (e.g. `17_16.sql`). This folder is the
history of post-deployment scripts; files are never compiled as schema objects.

## How a script gets deployed

1. Add `Scripts/Post/<release>.sql` here through a normal PR to `main`.
2. Run the **epr-data-sqldb-build** pipeline (defined in the epr-data-pipelines repo;
   it always builds this repo's `main`) with `postDeployScript = <release>.sql`.
   The build copies that file over `Scripts/Script.PostDeployment.sql` (on the build
   agent only) and compiles it into the dacpac. The run is tagged `post-<release>.sql`.
3. Deploy that build with the **epr-data-sqldb-release** pipeline. The script runs
   automatically after the schema deployment in every environment the dacpac goes to.

Builds run with `postDeployScript` left blank contain no post-deployment script.

## Rules for scripts

- **Make them safe to re-run.** The script runs on every deployment of that dacpac,
  including re-deployments and re-running a release stage. Guard statements, e.g.
  `IF OBJECT_ID('dbo.MyTable', 'U') IS NOT NULL DROP TABLE dbo.MyTable;`.
- **One script per build.** If an environment skips a release, that release's script
  will not run there unless a later script also covers it.
- **Environment-specific logic** must be guarded inside the script, e.g.
  `IF DB_NAME() IN ('preepdsp1401', 'preepdsp2401') BEGIN ... END`.
- **Scripts run on the Synapse dedicated SQL pool**, so only T-SQL supported there
  works - e.g. no `@@ROWCOUNT`. Test unfamiliar statements against TST first.
- **Report progress with `PRINT`.** SqlPackage doesn't show result sets or
  "(n rows affected)" in the deployment log, but it does show `PRINT` messages.
- `GO` batch separators are allowed.
- Do not edit `Scripts/Script.PostDeployment.sql`; it is a placeholder.
