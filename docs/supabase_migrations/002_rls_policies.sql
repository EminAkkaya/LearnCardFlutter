-- 002_rls_policies.sql
-- Row Level Security: her kullanıcı yalnız kendi satırlarını görür ve değiştirir.
-- Anon key istemcide herkese açıktır; veri güvenliğini yalnız bu politikalar sağlar.
-- Supabase Dashboard > SQL Editor'de çalıştırın (tekrar çalıştırmak güvenlidir).
--
-- RLS politikaları OR ile birleşir: `using (true)` olan tek bir geniş politika
-- ("Allow public access ...") diğer bütün kısıtlamaları boşa çıkarır, bu yüzden kaldırılır.
-- Mevcut durumu görmek için:
--   select tablename, policyname, cmd, qual, with_check
--   from pg_policies where schemaname = 'public';

alter table public.flashcards enable row level security;
alter table public.saved_readings enable row level security;

drop policy if exists "Allow public access on flashcards" on public.flashcards;
drop policy if exists "Allow public access on saved_readings" on public.saved_readings;

-- flashcards ---------------------------------------------------------------
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

-- saved_readings -----------------------------------------------------------
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
