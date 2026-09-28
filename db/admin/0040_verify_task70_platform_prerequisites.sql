-- Task: 70 ORDS and APEX Foundation
-- Purpose: Read-only human-run verification before installing ORDS or APEX.
-- Connection: SYSDBA connected directly to FREEPDB1.
-- State changes: none.

set serveroutput on
set verify off
whenever sqlerror exit sql.sqlcode rollback

declare
    l_count               pls_integer;
    l_value               varchar2(4000);
    l_sga_bytes           number;
    l_pga_bytes           number;

    l_free_bytes          number;
    l_autoextend_bytes    number;
    l_available_bytes     number;

    procedure require(
        p_condition boolean,
        p_message   varchar2
    ) is
    begin
        if not p_condition then
            raise_application_error(-20990, p_message);
        end if;
    end;

    procedure get_tablespace_capacity(
        p_tablespace_name in  varchar2,
        p_free_bytes      out number,
        p_autoextend_bytes out number,
        p_available_bytes out number
    ) is
    begin
        /*
         * Current unallocated space already inside the tablespace.
         */
        select nvl(sum(bytes), 0)
          into p_free_bytes
          from dba_free_space
         where tablespace_name = upper(p_tablespace_name);

        /*
         * Additional capacity available through AUTOEXTEND.
         *
         * For non-autoextensible files the additional capacity is zero.
         * GREATEST protects against any inconsistent metadata where
         * MAXBYTES might be reported below the current BYTES value.
         */
        select nvl(
                   sum(
                       case
                           when autoextensible = 'YES'
                           then greatest(maxbytes - bytes, 0)
                           else 0
                       end
                   ),
                   0
               )
          into p_autoextend_bytes
          from dba_data_files
         where tablespace_name = upper(p_tablespace_name);

        p_available_bytes :=
            p_free_bytes
            + p_autoextend_bytes;
    end;

begin
    require(
        sys_context('USERENV', 'CON_NAME') = 'FREEPDB1',
        'Connect directly to FREEPDB1 before running this check'
    );

    select count(*)
      into l_count
      from dba_registry
     where comp_id = 'XDB'
       and status = 'VALID';

    require(
        l_count = 1,
        'A valid Oracle XML DB component is required'
    );

    select count(*)
      into l_count
      from dba_users
     where username = 'ANONYMOUS';

    require(
        l_count = 1,
        'The ANONYMOUS database account required by APEX is missing'
    );

    select upper(value)
      into l_value
      from v$parameter
     where name = 'workarea_size_policy';

    require(
        l_value = 'AUTO',
        'WORKAREA_SIZE_POLICY must be AUTO'
    );

    select sum(value)
      into l_sga_bytes
      from v$sga;

    require(
        l_sga_bytes >= 1200 * 1024 * 1024,
        'SGA is below the APEX 1200 MB minimum'
    );

    select to_number(value)
      into l_pga_bytes
      from v$parameter
     where name = 'pga_aggregate_target';

    require(
        l_pga_bytes >= 300 * 1024 * 1024,
        'PGA_AGGREGATE_TARGET is below the APEX 300 MB minimum'
    );

    select limit
      into l_value
      from dba_profiles
     where profile = 'DEFAULT'
       and resource_name = 'PASSWORD_VERIFY_FUNCTION'
       and resource_type = 'PASSWORD';

    require(
        l_value = 'NULL',
        'DEFAULT password verification is enabled; stop for DBA review'
    );

    /*
     * APEX requires sufficient capacity in its target tablespace.
     *
     * Do not check DBA_FREE_SPACE alone because an AUTOEXTEND-enabled
     * datafile may legitimately have little currently allocated free space
     * while still having ample supported growth capacity.
     *
     * Effective available capacity:
     *
     *   current DBA_FREE_SPACE
     *   +
     *   remaining AUTOEXTEND capacity
     */

    get_tablespace_capacity(
        p_tablespace_name  => 'SYSAUX',
        p_free_bytes       => l_free_bytes,
        p_autoextend_bytes => l_autoextend_bytes,
        p_available_bytes  => l_available_bytes
    );

    dbms_output.put_line(
        'SYSAUX current free MB: '
        || to_char(round(l_free_bytes / 1024 / 1024, 1))
    );

    dbms_output.put_line(
        'SYSAUX AUTOEXTEND growth MB: '
        || to_char(round(l_autoextend_bytes / 1024 / 1024, 1))
    );

    dbms_output.put_line(
        'SYSAUX effective available MB: '
        || to_char(round(l_available_bytes / 1024 / 1024, 1))
    );

    require(
        l_available_bytes >= 260 * 1024 * 1024,
        'SYSAUX has less than 260 MB effective available capacity'
    );

    get_tablespace_capacity(
        p_tablespace_name  => 'SYSTEM',
        p_free_bytes       => l_free_bytes,
        p_autoextend_bytes => l_autoextend_bytes,
        p_available_bytes  => l_available_bytes
    );

    dbms_output.put_line(
        'SYSTEM current free MB: '
        || to_char(round(l_free_bytes / 1024 / 1024, 1))
    );

    dbms_output.put_line(
        'SYSTEM AUTOEXTEND growth MB: '
        || to_char(round(l_autoextend_bytes / 1024 / 1024, 1))
    );

    dbms_output.put_line(
        'SYSTEM effective available MB: '
        || to_char(round(l_available_bytes / 1024 / 1024, 1))
    );

    require(
        l_available_bytes >= 128 * 1024 * 1024,
        'SYSTEM has less than 128 MB effective available capacity'
    );

    select count(*)
      into l_count
      from dba_users
     where username in (
               'TASKHUB_OWNER',
               'TASKHUB_API',
               'TASKHUB_APP'
           );

    require(
        l_count = 3,
        'The three TaskHub application schemas are not all present'
    );

    dbms_output.put_line(
        'PASS: Task 70 platform prerequisites in FREEPDB1'
    );

    dbms_output.put_line(
        'SGA bytes: ' || to_char(l_sga_bytes)
    );

    dbms_output.put_line(
        'PGA target bytes: ' || to_char(l_pga_bytes)
    );
end;
/

prompt Existing APEX and ORDS registry state (informational):

select comp_id,
       version,
       status
  from dba_registry
 where comp_id in ('APEX', 'ORDS')
 order by comp_id;

select username,
       account_status
  from dba_users
 where username like 'APEX\_%' escape '\'
    or username like 'ORDS\_%' escape '\'
 order by username;