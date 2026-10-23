-- Re:Born MVP schema and row-level security.
-- User identity always comes from auth.uid(); clients never provide user_id.

create table if not exists public.profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  nickname text not null default '',
  consent_privacy boolean not null default false,
  consent_ai_analysis boolean not null default false,
  consent_analytics boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.people (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null check (char_length(btrim(name)) between 1 and 20),
  relation_type text not null check (relation_type in ('friend', 'family', 'teacher', 'coworker', 'other')),
  memo text,
  created_at timestamptz not null default now(),
  unique (user_id, name)
);

create table if not exists public.entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  body text not null check (char_length(btrim(body)) between 1 and 2000),
  person_id uuid references public.people(id) on delete set null,
  emotion text not null check (emotion in ('joy', 'sadness', 'neutral', 'anger', 'anxiety', 'love', 'excited')),
  intensity smallint not null check (intensity between 1 and 3),
  score smallint not null check (score between -3 and 3),
  created_at timestamptz not null default now(),
  analysis_status text not null default 'pending' check (analysis_status in ('pending', 'done', 'failed')),
  analysis_keywords text[],
  analyzed_at timestamptz
);

create table if not exists public.index_history (
  person_id uuid not null references public.people(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  date date not null,
  index smallint not null check (index between 0 and 100),
  entry_count integer not null check (entry_count >= 0),
  primary key (person_id, date)
);

create table if not exists public.insights (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  type text not null check (type in ('negative_trend', 'recovery')),
  person_id uuid not null references public.people(id) on delete cascade,
  message text not null,
  evidence_index_from smallint not null check (evidence_index_from between 0 and 100),
  evidence_index_to smallint not null check (evidence_index_to between 0 and 100),
  evidence_neg_count integer check (evidence_neg_count is null or evidence_neg_count >= 0),
  created_at timestamptz not null default now(),
  read boolean not null default false
);

create table if not exists public.todos (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null check (char_length(btrim(title)) between 1 and 100),
  person_id uuid references public.people(id) on delete set null,
  done boolean not null default false,
  done_at timestamptz,
  source text not null default 'manual' check (source in ('manual', 'suggestion')),
  insight_id uuid references public.insights(id) on delete set null,
  created_at timestamptz not null default now()
);

create index if not exists people_user_id_created_at_idx on public.people (user_id, created_at desc);
create index if not exists entries_user_id_created_at_idx on public.entries (user_id, created_at desc);
create index if not exists entries_user_id_person_id_created_at_idx on public.entries (user_id, person_id, created_at desc);
create index if not exists index_history_user_id_person_id_date_idx on public.index_history (user_id, person_id, date);
create index if not exists insights_user_id_created_at_idx on public.insights (user_id, created_at desc);
create index if not exists insights_user_id_person_id_created_at_idx on public.insights (user_id, person_id, created_at desc);
create index if not exists todos_user_id_created_at_idx on public.todos (user_id, created_at desc);

alter table public.profiles enable row level security;
alter table public.people enable row level security;
alter table public.entries enable row level security;
alter table public.index_history enable row level security;
alter table public.insights enable row level security;
alter table public.todos enable row level security;

drop policy if exists profiles_owner_all on public.profiles;
create policy profiles_owner_all on public.profiles
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists people_owner_all on public.people;
create policy people_owner_all on public.people
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists entries_owner_all on public.entries;
create policy entries_owner_all on public.entries
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists index_history_owner_all on public.index_history;
create policy index_history_owner_all on public.index_history
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists insights_owner_all on public.insights;
create policy insights_owner_all on public.insights
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists todos_owner_all on public.todos;
create policy todos_owner_all on public.todos
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());
