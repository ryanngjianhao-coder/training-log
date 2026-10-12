-- Nutrition tracker: run once in Supabase SQL Editor -> New query -> Run. Existing data is untouched.
create table if not exists meals (
  id bigint generated always as identity primary key,
  ref text unique,                                   -- set by Claude's meal code, so re-pasting updates instead of duplicating
  eaten_at timestamptz not null default now(),
  day date not null,                                 -- local date, so late meals land on the right day
  name text not null,
  kcal integer not null check (kcal between 0 and 10000),
  protein_g numeric(6,1) not null default 0 check (protein_g >= 0),
  carbs_g numeric(6,1) not null default 0 check (carbs_g >= 0),
  fat_g numeric(6,1) not null default 0 check (fat_g >= 0),
  items jsonb not null default '[]',                 -- [[name, kcal, protein, carbs, fat], ...]
  note text,
  source text not null default 'claude',
  created_at timestamptz not null default now()
);
create index if not exists meals_day_idx on meals (day);

alter table meals enable row level security;
create policy "open access" on meals for all using (true) with check (true);
