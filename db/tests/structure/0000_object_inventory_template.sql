-- TEMPLATE - do not treat as a completed test until expected objects are filled in.
-- Run separately in the relevant schema(s).

select object_type,
       object_name,
       status
from user_objects
order by object_type, object_name;
