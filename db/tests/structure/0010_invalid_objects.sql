-- Generic read-only invalid object check for the currently connected schema.

select object_type,
       object_name,
       status
from user_objects
where status <> 'VALID'
order by object_type, object_name;
