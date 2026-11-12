# Regulator B2C-to-Entra ID: Synapse lineage and change impact

## Purpose and conclusion

This document identifies checked-in Synapse and API objects that store, copy, join, filter, or expose the identifier currently represented by `rpd.Users.UserId`, and explains what may need to change when regulator sign-in moves from B2C to Entra ID.

**A provider switch does not, by itself, require a Synapse schema change.** If the regulator application continues to send the identifier Accounts already recognises (for example, through a verified Entra-to-existing-ID mapping), the existing `Users.UserId` flow can remain. If the application starts sending a different Entra object ID and that value is stored or used directly, the caller lookup and any event/profile joins that need to resolve the new or historic ID must be addressed. Do not update event and audit history just because the current sign-in identifier changes.

This is a static review of checked-in repositories and the supplied test-environment extract. It does not confirm deployed SQL, live pipeline/link state, production identity claims, or runtime consumers. “Change” below means a code, schema, or data operation may be required under the stated identity design; it is not a recommendation to edit every listed object.

## Data lineage diagrams

The lineage is split into focused diagrams so each flow is easier to read and zoom independently. Read them in order: sign-in and Accounts, Accounts ingestion, the regulator caller lookup, historical submission and audit resolution, then notebook/report outputs. Repeated nodes such as `Accounts dbo.Users.UserId` and `rpd.Users.UserId` are the shared points between diagrams.

### 1. Sign-in identity and Accounts relationships

```mermaid
flowchart TB
    IdP["B2C today / Entra ID proposed"] --> Token["Sign-in token\nissuer, tenant, subject/object ID"]
    Token --> RegFE["Regulator frontend / gateway"]
    RegFE -->|"caller GUID sent as userId"| AccountAPI["Facade / Accounts API"]
    AccountAPI -->|"store or match external sign-in ID"| AccountsUser["Accounts dbo.Users.UserId"]
    PackagingFrontend["epr-packaging-frontend\n(AzureADB2C configured)"] -->|"delegated calls: user-accounts / persons?userId"| PackagingAccountsAPI["Accounts Facade endpoints"]
    PackagingAccountsAPI -. "frontend-to-database mapping not verified" .-> AccountsUser
    AccountsUser -->|"internal integer Users.Id"| AccountsPerson["dbo.Persons.UserId"]
    AccountsPerson --> AccountsLink["PersonOrganisationConnections"]
    AccountsLink --> AccountsOrg["Organisations\nExternalId, NationId"]
    AccountsLink --> AccountsEnrol["Enrolments → ServiceRoles"]
```

### 2. Accounts ingestion into Synapse

```mermaid
flowchart TB
    Trigger["trg_tumb_rpd_apps_wd"] --> Main["pip_rpd_main_wd → pip_wrapper"]
    Main --> EnrolPipe["pip_enrolment"]
    Ctrl["External ctrl_table.csv\ndeployed table list unverified"] -. "selects tables and load type" .-> EnrolNotebook["notebook/enrolment"]
    EnrolPipe --> EnrolNotebook
    AccountsUsers["Accounts dbo.Users"] -->|"configured Users source"| EnrolNotebook
    AccountsMembership["Accounts persons, connections, organisations,\nenrolments and roles"] -->|"configured related sources"| EnrolNotebook
    EnrolNotebook -->|"writes source values"| Delta["Delta enrolment tables\nUsers and membership tables"]
    Delta --> Spark["Spark catalog rpd tables"]
    Delta -->|"schema-aligned write"| PoolUser["Dedicated SQL pool rpd.Users"]
    Delta --> PoolMembership["SQL pool rpd.Persons / connections /\norganisations / enrolments / roles"]

    AccountsUsers -. "configured whole-table replication; live state unverified" .-> Link["Separate Synapse Link"]
    Link -.-> Bronze["bronze_accountsdb.Users"]
```

### 3. Regulator caller lookup and nation scope

```mermaid
flowchart TB
    RegFE["Regulator frontend / gateway"] -->|"API request UserId"| CommonAPIRequest["Common Data API request"]
    CommonAPIRequest -->|"@RegulatorUserId"| PageProc["POM / registration summary procedure"]
    PageProc --> Resolve["Resolve caller identity"]
    Resolve -->|"match UserId; require ServiceId = 2"| RpdUser["rpd.Users.UserId"]
    RpdUser -->|"Users.Id = Persons.UserId"| RpdPerson["rpd.Persons"]
    RpdPerson --> RpdConnection["rpd.PersonOrganisationConnections"]
    RpdConnection --> RpdOrg["rpd.Organisations / enrolments / service roles"]
    RpdOrg -->|"derive"| Nation["Organisation\nNationId"]
    Nation --> Filter["Filter summaries by nation"]
    PageProc --> Filter
    SummaryTables["apps.SubmissionsSummaries / apps.RegistrationsSummaries"] --> Filter
    Filter -->|"summary and submitter details"| CommonAPIResponse["Common Data API response"]
```

### 4. Historical submission actors and summary materialisation

```mermaid
flowchart TB
    AppEvents["apps.SubmissionEvents.UserId\nand RegulatorUserId"] -->|"submitted actor ID"| SummaryViews["apps.v_SubmissionsSummaries /\napps.v_RegistrationsSummaries"]
    RpdUser["rpd.Users.UserId"] -->|"match event ID"| SummaryViews
    SummaryViews --> Merge["Aggregate / merge procedures"]
    Merge --> SummaryTables["apps.SubmissionsSummaries / apps.RegistrationsSummaries"]

    RpdEvents["rpd.SubmissionEvents.UserId\nand RegulatorUserId"] --> OrgRegView["apps.v_OrganisationRegistrationSummaries"]
    RpdSubmissions["rpd.Submissions.UserId"] --> OrgRegView
    OrgRegView -->|"retain actor IDs"| OrgRegTable["apps.OrgRegistrationsSummaries"]
    OrgRegTable --> DetailProc["Organisation registration detail procedure"]
    DetailProc --> DetailAPI["Common Data API detail response"]
```

### 5. Audit and enrolment-history attribution

```mermaid
flowchart TB
    AuditSource["Audit / event source"] --> AuditLogs["rpd.AuditLogs.UserId"]
    AuditLogs --> EnrolStatus["dbo.v_Enrolmentstatus"]
    RpdUser["rpd.Users.UserId"] -->|"resolve actor to person/name"| EnrolStatus
    RpdUser -->|"internal Users.Id"| Persons["rpd.Persons"]
    Persons --> EnrolStatus
```

### 6. Notebook exports and reporting outputs

```mermaid
flowchart TB
    Events["rpd.SubmissionEvents.UserId"] --> MasterNotebook["notebook/master_script_automation"]
    RpdUser["rpd.Users.UserId"] -->|"resolve submitter profile"| MasterNotebook
    MasterNotebook -->|"CSV/XLSX profile fields; raw ID not selected"| FlatFiles["Submitted-file exports"]

    Events --> GetFiles["notebook/get_rpd_files\n(and no_split variant)"]
    GetFiles -->|"event UserId is a grouping key"| FileLanding["File-processing metadata"]

    FileSource["File metadata source"] --> FileUser["rpd.cosmos_file_metadata.UserId"]
    FileUser --> FileViews["File metadata / POM reporting views"]
    RpdUser -->|"resolve metadata ID to profile"| FileViews
    FileViews --> ReportTables["Materialised report tables"]
    ReportTables -. "possible consumer; connection unconfirmed" .-> BI["Power BI / external reports"]
```

**Diagram conventions:** all diagrams flow top-to-bottom. Solid edges represent relationships supported by checked-in definitions or reviewed code paths; dotted edges indicate configured but runtime-unverified or otherwise unconfirmed paths. `UserId` fields in events, submissions, audit logs, and file metadata are separately stored actor/submitter values; their names do not prove that each has the same meaning as `rpd.Users.UserId`.

In diagram 4, `apps.SubmissionEvents` and `rpd.SubmissionEvents` are shown as separate sources because the checked-in summary views use different schema objects; the diagram does not assume a direct copy between them.

## Which objects may need to change

### Identity boundary and Accounts source

| Object / field | Current role | Migration impact |
|---|---|---|
| `waste-packaging-regulators-fe` gateway and Accounts client; `WebApiGateway.Api\Extensions\ClaimsPrincipalExtensions.cs:8-16`, `Clients\AccountServiceClient.cs:12-34` | Reads the signed-in user’s object-ID claim and sends a GUID to Accounts lookups. | **Review/change if the Entra token claim or ID differs.** Confirm issuer, tenant, audience and claim mapping. Either translate the verified Entra identity to the existing Accounts ID or make the new identity resolvable. A successful login alone does not establish an Accounts match. |
| Accounts `dbo.Users.UserId`; `epr-data-sqldb\rpd\Tables\Users.sql:1-12`; account lookup `epr-facade-account-microservice\src\FacadeAccountCreation\FacadeAccountCreation.API\Controllers\UsersController.cs:21` | Stores the external ID used in the reviewed account lookup. `Users.Id` is a separate internal integer. | **Data change only if the chosen identity design requires it.** Decide whether this retains the old ID, is replaced, or supports a separate crosswalk/alias. Do not assume changing this one value preserves history. |
| Accounts `Persons.UserId`, `PersonOrganisationConnections`, `Organisations`, `Enrolments`, `ServiceRoles`; pool key relationship in `epr-data-sqldb\rpd\Tables\Persons.sql:1-14` | Connects internal `Users.Id` to a person, organisation, nation and service role. | Usually **no schema change** for a pure ID translation if these stable internal relationships remain correct. If adding a parallel account, its person and membership/enrolment must be created through the supported Accounts process and reviewed for correct access. Do not create a Synapse-only user row. |

### Synapse ingestion and current-account tables

| Object | Current role | Migration impact |
|---|---|---|
| `epr-data-ado\notebook\enrolment.json:363-389,434-528,633-652` | Reads configured Accounts tables, writes Delta, exposes Spark `rpd` tables and writes to the dedicated pool. The notebook copies the source `Users.UserId`; it does not mint a sign-in ID. | **No code change solely for a changed value in an existing column.** Confirm deployed `ctrl_table.csv` includes `Users` and related tables and run/reconcile the relevant load. If introducing a new crosswalk/alias column or table, adapt source selection, Delta handling, Spark/SQL target schema and load configuration. |
| `trigger\trg_tumb_rpd_apps_wd.json:5-16`; `pipeline\pip_rpd_main_wd.json:5-14,71-90`, `pip_wrapper.json:5-19`, `pip_enrolment.json:5-30` | Checked-in trigger/pipeline chain that runs the notebook. | Normally **no definition change** for an ID value change. Coordinate and verify the actual trigger/run, deployed table list, watermarks and successful propagation before downstream refreshes. |
| Delta `Users` and related enrolment tables; dedicated pool `rpd.Users` and membership tables | Current copies of Accounts records. `rpd.Users.UserId` is the external ID; `rpd.Persons.UserId` points to internal `rpd.Users.Id`. | **Values must reconcile after cutover.** Existing columns can carry a replacement GUID without schema changes. A crosswalk design requires explicit Delta/pool schema and ingestion support. Compare IDs and relationships, not just row counts. |
| `epr-data-pipelines\linkConnections\config\accountsLinkConnectionTables.json:208-210` → `bronze_accountsdb.Users` | Separately configured replication of the whole `dbo.Users` table, with no column list or regulator filter. The README says a created link remains stopped until manually started (`linkConnections\README.md:91-95`). | **No indicated change for `UserId` value alone.** If the crosswalk is added, verify the linked target supports it. The configuration is not proof the link is started or connected to `rpd.Users`; do not treat it as the notebook’s source without deployment evidence. |

### Caller-to-nation SQL procedures

The following procedures resolve the caller through `rpd.Users.UserId`, follow the internal person/organisation/enrolment chain, require `ServiceRoles.ServiceId = 2`, and filter returned summaries by the resolved organisation nation. They do not use an `OrganisationTypes.Name = 'Regulators'` filter.

| Object | What it does | Migration impact |
|---|---|---|
| `epr-data-sqldb\apps\Stored Procedures\sp_FilterAndPaginateSubmissionsSummaries.sql:2-6,16-53,104-138` | Matches `@RegulatorUserId` to `rpd.Users.UserId` and derives nation. | **Change or compatibility logic required if this procedure receives a new Entra ID not present in `rpd.Users.UserId`.** Alternatively, keep the old ID as the procedure input through a verified translation. Test ambiguous matches and absent/inactive memberships. |
| `epr-data-sqldb\apps\Stored Procedures\sp_FilterAndPaginateSubmissionsSummaries_resub.sql:2-6,16-56,108-142` | Same caller-to-nation resolution for resubmission summaries. | Same conditional change as above. |
| `epr-data-sqldb\apps\Stored Procedures\sp_FilterAndPaginateRegistrationsSummaries.sql:2-6,15-52,100-146` | Same caller-to-nation resolution for registration summaries. | Same conditional change as above. |
| `epr-common-data-api\src\EPR.CommonDataService.Core\Models\Requests\PomSubmissionsSummariesRequest.cs:6-10`, `...\Extensions\StoredProcedureExtensions.cs:66-78`, `...\Services\SubmissionsService.cs:23-47`, `epr-common-data-api\src\EPR.CommonDataService.Api\Controllers\SubmissionsController.cs:22-45` | Carries request `Guid UserId`, maps it to `@RegulatorUserId`, calls summary procedures and returns submitter details. | **Review the value passed through end to end.** The API can carry a different GUID, but SQL must resolve it. API contracts need change only if identity mapping or request semantics change. The organisation-registration detail API is not the regulator caller lookup. |
| `epr-data-sqldb\dbo\Stored Procedures\sp_FilterAndPaginateOrganisationRegistrationSummaries.sql:2-10,54-78` and its `_resub` version | Filters by supplied `NationId`; does not perform the `@RegulatorUserId` lookup. | Not a direct caller-ID migration point. Confirm which deployed/API version is used before changing it. |

### Event, audit, view and materialised-table lineage

These are separate IDs written by submission, audit, or file-processing paths. Updating `rpd.Users.UserId` does **not** rewrite them. The proper action is to retain their existing resolution, add a deliberate alias/crosswalk where needed, or perform a separately approved historical data migration.

| Object family | Relevant objects | Migration impact |
|---|---|---|
| Stored actor/submitter IDs | `epr-data-sqldb\rpd\Tables\SubmissionEvents.sql:1-54` (`UserId`, `RegulatorUserId`); `rpd\Tables\Submissions.sql:15-19`; `rpd\Tables\AuditLogs.sql:1-5`; `apps\Tables\SubmissionEvents.sql:28-35`; `apps\Tables\Submissions.sql:13-19`; file metadata tables `rpd\Tables\cosmos_file_metadata.sql:2-6` and `error_files_not_processed.sql:2-6`. | **Do not bulk-replace by default.** Establish which source writes each ID and whether it is historical, producer, regulator, or submitter identity. Keep old IDs resolvable for old events and audit history. |
| POM/registration summary enrichment | `epr-data-sqldb\apps\Views\v_SubmissionsSummaries.sql:35-49,269-337` → `apps\Tables\SubmissionsSummaries.sql:3-16`; `apps\Views\v_RegistrationsSummaries.sql:42-68,291-366` → `apps\Tables\RegistrationsSummaries.sql:19-26`; `apps\Stored Procedures\sp_AggregateAndMergePomData.sql:44-76,78-112,113-179`, `sp_AggregateAndMergeRegistrationData.sql:8-50,52-110`. | Views join event IDs to `rpd.Users.UserId` to resolve person/profile/role. If current account IDs are replaced, **preserve or adapt the old-ID join** or historical summary rows may lose enrichment. If a view or mapping changes, rerun materialisation and reconcile results; summary table schema changes only if projected fields change. |
| Organisation registration actors | `epr-data-sqldb\apps\Views\v_OrganisationRegistrationSummaries.sql:124-162,234-250,271-314` → `apps\Tables\OrgRegistrationsSummaries.sql:3-39`; `apps\Stored Procedures\sp_MergeSubmissionsSummaries.sql:313-359,375-388`; `dbo\Views\V_FetchOrganisationRegistrationSubmissionDetails_resub.sql:751-830` → `dbo\Tables\t_FetchOrganisationRegistrationSubmissionDetails_resub.sql:25-47`; `dbo\Stored Procedures\sp_FetchOrganisationRegistrationSubmissionDetails_resub.sql:5-48,69-72`. | Actor IDs such as `RegulatorUserId` are derived/carried from events; they are not all looked up in `rpd.Users`. **Keep old values for history.** The detail view directly resolves submitted-user details in a separate join, which can require alias handling if that ID changes. |
| Audit / enrolment-history resolution | `epr-data-sqldb\dbo\Views\v_Enrolmentstatus.sql:37-55`; `dbo\Views\v_enrolment_history.sql:12-21`; `dbo\Views\v_rpd_Users_Active.sql:1-4`; `dbo\Views\v_rpd_Persons_Active.sql:1-17`. | `v_Enrolmentstatus` matches audit `UserId` to `rpd.Users.UserId` for a historical actor name. Replacing the current ID without an alias can break this name resolution. The active wrappers filter records, not identity values. |
| File metadata and profile joins | `epr-data-sqldb\dbo\Views\v_cosmos_file_metadata.sql:1-40,63-84`, `v_cosmos_file_metadata_CS_additions.sql:28-51,56-76`, `v_Submitter_Name.sql:16-34`, `v_PersonOrganisationConnections.sql:77-96`, `v_POM_Submissions.sql:77-88`, `v_POM_Submissions_R8.sql:77-88`, `v_submitted_pom_org_file_status.sql:363-389,413-425`. | Some directly match metadata/event IDs to `rpd.Users.UserId`, others expose profile fields through internal IDs. **Check joins that must resolve existing metadata IDs** if `Users.UserId` is replaced; retain old IDs or add mapping as appropriate. |
| Other report/output objects | `epr-data-sqldb\dbo\Views\v_extract_recent_pom_org_data.sql:100-107,283-290`, `v_submission_count.sql:85-92,268-275`, `v_CompanyBrandPartnerFileUploadSet.sql:94-108`, `v_registration_with_brandandpartner.sql:198-219`; materialised `dbo\Tables\t_cosmos_file_metadata.sql:3-28`, `t_submitted_pom_org_file_status.sql:10-18`, `t_CompanyBrandPartnerFileUploadSet.sql:84-88`, `t_registration_with_brandandpartner.sql:240-265` and related report tables. | These may derive names/email/role or carry a file metadata ID. Review their upstream joins; refresh materialised outputs if a dependency changes. Human-readable report fields are not proof of stable identity continuity. |
| Legacy / export notebooks | `epr-data-ado\notebook\master_script_automation.json:534-553,589-594,928-960`; `notebook\get_rpd_files.json:477-502`; `notebook\get_rpd_files_no_split.json:760-804`. | `master_script_automation` joins event `UserId` to `rpd.Users.UserId` to produce submitter name/email; raw ID is not in the shown CSV/XLSX selection. `get_rpd_files` uses event `UserId` as a grouping key, not a demonstrated `Users` join. Test exports if account joins or event IDs change; do not assume the notebook writes a new Entra ID. |

## Change by identity approach

| Approach | Likely Synapse/API changes | Main caveat |
|---|---|---|
| **Keep legacy ID at the application boundary**: Entra sign-in is mapped to the existing Accounts identifier before calls that expect it. | Potentially none to Synapse schemas or SQL, provided the mapping is trusted, the API continues to send the expected value, and history joins remain valid. Change/test the regulator gateway’s identity mapping and sign-in configuration. | Define mapping authority and include issuer/tenant as well as subject; a GUID alone may not be globally unique. Verify actual token claims and account resolution. |
| **Add a parallel Entra account**: preserve B2C account and create a distinct Accounts user/person as needed. | Existing `Users.UserId` and notebook schemas can carry the new row. Load it and its person/organisation/enrolment links; adapt caller lookup only if duplicate or multi-membership matching is ambiguous. A new crosswalk field/table still needs ingestion and SQL handling. | This is not automatically the same person. Use supported provisioning, approve roles/membership, and test that a caller resolves to one intended nation. Preserve old event joins. |
| **Replace `Users.UserId` with Entra ID** | Update Accounts data and load to Delta/`rpd.Users`; update caller lookup compatibility and every required historical event/audit/file-metadata resolution path, either via aliases/crosswalk or query changes. Refresh affected summary/report materialisations. | Replacing only the current user row can disconnect old B2C event/audit IDs. Do not rewrite event history without a separate approved data-migration decision and complete dependency analysis. |
| **Add an identity crosswalk/alias** | Add and propagate the mapping table/fields through Accounts extraction, Delta and SQL; update caller and event/profile joins that need old↔new resolution. Add reconciliation/monitoring for missing and ambiguous aliases. | No such ready-to-use mapping was demonstrated in the supplied test extract; provider-specific fields were null there. Define uniqueness, lifecycle, tenant/issuer scope and ownership. |

## Validation and release checks

1. Capture the old and new sign-in token’s issuer, tenant, subject/object ID, audience and relevant name/role claims; prove which identifier the regulator gateway sends to Accounts and to the Common Data API.
2. Obtain an approved user mapping and population. Separate real active users from pending invitations, all-zero placeholder IDs, soft-deleted records, historical users, other-service memberships and duplicate old IDs. Do not infer identity from email or organisation name alone.
3. For each test regulator, verify one intended Accounts user/person/membership, regulator service enrolment and role, organisation and nation. Test users with several organisation memberships and repeated IDs; a successful login is not enough.
4. Run the deployed Accounts-to-Delta-to-pool load (and check Synapse Link separately if relevant). Reconcile `Users.UserId` and linked internal IDs/relationships across Accounts, Delta and `rpd`; compare keys and values, including deletions and mapping records, not only counts.
5. Test each caller summary procedure/API with the old ID and new ID according to the chosen design. Verify the expected nation and summaries, and verify an unknown, placeholder, deleted, or ambiguous identity fails safely rather than selecting unintended data.
6. Confirm historical names and attribution for audit, submission/decision events and file metadata, plus the master-script exports. Refresh dependent summary/report materialisations only after related source tables and identity mappings are consistent.
7. Rehearse cutover and rollback. Preserve the old-ID lookup until historic dependencies are validated; record unresolved identities, propagation lag and failed joins as release blockers.

## Packaging frontend review

- `epr-packaging-frontend\src\FrontendSchemeRegistration.Application\Services\UserAccountService.cs:27-54,79-84` calls `user-accounts`, `persons?userId=...`, and `persons/all-persons?userId=...` (`Constants\UserAccountPaths.cs:5-7`). `AccountServiceApiClient.cs:28-61,64-100` sends delegated user tokens. This confirms an HTTP path to the Accounts Facade, but not which SQL tables or views the endpoint implementation uses. If the facade resolves these IDs against Accounts `dbo.Users.UserId`, that existing identity object is already covered in this document; the endpoint-to-table mapping remains unverified.
- `RegulatorService.cs:22-29` calls `regulators/resubmission-notify/`; the reviewed method sends an email request and does not resolve the caller or invoke the regulator pagination procedures.
- `SubmissionService.cs:46-64` sends a `SubmittedBy` string through the Web API Gateway, whose `/api/v1/submissions/{id}/submit` endpoint is posted at `WebApiGatewayClient.cs:225-242`. Registration application and decision calls use other `/api/v1/...` routes (`:245-286`). The inspected methods do not send a `UserId` as `@RegulatorUserId` or invoke the caller-to-nation summary lookups listed above. The frontend does not show the gateway's database persistence mapping, so these calls do not establish use of `rpd.SubmissionEvents.UserId`, the `apps` event copies, or related summary tables/views. `SubmittedBy` must not be assumed to equal `rpd.Users.UserId`.
- `WebApiGatewayClient.cs:712-717` and `AccountServiceApiClient.cs:96-100` acquire delegated user access tokens. The checked-in `src\FrontendSchemeRegistration.UI\appsettings.json:2-10` configures `AzureADB2C` and a producers-account-facade scope; this does not establish that the frontend is used by regulators or that this app is in their sign-in path.
- No direct use of a database table, view, or stored procedure was confirmed in the reviewed frontend call paths. No new affected SQL object was identified, so the existing object inventories remain unchanged. The Accounts Facade and Web API Gateway backend implementations, deployed routes, and runtime access by regulator accounts are not established by this static review.

## Evidence and limits

- The notebook path and object map are based on `epr-data-ado\notebook\enrolment.json`, the checked-in trigger/pipeline JSON, and the SQL/API definitions listed above. The notebook reads an external control file; the deployed file, run state, freshness and successful data propagation were not verified.
- The separate Synapse Link configuration includes the whole Accounts `dbo.Users` table in `bronze_accountsdb`, but the checked-in files do not establish that the link is running or that this bronze table feeds `rpd.Users`.
- No checked-in SQL predicate filtering `OrganisationTypes.Name = 'Regulators'` was found. The reviewed caller-scoping procedures use regulator service ID `2`; their `@OrganisationType` parameter is a result category filter. The caller lookup should still be checked for deployed deleted/status handling and ambiguous memberships.
- The reviewed definitions contain no confirmed Power BI dataset/report binding. Power BI and uninspected external consumers remain outside this static inventory.
- Detailed starting inventory: `docs\rpd-users-userid-lineage.md`. Key source references include `epr-data-sqldb\rpd\Tables\Users.sql`, `Persons.sql`, `apps\Stored Procedures\sp_FilterAndPaginateSubmissionsSummaries.sql`, `apps\Views\v_SubmissionsSummaries.sql`, `dbo\Views\v_Enrolmentstatus.sql`; `epr-common-data-api\src\EPR.CommonDataService.Api\Controllers\SubmissionsController.cs`; and `waste-packaging-regulators-fe\WebApiGateway\WebApiGateway.Api\Extensions\ClaimsPrincipalExtensions.cs`.