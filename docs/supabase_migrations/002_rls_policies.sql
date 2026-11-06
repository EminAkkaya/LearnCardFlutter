-- 002_rls_policies.sql
-- Row Level Security: her kullanıcı yalnız kendi satırlarını görür ve değiştirir.
-- Anon key istemcide herkese açıktır; veri güvenliğini yalnız bu politikalar sağlar.
-- Supabase Dashboard > SQL Editor'de çalıştırın (tekrar çalıştırmak güvenlidir).
--
-- Çalıştırmadan önce mevcut politikaları görmek için:
--   select tablename, policyname, cmd, qual, with_check
--   from pg_policies where schemaname = 'public'
--   and tablename in ('flashcards', 'saved_readings');

alter table public.flashcards enable row level security;
alter table public.saved_readings enable row level security;

-- flashcards ---------------------------------------------------------------
drop policy if exists "flashcards_select_own" on public.flashcards;
create policy "flashcards_select_own" on public.flashcards
  for select to authenticated using (auth.uid() = user_id);

drop policy if exists "flashcards_insert_own" on public.flashcards;
create policy "flashcards_insert_own" on public.flashcards
  for insert to authenticated with check (auth.uid() = user_id);

drop policy if exists "flashcards_update_own" on public.flashcards;
create policy "flashcards_update_own" on public.flashcards
  for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "flashcards_delete_own" on public.flashcards;
create policy "flashcards_delete_own" on public.flashcards
  for delete to authenticated using (auth.uid() = user_id);

-- saved_readings -----------------------------------------------------------
drop policy if exists "saved_readings_select_own" on public.saved_readings;
create policy "saved_readings_select_own" on public.saved_readings
  for select to authenticated using (auth.uid() = user_id);

drop policy if exists "saved_readings_insert_own" on public.saved_readings;
create policy "saved_readings_insert_own" on public.saved_readings
  for insert to authenticated with check (auth.uid() = user_id);

drop policy if exists "saved_readings_update_own" on public.saved_readings;
create policy "saved_readings_update_own" on public.saved_readings
  for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "saved_readings_delete_own" on public.saved_readings;
create policy "saved_readings_delete_own" on public.saved_readings
  for delete to authenticated using (auth.uid() = user_id);

-- Not: user_id sütunu uuid değil text ise karşılaştırmayı `auth.uid()::text = user_id`
-- olarak değiştirin. Eski, daha geniş politikalar varsa (ör. "Enable read access for all
-- users") yukarıdaki sorguyla bulup `drop policy` ile kaldırın; RLS politikaları OR ile
-- birleşir, tek bir geniş politika hepsini boşa çıkarır.
