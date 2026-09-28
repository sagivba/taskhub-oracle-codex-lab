-- Task 70 human-run SQLcl application import wrapper.
-- Connection: SYSDBA connected directly to FREEPDB1.
-- Do not execute through SQLcl MCP R4.

whenever oserror exit failure
whenever sqlerror exit sql.sqlcode rollback

begin
    if sys_context('USERENV', 'CON_NAME') <> 'FREEPDB1' then
        raise_application_error(-20990, 'TaskHub APEX import must run in FREEPDB1');
    end if;

    apex_application_install.set_workspace(p_workspace => 'TASKHUB');
    apex_application_install.set_schema(p_schema => 'TASKHUB_APP');
    apex_application_install.set_application_id(p_application_id => 700);
end;
/

@@../../../apex/taskhub_app.sql

whenever oserror exit failure
whenever sqlerror exit sql.sqlcode rollback
@@../../tests/structure/0420_task70_apex_application.sql
