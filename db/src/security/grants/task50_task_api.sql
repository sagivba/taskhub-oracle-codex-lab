-- Task 50 adds only the missing write privilege required to create Tasks.
-- SELECT WITH GRANT OPTION and UPDATE already exist for Task 30/40 behavior.
grant insert on taskhub_owner.tasks to taskhub_api;

-- Logical deletion uses UPDATE; TASKHUB_API receives no DELETE and TASKHUB_APP
-- continues to receive no direct owner-table privilege.
