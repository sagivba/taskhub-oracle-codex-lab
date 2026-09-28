# Task 70 ORDS and APEX Runbook

This runbook installs the bounded TaskHub web POC while preserving the existing
database and three-schema security boundary. Privileged database steps are
human-run. Do not use SQLcl MCP for the scripts in this runbook.

## Pinned platform

| Component | Version or immutable image |
|---|---|
| Oracle Database | 23.26.1.0.0 / Oracle AI Database 26ai Free |
| Database image | `container-registry.oracle.com/database/free@sha256:8a8084193724b95bc62247e3af4218b357e4f172c78925551b2181dbe2566232` |
| ORDS | 26.2.3 / `container-registry.oracle.com/database/ords@sha256:385c7ba284cb1c325a0096252d4e4f759026f1377be31521a9b30f09ae721cbc` |
| APEX | 26.1 English-only distribution |
| Java in ORDS image | Oracle GraalVM / Java 25 supplied by the pinned image |

APEX 26.1 supports Oracle AI Database 26ai from 23.26.0 and requires ORDS
26.1.1 or later. The selected versions satisfy that published compatibility
contract.

## Topology and boundaries

```text
Browser -> localhost:8181 -> taskhub-ords -> db:1521/FREEPDB1 -> taskhub-db
                                      taskhub-net

taskhub-db   -> external volume taskhub-oradata
taskhub-ords -> named volume taskhub-ords-config
```

The runtime parsing schema is `TASKHUB_APP`. The application reads
`TASKHUB_API.V_TODO_LISTS` and writes with
`TASKHUB_API.PKG_TASKHUB_API.CREATE_LIST`. It receives no direct privilege on
`TASKHUB_OWNER` and no access to the context core or DEV test package.

ORDS configuration persists the Docker service name `db`, never a container IP
or the host mapping. Only ports 1522 and 8181 are published.

## Protected rollback point

Never mount, replace, prune, or remove these Task 70 rollback artifacts:

```text
Docker volume: taskhub-oradata-pre-task70-cold
Archive:       ~/backups/taskhub/pre-task70-20260927/taskhub-oradata-pre-task70-cold.tar.gz
SHA-256:       46d50a9654b70f27828cbc77f221e9c3b1e33f5274965f1acdb63e7b1753a6b4
```

Run the non-mutating baseline check before any adoption or installation:

```bash
scripts/task70/preflight.sh
```

Stop if it does not report `PASS`.

## Local secrets and APEX source

Run the interactive helper to copy `.env.example` to ignored `.env` and create
every secret file with mode `0600` without echoing password values:

```bash
scripts/task70/prepare_secrets.sh
```

The helper checks each supplied value only for non-empty input. The existing
FREEPDB1 `SYS` password is reused without applying a creation policy. ORDS
receives its new database-account password through `--password-stdin`; the
verified DEFAULT profile and the ORDS installer remain authoritative for that
new account. APEX database service-account values are limited to the APEX
installer's 128-character bind and the character set that is safe in its SQLcl
substitution path. APEX ADMIN, Alice, and Bob are checked only for non-empty
values; Oracle APEX remains authoritative for any account-password rejection.
Real values never belong in Git, terminal output, evidence, or shell history.

If APEX rejects an account secret, replace only the APEX ADMIN, Alice, and Bob
values without changing the database or ORDS credentials:

```bash
scripts/task70/prepare_secrets.sh apex-accounts
```

Local Compose secrets retain their host ownership, while the pinned ORDS image
runs as UID `54321`. Each one-shot setup container therefore starts with UID 0,
copies only its mounted secrets to container-temporary files owned by
`oracle:oinstall` with mode `0600`, and immediately drops to the `oracle`
account before running an installer. The temporary copies disappear with the
`--rm` setup container. Persistent ORDS and APEX processes do not run as root.
The APEX archive is mounted read-only; its installer runs from a private
container-temporary copy because Oracle writes installation logs into that
working tree.

Stage and checksum the official APEX archive:

```bash
scripts/task70/download_apex_26_1.sh
```

The script accepts only Oracle's published SHA-256
`b277aa4650d2d4c5e88e8e3738e8098cddd7be7443376ae590ae8fab8b427919`
and extracts into the ignored `.task70/apex/apex` directory.

The ORDS runtime image is built with `.task70/apex/apex/images` as its complete
build context. Only the APEX 26.1 static resources are copied into
`/opt/oracle/apex/images`; the full APEX installation tree is not included.
ORDS Standalone serves that directory at `/i`, matching the APEX `/i/` image
prefix. Build the runtime image before starting or recreating `taskhub-ords`:

```bash
docker compose --env-file .env build ords
```

Once built, the runtime does not mount or otherwise depend on the ignored APEX
source tree. The source is required again only to rebuild the derived image.

## Privileged prerequisite gate

As the human DBA, connect `SYSDBA` directly to `FREEPDB1` and run:

```sql
@db/admin/0040_verify_task70_platform_prerequisites.sql
```

This read-only script verifies the PDB, XDB, ANONYMOUS account, memory,
`WORKAREA_SIZE_POLICY`, tablespace headroom, password-profile prerequisite, and
the three TaskHub schemas. Do not proceed unless it reports `PASS`. A non-null
DEFAULT password verification function is a stop condition for review; the
Task 70 automation never weakens the DEFAULT profile.

## Safe Compose adoption

The live container predates Compose. The following transition replaces only the
container and empty network objects; it must not remove or recreate the external
`taskhub-oradata` volume.

Immediately before adoption, rerun the preflight and inspect the planned model:

```bash
docker compose --env-file .env config
docker compose --env-file .env config --images
```

Then the human operator performs this narrow sequence during a local outage:

```bash
docker stop taskhub-db
docker rm taskhub-db
docker network rm taskhub-net
docker compose up -d db
docker compose ps
```

Verify that `taskhub-db` is healthy, port 1522 maps to 1521, and its only data
mount is `taskhub-oradata:/opt/oracle/oradata`. Stop immediately if the external
volume is missing or a new database initialization begins.

## Installation order

Run each command separately and review its result before continuing:

```bash
docker compose --profile setup run --rm ords-install
docker compose --profile setup run --rm apex-install
docker compose --profile setup run --rm ords-repair
docker compose --profile setup run --rm apex-configure
```

If the APEX 26.1 core installation is registered successfully but only the
ADMIN account configuration fails, do not rerun `apex-install`. Update only the
three APEX account secret files, then resume at the ADMIN recovery step:

```bash
scripts/task70/prepare_secrets.sh apex-accounts
docker compose --env-file .env --profile setup run --rm apex-admin-resume
docker compose --env-file .env --profile setup run --rm ords-repair
docker compose --env-file .env --profile setup run --rm apex-configure
```

The recovery wrapper fails on a nonzero SQLcl exit or any `ORA-`, `SP2-`, or
`PLS-` error in SQLcl output. It prints `PASS` only after change 0320 confirms
that the unlocked INTERNAL `ADMIN` account exists with the APEX ADMIN role.

The ORDS install disables SQL Developer Web, REST-enabled SQL, and the MongoDB
API. It sets `plsql.gateway.mode=proxied` and uses
`ords_util.authorize_plsql_gateway` as the request-validation function. The
APEX installation is full development mode in `FREEPDB1` and does not change
the DEFAULT profile. Static resources are served from the self-contained ORDS
runtime image at `/i/`. The final setup command applies numbered changes 0300
and 0310 to create the `TASKHUB` workspace, map only `TASKHUB_APP`, and create
the exact uppercase Oracle APEX Accounts for Alice and Bob. It then runs the
Task 70 platform postconditions before printing `PASS`.

Validate the ignored APEXlang authoring source, then import only application 700
into the existing workspace and parsing schema:

```bash
docker compose --env-file .env --profile setup run --rm apexlang-validate
docker compose --env-file .env --profile setup run --rm apexlang-import
scripts/task70/validate_apex_app_export.sh
```

Export application 700 through the approved `taskhub-app-mcp` SQLcl MCP
connection, not as SYSDBA. The restricted `TASKHUB_APP` parsing schema can use
the public APEX export API without an unnecessary SYS inheritance grant on the
APEX schema. Use the SQLcl command below, then promote its generated `f700.sql`
to `apex/taskhub_app.sql` and run the static export validator:

```text
apex export -applicationid 700 -exptype SQL -audittype NULL -skipexportdate -dir /tmp/taskhub-apex-export -overwrite-files
scripts/task70/validate_apex_app_export.sh
```

The ignored APEXlang directory is an authoring input only; the single SQL export
is the version-controlled application artifact.

Reimport the committed application and start ORDS:

```bash
docker compose --profile setup run --rm apex-import
docker compose up -d ords
docker compose ps
curl --fail --location --head http://localhost:8181/ords/
```

Application 700 uses Oracle APEX Accounts. Its request lifecycle is:

```text
clear TASKHUB_CTX
-> if authenticated, INIT_FROM_APEX
-> render/process through TASKHUB_API
-> clear TASKHUB_CTX during APEX cleanup
```

Public login requests clear context but do not call `INIT_FROM_APEX` until APEX
has authenticated a user. Initialization errors propagate after clearing, so
unknown and inactive identities fail closed.

## Automated verification

Run the existing test layers plus these Task 70 checks on the connection stated
in each file:

```text
db/tests/structure/0410_task70_apex_platform.sql       SYSDBA in FREEPDB1
db/tests/structure/0420_task70_apex_application.sql    SYSDBA in FREEPDB1
db/tests/security/0150_task70_runtime_boundary.sql     TASKHUB_APP
db/tests/context/0080_task70_apex_request_context.sql  TASKHUB_APP
```

The context test uses `APEX_SESSION.CREATE_SESSION` and `DELETE_SESSION`, which
execute the application's real initialization and cleanup PL/SQL. It reuses one
database session across Alice, Bob, unknown, and inactive identities. HTTP pool
behavior and browser authentication still require the manual gate below.

For ORDS configuration, retrieve individual settings rather than dumping the
whole pool configuration:

```bash
docker compose exec ords /opt/oracle/ords/bin/ords --config /etc/ords/config config get feature.sdw
docker compose exec ords /opt/oracle/ords/bin/ords --config /etc/ords/config config get restEnabledSql.active
docker compose exec ords /opt/oracle/ords/bin/ords --config /etc/ords/config config get mongo.enabled
docker compose exec ords /opt/oracle/ords/bin/ords --config /etc/ords/config config get plsql.gateway.mode
docker compose exec ords /opt/oracle/ords/bin/ords --config /etc/ords/config config get security.requestValidationFunction
```

## Mandatory manual browser gate

Do not record these items as passed until the human tester reports them:

- open `http://localhost:8181/ords/r/taskhub/taskhub/home`;
- sign in as uppercase `TASKHUB_TEST_ALICE`;
- confirm only Alice's lists appear;
- create a list and confirm it appears after submit;
- sign out;
- sign in as uppercase `TASKHUB_TEST_BOB`;
- confirm Bob cannot see Alice's list;
- create a Bob list and confirm it appears;
- sign out and confirm no authenticated data remains visible.

Any cross-user identity or data leakage is a Task 70 stop condition.

For the current TaskHub POC, the human tester reported this complete sequence as
passed on 2026-09-28. The resulting Alice/Bob canonical-list ownership and the
automated APEX-session lifecycle evidence are recorded in
`docs/status/CURRENT_STATUS.md`.

## Source-control export

The accepted application is a single full export at `apex/taskhub_app.sql`.
Export application 700 with SQLcl using `-exptype SQL`, omit audit metadata, and
skip the export date. Reimport it with `db/deploy/task70/import_apex_app.sql` and
rerun the automated checks before accepting a replacement export.

Downloaded archives, extracted APEX media, installation logs, ORDS configuration,
password files, and temporary APEXlang authoring sources remain outside Git.
