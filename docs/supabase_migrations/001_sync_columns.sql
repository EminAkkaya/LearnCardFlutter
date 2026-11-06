-- 001_sync_columns.sql
-- Offline-first eşitleme için son-yazan-kazanır zaman damgası.
-- Supabase Dashboard > SQL Editor'de bir kez çalıştırın (tekrar çalıştırmak güvenlidir).
-- Uygulama bu sütunlar yokken de çalışır; eklendikten sonra otomatik kullanır.

alter table public.flashcards
  add column if not exists updated_at timestamptz not null default now();

alter table public.saved_readings
  add column if not exists updated_at timestamptz not null default now();

-- İstemci updated_at göndermeden güncellerse (ör. başka bir araç) damgayı yenile.
-- Uygulama her yazımda kendi damgasını gönderir; o değer korunur.
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
