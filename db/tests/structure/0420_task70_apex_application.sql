-- Test: Task 70B TaskHub application metadata and approved database integration
-- Connection/schema: human-run SYSDBA connected directly to FREEPDB1
-- Preconditions: APEX 26.1, TASKHUB workspace, and application 700 are installed
-- Expected result: PASS

set serveroutput on
declare
    l_count pls_integer;

    procedure require(p_condition boolean, p_message varchar2) is
    begin
        if not p_condition then
            raise_application_error(-20990, p_message);
        end if;
    end;
begin
    require(
        sys_context('USERENV', 'CON_NAME') = 'FREEPDB1',
        'Test must run in FREEPDB1'
    );

    select count(*) into l_count
      from apex_applications
     where workspace = 'TASKHUB'
       and application_id = 700
       and application_name = 'TaskHub'
       and owner = 'TASKHUB_APP'
       and instr(upper(db_session_init_code),
                 'TASKHUB_API.PKG_TASKHUB_CONTEXT.CLEAR_CONTEXT') > 0
       and instr(upper(db_session_init_code),
                 'APEX_AUTHENTICATION.IS_AUTHENTICATED') > 0
       and instr(upper(db_session_init_code),
                 'TASKHUB_API.PKG_TASKHUB_CONTEXT.INIT_FROM_APEX') > 0
       and instr(upper(db_session_cleanup_code),
                 'TASKHUB_API.PKG_TASKHUB_CONTEXT.CLEAR_CONTEXT') > 0;
    require(l_count = 1, 'Application 700 metadata or request context lifecycle is invalid');

    select count(*) into l_count
      from apex_application_auth
     where application_id = 700
       and is_current_authentication = 'Y'
       and scheme_type = 'Oracle APEX Accounts';
    require(l_count = 1, 'Application 700 does not use Oracle APEX Accounts');

    select count(*) into l_count
      from apex_application_pages
     where application_id = 700
       and page_id = 1
       and page_alias = 'HOME'
       and page_requires_authentication = 'Yes';
    require(l_count = 1, 'Authenticated TODO Lists page is missing');

    select count(*) into l_count
      from apex_application_pages
     where application_id = 700
       and page_id = 9999
       and page_alias = 'LOGIN'
       and page_requires_authentication = 'No';
    require(l_count = 1, 'Public login page is missing');

    select count(*) into l_count
      from apex_application_page_regions
     where application_id = 700
       and page_id = 1
       and dbms_lob.instr(
               upper(region_source),
               'TASKHUB_API.V_TODO_LISTS'
           ) > 0;
    require(l_count = 1, 'TODO Lists page does not use TASKHUB_API.V_TODO_LISTS');

    select count(*) into l_count
      from apex_application_page_proc
     where application_id = 700
       and page_id = 1
       and process_type_code = 'PLSQL'
       and dbms_lob.instr(
               upper(process_source),
               'TASKHUB_API.PKG_TASKHUB_API.CREATE_LIST'
           ) > 0;
    require(l_count = 1, 'Create TODO List process does not call the approved API');

    select count(*) into l_count
      from apex_application_page_proc
     where application_id = 700
       and process_type_code in (
           'DML_PROCESS_ROW',
           'DML_FETCH_ROW',
           'DML_PROCESS_DELETE_ROW'
       );
    require(l_count = 0, 'Application 700 contains an automatic DML process');

    select count(*) into l_count
      from apex_application_page_regions
     where application_id = 700
       and dbms_lob.instr(upper(region_source), 'TASKHUB_OWNER.') > 0;
    require(l_count = 0, 'Application 700 region source references TASKHUB_OWNER');

    select count(*) into l_count
      from apex_application_page_proc
     where application_id = 700
       and dbms_lob.instr(upper(process_source), 'TASKHUB_OWNER.') > 0;
    require(l_count = 0, 'Application 700 process source references TASKHUB_OWNER');

    dbms_output.put_line('PASS: TaskHub APEX application metadata and API boundary');
end;
/
