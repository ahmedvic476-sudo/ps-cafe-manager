-- PS Cafe Manager V6.2.0 — Owner-controlled secure cloud setup
-- Run inside the BUSINESS OWNER'S Supabase project SQL Editor only.
-- Before running the INSERT block below: create the owner's user in Supabase Authentication > Users.

create extension if not exists pgcrypto;

create table if not exists public.ps_businesses (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  owner_user_id uuid not null references auth.users(id) on delete restrict,
  created_at timestamptz not null default now()
);

create table if not exists public.ps_business_members (
  business_id uuid not null references public.ps_businesses(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null check (role in ('owner','manager','cashier','viewer')),
  active boolean not null default true,
  created_at timestamptz not null default now(),
  primary key (business_id, user_id)
);

create table if not exists public.ps_business_state (
  business_id uuid primary key references public.ps_businesses(id) on delete cascade,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  updated_by uuid default auth.uid() references auth.users(id)
);

alter table public.ps_businesses enable row level security;
alter table public.ps_business_members enable row level security;
alter table public.ps_business_state enable row level security;

revoke all on public.ps_businesses, public.ps_business_members, public.ps_business_state from anon;
grant select on public.ps_businesses, public.ps_business_members, public.ps_business_state to authenticated;
grant insert, update on public.ps_business_state to authenticated;
grant insert, update, delete on public.ps_business_members to authenticated;

create or replace function public.ps_is_member(target_business uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.ps_business_members m
    where m.business_id = target_business and m.user_id = auth.uid() and m.active);
$$;

create or replace function public.ps_is_owner(target_business uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.ps_business_members m
    where m.business_id = target_business and m.user_id = auth.uid() and m.active and m.role = 'owner');
$$;

create or replace function public.ps_can_write(target_business uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.ps_business_members m
    where m.business_id = target_business and m.user_id = auth.uid() and m.active
      and m.role in ('owner','manager','cashier'));
$$;

drop policy if exists ps_business_read on public.ps_businesses;
create policy ps_business_read on public.ps_businesses for select to authenticated
using (public.ps_is_member(id));

drop policy if exists ps_member_read on public.ps_business_members;
create policy ps_member_read on public.ps_business_members for select to authenticated
using (public.ps_is_member(business_id));

drop policy if exists ps_member_owner_manage on public.ps_business_members;
create policy ps_member_owner_manage on public.ps_business_members for all to authenticated
using (public.ps_is_owner(business_id)) with check (public.ps_is_owner(business_id));

drop policy if exists ps_state_read on public.ps_business_state;
create policy ps_state_read on public.ps_business_state for select to authenticated
using (public.ps_is_member(business_id));

drop policy if exists ps_state_write on public.ps_business_state;
create policy ps_state_write on public.ps_business_state for insert to authenticated
with check (public.ps_can_write(business_id));

drop policy if exists ps_state_update on public.ps_business_state;
create policy ps_state_update on public.ps_business_state for update to authenticated
using (public.ps_can_write(business_id)) with check (public.ps_can_write(business_id));

-- INITIAL OWNER SETUP — replace both values before running these three statements:
-- 1) <OWNER_AUTH_USER_UUID> = UUID from Authentication > Users
-- 2) <BUSINESS_NAME> = real shop/business name
-- insert into public.ps_businesses (name, owner_user_id) values ('<BUSINESS_NAME>', '<OWNER_AUTH_USER_UUID>'::uuid) returning id;
-- Copy the returned id and replace <BUSINESS_UUID> below.
-- insert into public.ps_business_members (business_id, user_id, role) values ('<BUSINESS_UUID>'::uuid, '<OWNER_AUTH_USER_UUID>'::uuid, 'owner');
-- insert into public.ps_business_state (business_id, data, updated_by) values ('<BUSINESS_UUID>'::uuid, '{}'::jsonb, '<OWNER_AUTH_USER_UUID>'::uuid);

-- SECURITY RULE: Use only Project URL + Publishable Key in the app. Never place secret/service_role keys in this PWA or GitHub.
