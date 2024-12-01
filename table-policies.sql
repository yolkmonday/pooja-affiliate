-- Drop existing policies first
drop policy if exists "Sellers can view their own products" on products;
drop policy if exists "Sellers can insert their own products" on products;
drop policy if exists "Sellers can update their own products" on products;
drop policy if exists "Sellers can delete their own products" on products;

drop policy if exists "Sellers can view inventory" on inventory;
drop policy if exists "Sellers can insert inventory" on inventory;
drop policy if exists "Sellers can update inventory" on inventory;
drop policy if exists "Sellers can delete inventory" on inventory;

drop policy if exists "Public Access" on storage.objects;
drop policy if exists "Sellers can upload their own media" on storage.objects;
drop policy if exists "Sellers can update their own media" on storage.objects;
drop policy if exists "Sellers can delete their own media" on storage.objects;

-- Enable RLS
alter table products enable row level security;
alter table inventory enable row level security;

-- Create new policies for products
create policy "Sellers can view their own products"
on products for select
using (true);  -- Temporarily allow all reads for testing

create policy "Sellers can insert their own products"
on products for insert
with check (
  exists (
    select 1 from stores
    where id = store_id
    and seller_id = auth.uid()
  )
);

create policy "Sellers can update their own products"
on products for update
using (
  exists (
    select 1 from stores
    where id = store_id
    and seller_id = auth.uid()
  )
);

create policy "Sellers can delete their own products"
on products for delete
using (
  exists (
    select 1 from stores
    where id = store_id
    and seller_id = auth.uid()
  )
);

-- Create new policies for inventory
create policy "Sellers can view inventory"
on inventory for select
using (true);  -- Temporarily allow all reads for testing

create policy "Sellers can insert inventory"
on inventory for insert
with check (
  exists (
    select 1 from products p
    join stores s on s.id = p.store_id
    where p.id = product_id
    and s.seller_id = auth.uid()
  )
);

create policy "Sellers can update inventory"
on inventory for update
using (
  exists (
    select 1 from products p
    join stores s on s.id = p.store_id
    where p.id = product_id
    and s.seller_id = auth.uid()
  )
);

create policy "Sellers can delete inventory"
on inventory for delete
using (
  exists (
    select 1 from products p
    join stores s on s.id = p.store_id
    where p.id = product_id
    and s.seller_id = auth.uid()
  )
);

-- Create new storage policies
create policy "Public Access"
on storage.objects for select
using ( bucket_id = 'product-media' );

create policy "Sellers can upload their own media"
on storage.objects for insert
to authenticated
with check (
  bucket_id = 'product-media'
);

create policy "Sellers can update their own media"
on storage.objects for update
to authenticated
using (
  bucket_id = 'product-media'
);

create policy "Sellers can delete their own media"
on storage.objects for delete
to authenticated
using (
  bucket_id = 'product-media'
);
