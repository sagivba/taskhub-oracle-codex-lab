# Database Documentation Standard

## Principle

TaskHub database documentation is part of the source of truth and the security
contract. It must be maintained with the object it explains and deployed from Git.

> Non-obvious architecture, security, identity, privilege, transaction, and lifecycle decisions must document both WHAT the implementation does and WHY the design exists.

Documentation must be specific enough that a DBA, developer or future automation
session can preserve the three-schema trust boundary without reverse-engineering the
implementation.

## Tables and columns

Use the two Oracle mechanisms for different purposes:

- `COMMENT ON TABLE` and `COMMENT ON COLUMN` provide concise, human-readable business descriptions and immediately important constraints.
- Oracle Annotations provide structured architectural metadata for discovery and export. Use meaningful names such as `DESCRIPTION`, `PURPOSE`, `DOMAIN`, `OWNERSHIP`, `SECURITY_MODEL`, `LIFECYCLE`, `IDENTITY_SOURCE`, `AUDIT_FIELD`, `SECURITY_SENSITIVE` and `DERIVED_FROM_CONTEXT` only when the metadata adds information.

Ownership and audit annotations must identify their source of truth. In particular,
state whether a value is database generated, caller supplied, resolved from a
canonical object, maintained by API logic, or derived from `TASKHUB_CTX`.

Canonical annotation source belongs under `db/src/owner/annotations/`. Persistent
annotation/comment changes must first be recorded in a numbered `db/changes/` file.

## PL/SQL packages

The package specification is the public contract. Each public specification must
explain the package purpose, trust boundary, design rationale, security model,
transaction model, expected application-error categories and testability where they
apply. Package bodies should contain comments only for non-obvious security,
lifecycle, Oracle or implementation rationale; comments must not narrate the code.

Each public subprogram documents the relevant purpose, identity, authorization,
preconditions, side effects, errors and transaction behavior. Do not add empty or
mechanical sections.

> Public parameter documentation belongs inline next to the parameter declaration in the package specification, rather than in a duplicated parameter list.

Caller-controllable parameters must be distinguished from values derived from trusted
context. Do not add owner, application-user or audit-user parameters when those values
belong to `TASKHUB_CTX`.

## Application context

Context documentation must identify the `TASKHUB_CTX` namespace, its trusted core
package, the runtime APEX path, the isolated DEV test path, clear-before-initialize
behavior, inactive/unknown-user behavior and the stale-session risk. It must explain
why `TASKHUB_APP` cannot execute the trusted core or test facade.

## Privileges and transactions

Grant documentation must explain why `TASKHUB_APP` receives only approved API/view
access and why `TASKHUB_API` receives only direct object privileges required by its
definer-rights code. Documentation must never be used as a reason to widen a grant.

Business API packages do not commit or roll back. The caller owns the transaction
boundary so multiple API calls can remain one atomic business operation.

## Export and verification

Run `db/export/0010_annotations.sql` as the object owner to export structured
annotation metadata. Verification queries use Oracle 26ai
`USER_ANNOTATIONS_USAGE`, whose relevant columns are `OBJECT_NAME`, `OBJECT_TYPE`,
`COLUMN_NAME`, `ANNOTATION_NAME` and `ANNOTATION_VALUE`.

Documentation changes must verify comments, annotations, unchanged public signatures,
valid package specifications/bodies, empty `USER_ERRORS`, unchanged grants and clean
repository validation.
