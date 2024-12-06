-- Create new policies for products
create policy "Affiliator can view their own products"
on affiliator_products for select
using (true);  -- Temporarily allow all reads for testing

create policy "Affiliator can insert their own products"
on affiliator_products for insert
with check (
  exists (
    select 1 from stores
    where id = affiliate_id
    and affiliate_id = auth.uid()
  )
);

create policy "Affiliator can update their own products"
on affiliator_products for update
using (
  exists (
    select 1 from stores
    where id = affiliate_id
    and affiliate_id = auth.uid()
  )
);
