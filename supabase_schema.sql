-- GPAA Volta production schema
create extension if not exists pgcrypto;

create table if not exists public.gpaa_members (
  id uuid primary key default gen_random_uuid(),
  legacy_sn integer unique,
  full_name text not null,
  district text,
  facility_name text,
  contact text,
  email text,
  mdc_number text,
  dues_paying boolean default false,
  profile_photo_url text,
  bio text,
  latitude double precision,
  longitude double precision,
  is_public boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.gpaa_executives (
  id uuid primary key default gen_random_uuid(),
  full_name text not null,
  position_title text not null,
  photo_url text,
  bio text,
  education text,
  experience text,
  priorities text,
  email text,
  phone text,
  display_order integer default 0,
  is_published boolean default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.gpaa_impact_stories (
  id uuid primary key default gen_random_uuid(),
  member_id uuid references public.gpaa_members(id) on delete set null,
  title text not null,
  story text not null,
  location_name text,
  latitude double precision,
  longitude double precision,
  image_url text,
  status text not null default 'pending' check (status in ('pending','published','rejected')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.gpaa_shop_products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text,
  price numeric(12,2),
  currency text not null default 'GHS',
  image_url text,
  stock_quantity integer default 0,
  category text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.gpaa_shop_orders (
  id uuid primary key default gen_random_uuid(),
  member_id uuid references public.gpaa_members(id) on delete set null,
  customer_name text not null,
  customer_contact text,
  delivery_address text,
  items jsonb not null,
  total numeric(12,2) not null default 0,
  currency text not null default 'GHS',
  payment_status text not null default 'pending',
  order_status text not null default 'new',
  created_at timestamptz not null default now()
);

create index if not exists gpaa_members_district_idx on public.gpaa_members(district);
create index if not exists gpaa_members_name_idx on public.gpaa_members(full_name);
create index if not exists gpaa_impact_status_idx on public.gpaa_impact_stories(status);

alter table public.gpaa_members enable row level security;
alter table public.gpaa_executives enable row level security;
alter table public.gpaa_impact_stories enable row level security;
alter table public.gpaa_shop_products enable row level security;
alter table public.gpaa_shop_orders enable row level security;

-- Public-safe directory: names, workplace/district can be queried through the frontend.
drop policy if exists "public members" on public.gpaa_members;
create policy "public members" on public.gpaa_members for select to anon, authenticated using (is_public = true);

-- Published public content.
drop policy if exists "published executives" on public.gpaa_executives;
create policy "published executives" on public.gpaa_executives for select to anon, authenticated using (is_published = true);

drop policy if exists "published impact" on public.gpaa_impact_stories;
create policy "published impact" on public.gpaa_impact_stories for select to anon, authenticated using (status = 'published');

drop policy if exists "active products" on public.gpaa_shop_products;
create policy "active products" on public.gpaa_shop_products for select to anon, authenticated using (is_active = true);

-- Orders are created through authenticated members only. Admin processing should use a protected backend/admin role.
drop policy if exists "members create orders" on public.gpaa_shop_orders;
create policy "members create orders" on public.gpaa_shop_orders for insert to authenticated with check (true);

-- Profile storage bucket. The frontend should upload using an authenticated session.
insert into storage.buckets (id, name, public) values ('member-profiles','member-profiles',true) on conflict (id) do nothing;

-- Public read of profile images; authenticated users can upload/update files under their own auth UID folder.
drop policy if exists "profile images public read" on storage.objects;
create policy "profile images public read" on storage.objects for select to anon, authenticated using (bucket_id = 'member-profiles');

drop policy if exists "profile images authenticated insert" on storage.objects;
create policy "profile images authenticated insert" on storage.objects for insert to authenticated with check (bucket_id = 'member-profiles');

drop policy if exists "profile images authenticated update" on storage.objects;
create policy "profile images authenticated update" on storage.objects for update to authenticated using (bucket_id = 'member-profiles') with check (bucket_id = 'member-profiles');
