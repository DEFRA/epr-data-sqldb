### Context

We are assessing the impact of migrating regulator authentication from B2C to Microsoft Entra ID on Accounts, Synapse, SQL objects and their consumers. The supplied `rpd-users-userid-entra-migration.md` and `rpd-users-userid-lineage.md` documents contain detailed diagrams and source references. The `EMR-676 regulator authentication matrix.pdf` was also cross-checked.

### Key conclusions

- A provider switch does not automatically require a Synapse schema change. Impact depends on whether applications continue to send existing Accounts identifiers or use different Entra identifiers.
- `Users.UserId` is the external sign-in identifier; `Users.Id` is an internal integer linked to `Persons.UserId`.
- The Accounts-to-Synapse `enrolment` notebook copies configured source values through Delta to the SQL pool; it does not generate identity IDs. A separate Synapse Link configuration targets `bronze_accountsdb.Users`, but was not shown to feed `rpd.Users` or to be running.
- The three `apps.sp_FilterAndPaginate…` POM and registration summary procedures resolve the supplied `@RegulatorUserId` via `rpd.Users.UserId` → person, organisation and enrolment → nation, requiring service ID `2`. The Common Data API forwards a request-supplied GUID; binding to the authenticated caller is not established by the checked-in path. The SQL has no visible deleted/status predicate and does not handle multiple qualifying memberships deterministically.
- Historical event, submission, audit and file-metadata IDs are stored separately. Replacing `Users.UserId` does not update history and can break attribution or joins. POM and registration summary views use inner joins, so failed historical matches can remove source rows; refresh merges can then delete absent rows from materialised summary tables, while underlying events remain.
- `RegulatorUserId` is context-dependent: a procedure input can identify the current caller, while an output can identify a historical decision actor. In `apps.v_OrganisationRegistrationSummaries`, the decision actor comes from `rpd.SubmissionEvents.UserId`, not the separate `RegulatorUserId` column; `SubmittedUserId` comes from `rpd.Submissions.UserId`.

### Matrix cross-check

Consider tracking these dependencies; migration impact depends on which identities occur in them:

- `rpd.AuditLogs.UserId` → `dbo.v_Enrolmentstatus`: historical actor attribution.
- `rpd.Submissions.UserId` and `apps.Submissions.UserId`: stored submitter IDs; regulator use is not established.
- `dbo.v_submitted_pom_org_file_status` → `dbo.t_submitted_pom_org_file_status`: decision-actor ID and regulator name. The matrix’s `_ar` view was not verified in the checked-in SQL.
- `apps.sp_AggregateAndMergePomData` and `apps.sp_AggregateAndMergeRegistrationData`: refresh dependencies, not necessarily schema changes.
- `dbo.v_enrolment_history`, `dbo.v_Submitter_Name`, `dbo.v_PersonOrganisationConnections` and `rpd.error_files_not_processed.UserId`: additional identity exposure or storage points; regulator use of the error table is unconfirmed.

`dbo.sp_FilterAndPaginateOrganisationRegistrationSummaries` filters using supplied `@NationId`; it is not the caller-ID-to-nation lookup. Both variants allow `NationId = 0` in SQL, though the checked-in API rejects zero; `_resub` also permits an application-reference match from another nation. Verify intended authorization and deployed behavior; this static finding is not proof of an exploitable path. The API calls `_resub` organisation-registration pagination and detail procedures; deployed use of other variants remains unverified. In the detail path, actor IDs come from the detail table populated by its own view; the summary-table join supplies only `RegistrationJourney`.

### Consumers and exports

- The reviewed `epr-packaging-frontend` paths call Accounts Facade with delegated tokens and send submission requests through a gateway. The checked-in `user-accounts` route maps to the backend `Users.UserId` lookup, but the other `persons` endpoint mappings, deployed routing, gateway persistence and regulator use remain unverified. No new affected SQL object was confirmed; its `SubmittedBy` string must not be assumed to equal `rpd.Users.UserId`.
- The `master_script_automation` submitted-files query was previously found to join event IDs to users and persons and select submitter email and name, but not the raw ID. This is historical evidence only: the notebook/pipeline are absent from this checkout and no generated export was inspected. It is a different export from `Data_submissions_and_packaging_weights_2026_Small_04_Sep_2026.xlsx`, which does not contain submitter email or personal name columns.
- The Small spreadsheet’s extract has an indirect upstream dependency on a view joining file metadata and users. This does not prove its visible values change or that it contains personal fields.
- `get_rpd_files` groups by the submitted event’s `UserId` and writes file metadata; `get_rpd_files_no_split` groups by the antivirus-result event’s `UserId`. These distinct grouping keys do not establish equivalence, a `Users` join, or that the ID is written into submitted file contents.
- No specific Power BI dataset or report binding was established. Treat Power BI consumption as unverified, not absent.

### Decisions and validation still needed

Choose and verify an identity strategy: translate Entra identities to existing IDs, provision parallel accounts, replace IDs with historical compatibility, or introduce a crosswalk. A new ID already present in `rpd.Users.UserId` can match the existing equality lookup; additional lookup compatibility is conditional on the selected mapping and old-ID requirements. No ready-to-use mapping was demonstrated in the reviewed test extract; provider-specific fields were null there.

Validate token issuer, tenant and claims; authoritative user mapping; memberships, roles and nation scoping; ingestion and reconciliation across Accounts, Delta and SQL; old and new identity lookup; historical joins and refreshed outputs; and cutover and rollback. Test missing and ambiguous identities safely.

### Evidence limits

Findings are primarily static repository traces, not proof of deployed versions, live pipeline state, production values, API authorization, or runtime consumers. The ingestion schedule has UTC-hour/success conditions and separate fact/master branches; actual control-file contents and runs remain unverified. The checked-in `user-accounts` route maps through the Accounts Facade to a backend `Users.UserId` lookup, but deployed routing, other `persons` endpoints and regulator use are unverified. PDF text extraction did not reliably preserve every matrix marking; the production-empty assertion and live usage were not independently verified. The docs are untracked in this checkout.