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
- [x] **R1 Full review (subagent'lar):** çekirdek/veri/güvenlik, oyunlar/UX, store yapılandırması. Bulgular aşağıda görev olarak.

**Uygulama sırası:** D3 → G2 → G3 → D1+D6 (+D2) → S3 → D4 → S4/S6 → G4-G9 → D5, D7-D12 → S8/S9 → Q2-Q4 → G10/G11 → P2.
- [x] **S1 Android release yapılandırması:** `key.properties` tabanlı release imzası (yoksa debug'a düşer), uygulama adı "LearnCard". applicationId kullanıcı onayı bekliyor (soru 1). Minify/targetSdk → S8.
- [x] **S2 iOS yapılandırması:** display name "LearnCard", `ITSAppUsesNonExemptEncryption=false`. İzin metni gerekmiyor (kamera/konum yok). Bundle id → soru 1; Podfile/PrivacyInfo → S6/S7.
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

## Review bulguları (R1, 2026-11-07) → görevler

### P0 — veri kaybı / yayın engeli
- [ ] **D1 Senkron yereli eziyor:** `supabase_service.dart:124-129, 251-256` bulut boş değilse yerel kartlar `insertOrReplace` ile eziliyor; çevrimdışı çalışılan ilerleme kayboluyor, misafir kartları düşüyor. Çözüm: `updated_at` + yerel `dirty` bayrağı; önce dirty push, sonra satır bazlı last-write-wins pull. Drift şema migrasyonu gerekir (schemaVersion artır, test yaz).
- [ ] **D2 Misafir → giriş migrasyonu yok:** okuma metinleri (`:230-263`) ve kartlar için girişte misafir verisini (userId null) kullanıcıya bağlayıp buluta bir kez yükle.
- [x] **D3 Misafir modunda başka hesabın verisi görünüyor:** `app_database.dart:90-96` userId null iken filtre yok → `userId.isNull()` ekle. (Hızlı, önce bunu yap.)
- [ ] **D4 Auth deep link:** Android intent-filter + iOS `CFBundleURLTypes` (`io.supabase.learncard://login-callback`), `resetPasswordForEmail(redirectTo:)`, `passwordRecovery` event'inde yeni şifre ekranı. Supabase panelinde redirect URL kullanıcı ekleyecek.
- [ ] **S6 iOS PrivacyInfo.xcprivacy** ekle (UserDefaults CA92.1, FileTimestamp C617.1; toplanan veri: e-posta, user id → App Functionality) ve pbxproj'a dahil et.
- [ ] **S7 iOS Podfile** yok — macOS'ta `flutter build ios` ile üretilecek (kullanıcı, Linux'ta yapılamaz). Not olarak RELEASE.md'ye yaz.

### P1
- [ ] **D5 Eşzamanlı yükleme yarışı:** `flashcard_provider.dart:73-81, 200-209`, `reading_provider` loadReadings — generation token ile eski yükleme sonucunu yok say.
- [ ] **D6 Silme senkronu:** `supabase_service.dart:223` çevrimdışı silme yutuluyor, kart geri geliyor → tombstone/silme kuyruğu (D1 ile birlikte).
- [ ] **D7 learning_step fallback her hatada:** `:164-173, 196-203` yalnız "column not found" hatasında fallback yap.
- [ ] **D8 Stats:** `stats_provider.dart:8-19` load await edilmeden kayıt state'i sıfırlayabiliyor; istatistikler kullanıcıya göre ayrılmıyor. Yüklenene kadar kayıtları beklet/kuyrukla, anahtarı userId'ye bağla.
- [ ] **D9 Seed kartlar sabit id** (`seed-1..4`, `:18-85`) → UUID; tüm kartlar silinince seed'i tekrar oluşturma.
- [ ] **D10 Tarih/saat dilimi:** `srs_service.dart:171` nextReviewDate karışık format → UTC ISO.
- [ ] **D11 Hata görünürlüğü:** flashcard_provider iyimser güncellemede DB hatası yutuluyor; `bulkAddCards` tüm desteyi upsert ediyor (yalnız yenileri gönder); `main.dart` Supabase init hatası sessiz; `resendVerificationOtp` istemci yoksa başarı dönüyor.
- [ ] **D12 signUp mevcut e-posta:** `identities` boşsa "bu e-posta kayıtlı" göster.
- [ ] **S8 Android:** targetSdk açıkça 35+, release'te `isMinifyEnabled/isShrinkResources` (release build ile doğrulanarak), kullanılmayan bağımlılıklar (`path`, `path_provider`?) `flutter pub deps` ile doğrula/temizle.
- [ ] **S9 google_fonts çevrimdışı:** fontu asset olarak paketle veya `GoogleFonts.config.allowRuntimeFetching` + asset.
- [ ] **SEC1 RLS doğrulama:** anon key ilk commit (35969d8) geçmişinde var; anon key public olsa da tablolarda RLS politikaları kontrol edilmeli (kullanıcı Supabase panelinden; SQL'i `docs/supabase_rls.sql` olarak hazırla).

### Oyunlar (Q1 alt görevleri; P = lib/providers/games)
- [ ] **G1 (P0) Oyunlar SRS'i beslemiyor:** yanlış cevaplanan kartı oyun sonunda "tekrar listesi" ile göster, tek dokunuşla `again` olarak işaretle (otomatik zorla değil). Doğru cevaplar SRS'i değiştirmez.
- [x] **G2 (P0) Skor yalnız son "İleri"de kaydediliyor:** son cevapta kaydet; yarıda bırakılan oyunu kaydetme ama çift kaydı bayrakla engelle. Word match: game-over gecikmesinde restart → çift kayıt (`word_match_provider.dart` restart'ta `_recorded` bayrağı).
- [x] **G3 (P0) Hızlı Karar çeldiricileri:** sabit Türkçe fallback cümlelerini kaldır; yeterli çeldirici yoksa (destede <4 farklı anlam) soru sayısını düşür / şık sayısını 3'e indir; TR yoksa definition kullanan kartlar yalnız aynı dildeki anlamlarla eşlensin.
- [ ] **G4 (P1) Cloze:** regex eşleşmeyen kartı atla (sahte şablon yok), eki boşluğun dışında bırak ("walk|ed"); sabit fallback kelimeleri kaldır, <2 soru üretilirse "yetersiz kart" göster.
- [ ] **G5 (P1) Eşleştirme:** aynı TR metnine sahip kartları tek oyunda kullanma; definition kullanılıyorsa etiket "TANIM"; hata sayısı skordan düşsün; streak çarpanını sınırla.
- [ ] **G6 (P1) Hub:** kategori boşsa sessizce tüm desteye düşme → uyarı/disabled; oyun başına geçerli kart sayısını kontrol et (scramble tek kelimelik kart sayısı).
- [ ] **G7 (P1) Harf Sihirbazı:** "Geç" butonu; ipucu cezası yalnız o kelimenin puanından (önceki kelimeleri silmesin); İ/ı için `toLowerCase` yerine güvenli normalizasyon (Türkçe karakterler tek karo).
- [ ] **G8 (P1) Hızlı Karar puanı:** seri bonusunu sınırla; süre dolması ayrı sayılsın (özet ekranında).
- [ ] **G9 (P1) Tekrar ekranı:** `flashcard_review_screen.dart:28-33, 56-62` customCards ile gelince bitişte eski due kartlara başa sarma hatası; çıkış onayı (PopScope); son derecelendirmeyi geri al.
- [ ] **G10 (P2) Erişilebilirlik/tema:** oyun karolarına `Semantics`, eşleşen karoya ikon, sabit `Colors.white/black` ve dağınık `emerald` sabitlerini tema rengine bağla.
- [ ] **G11 (P2) Fikirler:** zayıf kartlara (lapses/due) ağırlıklı seçim, oyun sonu kart başına doğru/yanlış özeti + doğruluk yüzdesi, TR→EN yönü.

## Kullanıcıya sorulacaklar
1. **Nihai paket/bundle id:** şu an Android `com.learncard.learncard_flutter`, iOS `com.learncard.learncardFlutter`. Yayından sonra değiştirilemez. Öneri: ikisinde de aynı, ör. `com.<senin-alan-adın>.learncard`. Onay gelene kadar dokunulmadı.
2. **Release keystore:** `keytool` ile üretilip `android/key.properties` yazılacak (şablon `docs/RELEASE.md`). Parolayı sen belirle ve yedekle; Play App Signing önerilir.
3. **Gizlilik politikası + hesap silme web URL'si + destek e-postası** (taslak metni ben hazırlayabilirim, yayınlanacak yer senin).
4. **Hesap silme yöntemi:** Supabase Edge Function (`auth.admin.deleteUser`, service role) — fonksiyon kodunu ben yazarım, deploy senin.
5. **Supabase paneli:** auth redirect URL ekleme, RLS kontrolü.
6. Play Console (25$) ve Apple Developer (99$/yıl) hesapları.

## İlerleme günlüğü
- 2026-11-07 00:30 — Plan oluşturuldu, refactor main'e merge edildi (`ee0a127`).
- 2026-11-07 00:55 — R1 review bitti, S1/S2 kısmi, D3 tamam (misafir yalnız userId=null veriyi görür/siler). Sıradaki: G2.
- 00:36 — G2 (skor son cevapta, tek sefer) ve G3 (sabit çeldiriciler kaldırıldı, aynı tür şıklar) tamam. Sıradaki: D1+D6+D2 senkron.
