create or replace package taskhub_api.pkg_taskhub_api
authid definer
as
    function create_list(
        p_list_name in varchar2
    ) return number;
end pkg_taskhub_api;
/
