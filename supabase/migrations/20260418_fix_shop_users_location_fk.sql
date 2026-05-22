begin;

alter table public.shop_users
drop constraint if exists shop_users_location_id_fkey;

alter table public.shop_users
add constraint shop_users_location_id_fkey
foreign key (location_id)
references public.sotre_location (id)
on update cascade
on delete restrict
not valid;

commit;
