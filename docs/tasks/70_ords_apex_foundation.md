# Task 70 - ORDS and APEX Foundation

## Objective

Add a working web application layer to TaskHub using Oracle REST Data Services and Oracle APEX while preserving the database, API, identity, and security boundaries established in Tasks 00-60.

The task must prove one complete vertical slice:

```text
Browser
  ->
ORDS
  ->
APEX
  ->
TASKHUB_APP
  ->
TASKHUB_API
  ->
TASKHUB_OWNER
```

This task is for a bounded POC and learning environment. Production architecture, SSO, HA, CI/CD, and full deployment automation are out of scope.

---

## Baseline

Database:

```text
Oracle AI Database 26ai Free
PDB: FREEPDB1
```

Application schemas:

```text
TASKHUB_OWNER
TASKHUB_API
TASKHUB_APP
```

Completed foundation:

```text
Tasks 00-60 COMPLETE
```

The Database/API layer already includes:

- Canonical data model
- `TASKHUB_CTX`
- Application identity mapping
- Filtered read views
- Business APIs
- Ownership enforcement
- Soft delete
- Maintenance and purge
- Security boundary
- Regression tests

---

## 1. Target Versions

Use:

```text
Oracle APEX 26.1
Oracle REST Data Services 26.2
```

APEX 26.1 requires ORDS 26.1.1 or later, so ORDS 26.2 is suitable.

For a new installation, install ORDS before APEX.

---

## 2. Docker Topology

Use one Docker Compose project.

Target topology:

```text
docker compose
|
+-- db
|   +-- taskhub-db
|       +-- taskhub-oradata
|
+-- ords
    +-- taskhub-ords
        +-- taskhub-ords-config
```

Shared Docker network:

```text
taskhub-net
```

ORDS must connect to the database using Docker service DNS, not a container IP and not localhost:

```text
db:1521/FREEPDB1
```

---

## 3. Existing Oracle Container

The existing Oracle database must be preserved.

Current persistent volume:

```text
taskhub-oradata
```

Declare it as an external Docker volume.

The existing database image must remain pinned to its current exact image digest.

Do not recreate, initialize, replace, or delete the database volume.

The existing host port mapping remains:

```text
1522 -> 1521
```

No new Oracle environment overrides are required unless implementation evidence proves otherwise.

---

## 4. ORDS Deployment

Use:

```text
ORDS 26.2
Standalone mode
Embedded Jetty
Docker container
```

Do not introduce:

```text
Tomcat
WebLogic
Kubernetes
Reverse proxy
```

unless required by a later task.

ORDS configuration persistence:

```text
taskhub-ords-config
```

Use a Docker named volume.

The ORDS database repository remains persistent inside the Oracle database.

---

## 5. APEX Installation

APEX is currently not installed in `FREEPDB1`.

Task 70 performs a new APEX 26.1 installation.

Install a full development environment because this environment is intended for application development and learning.

The installation must target:

```text
FREEPDB1
```

Do not install APEX into an unintended container.

---

## 6. APEX Static Resources

For the POC, use the Oracle APEX CDN for APEX static resources.

This avoids maintaining a separate local `/i/` images directory inside the ORDS container.

If the lab later requires offline operation, local static resources may be introduced as a separate change.

---

## 7. APEX Workspace

Create one workspace for TaskHub.

Suggested logical name:

```text
TASKHUB
```

Associate the workspace with:

```text
TASKHUB_APP
```

Do not associate APEX directly with `TASKHUB_OWNER`.

Do not use `TASKHUB_API` as the Parsing Schema.

---

## 8. Parsing Schema

The APEX application Parsing Schema is:

```text
TASKHUB_APP
```

No new `TASKHUB_APEX` schema is required for this POC.

This preserves the existing runtime boundary:

```text
APEX
  ->
TASKHUB_APP
  ->
TASKHUB_API
  ->
TASKHUB_OWNER
```

---

## 9. Authentication

For the POC, use:

```text
Oracle APEX Accounts
```

Do not introduce LDAP, SAML, OIDC, or another external IdP in Task 70.

Create two test identities so cross-user isolation can be demonstrated.

Their APEX usernames must map exactly to active rows in:

```text
TASKHUB_OWNER.APP_USERS
```

The case of the APEX username must match the canonical `APP_USERS.USERNAME` value.

---

## 10. Application Identity

The authenticated APEX user is obtained only from:

```sql
sys_context('APEX$SESSION', 'APP_USER')
```

The application must not send a username or `APP_USER_ID` to the database as a trusted identity parameter.

The existing runtime API is:

```sql
TASKHUB_API.PKG_TASKHUB_CONTEXT.INIT_FROM_APEX
```

The implementation has already been verified to:

- Clear existing `TASKHUB_CTX`
- Read `APEX$SESSION.APP_USER`
- Delegate validation to `PKG_TASKHUB_CONTEXT_CORE`
- Map the username to one active `APP_USERS` row
- Set `APP_USER_ID` and `APP_USERNAME`
- Fail closed when identity is invalid
- Clear context again on failure

No redesign of this package is required by Task 70.

---

## 11. Application Context Lifecycle

`TASKHUB_CTX` is database-session scoped.

An APEX logical session must not be treated as a dedicated Oracle database session.

ORDS may reuse pooled database sessions.

Therefore TaskHub identity must be initialized for each relevant APEX request.

Conceptual request lifecycle:

```text
APEX request
    |
    v
APP_USER established
    |
    v
INIT_FROM_APEX
    |
    +--> clear previous TASKHUB_CTX
    |
    +--> validate APP_USER
    |
    +--> set APP_USER_ID
    |
    v
page processing
    |
    v
clear TASKHUB_CTX
```

Initialization must never depend on identity remaining in a pooled database session from a previous request.

Logout and APEX session timeout are not sufficient controls for clearing database session context.

---

## 12. Read Access

APEX reads application data only through approved filtered views owned by:

```text
TASKHUB_API
```

Examples include the existing TaskHub read views:

```text
V_TODO_LISTS
V_TODO_LIST_TAGS
V_TASKS
V_TASK_TREE
```

APEX must not read directly from `TASKHUB_OWNER` tables.

---

## 13. Write Access

All business writes must use approved PL/SQL APIs owned by:

```text
TASKHUB_API
```

This includes:

```text
INSERT
UPDATE
DELETE
Business actions
```

APEX must not perform direct DML against `TASKHUB_OWNER`.

APEX Automatic Row Processing must not be used where it would bypass the TaskHub API boundary.

Typical page behavior:

```text
Display
   ->
TASKHUB_API view

Submit
   ->
TASKHUB_API package

Success
   ->
refresh/re-query view
```

---

## 14. Grants

`TASKHUB_APP` receives only the privileges required by the application.

Read path:

```text
SELECT on explicitly approved TASKHUB_API views
```

Write path:

```text
EXECUTE on explicitly approved TASKHUB_API packages
```

Identity initialization:

```text
EXECUTE on TASKHUB_API.PKG_TASKHUB_CONTEXT
```

Do not introduce:

```text
Direct DML on TASKHUB_OWNER
Direct SELECT on TASKHUB_OWNER for APEX pages
ANY privileges
EXECUTE on PKG_TASKHUB_CONTEXT_CORE
```

The existing trusted context setter remains inaccessible to `TASKHUB_APP`.

---

## 15. First Vertical Slice

The first APEX application flow is deliberately small:

```text
Login
  |
  v
Initialize TaskHub identity
  |
  v
TODO Lists page
  |
  v
Create TODO List
  |
  v
Refresh TODO Lists
```

Only functionality required to demonstrate this flow belongs in Task 70.

Do not add Tasks UI, Tags UI, administration screens, or unrelated features unless required to prove the foundation.

---

## 16. TODO Lists Page

The first application page displays the current user's TODO Lists using the existing filtered TaskHub view.

The page must demonstrate that database filtering is driven by:

```text
TASKHUB_CTX.APP_USER_ID
```

and not by a page item containing a user identifier.

---

## 17. Create TODO List

Creating a list must call the existing TaskHub business API.

The APEX page must not contain SQL equivalent to:

```sql
insert into taskhub_owner.todo_lists ...
```

After successful creation, refresh the TODO Lists region from the canonical filtered view.

---

## 18. Source Control

Keep APEX source control simple.

Repository structure:

```text
apex/
  taskhub_app.sql
```

Store one complete APEX application export.

Do not introduce split exports in Task 70.

Database objects continue to be managed under:

```text
db/
```

Docker infrastructure is managed through:

```text
compose.yaml
```

---

## 19. Secrets

Secrets must not be committed to Git.

Use a local:

```text
.env
```

where appropriate.

Commit only a non-secret example:

```text
.env.example
```

The repository must not contain:

```text
Database passwords
APEX administrator passwords
ORDS credentials
Wallet secrets
Tokens
```

Generated ORDS runtime configuration containing secrets remains in the ORDS configuration volume and outside Git.

---

## 20. Reproducibility Goal

Task 70 does not require one-click provisioning.

The required reproducibility model is:

```text
git clone
   |
   v
prepare local secrets/config
   |
   v
docker compose up
   |
   v
install/configure ORDS
   |
   v
install/configure APEX
   |
   v
create/configure workspace
   |
   v
import apex/taskhub_app.sql
   |
   v
validate TaskHub
```

Where practical, Codex may create scripts for deterministic steps.

Do not create an unnecessary provisioning framework.

---

## 21. Acceptance Tests

Task 70 is complete only when the following are demonstrated.

### Infrastructure

- ORDS container starts successfully.
- ORDS can connect to `FREEPDB1`.
- APEX is reachable through ORDS.
- The existing TaskHub database remains intact.

### Authentication

- Test User A can authenticate.
- Test User B can authenticate.
- `APEX$SESSION.APP_USER` contains the expected authenticated username.

### Identity Initialization

For User A:

```text
APP_USER
  ->
INIT_FROM_APEX
  ->
correct TASKHUB_CTX.APP_USER_ID
```

For User B, the context changes to User B's canonical identity.

Unknown or inactive identity must fail closed.

### Pool Isolation

Perform:

```text
Login User A
   ->
access TaskHub
   ->
logout

Login User B
   ->
access TaskHub
```

User B must never inherit:

```text
User A APP_USER_ID
User A APP_USERNAME
User A data
```

This is a mandatory Task 70 security test.

### Reads

- User A sees only User A's TODO Lists.
- User B sees only User B's TODO Lists.
- Reads come through approved `TASKHUB_API` views.

### Writes

- Create TODO List succeeds through the approved API.
- The new list appears after region refresh.
- No direct owner-table DML is required.

### Source Control

Export the working APEX application to:

```text
apex/taskhub_app.sql
```

The export must be capable of recreating the application through APEX import.

---

## 22. Stop Conditions

Codex must stop and report rather than improvise if any of the following occurs:

```text
taskhub-oradata cannot be positively identified

an operation would delete or recreate taskhub-oradata

the existing TaskHub database cannot be preserved during Compose adoption

ORDS/APEX compatibility differs from the documented target

installation requires an unexpected privilege or architecture change

APEX requires direct TASKHUB_OWNER access

INIT_FROM_APEX requires caller-supplied identity

TASKHUB_APP requires access to PKG_TASKHUB_CONTEXT_CORE

User B can observe User A identity or data

pooled-session context cannot be reliably initialized or cleared

implementation would materially change the Tasks 00-60 security model
```

A stop condition requires investigation and an explicit design decision before continuing.

---

## 23. Codex Responsibilities

Codex may implement and validate:

```text
Compose configuration
ORDS container definition
ORDS configuration/bootstrap
APEX installation support
Workspace/application setup where automatable
Required repository structure
Required grants
APEX application implementation
PL/SQL page processes
APEX export
Repeatable validation scripts
Documentation
Evidence
Repository validation
```

Codex must preserve the existing database and security boundaries.

---

## 24. Manual Verification

The following must include human browser verification:

```text
APEX login
User A behavior
User A data visibility
Create TODO List
Logout
User B login
User B data visibility
Absence of User A data
Basic UI behavior
```

Automation may supplement these checks but does not replace the required manual identity/isolation validation for the POC.

---

## 25. Out of Scope

Task 70 does not include:

```text
Production deployment
TLS architecture
Reverse proxy
SSO
LDAP
SAML
OIDC
High availability
Load balancing
Kubernetes
CI/CD
Advanced monitoring
Full application functionality
Tasks UI
Tags UI
Administration UI
Production hardening
```

These may be addressed by later tasks.

---

## Success Criteria

Task 70 is complete when:

1. Oracle DB and ORDS run under the agreed Docker Compose topology.
2. The existing `taskhub-oradata` volume is preserved.
3. ORDS 26.2 runs in Standalone mode.
4. APEX 26.1 is installed in `FREEPDB1`.
5. A TaskHub APEX workspace and application exist.
6. The Parsing Schema is `TASKHUB_APP`.
7. APEX authentication uses two POC APEX Accounts.
8. Runtime identity is established from `APEX$SESSION.APP_USER`.
9. `INIT_FROM_APEX` correctly maps APEX identity to TaskHub identity.
10. Reads use approved `TASKHUB_API` views.
11. Writes use approved `TASKHUB_API` packages.
12. `TASKHUB_APP` has no direct owner-table DML.
13. User A and User B remain isolated across pooled requests.
14. The first vertical slice works end to end.
15. The APEX application is exported to `apex/taskhub_app.sql`.
16. Documentation and evidence are sufficient to reproduce and validate the POC.
