create table if not exists public.profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  nickname text,
  consent_privacy boolean not null default false,
  consent_ai_analysis boolean not null default false,
  consent_analytics boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.people (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null check (char_length(name) between 1 and 20),
  relation_type text not null check (relation_type in ('friend', 'family', 'teacher', 'coworker', 'other')),
  memo text,
  created_at timestamptz not null default now(),
  unique (user_id, name)
);

alter table public.profiles enable row level security;
alter table public.people enable row level security;

drop policy if exists profiles_own on public.profiles;
drop policy if exists people_own on public.people;

create policy profiles_own on public.profiles for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy people_own on public.people for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());
