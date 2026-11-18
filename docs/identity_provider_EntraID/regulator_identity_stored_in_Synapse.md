# Regulator identity stored in Synapse

Regulators' ticket -\> [AMCR-578](https://eaflood.atlassian.net/browse/AMCR-578)

Data Team’s ticket → [EMR-676](https://eaflood.atlassian.net/browse/EMR-676)

| **DB object containing / referencing RegulatorUserId guids** | **Submit Team** | **Regulator Team** | **PowerBI** | **Master Script** | **Matt Cooper’s extract** | **Synapse Notebooks** | **Other Teams?** |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `rpd.SubmissionEvents.RegulatorUserId` (ATM all empty in PRD) | NA | Used on portal - wont be migrated | Used in  1. v\_CrossValidation\_Landing\_Page via v\_submitted\_pom\_org\_file\_status, a datasource for Cross Validation Landing Page 2. v\_get\_orgfile\_submitted\_year\_nation via v\_latest\_pending\_or\_accepted\_orgfile\_by\_year, v\_submitted\_pom\_org\_file\_status and  v\_latest\_accepted\_orgfile\_by\_year, a datasource for Joiners and Leavers Landing Page | NA | NA | `cosmos_ingestion` `get_rpd_files` `get_rpd_files_no_split` `paycal2_org_data` |  |
| `apps.sp_FilterAndPaginateRegistrationsSummaries @RegulatorUserId` | NA | Used on portal - wont be migrated |  | NA | NA | NA |  |
| `apps.sp_FilterAndPaginateSubmissionsSummaries @RegulatorUserId` | NA | Used on portal - wont be migrated |  | NA | NA | NA |  |
| `apps.sp_FilterAndPaginateSubmissionsSummaries_resub @RegulatorUserId` | NA | Used on portal - wont be migrated |  | NA | NA | NA |  |
| `apps.sp_MergeSubmissionsSummaries.RegulatorUserId` | NA | NA |  | NA | NA | `recyclers` |  |
| `apps.OrgRegistrationsSummaries.RegulatorUserId` | NA | NA |  |  | NA (joins on `sub_id`) | NA |  |
| `apps.v_OrganisationRegistrationSummaries.RegulatorUserId` | NA | NA |  | NA | NA | NA (`performance_test`) |  |
| `dbo.sp_FetchOrganisationRegistrationSubmissionDetails.RegulatorUserId` | NA | NA |  | NA | NA | NA (`performance_test`) |  |
| `dbo.sp_FetchOrganisationRegistrationSubmissionDetails_resub.RegulatorUserId` | NA | NA  (not `UserId` / `RegulatorUserId`) |  | NA | NA | NA (`performance_test`) |  |
| `dbo.sp_OrganisationRegistrationSummaries.RegulatorUserId` | NA | NA |  | NA | NA | NA |  |
| `dbo.sp_OrganisationRegistrationSummaries_resub.RegulatorUserId` | NA | NA |  | NA | NA | NA |  |
| `dbo.v_FetchOrganisationRegistrationSubmissionDetails_resub.RegulatorUserId` | NA | NA |  | NA | NA | NA |  |
| `dbo.t_FetchOrganisationRegistrationSubmissionDetails_resub.RegulatorUserId` | NA | NA |  | NA | NA | NA |  |

| **DB object containing / referencing UserId guids** | **Submit Team** | **Regulator Team** | **PowerBI** | **Master Script** | **Matt Cooper’s extract** | **Synapse Notebooks** | **Other Teams?** |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `rpd.Users.UserId` | Yes, indirectly. It is used in joins when generating data for the `apps.SubmissionsSummaries` table | Used in old portal wont be used going forward | Used in  1. v\_CrossValidation\_Landing\_Page via v\_submitted\_pom\_org\_file\_status, a datasource for Cross Validation Landing Page 2. v\_get\_orgfile\_submitted\_year\_nation via v\_latest\_pending\_or\_accepted\_orgfile\_by\_year, v\_submitted\_pom\_org\_file\_status and  v\_latest\_accepted\_orgfile\_by\_year, a datasource for Joiners and Leavers Landing Page | submitter\_emailsubmitted\_file\_details.sql |  | `enrolment` |  |
| `rpd.SubmissionEvents.UserId` | Yes, indirectly. It is used in joins when generating data for the `apps.SubmissionsSummaries` table | UserId not used | Used in  1. v\_CrossValidation\_Landing\_Page via v\_submitted\_pom\_org\_file\_status, a datasource for Cross Validation Landing Page 2. v\_get\_orgfile\_submitted\_year\_nation via v\_latest\_pending\_or\_accepted\_orgfile\_by\_year, v\_submitted\_pom\_org\_file\_status and  v\_latest\_accepted\_orgfile\_by\_year, a datasource for Joiners and Leavers Landing Page | submitter\_emailsubmitted\_file\_details.sql |  | `cosmos_ingestion` `get_rpd_files` `get_rpd_files_no_split` `paycal2_org_data` |  |
| `apps.v_SubmissionsSummaries.UserId` | NA | NA - field not used |  | recyclers notebook | NA | NA |  |
| `apps.SubmissionsSummaries.UserId` | NA - field not used (Submit reads other columns: resubmission fee details, actual submission period) | NA - field not used |  | recyclers notebook | NA (joins on `sub_id`) | NA |  |
| `apps.v_RegistrationsSummaries.UserId` | NA | NA - field not used |  | NA | NA | NA |  |
| `apps.RegistrationsSummaries.UserId` | NA | NA - field not used |  | NA | NA | NA |  |
| `apps.sp_FilterAndPaginateRegistrationsSummaries.UserId` | NA | NA |  | NA | NA | NA |  |
| `apps.sp_FilterAndPaginateSubmissionsSummaries.UserId` | NA | Bug currently, we are not passing the right id, should be regulator |  | NA | NA | NA |  |
| `apps.sp_FilterAndPaginateSubmissionsSummaries_resub.UserId` | NA | NA - field not used |  | NA | NA | NA |  |
| `apps.sp_MergeSubmissionsSummaries` | Yes**.** It populates most of what epr-pom-api-web’s endpoints read | NA - field not used |  | recyclers notebook | NA | `recyclers` |  |
| `apps.OrgRegistrationsSummaries` | NA | NA - field not used |  | recyclers notebook | NA | NA |  |
| `apps.SubmissionEvents` | Yes, if affects several endpoints used by epr-pom-api-web | NA - field not used - only gets last synced date |  | NA | NA (joins on `sub_id`) | NA |  |
| `apps.v_OrganisationRegistrationSummaries` | NA | NA |  | NA | NA | NA |  |
| `dbo.sp_FetchOrganisationRegistrationSubmissionDetails` | NA | NA |  | NA | NA | NA |  |
| `dbo.sp_FetchOrganisationRegistrationSubmissionDetails_resub` | NA | NA |  | NA | NA | NA (`performance_test`) |  |
| `dbo.sp_FilterAndPaginateOrganisationRegistrationSummaries` | NA | NA |  | NA | NA | NA |  |
| `dbo.sp_OrganisationRegistrationSummaries` | NA | NA |  | NA | NA | NA |  |
| `dbo.sp_OrganisationRegistrationSummaries_resub` | NA | NA |  | NA | NA | NA |  |
| `dbo.V_FetchOrganisationRegistrationSubmissionDetails_resub` | NA | NA |  | NA | NA | NA |  |
| `rpd.cosmos_file_metadata.UserId` | NA - field not used (only check a file has synced) | NA | Used in  1. v\_Compliance\_Report, a datasource for Compliance Report 2. v\_CrossValidation\_Landing\_Page directly and via v\_submitted\_pom\_org\_file\_status a datasource for Cross Validation Landing Page 3. v\_PRN\_Details and v\_PRN\_Obligations a data source for PRN Detail and Obligations Report 4. v\_get\_orgfile\_submitted\_year\_nation via v\_latest\_pending\_or\_accepted\_orgfile\_by\_year, v\_submitted\_pom\_org\_file\_status and  v\_latest\_accepted\_orgfile\_by\_year, a datasource for Joiners and Leavers Landing Page | NA | NA | `get_rpd_files` `get_rpd_files_no_split` `process_rpd_files` `producer_obligation_determination` |  |
| `dbo.v_cosmos_file_metadata.UserId` | NA | NA |  | NA | NA | NA |  |
| `dbo.t_cosmos_file_metadata.UserId` | NA | NA | Used in v\_Compliance\_Report which is a data source for Compliance Report | NA | NA | NA |  |
| `dbo.v_cosmos_file_metadata_CS_additions.UserId` | NA | NA |  | NA | NA | NA |  |
| `rpd.files_only_processed.UserId` | NA | NA |  | NA | NA | NA |  |
| `dbo.v_submitted_pom_org_file_status_ar.UserId` | NA | NA |  | NA | NA | NA |  |
| `rpd.AuditLogs.UserId` | NA | Used to derive the name of person who |  | NA | NA | NA (`debug`) |  |
| `rpd.Submissions.UserId` | Not read. Submit writes the submitter UserId (Submission Status API) | NA | Used in  1. v\_CrossValidation\_Landing\_Page via v\_submitted\_pom\_org\_file\_status, a datasource for Cross Validation Landing Page 2. v\_get\_orgfile\_submitted\_year\_nation via v\_latest\_pending\_or\_accepted\_orgfile\_by\_year, v\_submitted\_pom\_org\_file\_status and  v\_latest\_accepted\_orgfile\_by\_year, a datasource for Joiners and Leavers Landing Page | NA | NA (not using `userid`) | `cosmos_ingestion` `get_rpd_files` `get_rpd_files_no_split` `move_files_from_apps_to_dw` `recyclers` |  |
| `apps.Submissions.UserId` | NA | NA |  | NA | NA | NA |  |
| `dbo.v_submitted_pom_org_file_status` `Regulator_User_Name` & `UserId` | NA | NA | Used in v\_CrossValidation\_Landing\_Page  (Cross Validation Landing Page | NA | NA | `paycal2_org_data` `pip_paycal2_ingest_org_data` |  |
| `dbo.t_submitted_pom_org_file_status` `Regulator_User_Name` & `UserId` | NA | NA | Used in v\_Compliance\_Report which is a data source for Compliance Report | NA | NA | NA |  |
| `dbo.v_Submitter_Name.Submitter` `UserId` & `SubmitterId` | NA | NA |  | NA | NA | NA |  |
| `dbo.v_enrolment_history.UserId` | NA | NA |  | NA | NA | NA |  |
| `dbo.v_PersonOrganisationConnections.Users_UserId` | NA | NA |  | NA | NA | NA |  |
| `rpd.error_files_not_processed.UserId` | NA | NA |  | NA | NA | `process_rpd_files` |  |

| **Other objects** | **Submit Team** | **Regulator Team** | **PowerBI** | **Master Script** | **Matt Cooper’s extract** | **Synapse Notebooks** | **Other Teams?** |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `dbo.v_Enrolmentstatus.Regulator_User_name` | NA | NA |  | NA | NA | NA |  |
| `get_rpd_files`  uses `rpd.SubmissionEvents`.`UserId` for grouping in `df_pom` | NA | NA |  | NA | NA | `get_rpd_files` |  |
| dbo.t\_POM\_All\_Submissions.Regulator\_User\_Name |  |  | Data source for PowerBI Reports (Audit Data form, Midyear Registrations and Packaging Report and Packaging Supplied Report) |  |  |  |  |
| dbo.t\_Registration\_Comparison\_Landing\_Page.Regulator\_Status |  |  | Data source for PowerBIReport (Cross Validation Landing Page and Registration Comparison\_Landing Page) |  |  |  |  |
| dbo.t\_CV\_Static\_ComplianceScheme.Pom\_Regulator\_Status |  |  | Used via sp\_CrossValidation\_pom\_org\_files, a data source for Cross Validation Landing Page |  |  |  |  |
| dbo.t\_CV\_Static\_AllProducers.Pom\_Regulator\_Status |  |  | Used via sp\_CrossValidation\_pom\_org\_files, a data source for Cross Validation Landing Page |  |  |  |  |
| dbo.t\_new\_enrolment\_report.Regulator\_User\_Name |  |  | Data source for Enrolment Report |  |  |  |  |
| dbo.t\_BrndPrtnr\_Registrations.Regulator\_User\_Name |  |  | Data source for 1. Registration Report 2. Midyear Registrations and Packaging Report |  |  |  |  |
| dbo.t\_registration\_enrolled\_not\_registered.Regulator\_Rejection\_Comments |  |  | Data source for 1. Registration Report 2. Midyear Registrations and Packaging Report |  |  |  |  |
| dbo.t\_BrndPrtnr\_Org\_Submissions.Regulator\_User\_Name |  |  | Data source for 1. Organisation Details Report |  |  |  |  |
| dbo.t\_organisation\_details\_not\_submitted.Regulator\_Rejection\_Comments |  |  | Data source for 1. Organisation Details Report |  |  |  |  |
| dbo.t\_POM\_Com\_Landing\_Filter.Rejection\_Status |  |  | Data source for  1. Packaging Supplied Comparison |  |  |  |  |
| dbo.t\_POM\_Submissions\_POM\_Comparison.Regulator\_Status |  |  | Data source for  1. Packaging Supplied Comparison via POM\_Comparison\_members, POM\_Comparison\_DRILL and POM\_Comparison\_ARROW\_LOGIC |  |  |  |  |
| dbo.t\_rpd\_data\_SECURITY\_FIX.Regulator\_User\_Name |  |  | Data source for  1. Registration Comparison\_Landing Page |  |  |  |  |
| dbo.t\_CompanyBrandPartnerFileUploadSet.UserId |  |  | Data source for  1. Registration Comparison\_Landing Page via Registration\_Comparison\_Change\_Of\_Member\_and\_Membership |  |  |  |  |
| dbo.t\_latest\_accepted\_orgfile\_by\_year.RegulatorStatus |  |  | Used via sp\_compare\_org\_file, a data source for Joiners and Leavers Landing Page |  |  |  |  |
| dbo.t\_latest\_pending\_or\_accepted\_orgfile\_by\_year.RegulatorStatus |  |  | Used via sp\_compare\_org\_file, a data source for Joiners and Leavers Landing Page |  |  |  |  |
| dbo.`v_rpd_data_SECURITY_FIX.regulator_User_Name` |  |  | Used via t\_POM\_Submissions, a data source for Packaging Supplied Report |  |  |  |  |
