# LearnCard Engineering Rules & Standards

Bu dosya, LearnCard projesinde çalışan tüm AI asistanları ve geliştiriciler için **otomatik yüklenen ana kural tablosudur**. Detaylı felsefe ve SOP için `soul.md` ve `skill.md` dosyalarına bakınız.

---

## 🚫 1. Katı Yasaklar (Hard Limits & Rules)
1. **Dosya Satır Limiti:** Hiçbir `.dart` dosyası (ekran veya widget) **150 satırı GEÇEMEZ**.
   - Ana ekranlar (`*Screen`): **60 - 100 satır**
   - Alt widget'lar (`*Widget`): **40 - 100 satır**
2. **Helper Metot Yasağı:** Sınıf içinde `Widget _buildSection()`, `Widget _buildCard()` gibi fonksiyonel widget metotları yazmak **kesinlikle yasaktır**. Tüm UI parçaları `widgets/` altına bağımsız bir `StatelessWidget` / `ConsumerWidget` dosyası olarak çıkarılmalıdır.
3. **StatefulWidget Yasağı:** Klasik `StatefulWidget` ve `setState()` yasaktır. Yalnızca `ConsumerWidget` veya zorunlu lifecycle (controller/animation) durumlarında `ConsumerStatefulWidget` kullanılır.
4. **Monolitik Diyalog Yasağı:** Birden fazla diyalogu tek dosyada toplamak yasaktır (`reader_dialogs.dart` gibi). Her diyalog `views/<feature>/dialogs/<dialog_name>.dart` şeklinde ayrı dosyada olmalıdır.

---

## 🏗️ 2. Standart Dizin Yapısı (Feature-First Modülerlik)
```text
lib/views/<feature_name>/
├── <feature>_screen.dart            # Sadece iskelet (Scaffold + AppBar, max 80 satır)
├── dialogs/                         # Her diyalog bağımsız dosya
│   └── <feature>_action_dialog.dart
└── widgets/                         # Atomik alt bileşenler (max 100 satır)
    ├── <feature>_header_widget.dart
    ├── <feature>_card_item.dart
    └── <feature>_action_bar.dart
```

---

## 🤖 3. Yapay Zeka Asistanı İş Akışı (Token & Modülerlik Koruma)
1. **Önce Parçala:** Yeni bir sayfa veya özellik yazmadan önce bu sayfayı hangi bağımsız alt widget dosyalarına böleceğini listele.
2. **Atomik Yaz:** Önce `widgets/` altındaki küçük parçaları yaz, en son ana ekranı birleştirici olarak oluştur.
3. **Refactor Refleksi:** 150 satırı aşan veya `_buildX()` içeren mevcut dosyaları tespit ettiğinde derhal `widgets/` klasörüne taşıyarak parçala.
4. **0 Hata Analizi:** Her değişiklikten sonra `flutter analyze` ile 0 hata / 0 uyarı sağla.
