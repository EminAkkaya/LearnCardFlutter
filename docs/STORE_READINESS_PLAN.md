# LearnCard — Store Hazırlık ve Full Review Planı

Otonom çalışma planı. Her oturum bu dosyayı okur, sıradaki `[ ]` görevi alır, bitirince `[x]` yapar,
kısa not düşer ve görev başına commit atar. Öncelik: P0 (yayın engeli) → P1 (kalite) → P2 (olsa iyi olur).

## Çalışma kuralları
- Kod `rules.md`'ye uyar. Her görevden sonra: analyzer (ASCII kopyada) + `flutter test` temiz.
  - Analyzer: `rsync -a --delete --exclude build --exclude .dart_tool ./ <scratchpad>/lccopy/ && cd <scratchpad>/lccopy && flutter pub get && flutter analyze`
- Ağır inceleme/okuma işleri subagent'a verilir; ana bağlama yalnız kısa rapor gelir.
- Commit main'e, push YOK (kullanıcı onayı gerekir).
- Kullanıcı kararı gereken şeyler (paket adı, gizlilik politikası URL'i, imza anahtarı, mağaza hesapları) "Kullanıcıya sorulacaklar" bölümüne yazılır, varsayılanla devam edilir.

## Görevler

### P0 — Yayın engelleri
- [ ] **R1 Full review (subagent'lar):** çekirdek/veri/güvenlik, oyunlar/UX, store yapılandırması. Bulgular aşağıya görev olarak eklenir.
- [ ] **S1 Android release yapılandırması:** gerçek `applicationId` (com.example değil), `key.properties` ile release imzası, versionCode/versionName, target/compileSdk güncel, uygulama adı, R8/minify.
- [ ] **S2 iOS yapılandırması:** bundle id, display name, Info.plist izin açıklamaları, deployment target, export compliance.
- [ ] **S3 Hesap silme:** uygulama içinden hesap + veri silme (Play ve App Store zorunlu kılıyor).
- [ ] **S4 Gizlilik:** gizlilik politikası sayfası/bağlantısı ayarlar ekranında; Data Safety / Privacy Nutrition için toplanan veri listesi (`docs/`).
- [ ] **S5 Supabase config:** `supabase_config.dart` gitignore'da; release/CI için `--dart-define` tabanlı yapı, anahtar yoksa net hata.

### P1 — Kalite
- [ ] **Q1 Oyun mantığı gözden geçirme:** az kartla (<4) davranış, çeldirici kalitesi, tekrar oynanabilirlik, istatistik kaydı, SRS ile etkileşim.
- [ ] **Q2 Hata/çevrimdışı davranış:** ağ hatalarında kullanıcıya geri bildirim, sessiz `catch (_) {}` noktalarının gözden geçirilmesi.
- [ ] **Q3 Test kapsamı:** SRS, auth, sync, stats için eksik testler.
- [ ] **Q4 Erişilebilirlik ve küçük ekran:** semantik etiketler, metin ölçekleme, taşma.

### P2 — Olsa iyi olur
- [ ] **N1 Store listing taslağı:** kısa/uzun açıklama (TR/EN), anahtar kelimeler, ekran görüntüsü listesi (`docs/store_listing.md`).
- [ ] **N2 Onboarding / ilk açılış deneyimi.**
- [ ] **N3 Çoklu dil altyapısı (intl) değerlendirmesi.**

## Review bulguları
_(R1 sonrası doldurulur)_

## Kullanıcıya sorulacaklar
_(karar gereken şeyler)_

## İlerleme günlüğü
- 2026-11-07 00:30 — Plan oluşturuldu, refactor main'e merge edildi (`ee0a127`).
