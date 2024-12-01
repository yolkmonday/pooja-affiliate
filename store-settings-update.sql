-- Add new columns to stores table
alter table stores add column if not exists banner_url text;
alter table stores add column if not exists theme jsonb default '{
  "primary_color": "#6419E6",
  "secondary_color": "#D926AA",
  "accent_color": "#1FB2A5",
  "neutral_color": "#191D24",
  "font_family": "Inter, sans-serif"
}'::jsonb;
alter table stores add column if not exists social_media jsonb default '{
  "facebook": "",
  "instagram": "",
  "twitter": "",
  "tiktok": ""
}'::jsonb;

-- Create shipping_methods table
create table if not exists shipping_methods (
  id uuid primary key default uuid_generate_v4(),
  store_id uuid references stores(id) on delete cascade,
  name text not null,
  description text,
  base_cost decimal(10,2) not null default 0,
  is_active boolean default true,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Create payment_methods table
create table if not exists payment_methods (
  id uuid primary key default uuid_generate_v4(),
  store_id uuid references stores(id) on delete cascade,
  name text not null,
  type text not null check (type in ('bank_transfer', 'e_wallet', 'cod')),
  account_number text,
  account_name text,
  instructions text,
  is_active boolean default true,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Add RLS policies for shipping_methods
alter table shipping_methods enable row level security;

create policy "Sellers can view their shipping methods"
  on shipping_methods for select
  using (
    exists (
      select 1 from stores
      where id = shipping_methods.store_id
      and seller_id = auth.uid()
    )
  );

create policy "Sellers can create their shipping methods"
  on shipping_methods for insert
  with check (
    exists (
      select 1 from stores
      where id = shipping_methods.store_id
      and seller_id = auth.uid()
    )
  );

create policy "Sellers can update their shipping methods"
  on shipping_methods for update
  using (
    exists (
      select 1 from stores
      where id = shipping_methods.store_id
      and seller_id = auth.uid()
    )
  );

create policy "Sellers can delete their shipping methods"
  on shipping_methods for delete
  using (
    exists (
      select 1 from stores
      where id = shipping_methods.store_id
      and seller_id = auth.uid()
    )
  );

-- Add RLS policies for payment_methods
alter table payment_methods enable row level security;

create policy "Sellers can view their payment methods"
  on payment_methods for select
  using (
    exists (
      select 1 from stores
      where id = payment_methods.store_id
      and seller_id = auth.uid()
    )
  );

create policy "Sellers can create their payment methods"
  on payment_methods for insert
  with check (
    exists (
      select 1 from stores
      where id = payment_methods.store_id
      and seller_id = auth.uid()
    )
  );

create policy "Sellers can update their payment methods"
  on payment_methods for update
  using (
    exists (
      select 1 from stores
      where id = payment_methods.store_id
      and seller_id = auth.uid()
    )
  );

create policy "Sellers can delete their payment methods"
  on payment_methods for delete
  using (
    exists (
      select 1 from stores
      where id = payment_methods.store_id
      and seller_id = auth.uid()
    )
  );

-- Create storage bucket for store banners if it doesn't exist
insert into storage.buckets (id, name, public)
values ('store-assets', 'store-assets', true)
on conflict (id) do nothing;

-- Add storage policy for store assets
create policy "Authenticated users can upload store assets"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'store-assets' and
    (storage.foldername(name))[1] in (
      select id::text from stores
      where seller_id = auth.uid()
    )
  );
