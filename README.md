# 🎴 LearnCard Flutter - İnteraktif Okuyucu & Akıllı Kelime Kartı Uygulaması

**LearnCard**, yabancı dilde metin okuma ve kelime öğrenme sürecini maksimum verim ve minimum dikkat dağılması ile gerçekleştirmek için geliştirilmiş modern bir Flutter uygulamasıdır.

İnteraktif e-kitap okuyucu, SM-2 Aralıklı Tekrar (Spaced Repetition) algoritması ve Supabase bulut senkronizasyonu ile donatılmıştır.

---

## ✨ Öne Çıkan Özellikler

### 📖 1. İnteraktif Okuyucu (Interactive Reader)
- **Anında Kelime Sözlüğü**: Metin içindeki herhangi bir kelimeye tıklayarak Türkçe çeviriye, İngilizce tanıma, IPA okunuşuna ve sesli telaffuza anında ulaşabilirsiniz.
- **Otomatik Bağlam Çıkarma (Context Extraction)**: Tıklanan kelime desteye eklenirken geçtiği cümle otomatik olarak algılanır ve örnek cümle olarak karta kaydedilir.
- **Dinamik Kelime Renklendirmesi**: Okuduğunuz metindeki kelimeler, kelime destenizdeki öğrenme durumunuza göre otomatik renklendirilir:
  - 🔴 **Kırmızı**: Destede kayıtlı fakat **Öğrenilmemiş / Yeni** kelimeler.
  - 🟠 **Turuncu**: **Öğrenilmekte** olan kelimeler.
  - 🟢 **Yeşil**: **Öğrenilmiş / Pekiştirilmiş** kelimeler.
  - ⚪ **Beyaz / Mürekkep**: Destenizde bulunmayan (tek tıkla eklenebilir) kelimeler.
- **Yüksek Performanslı Paragraf İşleme**: 50.000+ kelimelik büyük metin bloklarında dahi donma ve noktalama kayması yapmayan saf `TextSpan` + `TapGestureRecognizer` mimarisi.

### 🎨 2. Seçilebilir Okuma Temaları & Odak Modu
- **Göz Yormayan Ekran Temaları**:
  - 🖤 **OLED Siyah**: `#000000` tam siyah (AMOLED ekranlarda maksimum pil tasarrufu).
  - ⬛ **Mat Siyah**: `#0F172A` modern mat koyu tema.
  - 📜 **Papirüs**: `#FBF0D9` e-kitap kağıt sepya tonu.
  - ☕ **Gece Papirüsü**: `#241E19` koyu sepya.
- **Odak Modu (Focus Mode)**: Navigasyon çubuğunu ve gereksiz arayüz elemanlarını gizleyerek pürüzsüz bir okuma ortamı sunar.

### 🧠 3. SM-2 Aralıklı Tekrar (Spaced Repetition Flashcards)
- **SuperMemo SM-2 Algoritması**: Kelimeleri unutma eğrinize (Forgetting Curve) göre optimize edilmiş zaman aralıklarıyla karşınıza çıkarır.
- **Kart Derecelendirme**: *Yine*, *Zor*, *İyi*, *Kolay* seçenekleri ile akıllı kart yönetimi.
- **Sesli Telaffuz**: Kartları incelerken kelimelerin sesli okunuşunu dinleme desteği.

### ⚡ 4. Metin Çıkarıcı & Deste Yönetimi
- **Otomatik Kelime Çıkarma**: Yapıştırılan metinlerdeki sık kullanılan kelimeleri analiz eder ve tek tıkla toplu olarak destenize aktarır.
- **Arama ve Filtreleme**: Kartlarınızı duruma göre (*Tümü*, *Bugün Tekrar*, *Yeni*, *Öğrenilmekte*, *Öğrenildi*) filtreleyin.

### ☁️ 5. Supabase Bulut Senkronizasyonu
- Tüm kelime kartları ve okuma metinleri Supabase veritabanında güvenle saklanır ve cihazlar arasında senkronize edilir.

---

## 🛠️ Kullanılan Teknolojiler

- **Çerçeve**: [Flutter](https://flutter.dev) (Dart)
- **Durum Yönetimi (State Management)**: `flutter_riverpod`
- **Veritabanı & Backend**: [Supabase](https://supabase.com) (`supabase_flutter`)
- **Ağ İletişimi**: `http` (Free Dictionary API)
- **Ses Oynatıcı**: `audioplayers`
- **Benzersiz Kimlik Yönetimi**: `uuid`

---

## 🚀 Projeyi Çalıştırma

### Gereksinimler
- Flutter SDK (v3.0.0+)
- Dart SDK
- Git

### Kurulum Adımları

1. Repoyu klonlayın:
   ```bash
   git clone https://github.com/KULLANICI_ADI/LearnCardFlutter.git
   cd LearnCardFlutter
   ```

2. Bağımlılıkları yükleyin:
   ```bash
   flutter pub get
   ```

3. Uygulamayı çalıştırın:
   ```bash
   # Mobil (Android/iOS) veya Masaüstü (Linux/Windows/macOS)
   flutter run
   ```

---

## 📁 Proje Dizin Yapısı

```
lib/
├── config/             # Supabase ve uygulama konfigürasyonları
├── core/               # Tema, renkler, sabitler ve yardımcı araçlar (TextParser, AudioHelper)
├── models/             # Flashcard ve Reading Article veri modelleri
├── providers/          # Riverpod StateNotifier sınıfları (ReadingProvider, FlashcardProvider)
├── services/           # SRS Algoritması, Sözlük API ve Supabase Servisleri
└── views/              # Ekran tasarımları ve arayüz bileşenleri
    ├── extractor/      # Metin Çıkarıcı Ekranı
    ├── flashcard/      # Flashcard İnceleme ve Deste Yönetim Ekranları
    ├── reader/         # İnteraktif Okuyucu & Kelime Detay Sayfaları
    ├── stats/          # İstatistikler Ekranı
    └── home_screen.dart # Ana Navigasyon Container
```

---

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır.
