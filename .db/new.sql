-- Supabase AI is experimental and may produce incorrect answers
-- Always verify the output before executing

create table
  affiliators (
    id uuid default gen_random_uuid () primary key,
    name text not null,
    email text unique not null,
    phone_number text,
    referral_code text unique not null,
    total_commission numeric(10, 2) default 0.00,
    created_at timestamp default current_timestamp,
    updated_at timestamp default current_timestamp,
    status text default 'active' check (status in ('active', 'inactive', 'suspended'))
  );
