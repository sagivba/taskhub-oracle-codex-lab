# Database Tests

The initial POC uses deterministic SQL/PLSQL scripts, not utPLSQL.

Each test file should:

- state its target connection/schema;
- initialize its own prerequisites;
- explicitly initialize/clear application context when identity matters;
- produce a clear PASS/FAIL signal;
- avoid depending on another test's session state.

Test groups:

- `structure/`
- `context/`
- `security/`
- `functional/`
- `maintenance/`
- `rebuild/`
