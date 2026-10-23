-- 개발 단계에서 단일 일기 저장을 허용한다.
-- 사용자 인증을 추가할 때 user_id NOT NULL과 RLS 정책을 복구해야 한다.
alter table public.diary
  alter column user_id drop not null;
