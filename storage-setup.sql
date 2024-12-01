-- Create the storage bucket for product media
insert into storage.buckets (id, name, public)
values ('product-media', 'product-media', true);

-- Allow public read access to files
create policy "Public Access"
on storage.objects for select
using ( bucket_id = 'product-media' );

-- Allow authenticated sellers to upload files
-- The path pattern will be: product-media/{store_id}/images/* or product-media/{store_id}/videos/*
create policy "Sellers can upload their own media"
on storage.objects for insert
to authenticated
with check (
  bucket_id = 'product-media' 
  and (
    -- Check if the user owns the store based on the path
    exists (
      select 1 from public.stores
      where id::text = (storage.foldername(name))[1]
      and seller_id = auth.uid()
    )
  )
);

-- Allow authenticated sellers to update their own files
create policy "Sellers can update their own media"
on storage.objects for update
to authenticated
using (
  bucket_id = 'product-media'
  and (
    exists (
      select 1 from public.stores
      where id::text = (storage.foldername(name))[1]
      and seller_id = auth.uid()
    )
  )
);

-- Allow authenticated sellers to delete their own files
create policy "Sellers can delete their own media"
on storage.objects for delete
to authenticated
using (
  bucket_id = 'product-media'
  and (
    exists (
      select 1 from public.stores
      where id::text = (storage.foldername(name))[1]
      and seller_id = auth.uid()
    )
  )
);

-- Helper function to get path segments
create or replace function storage.foldername(name text)
returns text[]
language plpgsql
as $$
begin
  return string_to_array(regexp_replace(name, '^[^/]*/', ''), '/');
end
$$;
