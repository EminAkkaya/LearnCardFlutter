# LearnCard — Yayın (Release) Rehberi

Bu dosya mağazaya yükleme için senin yapman gereken adımları toplar. Kod tarafındaki
hazırlık `docs/STORE_READINESS_PLAN.md` içinde takip edilir.

## 0. Önce karar ver
- **Paket / bundle id:** `dev.eminakkaya.learncard` (Android, iOS, macOS, Linux; 2026-11-13 kararı).
  Play Store'da yayından sonra **değiştirilemez**.

## 1. Supabase yapılandırması
- `lib/config/supabase_config.dart` gitignore'dadır; `lib/config/supabase_config.template.dart`
  dosyasını kopyalayıp doldur. CI kullanırsan bu dosyayı build adımında secret'lardan üret.
- `docs/supabase_migrations/` altındaki SQL dosyalarını sırayla Supabase SQL Editor'da çalıştır.
- **Hesap silme fonksiyonu:** `supabase functions deploy delete-account` (kod: `supabase/functions/delete-account/index.ts`).
  Service role anahtarı Supabase tarafından fonksiyona otomatik verilir; istemciye hiç gitmez.
  Deploy edilmezse uygulamadaki "Hesabı Sil" hata mesajı gösterir ve hiçbir veri silinmez.
- **RLS:** tüm tablolarda Row Level Security açık olmalı ve politikalar `auth.uid() = user_id`
  şeklinde olmalı. Anon key istemcide herkese açıktır; güvenliği RLS sağlar.
- **Auth redirect:** Supabase → Authentication → URL Configuration → Redirect URLs'e
  `io.learncard.app://login-callback` adresini ekle. Bu adres `AuthService.authRedirectUrl`,
  AndroidManifest intent-filter'ı ve iOS `CFBundleURLTypes` ile aynıdır; birini değiştirirsen hepsini değiştir.

## 2. Android imza anahtarı
Oluşturuldu (2026-11-13): `bash tool/create_upload_key.sh` parolayı terminalde sorar,
`~/.android-keys/learncard-upload.jks` (PKCS12, RSA 4096, alias `upload`) ve
`android/key.properties` (gitignore'da) yazar. Sertifika SHA-256:
`04:AF:E8:73:19:F4:2D:46:D8:67:FE:38:BA:B1:59:DF:D8:BA:10:E3:46:46:5A:79:C5:9A:FE:46:A7:19:51:3E`
- `.jks` dosyasını ve parolayı **yedekle**. Play App Signing'i aç; bu dosya "upload key" olur.
- `key.properties` yoksa release build debug anahtarıyla imzalanır (yalnız yerel test için).
- Mağaza paketi: `flutter build appbundle --release` → `build/app/outputs/bundle/release/app-release.aab`.

## 3. Sürüm numarası
`pubspec.yaml` → `version: 1.0.0+1`. Her mağaza yüklemesinde `+N` (build numarası) artmalı.

## 4. Android build
```bash
flutter build appbundle --release
```
Çıktı: `build/app/outputs/bundle/release/app-release.aab` → Play Console'a yükle.

## 5. iOS build (macOS gerekir)
- `ios/Podfile` repoda yok; macOS'ta ilk `flutter build ios` bunu üretir. `platform :ios, '13.0'`
  satırını aç ve Podfile'ı commit'le.
- Xcode'da Signing & Capabilities → Team seç.
- `ios/Runner/PrivacyInfo.xcprivacy` dosyasının Runner target'ına dahil olduğunu kontrol et.
```bash
flutter build ipa --release
```
Çıktıyı Transporter veya Xcode Organizer ile App Store Connect'e yükle.

## 6. Mağaza formları
- **Gizlilik politikası URL'si:** https://eminakkaya.dev/learncard/gizlilik
- **Hesap silme URL'si (Play zorunlu):** https://eminakkaya.dev/learncard/hesap-silme
- **Destek:** https://eminakkaya.dev/learncard · iletisim@eminakkaya.dev
- **Data Safety (Play) / App Privacy (Apple):** `docs/DATA_SAFETY.md` cevaplarını kullan.
- **İçerik derecelendirmesi:** eğitim uygulaması, kullanıcılar arası iletişim yok.
