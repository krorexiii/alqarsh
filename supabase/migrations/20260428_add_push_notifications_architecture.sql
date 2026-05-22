create table if not exists public.broadcast_notifications (
  id bigint generated always as identity primary key,
  shop_id uuid not null references public.shops(id) on delete cascade,
  topic text not null,
  type text not null default 'announcement' check (
    type = any (array['promotion'::text, 'announcement'::text])
  ),
  title text not null,
  body text not null,
  image_url text,
  payload jsonb not null default '{}'::jsonb,
  sent_by_user_id uuid references auth.users(id),
  is_sent_fcm boolean not null default false,
  sent_at timestamptz,
  fcm_message_id text,
  delivery_meta jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists broadcast_notifications_shop_created_at_idx
  on public.broadcast_notifications (shop_id, created_at desc);

alter table public.broadcast_notifications enable row level security;

alter table public.fcm_tokens
  add column if not exists device_id text,
  add column if not exists app_version text,
  add column if not exists last_seen_at timestamptz not null default now(),
  add column if not exists topic_name text,
  add column if not exists topic_subscribed_at timestamptz;

alter table public.customer_notifications
  add column if not exists sent_by_user_id uuid references auth.users(id),
  add column if not exists sent_at timestamptz,
  add column if not exists fcm_message_id text,
  add column if not exists delivery_meta jsonb not null default '{}'::jsonb;

create unique index if not exists fcm_tokens_token_key
  on public.fcm_tokens (token);

create index if not exists fcm_tokens_customer_updated_at_idx
  on public.fcm_tokens (customer_id, updated_at desc);

create index if not exists customer_notifications_shop_created_at_idx
  on public.customer_notifications (shop_id, created_at desc);

create or replace function public.build_shop_broadcast_topic(p_shop_id uuid)
returns text
language sql
immutable
set search_path = public
as $function$
  select 'shop_' || regexp_replace(lower(p_shop_id::text), '[^a-z0-9]+', '_', 'g') || '_broadcast';
$function$;

create or replace function public.get_my_customer_id()
returns bigint
language sql
stable
security definer
set search_path = public
as $function$
  select c.id
  from public.customers c
  where c.auth_user_id = auth.uid()
  limit 1;
$function$;

create or replace function public.get_my_customer_shop_id()
returns uuid
language sql
stable
security definer
set search_path = public
as $function$
  select c.shop_id
  from public.customers c
  where c.auth_user_id = auth.uid()
  limit 1;
$function$;

create or replace function public.get_public_broadcast_notifications(
  p_shop_id uuid,
  p_limit integer default 50
)
returns table (
  id bigint,
  shop_id uuid,
  topic text,
  type text,
  title text,
  body text,
  image_url text,
  payload jsonb,
  is_sent_fcm boolean,
  created_at timestamptz
)
language sql
stable
security definer
set search_path = public
as $function$
  select
    bn.id,
    bn.shop_id,
    bn.topic,
    bn.type,
    bn.title,
    bn.body,
    bn.image_url,
    bn.payload,
    bn.is_sent_fcm,
    bn.created_at
  from public.broadcast_notifications bn
  where bn.shop_id = p_shop_id
  order by bn.created_at desc
  limit greatest(1, least(coalesce(p_limit, 50), 200));
$function$;

create or replace function public.get_my_notification_feed(
  p_limit integer default 100
)
returns table (
  id bigint,
  scope text,
  type text,
  title text,
  body text,
  image_url text,
  payload jsonb,
  order_id bigint,
  order_status text,
  is_read boolean,
  is_sent_fcm boolean,
  created_at timestamptz
)
language plpgsql
stable
security definer
set search_path = public
as $function$
declare
  v_customer_id bigint := public.get_my_customer_id();
  v_shop_id uuid := public.get_my_customer_shop_id();
  v_limit integer := greatest(1, least(coalesce(p_limit, 100), 200));
begin
  if auth.uid() is null or v_customer_id is null or v_shop_id is null then
    return;
  end if;

  return query
  with merged_feed as (
    select
      bn.id,
      'broadcast'::text as scope,
      bn.type,
      bn.title,
      bn.body,
      bn.image_url,
      bn.payload,
      null::bigint as order_id,
      null::text as order_status,
      false as is_read,
      bn.is_sent_fcm,
      bn.created_at
    from public.broadcast_notifications bn
    where bn.shop_id = v_shop_id

    union all

    select
      cn.id,
      'customer'::text as scope,
      cn.type,
      cn.title,
      cn.body,
      cn.image_url,
      coalesce(cn.payload, '{}'::jsonb),
      cn.order_id,
      cn.order_status,
      cn.is_read,
      cn.is_sent_fcm,
      cn.created_at
    from public.customer_notifications cn
    where cn.shop_id = v_shop_id
      and cn.customer_id = v_customer_id
  )
  select *
  from merged_feed
  order by created_at desc
  limit v_limit;
end;
$function$;

create or replace function public.upsert_my_fcm_token(
  p_token text,
  p_platform text default 'unknown',
  p_device_id text default null,
  p_app_version text default null,
  p_topic_name text default null
)
returns public.fcm_tokens
language plpgsql
security definer
set search_path = public
as $function$
declare
  v_customer_id bigint := public.get_my_customer_id();
  v_shop_id uuid := public.get_my_customer_shop_id();
  v_platform text := lower(coalesce(nullif(trim(p_platform), ''), 'unknown'));
  v_topic_name text := nullif(trim(p_topic_name), '');
  v_row public.fcm_tokens%rowtype;
begin
  if auth.uid() is null then
    raise exception 'AUTH_REQUIRED';
  end if;

  if v_customer_id is null or v_shop_id is null then
    raise exception 'CUSTOMER_PROFILE_NOT_FOUND';
  end if;

  if trim(coalesce(p_token, '')) = '' then
    raise exception 'TOKEN_REQUIRED';
  end if;

  if v_platform not in ('android', 'ios', 'web', 'unknown') then
    v_platform := 'unknown';
  end if;

  insert into public.fcm_tokens (
    shop_id,
    customer_id,
    token,
    platform,
    device_id,
    app_version,
    is_active,
    last_seen_at,
    updated_at,
    topic_name,
    topic_subscribed_at
  )
  values (
    v_shop_id,
    v_customer_id,
    trim(p_token),
    v_platform,
    nullif(trim(p_device_id), ''),
    nullif(trim(p_app_version), ''),
    true,
    now(),
    now(),
    v_topic_name,
    case when v_topic_name is null then null else now() end
  )
  on conflict (token) do update
  set
    shop_id = excluded.shop_id,
    customer_id = excluded.customer_id,
    platform = excluded.platform,
    device_id = coalesce(excluded.device_id, public.fcm_tokens.device_id),
    app_version = coalesce(excluded.app_version, public.fcm_tokens.app_version),
    is_active = true,
    last_seen_at = now(),
    updated_at = now(),
    topic_name = coalesce(excluded.topic_name, public.fcm_tokens.topic_name),
    topic_subscribed_at = case
      when excluded.topic_name is null then public.fcm_tokens.topic_subscribed_at
      else now()
    end
  returning * into v_row;

  return v_row;
end;
$function$;

create or replace function public.deactivate_my_fcm_token(p_token text)
returns boolean
language plpgsql
security definer
set search_path = public
as $function$
declare
  v_customer_id bigint := public.get_my_customer_id();
  v_shop_id uuid := public.get_my_customer_shop_id();
begin
  if auth.uid() is null then
    raise exception 'AUTH_REQUIRED';
  end if;

  if v_customer_id is null or v_shop_id is null then
    raise exception 'CUSTOMER_PROFILE_NOT_FOUND';
  end if;

  update public.fcm_tokens
  set
    is_active = false,
    updated_at = now()
  where shop_id = v_shop_id
    and customer_id = v_customer_id
    and token = trim(coalesce(p_token, ''));

  return found;
end;
$function$;

drop policy if exists notifications_read_own on public.customer_notifications;
drop policy if exists notifications_update_own on public.customer_notifications;
drop policy if exists fcm_tokens_select_own on public.fcm_tokens;
drop policy if exists fcm_tokens_insert_own on public.fcm_tokens;
drop policy if exists fcm_tokens_update_own on public.fcm_tokens;
drop policy if exists fcm_tokens_delete_own on public.fcm_tokens;
drop policy if exists broadcast_notifications_read_staff on public.broadcast_notifications;
drop policy if exists broadcast_notifications_admin_manage on public.broadcast_notifications;

create policy notifications_read_own
on public.customer_notifications
for select
to authenticated
using (
  customer_id = public.get_my_customer_id()
  and shop_id = public.get_my_customer_shop_id()
);

create policy notifications_update_own
on public.customer_notifications
for update
to authenticated
using (
  customer_id = public.get_my_customer_id()
  and shop_id = public.get_my_customer_shop_id()
)
with check (
  customer_id = public.get_my_customer_id()
  and shop_id = public.get_my_customer_shop_id()
);

create policy fcm_tokens_select_own
on public.fcm_tokens
for select
to authenticated
using (
  customer_id = public.get_my_customer_id()
  and shop_id = public.get_my_customer_shop_id()
);

create policy fcm_tokens_insert_own
on public.fcm_tokens
for insert
to authenticated
with check (
  customer_id = public.get_my_customer_id()
  and shop_id = public.get_my_customer_shop_id()
);

create policy fcm_tokens_update_own
on public.fcm_tokens
for update
to authenticated
using (
  customer_id = public.get_my_customer_id()
  and shop_id = public.get_my_customer_shop_id()
)
with check (
  customer_id = public.get_my_customer_id()
  and shop_id = public.get_my_customer_shop_id()
);

create policy fcm_tokens_delete_own
on public.fcm_tokens
for delete
to authenticated
using (
  customer_id = public.get_my_customer_id()
  and shop_id = public.get_my_customer_shop_id()
);

create policy broadcast_notifications_read_staff
on public.broadcast_notifications
for select
to authenticated
using (public.is_shop_staff(shop_id));

create policy broadcast_notifications_admin_manage
on public.broadcast_notifications
for all
to authenticated
using (public.is_shop_admin(shop_id))
with check (public.is_shop_admin(shop_id));

grant select on table public.broadcast_notifications to authenticated;
grant insert, update, delete on table public.broadcast_notifications to authenticated;

grant execute on function public.build_shop_broadcast_topic(uuid) to anon, authenticated;
grant execute on function public.get_public_broadcast_notifications(uuid, integer) to anon, authenticated;
grant execute on function public.get_my_customer_id() to authenticated;
grant execute on function public.get_my_customer_shop_id() to authenticated;
grant execute on function public.get_my_notification_feed(integer) to authenticated;
grant execute on function public.upsert_my_fcm_token(text, text, text, text, text) to authenticated;
grant execute on function public.deactivate_my_fcm_token(text) to authenticated;
