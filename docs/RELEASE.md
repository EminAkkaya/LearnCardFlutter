# LearnCard — Yayın (Release) Rehberi

Bu dosya mağazaya yükleme için senin yapman gereken adımları toplar. Kod tarafındaki
hazırlık `docs/STORE_READINESS_PLAN.md` içinde takip edilir.

## 0. Önce karar ver
- **Paket / bundle id:** Şu an Android `com.learncard.learncard_flutter`, iOS `com.learncard.learncardFlutter`.
  Play Store'da yayından sonra **değiştirilemez**. İkisini aynı yap (ör. `com.<alanadın>.learncard`).
  Değiştirmek için: `android/app/build.gradle.kts` (`namespace`, `applicationId`),
  `android/app/src/main/kotlin/...` paket klasörü + `MainActivity.kt` package satırı,
  `ios/Runner.xcodeproj/project.pbxproj` (`PRODUCT_BUNDLE_IDENTIFIER`).

## 1. Supabase yapılandırması
- `lib/config/supabase_config.dart` gitignore'dadır; `lib/config/supabase_config.template.dart`
  dosyasını kopyalayıp doldur. CI kullanırsan bu dosyayı build adımında secret'lardan üret.
- `docs/supabase_migrations/` altındaki SQL dosyalarını sırayla Supabase SQL Editor'da çalıştır.
- **RLS:** tüm tablolarda Row Level Security açık olmalı ve politikalar `auth.uid() = user_id`
  şeklinde olmalı. Anon key istemcide herkese açıktır; güvenliği RLS sağlar.
- **Auth redirect:** Supabase → Authentication → URL Configuration → Redirect URLs'e
  uygulamanın deep link şemasını ekle (deep link görevi D4 tamamlanınca şema burada yazacak).

## 2. Android imza anahtarı
```bash
keytool -genkey -v -keystore ~/learncard-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```
`android/key.properties` oluştur (gitignore'da, commit'leme):
```properties
storePassword=<parola>
keyPassword=<parola>
keyAlias=upload
storeFile=/home/<kullanıcı>/learncard-upload.jks
```
- `.jks` dosyasını ve parolayı **yedekle**. Play App Signing'i aç; bu dosya "upload key" olur.
- `key.properties` yoksa release build debug anahtarıyla imzalanır (yalnız yerel test için).

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
- **Gizlilik politikası URL'si:** `docs/PRIVACY_POLICY.md` taslağını bir web sayfasında yayınla
  (GitHub Pages, Notion vb.) ve hem mağaza formuna hem uygulamadaki ayarlara bağla.
- **Hesap silme URL'si:** Play, uygulama dışından da silme talebi yapılabilecek bir web adresi ister.
- **Data Safety (Play) / App Privacy (Apple):** `docs/DATA_SAFETY.md` cevaplarını kullan.
- **İçerik derecelendirmesi:** eğitim uygulaması, kullanıcılar arası iletişim yok.
