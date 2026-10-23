alter table public.entries
  drop constraint if exists entries_emotion_check;

update public.entries
set emotion = case emotion
  when 'neutral' then 'calm'
  when 'love' then 'gratitude'
  when 'excited' then 'excitement'
  else emotion
end
where emotion in ('neutral', 'love', 'excited');

alter table public.entries
  add constraint entries_emotion_check
  check (emotion = any (array[
    'joy', 'gratitude', 'excitement', 'calm', 'hurt', 'anxiety', 'anger', 'sadness'
  ]));
