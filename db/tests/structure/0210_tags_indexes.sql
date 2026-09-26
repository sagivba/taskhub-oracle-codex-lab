-- Test: TAGS exact approved index set and active-name function index shape
-- Connection/schema: TASKHUB_OWNER
-- Preconditions: db/changes/0050_create_tags.sql has been applied.
-- Expected result: all three queries return zero rows.

with expected (index_name, uniqueness, index_type, column_count) as (
    select 'TAGS_PK',  'UNIQUE', 'NORMAL',        1 from dual union all
    select 'TAGS_UQ1', 'UNIQUE', 'FUNCTION-BASED NORMAL', 2 from dual
), actual as (
    select i.index_name, i.uniqueness, i.index_type, count(c.column_position) column_count
    from user_indexes i join user_ind_columns c on c.index_name = i.index_name
    where i.table_name = 'TAGS'
    group by i.index_name, i.uniqueness, i.index_type
)
select 'INDEX_MISMATCH' as issue, nvl(e.index_name, a.index_name) index_name
from expected e full outer join actual a on a.index_name = e.index_name
where e.index_name is null or a.index_name is null
   or e.uniqueness <> a.uniqueness or e.index_type <> a.index_type or e.column_count <> a.column_count
   or exists (select 1 from user_indexes i where i.index_name = a.index_name and i.status <> 'VALID');

select 'FUNCTION_EXPRESSION_COUNT_MISMATCH' as issue
from dual
where (select count(*) from user_ind_expressions where index_name = 'TAGS_UQ1') <> 2;

-- COLUMN_EXPRESSION is a legacy LONG, so inspect the index DDL as a CLOB to
-- verify the exact active-row and normalized-name expressions deterministically.
with actual as (
    select regexp_replace(
               upper(replace(dbms_metadata.get_ddl('INDEX', 'TAGS_UQ1', user), '"', '')),
               '[[:space:]]+',
               ''
           ) as normalized_ddl
    from dual
)
select 'FUNCTION_EXPRESSION_MISMATCH' as issue
from actual
where dbms_lob.instr(normalized_ddl, 'CASEWHENDELETED_ATISNULLTHENAPP_USER_IDEND') = 0
   or dbms_lob.instr(normalized_ddl, 'CASEWHENDELETED_ATISNULLTHENUPPER(TRIM(TAG_NAME))END') = 0;
