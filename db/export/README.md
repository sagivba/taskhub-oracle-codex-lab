# Schema Documentation Export

These SQLcl scripts expose database-resident documentation in a stable,
review-friendly shape. They are read-only and may be spooled or redirected by the
human operator.

Run `0010_annotations.sql` while connected as the schema that owns the documented
objects. For the current TaskHub model, use the approved `TASKHUB_OWNER` connection.

The annotation export reports object name/type, table-or-column target level, column
name, annotation name and annotation value. The query uses the Oracle 26ai dictionary
shape verified from `USER_ANNOTATIONS_USAGE` in the DEV lab.
