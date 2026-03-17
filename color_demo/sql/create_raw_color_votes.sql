create table if not exists public.raw_color_votes (
  record_id bigint generated always as identity primary key,
  favorite_color text not null check (favorite_color in ('red', 'blue', 'yellow', 'green', 'orange', 'purple')),
  submitted_at timestamptz not null default now(),
  submission_source text not null default 'shiny_entry'
);

alter table public.raw_color_votes enable row level security;

drop policy if exists raw_color_votes_anon_insert on public.raw_color_votes;
create policy raw_color_votes_anon_insert
  on public.raw_color_votes
  for insert
  to anon
  with check (true);

revoke all on public.raw_color_votes from anon;
grant insert on public.raw_color_votes to anon;
grant usage on schema public to anon;
grant usage, select on sequence public.raw_color_votes_record_id_seq to anon;
