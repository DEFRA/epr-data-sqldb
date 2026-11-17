/*
 Post-deployment script placeholder - DO NOT EDIT.

 The epr-data-sqldb build pipeline replaces this file at build time with the
 release script chosen in its 'postDeployScript' parameter (a file name from
 Scripts/Post/, e.g. 17_16.sql). That script is compiled into the dacpac and
 runs automatically after every deployment of that dacpac.

 When no script is chosen, this placeholder is compiled in and does nothing.

 To add a release script: add Scripts/Post/<release>.sql via a PR, then queue
 the build with postDeployScript = <release>.sql. See Scripts/Post/README.md.
*/
PRINT 'No post-deployment script in this build.';
