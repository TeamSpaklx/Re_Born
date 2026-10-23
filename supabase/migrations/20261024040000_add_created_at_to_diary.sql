alter table public.diary
  add column if not exists created_at timestamptz not null default now();
