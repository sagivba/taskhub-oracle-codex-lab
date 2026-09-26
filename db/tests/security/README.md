# Security Tests

This directory will contain executable negative tests for:

- direct table access denial from TASKHUB_APP;
- unapproved package execution denial;
- cross-user read/write isolation;
- invalid ID non-disclosure;
- cross-user list/tag association denial;
- missing/stale context behavior.

Do not implement these tests by granting temporary broad privileges to the application schema.
