-- TRAP LOGGER: database setup for Supabase.
-- Run this whole file once: Supabase dashboard > SQL Editor > New query > paste > Run.

-- 1. Tables ------------------------------------------------------------------
create table if not exists public.profiles (
  id          uuid primary key references auth.users (id) on delete cascade,
  name        text not null default '',
  dob         date,
  email       text not null default '',
  weapon      text not null default '',
  ammo        text not null default '',
  choke1      text not null default '',
  choke2      text not null default '',
  consent_at  timestamptz,
  created_at  timestamptz not null default now()
);

create table if not exists public.rounds (
  id          text primary key,
  uid         uuid not null default auth.uid() references auth.users (id) on delete cascade,
  doc         jsonb not null,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);
create index if not exists rounds_uid_idx on public.rounds (uid);

-- Owners (admins) who can read every shooter and every round.
create table if not exists public.admins (
  user_id     uuid primary key references auth.users (id) on delete cascade
);

-- 2. Admin check -------------------------------------------------------------
create or replace function public.is_admin() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.admins where user_id = auth.uid());
$$;

-- 3. Profile row is created automatically when someone registers --------------
create or replace function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
declare m jsonb := coalesce(new.raw_user_meta_data, '{}'::jsonb);
begin
  insert into public.profiles (id, name, dob, email, weapon, ammo, choke1, choke2, consent_at)
  values (
    new.id,
    coalesce(m->>'name', ''),
    nullif(m->>'dob', '')::date,
    coalesce(new.email, ''),
    coalesce(m->>'weapon', ''),
    coalesce(m->>'ammo', ''),
    coalesce(m->>'choke1', ''),
    coalesce(m->>'choke2', ''),
    case when m->>'consent' = 'true' then now() end
  );
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
  for each row execute function public.handle_new_user();

-- 4. Row level security: each shooter sees only their own data ---------------
alter table public.profiles enable row level security;
alter table public.rounds   enable row level security;
alter table public.admins   enable row level security;

drop policy if exists profiles_select on public.profiles;
create policy profiles_select on public.profiles for select to authenticated
  using (id = auth.uid() or public.is_admin());
drop policy if exists profiles_update on public.profiles;
create policy profiles_update on public.profiles for update to authenticated
  using (id = auth.uid()) with check (id = auth.uid());

drop policy if exists rounds_select on public.rounds;
create policy rounds_select on public.rounds for select to authenticated
  using (uid = auth.uid() or public.is_admin());
drop policy if exists rounds_insert on public.rounds;
create policy rounds_insert on public.rounds for insert to authenticated
  with check (uid = auth.uid());
drop policy if exists rounds_update on public.rounds;
create policy rounds_update on public.rounds for update to authenticated
  using (uid = auth.uid()) with check (uid = auth.uid());
drop policy if exists rounds_delete on public.rounds;
create policy rounds_delete on public.rounds for delete to authenticated
  using (uid = auth.uid());

drop policy if exists admins_select on public.admins;
create policy admins_select on public.admins for select to authenticated
  using (user_id = auth.uid());

-- Signed-out visitors get nothing. Signed-in shooters edit only their own details.
revoke all on public.profiles, public.rounds, public.admins from anon;
revoke all on public.profiles, public.rounds, public.admins from authenticated;
grant select on public.profiles to authenticated;
grant update (name, dob, weapon, ammo, choke1, choke2, consent_at) on public.profiles to authenticated;
grant select, insert, update, delete on public.rounds to authenticated;
grant select on public.admins to authenticated;

-- 5. Delete my account (needed for the App Store later) -----------------------
create or replace function public.delete_my_account() returns void
language plpgsql security definer set search_path = public, auth as $$
begin
  if auth.uid() is null then raise exception 'Not signed in'; end if;
  delete from auth.users where id = auth.uid();
end;
$$;
revoke all on function public.delete_my_account() from public, anon;
grant execute on function public.delete_my_account() to authenticated;

-- 6. AFTER you have registered your own account in the app, run this once ----
--    to make yourself the owner (replace the email if it differs):
--
--    insert into public.admins (user_id)
--    select id from auth.users where email = 'taj@tajmahalgp.com'
--    on conflict do nothing;
