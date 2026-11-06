# LearnCard Engineering Rules & Standards

Bu dosya, LearnCard projesinde çalışan tüm AI asistanları ve geliştiriciler için **otomatik yüklenen ana kural tablosudur**. Detaylı felsefe ve SOP için `soul.md` ve `skill.md` dosyalarına bakınız.

---

## 🎯 0. Temel İlke
Satır sayısı amaç değil, ölçüdür. Asıl kural: **her dosyanın tek bir sorumluluğu olur.**
Uzun ama tek işe odaklı bir dosya kabul edilir; kısa ama birden çok iş yapan dosya bölünür.
Sırf satır düşürmek için yönlendirme (re-export / wrapper) dosyası açılmaz.

## 📏 1. Kurallar
1. **Dosya Boyutu (UI: `views/` altı):**
   - **150 satır = uyarı:** Dosyanın birden fazla iş yapıp yapmadığını kontrol et.
   - **300 satır = zorunlu bölme.**
   - Ekranlar (`*_screen.dart`) mümkünse iskelet olarak kalır (Scaffold + bileşen birleştirme).
   - `providers/`, `services/`, `core/database/` ve üretilmiş (`*.g.dart`) dosyalar bu sayılara tabi değildir; onlar için ölçü yalnızca tek sorumluluktur.
2. **İş Mantığı UI'da Durmaz:** Oyun kuralları, puanlama, soru üretme, zamanlayıcı, filtreleme gibi mantık widget `State` sınıfında değil, `providers/` altında bir Riverpod `Notifier`'da (veya saf Dart sınıfında) yazılır. Ekran yalnızca durumu izler ve olayları iletir. Bu mantık UI kurmadan unit test edilebilir olmalıdır.
3. **Durum Yönetimi:**
   - Birden fazla ekranın paylaştığı veya kalıcı olan durum → Riverpod.
   - Sadece o widget'ı ilgilendiren geçici UI durumu (`TextEditingController`, `FocusNode`, form alanı, animasyon, seçili sekme) → `StatefulWidget` / `ConsumerStatefulWidget` + `setState` **serbesttir**. Bu Flutter'ın resmi önerisidir.
4. **Widget'ı Sınıf Olarak Çıkar:** Anlamlı büyüklükteki UI parçaları `Widget _buildX()` metodu yerine ayrı `StatelessWidget` sınıfı olur (`const` ve rebuild verimi için). 3–5 satırlık küçük yardımcılar istisnadır.
5. **Diyalog Başına Dosya:** Her diyalog `views/<feature>/dialogs/<dialog_name>.dart` altında kendi dosyasındadır.

---

## 🏗️ 2. Standart Dizin Yapısı (Feature-First Modülerlik)
```text
lib/views/<feature_name>/
├── <feature>_screen.dart            # İskelet: durumu izler, bileşenleri birleştirir
├── dialogs/                         # Her diyalog bağımsız dosya
│   └── <feature>_action_dialog.dart
└── widgets/                         # Tek işe odaklı alt bileşenler
    ├── <feature>_header_widget.dart
    ├── <feature>_card_item.dart
    └── <feature>_action_bar.dart

lib/providers/<feature>_provider.dart  # Ekranın iş mantığı ve durumu (Notifier)
```

---

## 🤖 3. Yapay Zeka Asistanı İş Akışı (Token & Modülerlik Koruma)
1. **Önce Ayır:** Yeni bir sayfa yazmadan önce mantığı (Notifier) ve UI parçalarını (widgets) ayrı listele.
2. **Mantık Önce, Testle Birlikte:** Notifier'ı ve unit testini yaz, sonra ekranı onu izleyen ince bir katman olarak kur.
3. **Refactor Refleksi:** 300 satırı aşan veya UI içinde iş mantığı barındıran dosyayı sorumluluklarına göre böl. Satır düşürmek için anlamsız parçalama yapma.
4. **0 Hata Analizi:** Her değişiklikten sonra `flutter analyze` ve `flutter test` temiz olmalı.
   Not: Proje yolu ASCII olmayan karakter (`kişisel`) içerdiği için `flutter analyze` bu klasörde çökebilir; projeyi ASCII bir yola kopyalayıp analiz et.
