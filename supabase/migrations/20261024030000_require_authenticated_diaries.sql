-- 백엔드가 검증한 Supabase 사용자만 일기를 저장·조회할 수 있도록 복구한다.
alter table public.diary
  alter column user_id set default auth.uid(),
  alter column user_id set not null;

alter table public.diary enable row level security;

drop policy if exists diary_select_own on public.diary;
drop policy if exists diary_insert_own on public.diary;

create policy diary_select_own on public.diary
  for select to authenticated
  using (user_id = auth.uid());

create policy diary_insert_own on public.diary
  for insert to authenticated
  with check (user_id = auth.uid());
