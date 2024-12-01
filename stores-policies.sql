-- Enable RLS on stores table
alter table stores enable row level security;

-- Sellers can view their own stores
create policy "Sellers can view their own stores"
  on stores for select
  using (seller_id = auth.uid());

-- Sellers can create their own store
create policy "Sellers can create their own store"
  on stores for insert
  with check (seller_id = auth.uid());

-- Sellers can update their own store
create policy "Sellers can update their own store"
  on stores for update
  using (seller_id = auth.uid());

-- Sellers can delete their own store
create policy "Sellers can delete their own store"
  on stores for delete
  using (seller_id = auth.uid());
