-- LearnCard: 001 + 002 tek seferde. Supabase > SQL Editor > New query'ye yapıştırıp Run.
begin;

alter table public.flashcards enable row level security;
alter table public.saved_readings enable row level security;

drop policy if exists "Allow public access on flashcards" on public.flashcards;
drop policy if exists "Allow public access on saved_readings" on public.saved_readings;

drop policy if exists "Users can view their own flashcards" on public.flashcards;
create policy "Users can view their own flashcards" on public.flashcards
  for select to authenticated using (auth.uid() = user_id);

drop policy if exists "Users can insert their own flashcards" on public.flashcards;
create policy "Users can insert their own flashcards" on public.flashcards
  for insert to authenticated with check (auth.uid() = user_id);

drop policy if exists "Users can update their own flashcards" on public.flashcards;
create policy "Users can update their own flashcards" on public.flashcards
  for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "Users can delete their own flashcards" on public.flashcards;
create policy "Users can delete their own flashcards" on public.flashcards
  for delete to authenticated using (auth.uid() = user_id);

drop policy if exists "Users can view their own saved readings" on public.saved_readings;
create policy "Users can view their own saved readings" on public.saved_readings
  for select to authenticated using (auth.uid() = user_id);

drop policy if exists "Users can insert their own saved readings" on public.saved_readings;
create policy "Users can insert their own saved readings" on public.saved_readings
  for insert to authenticated with check (auth.uid() = user_id);

drop policy if exists "Users can update their own saved readings" on public.saved_readings;
create policy "Users can update their own saved readings" on public.saved_readings
  for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "Users can delete their own saved readings" on public.saved_readings;
create policy "Users can delete their own saved readings" on public.saved_readings
  for delete to authenticated using (auth.uid() = user_id);

alter table public.flashcards
  add column if not exists updated_at timestamptz not null default now();

alter table public.saved_readings
  add column if not exists updated_at timestamptz not null default now();

create or replace function public.touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  if new.updated_at is not distinct from old.updated_at then
    new.updated_at := now();
  end if;
  return new;
end;
$$;

drop trigger if exists flashcards_touch_updated_at on public.flashcards;
create trigger flashcards_touch_updated_at
  before update on public.flashcards
  for each row execute function public.touch_updated_at();

drop trigger if exists saved_readings_touch_updated_at on public.saved_readings;
create trigger saved_readings_touch_updated_at
  before update on public.saved_readings
  for each row execute function public.touch_updated_at();
commit;
