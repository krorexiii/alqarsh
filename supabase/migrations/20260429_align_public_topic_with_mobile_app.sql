create or replace function public.build_shop_broadcast_topic(p_shop_id uuid)
returns text
language sql
immutable
set search_path = public
as $function$
  select 'shop_' || regexp_replace(lower(p_shop_id::text), '[^a-z0-9_-]', '_', 'g') || '_all';
$function$;
