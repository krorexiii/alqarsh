begin;

create or replace function public.get_my_shop_role(check_shop_id uuid default null)
returns text
language sql
stable
security definer
set search_path = 'public'
as $$
  select su.role
  from public.shop_users su
  where su.user_id = auth.uid()
    and (check_shop_id is null or su.shop_id = check_shop_id)
  order by case su.role
    when 'owner' then 1
    when 'admin' then 2
    when 'staff' then 3
    else 99
  end
  limit 1;
$$;

create or replace function public.is_shop_admin(check_shop_id uuid)
returns boolean
language sql
stable
security definer
set search_path = 'public'
as $$
  select exists (
    select 1
    from public.shop_users
    where user_id = auth.uid()
      and shop_id = check_shop_id
      and role in ('owner', 'admin')
  );
$$;

create or replace function public.get_my_staff_location_id(check_shop_id uuid default null)
returns bigint
language sql
stable
security definer
set search_path = 'public'
as $$
  select su.location_id
  from public.shop_users su
  where su.user_id = auth.uid()
    and su.role = 'staff'
    and (check_shop_id is null or su.shop_id = check_shop_id)
  limit 1;
$$;

create or replace function public.can_read_shop_order(
  check_shop_id uuid,
  assigned_location_id bigint
)
returns boolean
language sql
stable
security definer
set search_path = 'public'
as $$
  select
    public.is_shop_admin(check_shop_id)
    or exists (
      select 1
      from public.shop_users su
      where su.user_id = auth.uid()
        and su.shop_id = check_shop_id
        and su.role = 'staff'
        and su.location_id is not null
        and su.location_id = assigned_location_id
    );
$$;

create or replace function public.can_write_shop_order(
  check_shop_id uuid,
  assigned_location_id bigint
)
returns boolean
language sql
stable
security definer
set search_path = 'public'
as $$
  select
    public.is_shop_admin(check_shop_id)
    or exists (
      select 1
      from public.shop_users su
      where su.user_id = auth.uid()
        and su.shop_id = check_shop_id
        and su.role = 'staff'
        and su.location_id is not null
        and (su.location_id = assigned_location_id or assigned_location_id is null)
    );
$$;

create or replace function public.compute_discount_code_amount(
  p_subtotal numeric,
  p_discount_type text,
  p_discount_percent integer,
  p_discount_amount numeric,
  p_max_discount_amount numeric
)
returns numeric
language plpgsql
immutable
set search_path = 'public'
as $function$
declare
  v_discount numeric := 0;
begin
  if coalesce(p_subtotal, 0) <= 0 then
    return 0;
  end if;

  if p_discount_type = 'percent' then
    v_discount := round(p_subtotal * (coalesce(p_discount_percent, 0)::numeric / 100), 2);
  else
    v_discount := coalesce(p_discount_amount, 0);
  end if;

  if p_max_discount_amount is not null and v_discount > p_max_discount_amount then
    v_discount := p_max_discount_amount;
  end if;

  if v_discount > p_subtotal then
    v_discount := p_subtotal;
  end if;

  if v_discount < 0 then
    v_discount := 0;
  end if;

  return round(v_discount, 2);
end;
$function$;

create or replace function public.apply_discount_code_to_order()
returns trigger
language plpgsql
set search_path = 'public'
as $function$
declare
  v_discount_code public.discount_codes%rowtype;
  v_discount_amount numeric := 0;
begin
  if new.discount_code_id is null then
    new.discount_amount := 0;
    new.discount_code_snapshot := null;
    new.total := greatest(coalesce(new.subtotal, 0) + coalesce(new.delivery_fee, 0), 0);
    return new;
  end if;

  select *
  into v_discount_code
  from public.discount_codes
  where id = new.discount_code_id
    and shop_id = new.shop_id
  for update;

  if not found then
    raise exception 'DISCOUNT_CODE_NOT_FOUND';
  end if;

  if coalesce(v_discount_code.is_active, false) = false then
    raise exception 'DISCOUNT_CODE_INACTIVE';
  end if;

  if v_discount_code.expiry_date < current_date then
    raise exception 'DISCOUNT_CODE_EXPIRED';
  end if;

  if coalesce(new.subtotal, 0) < coalesce(v_discount_code.min_purchase_amount, 0) then
    raise exception 'DISCOUNT_CODE_MIN_PURCHASE_NOT_MET';
  end if;

  if v_discount_code.limit_count is not null
     and coalesce(v_discount_code.used_count, 0) >= v_discount_code.limit_count then
    raise exception 'DISCOUNT_CODE_LIMIT_REACHED';
  end if;

  v_discount_amount := public.compute_discount_code_amount(
    p_subtotal => coalesce(new.subtotal, 0),
    p_discount_type => v_discount_code.discount_type,
    p_discount_percent => v_discount_code.discount_percent,
    p_discount_amount => v_discount_code.discount_amount,
    p_max_discount_amount => v_discount_code.max_discount_amount
  );

  if v_discount_amount <= 0 then
    raise exception 'DISCOUNT_CODE_INVALID_AMOUNT';
  end if;

  new.discount_code_snapshot := v_discount_code.code;
  new.discount_amount := v_discount_amount;
  new.total := greatest(
    coalesce(new.subtotal, 0) - v_discount_amount + coalesce(new.delivery_fee, 0),
    0
  );

  update public.discount_codes
  set used_count = used_count + 1,
      updated_at = now()
  where id = v_discount_code.id;

  return new;
end;
$function$;

create or replace function public.prepare_discount_code_row()
returns trigger
language plpgsql
set search_path = 'public'
as $function$
begin
  new.code := upper(trim(coalesce(new.code, '')));
  new.discount_type := lower(trim(coalesce(new.discount_type, 'amount')));
  new.min_purchase_amount := coalesce(new.min_purchase_amount, 0);
  new.is_active := coalesce(new.is_active, true);
  new.updated_at := now();

  if tg_op = 'insert' and new.created_at is null then
    new.created_at := now();
  end if;

  if new.discount_type = 'percent' then
    new.discount_amount := null;
  elsif new.discount_type = 'amount' then
    new.discount_percent := null;
  end if;

  return new;
end;
$function$;

create or replace function public.release_discount_code_from_deleted_order()
returns trigger
language plpgsql
set search_path = 'public'
as $function$
begin
  if old.discount_code_id is not null then
    update public.discount_codes
    set used_count = greatest(used_count - 1, 0),
        updated_at = now()
    where id = old.discount_code_id;
  end if;

  return old;
end;
$function$;

drop policy if exists banner_ads_all_staff on public.banner_ads;
drop policy if exists categories_all_staff on public.categories;
drop policy if exists delivery_zones_all_staff on public.delivery_zones;
drop policy if exists discount_codes_all_staff on public.discount_codes;
drop policy if exists items_all_staff on public.items;
drop policy if exists parts_all_staff on public.parts;
drop policy if exists store_location_all_staff on public.sotre_location;
drop policy if exists item_images_all_staff on public.item_images;
drop policy if exists item_colors_all_staff on public.item_colors;
drop policy if exists item_sizes_all_staff on public.item_sizes;
drop policy if exists part_items_all_staff on public.part_items;
drop policy if exists notifications_create_for_own on public.customer_notifications;
drop policy if exists notifications_create_staff on public.customer_notifications;
drop policy if exists notifications_read_staff on public.customer_notifications;
drop policy if exists customer_read_staff on public.customers;
drop policy if exists fcm_read_staff on public.fcm_tokens;
drop policy if exists order_items_read_staff on public.order_items;
drop policy if exists history_create_own on public.order_status_history;
drop policy if exists history_create_staff on public.order_status_history;
drop policy if exists history_read_staff on public.order_status_history;
drop policy if exists orders_read_staff on public.orders;
drop policy if exists orders_update_staff on public.orders;
drop policy if exists shop_users_read_colleagues on public.shop_users;
drop policy if exists store_location_read_staff on public.sotre_location;
drop policy if exists password_reset_insert on public.password_reset_otps;
drop policy if exists password_reset_select on public.password_reset_otps;
drop policy if exists password_reset_update on public.password_reset_otps;

create policy banner_ads_read_staff
on public.banner_ads
for select
to authenticated
using (public.is_shop_staff(shop_id));

create policy banner_ads_admin_manage
on public.banner_ads
for all
to authenticated
using (public.is_shop_admin(shop_id))
with check (public.is_shop_admin(shop_id));

create policy categories_read_staff
on public.categories
for select
to authenticated
using (public.is_shop_staff(shop_id));

create policy categories_admin_manage
on public.categories
for all
to authenticated
using (public.is_shop_admin(shop_id))
with check (public.is_shop_admin(shop_id));

create policy delivery_zones_read_staff
on public.delivery_zones
for select
to authenticated
using (public.is_shop_staff(shop_id));

create policy delivery_zones_admin_manage
on public.delivery_zones
for all
to authenticated
using (public.is_shop_admin(shop_id))
with check (public.is_shop_admin(shop_id));

create policy discount_codes_read_staff
on public.discount_codes
for select
to authenticated
using (public.is_shop_staff(shop_id));

create policy discount_codes_admin_manage
on public.discount_codes
for all
to authenticated
using (public.is_shop_admin(shop_id))
with check (public.is_shop_admin(shop_id));

create policy items_read_staff
on public.items
for select
to authenticated
using (public.is_shop_staff(shop_id));

create policy items_admin_manage
on public.items
for all
to authenticated
using (public.is_shop_admin(shop_id))
with check (public.is_shop_admin(shop_id));

create policy parts_read_staff
on public.parts
for select
to authenticated
using (public.is_shop_staff(shop_id));

create policy parts_admin_manage
on public.parts
for all
to authenticated
using (public.is_shop_admin(shop_id))
with check (public.is_shop_admin(shop_id));

create policy store_location_read_staff
on public.sotre_location
for select
to authenticated
using (public.is_shop_staff(shop_id));

create policy store_location_admin_manage
on public.sotre_location
for all
to authenticated
using (public.is_shop_admin(shop_id))
with check (public.is_shop_admin(shop_id));

create policy item_images_read_staff
on public.item_images
for select
to authenticated
using (
  item_id in (
    select i.id
    from public.items i
    where public.is_shop_staff(i.shop_id)
  )
);

create policy item_images_admin_manage
on public.item_images
for all
to authenticated
using (
  item_id in (
    select i.id
    from public.items i
    where public.is_shop_admin(i.shop_id)
  )
)
with check (
  item_id in (
    select i.id
    from public.items i
    where public.is_shop_admin(i.shop_id)
  )
);

create policy item_colors_read_staff
on public.item_colors
for select
to authenticated
using (
  item_id in (
    select i.id
    from public.items i
    where public.is_shop_staff(i.shop_id)
  )
);

create policy item_colors_admin_manage
on public.item_colors
for all
to authenticated
using (
  item_id in (
    select i.id
    from public.items i
    where public.is_shop_admin(i.shop_id)
  )
)
with check (
  item_id in (
    select i.id
    from public.items i
    where public.is_shop_admin(i.shop_id)
  )
);

create policy item_sizes_read_staff
on public.item_sizes
for select
to authenticated
using (
  item_id in (
    select i.id
    from public.items i
    where public.is_shop_staff(i.shop_id)
  )
);

create policy item_sizes_admin_manage
on public.item_sizes
for all
to authenticated
using (
  item_id in (
    select i.id
    from public.items i
    where public.is_shop_admin(i.shop_id)
  )
)
with check (
  item_id in (
    select i.id
    from public.items i
    where public.is_shop_admin(i.shop_id)
  )
);

create policy part_items_read_staff
on public.part_items
for select
to authenticated
using (
  part_id in (
    select p.id
    from public.parts p
    where public.is_shop_staff(p.shop_id)
  )
);

create policy part_items_admin_manage
on public.part_items
for all
to authenticated
using (
  part_id in (
    select p.id
    from public.parts p
    where public.is_shop_admin(p.shop_id)
  )
)
with check (
  part_id in (
    select p.id
    from public.parts p
    where public.is_shop_admin(p.shop_id)
  )
);

create policy customer_read_staff
on public.customers
for select
to authenticated
using (public.is_shop_staff(shop_id));

create policy notifications_read_staff
on public.customer_notifications
for select
to authenticated
using (public.is_shop_staff(shop_id));

create policy notifications_admin_manage
on public.customer_notifications
for all
to authenticated
using (public.is_shop_admin(shop_id))
with check (public.is_shop_admin(shop_id));

create policy order_items_read_staff
on public.order_items
for select
to authenticated
using (
  order_id in (
    select o.id
    from public.orders o
    where public.can_read_shop_order(o.shop_id, o.assigned_location_id)
  )
);

create policy history_read_staff
on public.order_status_history
for select
to authenticated
using (
  order_id in (
    select o.id
    from public.orders o
    where public.can_read_shop_order(o.shop_id, o.assigned_location_id)
  )
);

create policy history_create_staff
on public.order_status_history
for insert
to authenticated
with check (
  order_id in (
    select o.id
    from public.orders o
    where public.can_write_shop_order(o.shop_id, o.assigned_location_id)
  )
);

create policy orders_read_staff
on public.orders
for select
to authenticated
using (public.can_read_shop_order(shop_id, assigned_location_id));

create policy orders_update_staff
on public.orders
for update
to authenticated
using (public.can_read_shop_order(shop_id, assigned_location_id))
with check (public.can_write_shop_order(shop_id, assigned_location_id));

create policy shop_users_read_colleagues
on public.shop_users
for select
to authenticated
using (public.is_shop_admin(shop_id));

revoke all on all tables in schema public from anon, authenticated;
revoke all on all sequences in schema public from anon, authenticated;

grant select
on table
  public.app_versions,
  public.banner_ads,
  public.categories,
  public.delivery_zones,
  public.discount_codes,
  public.item_colors,
  public.item_images,
  public.item_sizes,
  public.items,
  public.part_items,
  public.parts
to anon;

grant select
on table
  public.app_versions,
  public.banner_ads,
  public.carts,
  public.cart_items,
  public.categories,
  public.customer_notifications,
  public.customers,
  public.delivery_zones,
  public.discount_codes,
  public.favorites,
  public.fcm_tokens,
  public.item_colors,
  public.item_images,
  public.item_sizes,
  public.items,
  public.location,
  public.order_items,
  public.order_status_history,
  public.orders,
  public.part_items,
  public.parts,
  public.shop_users,
  public.shops,
  public.sotre_location,
  public.whatsapp_otps
to authenticated;

grant insert, update, delete
on table
  public.banner_ads,
  public.categories,
  public.customer_notifications,
  public.delivery_zones,
  public.discount_codes,
  public.item_colors,
  public.item_images,
  public.item_sizes,
  public.items,
  public.part_items,
  public.parts
to authenticated;

grant insert, update
on table
  public.carts,
  public.cart_items,
  public.customers,
  public.favorites,
  public.fcm_tokens,
  public.location,
  public.order_status_history,
  public.orders,
  public.whatsapp_otps
to authenticated;

grant delete
on table
  public.carts,
  public.cart_items,
  public.favorites,
  public.fcm_tokens,
  public.location
to authenticated;

grant insert
on table
  public.order_items
to authenticated;

grant usage, select
on all sequences in schema public
to authenticated;

alter default privileges in schema public revoke all on tables from anon, authenticated;
alter default privileges in schema public revoke all on sequences from anon, authenticated;
alter default privileges in schema public grant usage, select on sequences to authenticated;

drop policy if exists storage_public_read_ads on storage.objects;
drop policy if exists storage_public_read_icon on storage.objects;
drop policy if exists storage_public_read_items on storage.objects;
drop policy if exists storage_admin_manage_ads on storage.objects;
drop policy if exists storage_admin_manage_icon on storage.objects;
drop policy if exists storage_admin_manage_items on storage.objects;

create policy storage_admin_manage_ads
on storage.objects
for all
to authenticated
using (
  bucket_id = 'ads'
  and public.is_shop_admin(public.get_my_shop_id())
  and coalesce((storage.foldername(name))[1], '') = ('shop_' || public.get_my_shop_id()::text)
)
with check (
  bucket_id = 'ads'
  and public.is_shop_admin(public.get_my_shop_id())
  and coalesce((storage.foldername(name))[1], '') = ('shop_' || public.get_my_shop_id()::text)
);

create policy storage_admin_manage_icon
on storage.objects
for all
to authenticated
using (
  bucket_id = 'icon'
  and public.is_shop_admin(public.get_my_shop_id())
  and coalesce((storage.foldername(name))[1], '') = ('shop_' || public.get_my_shop_id()::text)
)
with check (
  bucket_id = 'icon'
  and public.is_shop_admin(public.get_my_shop_id())
  and coalesce((storage.foldername(name))[1], '') = ('shop_' || public.get_my_shop_id()::text)
);

create policy storage_admin_manage_items
on storage.objects
for all
to authenticated
using (
  bucket_id = 'items'
  and public.is_shop_admin(public.get_my_shop_id())
  and coalesce((storage.foldername(name))[1], '') = ('shop_' || public.get_my_shop_id()::text)
)
with check (
  bucket_id = 'items'
  and public.is_shop_admin(public.get_my_shop_id())
  and coalesce((storage.foldername(name))[1], '') = ('shop_' || public.get_my_shop_id()::text)
);

commit;
