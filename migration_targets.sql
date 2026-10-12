-- Nutrition targets in Supabase + Fitbit weigh-in backfill.
-- Run once in Supabase SQL Editor -> New query -> Run. Safe to re-run; existing data is untouched.

create table if not exists nutrition_targets (
  id bigint generated always as identity primary key,
  effective_from date not null unique,               -- latest row on or before today is the active target
  kcal integer not null check (kcal between 1000 and 8000),
  protein_g integer not null check (protein_g >= 0),
  carbs_g integer not null check (carbs_g >= 0),
  fat_g integer not null check (fat_g >= 0),
  note text,
  created_at timestamptz not null default now()
);

alter table nutrition_targets enable row level security;
drop policy if exists "open access" on nutrition_targets;
create policy "open access" on nutrition_targets for all using (true) with check (true);

-- Targets from Fitbit export (1 Jun - 11 Oct 2026): maintenance ~3,000 kcal, +250 lean-bulk surplus.
insert into nutrition_targets (effective_from, kcal, protein_g, carbs_g, fat_g, note) values
  ('2026-10-12', 3250, 150, 480, 80, 'From Fitbit data: ~3,000 maintenance + 250 surplus')
on conflict (effective_from) do update
  set kcal = excluded.kcal, protein_g = excluded.protein_g, carbs_g = excluded.carbs_g,
      fat_g = excluded.fat_g, note = excluded.note;

-- Weigh-ins from the Fitbit / Google Health export. Days you already logged in the app are left alone.
insert into bodyweight (day, weight_kg) values
  ('2026-05-30', 73.0),
  ('2026-06-02', 70.3),
  ('2026-06-04', 70.5),
  ('2026-07-01', 73.5),
  ('2026-07-05', 73.9),
  ('2026-07-06', 74.5)
on conflict (day) do nothing;
