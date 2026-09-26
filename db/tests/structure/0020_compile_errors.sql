-- Generic read-only compilation error check for the currently connected schema.

select name,
       type,
       line,
       position,
       text
from user_errors
order by name, sequence;
