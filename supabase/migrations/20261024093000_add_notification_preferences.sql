alter table public.profiles
  add column if not exists notification_insight boolean not null default true,
  add column if not exists notification_reminder boolean not null default false,
  add column if not exists notification_reminder_time varchar(5) not null default '21:00';

alter table public.profiles
  add constraint profiles_reminder_time_format
  check (notification_reminder_time ~ '^(?:[01][0-9]|2[0-3]):[0-5][0-9]$');
