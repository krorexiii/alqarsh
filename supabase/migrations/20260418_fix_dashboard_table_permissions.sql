begin;

create or replace function public.is_shop_staff(check_shop_id uuid)
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
      and role in ('owner', 'admin', 'staff')
  );
$$;

drop policy if exists shop_users_read_self on public.shop_users;

create policy shop_users_read_self
on public.shop_users
for select
to authenticated
using (user_id = auth.uid());

grant insert, update, delete
on table public.sotre_location
to authenticated;

commit;
