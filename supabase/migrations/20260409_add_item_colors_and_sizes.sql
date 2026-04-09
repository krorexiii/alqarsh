begin;

create table if not exists public.item_colors (
  id bigint generated always as identity not null,
  item_id bigint not null,
  name text not null,
  hex_code text null,
  sort_order smallint not null default 1,
  is_active boolean not null default true,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now(),
  constraint item_colors_pkey primary key (id),
  constraint item_colors_item_id_fkey
    foreign key (item_id) references public.items (id) on delete cascade,
  constraint item_colors_sort_order_chk check (sort_order >= 1),
  constraint item_colors_hex_code_chk
    check (hex_code is null or hex_code ~ '^#[0-9A-Fa-f]{6}$')
);

create index if not exists item_colors_item_id_idx
  on public.item_colors (item_id);

create index if not exists item_colors_item_id_sort_order_idx
  on public.item_colors (item_id, sort_order, id);

create table if not exists public.item_sizes (
  id bigint generated always as identity not null,
  item_id bigint not null,
  name text not null,
  sort_order smallint not null default 1,
  is_active boolean not null default true,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now(),
  constraint item_sizes_pkey primary key (id),
  constraint item_sizes_item_id_fkey
    foreign key (item_id) references public.items (id) on delete cascade,
  constraint item_sizes_sort_order_chk check (sort_order >= 1)
);

create index if not exists item_sizes_item_id_idx
  on public.item_sizes (item_id);

create index if not exists item_sizes_item_id_sort_order_idx
  on public.item_sizes (item_id, sort_order, id);

alter table public.order_items
  add column if not exists selected_color_id bigint null,
  add column if not exists selected_color_name text null,
  add column if not exists selected_color_hex text null,
  add column if not exists selected_size_id bigint null,
  add column if not exists selected_size_name text null;

alter table public.order_items
  drop constraint if exists order_items_selected_color_hex_chk;

alter table public.order_items
  add constraint order_items_selected_color_hex_chk
  check (
    selected_color_hex is null
    or selected_color_hex ~ '^#[0-9A-Fa-f]{6}$'
  );

create index if not exists order_items_selected_color_id_idx
  on public.order_items (selected_color_id);

create index if not exists order_items_selected_size_id_idx
  on public.order_items (selected_size_id);

commit;
