# `rpd.Users.UserId` data lineage

This document maps where the sign-in/user identifier in `rpd.Users.UserId` is copied, matched, retained as an event actor, or exposed by the checked-in Synapse and API definitions. It is a static repository trace, not proof of deployed objects, current pipeline state, or actual Power BI connections.

## End-to-end lineage

```mermaid
flowchart TB
    subgraph Accounts[Accounts and identity]
        IdP["B2C / Entra identity provider"] -. "regulator-specific token-to-account mapping not verified" .-> AccountUser["Accounts Users.UserId"]
        PackagingFrontend["epr-packaging-frontend"] -->|"delegated calls: user-accounts / persons?userId"| PackagingAccountsAPI["Accounts Facade endpoints"]
        PackagingAccountsAPI -->|"user-accounts endpoint mapping verified"| AccountUser
        PackagingAccountsAPI -. "persons endpoints not traced to SQL objects" .-> Person
        AccountUser -->|"internal Users.Id"| Person["Persons.UserId (integer account key)"]
        Person --> Connection["PersonOrganisationConnections"]
        Connection --> Org["Organisations: nation, external ID"]
        Connection --> Enrolment["Enrolments → ServiceRoles"]
    end

    subgraph NotebookLoad["Accounts → Synapse notebook load"]
        Trigger["trg_tumb_rpd_apps_wd"] --> MainPipe["pip_rpd_main_wd → pip_wrapper"]
        MainPipe --> HourGate["UTC-hour condition"]
        HourGate -->|"true branch after preceding activity succeeds"| EnrolPipe["pip_enrolment\nfact load enabled"]
        HourGate -->|"otherwise"| Skip["not run"]
        MasterTrigger["trg_enrolment_master_tbl"] --> MasterPipe["pip_enrolment_master_tbl\nmaster load"]
        Ctrl["External conf/ctrl_table.csv\n(deployed content not checked)" ] -. "table list / load type" .-> EnrolNotebook["notebook/enrolment"]
        EnrolPipe -->|"INCR tables plus Users when configured"| EnrolNotebook
        MasterPipe -->|"FULL tables except Users when configured"| EnrolNotebook
        AccountUser -->|"configured Users source table"| EnrolNotebook
        Connection -->|"other configured Accounts tables"| EnrolNotebook
        EnrolNotebook -->|"Delta write"| Delta["Delta Lake enrolment tables (Users and related tables)"]
        Delta -->|"Spark external tables"| SparkRpd["Spark catalog rpd tables (including Users)"]
        Delta -->|"schema-aligned SQL pool writes"| SqlRpd["Dedicated SQL pool rpd.Users"]
        Delta --> SqlMembership["Dedicated SQL pool rpd.Persons / connections / organisations / enrolments / roles"]
    end

    subgraph LinkPath["Separate configured Synapse Link path"]
        AccountUser -. "whole dbo.Users table; state not verified" .-> Bronze["bronze_accountsdb.Users"]
    end

    subgraph SQLConsumers["SQL identity lookups and derived data"]
        AuthPrincipal["Authenticated API principal"] -. "binding to request UserId not established" .-> Request["Common Data API request-supplied UserId"]
        Request -->|"mapped to @RegulatorUserId"| RegProc["POM / registration summary procedures"]
        RegProc -->|"match Users.UserId; require ServiceId=2"| SqlRpd
        SqlRpd -->|"Users.Id → Persons.UserId"| SqlMembership
        SqlMembership -->|"connection → organisation → service enrolment"| Nation["Resolved organisation NationId"]
        Nation -->|"nation filter"| SummaryTables["apps.SubmissionsSummaries /\napps.RegistrationsSummaries"]
        SummaryTables --> ApiResponse["Summary API response\nsubmitter ID and profile fields"]

        AppSubmittedEvents["apps.SubmissionEvents.UserId\n(submitted event actor)"] --> SummaryViews["apps.v_SubmissionsSummaries /\napps.v_RegistrationsSummaries"]
        SqlRpd -->|"inner joins resolve UserId to person/profile; unmatched rows are omitted"| SummaryViews
        SummaryViews -->|"aggregate / merge"| SummaryTables

        Audit["rpd.AuditLogs.UserId"] --> EnrolStatus["dbo.v_Enrolmentstatus"]
        SqlRpd -->|"match audit UserId; resolve person name"| EnrolStatus

        DecisionEvents["rpd.SubmissionEvents.UserId\n(decision actor)"] -->|"output RegulatorUserId derives from event UserId, not the separate RegulatorUserId column"| OrgRegView["apps.v_OrganisationRegistrationSummaries"]
        RpdSubmissions["rpd.Submissions.UserId\n(submitter)"] --> OrgRegView
        OrgRegView -->|"actor IDs retained, not all resolved to Users"| OrgRegTable["apps.OrgRegistrationsSummaries"]
        OrgRegTable -. "RegistrationJourney join only; not actor-ID source" .-> DetailProc["sp_FetchOrganisationRegistrationSubmissionDetails_resub"]
        DetailView["dbo.V_FetchOrganisationRegistrationSubmissionDetails_resub\n(independent event and user joins)"] --> DetailTable["dbo.t_FetchOrganisationRegistrationSubmissionDetails_resub"]
        DetailTable --> DetailProc
        DetailProc --> DetailApi["Organisation registration detail API"]
    end

    subgraph NotebookAndFiles["Notebook / file outputs"]
        HistoricalEvents["Submission events\n(actor source in earlier inspection)"] -. "historical finding; notebook absent from this checkout" .-> MasterScript["master_script_automation\nnot independently reverified"]
        SqlRpd -. "historical finding: user/person join" .-> MasterScript
        MasterScript -. "earlier inspection found submitter name/email; raw ID not selected" .-> FlatFiles["Submitted-files export\nactual generated file not inspected"]
        SubmittedEvent["Submitted event UserId"] --> GetFiles["notebook/get_rpd_files"]
        AntivirusEvent["Antivirus-result event UserId"] --> GetFilesNoSplit["notebook/get_rpd_files_no_split"]
        GetFiles -->|"groups by submitted-event UserId; writes metadata"| Landing["Delta and SQL pool\nrpd.cosmos_file_metadata"]
        GetFilesNoSplit -->|"groups by antivirus-result UserId; writes metadata"| Landing
    end

    SqlRpd -. "possible reporting consumers; not confirmed" .-> PowerBI["Power BI / external reports\nconnection not established"]
```

**How to read the diagram:** solid arrows show relationships present in checked-in code or definitions. Dotted arrows show a configured but runtime-unverified path or an unconfirmed consumer. `UserId` columns on events, submissions, audit, and file metadata are separately stored actor/submitter values; their names alone do not prove every value is the same kind of identity as `rpd.Users.UserId`.

## Key findings

- **The Synapse notebook copies the configured source value; it does not mint a new user ID.** `notebook/enrolment.json` reads its table list from the external `ctrl_table.csv` (`:363-367, 379-389`), forms a source `SELECT *` from configured schema/table (`:434-465`), writes Delta (`:472-496`), creates Spark-catalog `rpd.<table>` over that Delta location (`:491-496`), then writes to the dedicated pool (`:503-528, 633-652`). An earlier review reported `Users` in the checked-in example `epr-data-sqldb\Delta Lake Files\ctrl_table.csv`, but its contents were not independently reverified in the audit. Check the deployed file to confirm the live source/table and load type.
- **Notebook ingestion has conditional and separate branches.** The `trg_tumb_rpd_apps_wd` → `pip_rpd_main_wd` path runs the wrapper only on the configured UTC-hour branch and after a preceding activity succeeds (`pipeline/pip_rpd_main_wd.json:5-15,43-44,71-90`). `pip_enrolment` enables fact loading; the notebook selects configured `INCR` tables plus `Users` (`pipeline/pip_enrolment.json:22-30`; `notebook/enrolment.json:379-389`). A separate `trg_enrolment_master_tbl` → `pip_enrolment_master_tbl` path loads configured `FULL` tables other than `Users` (`trigger/trg_enrolment_master_tbl.json:5-20`; `pipeline/pip_enrolment_master_tbl.json:22-30`; `notebook/enrolment.json:386-389`). These are checked-in conditions, not live-run evidence, and final table selection depends on the external control file.
- **The SQL pool identity table distinguishes two keys.** `rpd.Users.Id` is an internal integer used by `rpd.Persons.UserId`; `rpd.Users.UserId` is the external identifier (`epr-data-sqldb\rpd\Tables\Users.sql:1-12`; `Persons.sql:1-14`). The checked-in Accounts service code includes a token object-ID lookup path, but that does not establish a regulator-specific sign-in-to-storage mapping or that every account ID comes from that claim (`epr-facade-account-microservice\src\FacadeAccountCreation\FacadeAccountCreation.API\Controllers\UsersController.cs:21`; `epr-backend-account-microservice\src\BackendAccountService.Core\Services\UserService.cs:164`).
- **The second Accounts replication design is independent.** `epr-data-pipelines\linkConnections\config\accountsLinkConnectionTables.json:208-210` configures the whole `dbo.Users` table into `bronze_accountsdb`; it does not list columns or regulator predicates. Its README says link creation leaves the connection stopped until manually started (`linkConnections\README.md:91-95`). This does not establish that it populates `rpd.Users` or is currently running.
- **Regulator summary procedures resolve a supplied ID to nation, but its identity binding is not established here.** The procedures match `@RegulatorUserId` to `rpd.Users.UserId`, follow the internal person/organisation/enrolment chain, require `ServiceRoles.ServiceId = 2`, then filter summaries by the resolved nation. The API accepts a request-supplied `Guid UserId` and maps it to the SQL parameter; the reviewed path does not prove that the value is bound to the authenticated principal. The SQL has no explicit deleted/status predicate and does not handle multiple qualifying memberships deterministically (`sp_FilterAndPaginateSubmissionsSummaries_resub.sql:16-28`).
- **`RegulatorUserId` has more than one meaning in SQL.** In pagination procedures it is an input used to resolve the supplied ID. In registration event/view/table outputs it can be an actor ID carried from a decision event; those output columns are not automatically equivalent to a validated lookup against `rpd.Users.UserId`.
- **The API exposes a request-to-procedure path, not proof of caller authentication binding.** The Common Data API accepts a request `Guid UserId`, maps it to `@RegulatorUserId`, and invokes summary procedures. Its responses include submitter IDs and profile data. Organisation-registration detail actor IDs are read from the detail table populated by its own detail view; the join to `apps.OrgRegistrationsSummaries` supplies `RegistrationJourney`, not the actor IDs.

## SQL object inventory

### Current account identity and membership graph

| Object | Role in lineage |
|---|---|
| `epr-data-sqldb\rpd\Tables\Users.sql:1-12` | Stores the external identifier in `rpd.Users.UserId` separately from internal integer `Id`; includes provider-related and account fields. |
| `epr-data-sqldb\rpd\Tables\Persons.sql:1-14` | `Persons.UserId` points to `Users.Id`, not to `Users.UserId`. |
| `epr-data-sqldb\rpd\Tables\PersonOrganisationConnections.sql:1-14`, `Organisations.sql`, `Enrolments.sql` | Links person to organisation and regulator service enrolments/roles; these links determine the nation used by regulator pagination. |
| `epr-data-sqldb\dbo\Views\v_rpd_Users_Active.sql:1-4`, `v_rpd_Persons_Active.sql:1-17` | Active-account wrappers used by profile/enrolment reporting views; they filter records but do not change the identifier. |

### Regulator lookup procedures and API calls

| Object | Use |
|---|---|
| `epr-data-sqldb\apps\Stored Procedures\sp_FilterAndPaginateSubmissionsSummaries.sql:2-6,16-53,104-138` | Accepts `@RegulatorUserId`, resolves the supplied ID to a nation through `rpd.Users.UserId` and the membership/service-role chain, then filters submission summaries by nation. The API maps a request-supplied `UserId`; binding to the authenticated caller is not established by this trace. |
| `epr-data-sqldb\apps\Stored Procedures\sp_FilterAndPaginateSubmissionsSummaries_resub.sql:2-6,16-56,108-142` | Same supplied-ID-to-nation lookup for the resubmission subset. Multiple qualifying memberships have no explicit deterministic handling, and the lookup has no visible deleted/status predicate (`:16-28`). |
| `epr-data-sqldb\apps\Stored Procedures\sp_FilterAndPaginateRegistrationsSummaries.sql:2-6,15-52,100-146` | Same identity-to-nation lookup for registration summaries. |
| `epr-common-data-api\src\EPR.CommonDataService.Api\Controllers\SubmissionsController.cs:22-45` | Exposes POM and registration summary POST routes. |
| `epr-common-data-api\src\EPR.CommonDataService.Core\Models\Requests\PomSubmissionsSummariesRequest.cs:6-10`; `...\Extensions\StoredProcedureExtensions.cs:66-78` | Carries request `UserId` and converts it to SQL parameter `@RegulatorUserId`. |
| `epr-common-data-api\src\EPR.CommonDataService.Core\Services\SubmissionsService.cs:23-47` | Calls the resub POM summary procedure and registration summary procedure; returned DTOs include submitter identity/profile attributes. |
| `epr-data-sqldb\dbo\Stored Procedures\sp_FilterAndPaginateOrganisationRegistrationSummaries.sql:2-10,77-81`; `..._resub.sql:49-60` | Uses `NationId`, not `@RegulatorUserId`; it is not the user-to-nation lookup. Both variants allow `NationId = 0`; `_resub` also permits application-reference matches from another nation. The checked-in API rejects zero but calls `_resub`; confirm intended authorization and deployed behavior rather than inferring an exploit. |

### Event, audit, and materialized summary identifiers

| Objects | How `UserId` is used |
|---|---|
| `epr-data-sqldb\rpd\Tables\SubmissionEvents.sql:1-54`; `Submissions.sql:15-19`; `AuditLogs.sql:1-5`; `cosmos_file_metadata.sql:2-6`; `error_files_not_processed.sql:2-6` | Store separate event actor, submitter, audit, or file metadata identifiers. `SubmissionEvents` also has a distinct `RegulatorUserId` column. These values are not refreshed just by copying `rpd.Users`. |
| `epr-data-sqldb\apps\Tables\SubmissionEvents.sql:28-35`; `apps\Tables\Submissions.sql:13-19` | Application-schema event/submission copies retain actor identifiers. |
| `epr-data-sqldb\apps\Views\v_SubmissionsSummaries.sql:35-49,269-337` → `apps\Tables\SubmissionsSummaries.sql:3-16` | Resolves the submitted event's `UserId` (not a resubmission actor ID) through `rpd.Users` and person/profile/role joins. Inner joins omit unmatched IDs; on refresh, `sp_AggregateAndMergePomData.sql:178-179` deletes target rows absent from the source view. This removes materialized summary rows, not underlying events. |
| `epr-data-sqldb\apps\Views\v_RegistrationsSummaries.sql:42-68,291-366` → `apps\Tables\RegistrationsSummaries.sql:19-26` | Similar event-to-user/person/role enrichment for registrations, with inner joins that omit unmatched IDs; on refresh, `sp_AggregateAndMergeRegistrationData.sql:226-227` deletes target rows absent from the source view, not underlying events. |
| `epr-data-sqldb\apps\Views\v_OrganisationRegistrationSummaries.sql:3-45,124-162,234-257,271-314` → `apps\Tables\OrgRegistrationsSummaries.sql:3-39` | Derives and stores `SubmittedUserId`, `ResubmittedUserId`, `ProducerUserId`, and `RegulatorUserId` from `rpd` events/submissions. `SubmittedUserId` comes from `rpd.Submissions.UserId`; the output `RegulatorUserId` derives from decision-event `UserId`, not the separate event `RegulatorUserId` column. These are carried actor IDs and this view does not resolve all through `rpd.Users`. `sp_MergeSubmissionsSummaries.sql:313-359,375-388` materializes the summary. |
| `epr-data-sqldb\dbo\Views\V_FetchOrganisationRegistrationSubmissionDetails_resub.sql:47-55,106-107,823-830` → `dbo\Tables\t_FetchOrganisationRegistrationSubmissionDetails_resub.sql` → `dbo\Stored Procedures\sp_FetchOrganisationRegistrationSubmissionDetails_resub.sql:29-31,43-48,65-72` | Detail actor IDs come from the detail view/table path; the join to `apps.OrgRegistrationsSummaries` supplies `RegistrationJourney`, not those actor IDs. |
| `epr-data-sqldb\dbo\Views\v_Enrolmentstatus.sql:37-55` | Joins `rpd.AuditLogs.UserId` to `rpd.Users.UserId`, then through the internal person key, to show a historical actor name. |
| `epr-data-sqldb\dbo\Views\v_enrolment_history.sql:12-21` | Emits `u.UserId` with organisation/person/service-role history while joining user to person through internal IDs. |
| `epr-data-sqldb\dbo\Views\v_Submitter_Name.sql:16-34`; `v_PersonOrganisationConnections.sql:77-96` | Resolve a person via internal `Users.Id`; expose `Users.UserId` as a submitter/member attribute. |
| `epr-data-sqldb\dbo\Views\v_cosmos_file_metadata.sql:1-40,63-84`; `v_cosmos_file_metadata_CS_additions.sql:28-51,56-76` | Match file metadata user IDs to active `rpd.Users.UserId` and derive submitter/profile fields. |
| `epr-data-sqldb\dbo\Views\v_POM_Submissions.sql:77-88`; `v_POM_Submissions_R8.sql:77-88` | Use the exposed user ID from `v_PersonOrganisationConnections` when relating submitter metadata to POM submissions. |
| `epr-data-sqldb\dbo\Views\v_submitted_pom_org_file_status.sql:363-389,413-425` → `dbo\Tables\t_submitted_pom_org_file_status.sql:10-18` | Resolves a decision-event actor ID against `rpd.Users.UserId`, adds regulator display name, and materializes the ID/name. |
| `epr-data-sqldb\dbo\Views\files_not_processed.sql:3-7`, `files_processed.sql:3-7` | Project stored file `UserId` values without resolving them to `rpd.Users`. |
| `epr-data-sqldb\dbo\Views\V_FetchOrganisationRegistrationSubmissionDetails_resub.sql:751-830` → `dbo\Tables\t_FetchOrganisationRegistrationSubmissionDetails_resub.sql:25-47` | Returns regulator and submitter actor IDs; directly joins the submitted actor to `rpd.Users.UserId` for submitter details. The regulator decision actor can remain a returned ID rather than a resolved user. |
| `epr-data-sqldb\dbo\Stored Procedures\sp_FetchOrganisationRegistrationSubmissionDetails_resub.sql:5-48,69-72`; Common Data API `SubmissionsController.cs:159-188`, `SubmissionsService.cs:148-164` | Fetches organisation registration details by submission ID and exposes `RegulatorUserId` / `SubmittedUserId`; the API does not use this route to resolve the regulator caller. |

### Other reporting and legacy references

- File-upload reporting joins are also present in `dbo\Views\v_extract_recent_pom_org_data.sql:100-107,283-290`, `v_submission_count.sql:85-92,268-275`, and `v_CompanyBrandPartnerFileUploadSet.sql:94-108`. Their materialized outputs include report or metadata fields (`dbo\Tables\t_submission_count.sql`, `t_extract_recent_pom_org_data.sql`, `t_CompanyBrandPartnerFileUploadSet.sql`); not every output retains the external ID.
- `dbo\Views\v_registration_with_brandandpartner.sql:198-219` and `dbo\Tables\t_registration_with_brandandpartner.sql:240-265` carry file metadata user IDs and submitter details. Other report tables store human-readable `SubmittedBy`, email, or role rather than the external ID (`t_BrndPrtnr_Org_Submissions.sql`, `t_BrndPrtnr_Registrations.sql`, `t_POM_All_Submissions.sql`, `t_POM_Operator_Submissions.sql`, `t_POM_Submissions.sql`).
- `epr-data-sqldb\grey_IT_scripts\submitted_file_details.sql:80-87,127-169,227-231` contains a legacy/grey event-to-user join; it is not evidence that the script is actively deployed or consumed.
- The SQL repository search found no filter on `OrganisationTypes.Name = 'Regulators'`. `OrganisationTypes` appears as a lookup in some views; regulator pagination instead qualifies the user through `ServiceRoles.ServiceId = 2`.

## Notebook and export references

- The earlier inspection of `notebook/master_script_automation.json` found a query joining `rpd.SubmissionEvents.UserId` to `rpd.Users.UserId` and `rpd.Persons`, with email and first/last name selected but not raw `UserId`; it wrote CSV/XLSX output. The notebook and its pipeline/trigger are absent from this checkout, so this is a historical finding, not independently reverified current source or proof of deployment. An actual generated copy of that export was not inspected.
- `notebook/get_rpd_files.json:461-494,673-721` groups on the submitted event's `UserId` and writes resulting metadata to Delta and the SQL pool (`rpd.cosmos_file_metadata`). `notebook/get_rpd_files_no_split.json:751-793,988-1017` groups on the antivirus-result event's `UserId` and also writes file metadata to Delta and the SQL pool. These distinct grouping keys are not joins to `rpd.Users.UserId`; the code does not establish that the raw ID is written into submitted file contents.
- No direct Power BI dataset/report binding or Power BI-specific `UserId` query was found in the inspected data workspace/SQL/API definitions. An earlier review reported that an architecture model leaves the Synapse-to-Power BI connection unresolved (`epr-programme-docs\docs\architecture\report-packaging-data\model.external.c4:11-15`); that checkout was unavailable for this audit. The dotted report edge is intentionally unconfirmed.

## Packaging frontend review

The added `epr-packaging-frontend` repository was reviewed for paths into the identity objects above:

- `src\FrontendSchemeRegistration.Application\Services\UserAccountService.cs:27-54,79-84` calls `user-accounts`, `persons?userId=...`, and `persons/all-persons?userId=...` (`Constants\UserAccountPaths.cs:5-7`); `AccountServiceApiClient.cs:28-61,64-100` sends delegated user tokens. The checked-in `user-accounts` route is traceable through the Facade to the backend lookup matching `person.User.UserId` (`epr-facade-account-microservice\src\FacadeAccountCreation\FacadeAccountCreation.API\Controllers\UsersController.cs:15-31`; `epr-backend-account-microservice\src\BackendAccountService.Core\Services\UserService.cs:46-64`). This establishes that checked-in route only, not deployed routing, the other `persons` endpoint mappings, or regulator use.
- `src\FrontendSchemeRegistration.Application\Services\RegulatorService.cs:22-29` posts `regulators/resubmission-notify/`. This is a notification call, not evidence of regulator caller lookup or use of the regulator pagination procedures.
- `SubmissionService.cs:46-64` places a `SubmittedBy` string in a submission payload and delegates to `WebApiGatewayClient`; the gateway posts to `/api/v1/submissions/{id}/submit` (`WebApiGatewayClient.cs:225-242`). Registration and decision calls also use `/api/v1/...` gateway routes (`:245-286`). The inspected methods do not send a `UserId` as `@RegulatorUserId` or invoke the summary lookup methods described above. These are HTTP calls; the frontend code does not establish that `SubmittedBy` maps to `rpd.SubmissionEvents.UserId`, an `apps` event column, or any particular SQL table or view. Do not equate it to `rpd.Users.UserId` without tracing the gateway and persistence implementation.
- `WebApiGatewayClient.cs:712-717` and `AccountServiceApiClient.cs:96-100` acquire delegated user tokens. Checked-in `src\FrontendSchemeRegistration.UI\appsettings.json:2-10` contains `AccountsFacadeAPI` and `AzureADB2C` settings; this is evidence of the frontend's configured B2C setup, not evidence that it is the regulator sign-in application or that regulators use these endpoints.

No additional affected SQL table, view, or stored procedure was confirmed from this frontend review, so no new database object was added to the inventory. Mappings for the other Accounts endpoints, gateway persistence, deployed endpoint routing, and runtime access by regulator accounts remain unverified.

## Important limits

1. The notebook reads a control file from storage; checked-in control-file examples and pipeline JSON do not prove the deployed table list, current run state, data freshness, or successful propagation. The documented branches and table selection are configuration evidence only.
2. The Synapse Link files define desired replication configuration, not evidence that it is started. No downstream connection from `bronze_accountsdb.Users` to the notebook's `rpd.Users` path was established.
3. Similar column names are not enough to equate every event/file `UserId` to the current account ID. Each view/procedure listed above should be read according to its explicit join and source event type.
4. The summary procedure's regulator input lookup does not visibly filter deleted users or enrolment status. Validate the deployed SQL and effective API authorization separately.
5. This inventory describes checked-in assets and their references. It does not enumerate runtime queries, report workspaces, manually authored SQL, or all consumers outside the cloned repositories.
6. The SQL repository scan produced many repeated `UserId` references in merge and projection code; the inventory groups them by distinct lineage object rather than repeating every column assignment.