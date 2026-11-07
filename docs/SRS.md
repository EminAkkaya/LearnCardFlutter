# LearnCard SRS algoritması

Kod: `lib/services/srs_service.dart` · Testler: `test/srs_service_test.dart`

LearnCard, Anki'nin SM-2 varyantını kullanır. Mevcut veritabanı alanlarıyla
(`status`, `interval`, `repetitions`, `learningStep`, `easeFactor`,
`nextReviewDate`) çalışır; şema değişikliği gerekmez ve eski kartlar olduğu gibi
devam eder.

## Fazlar

| Faz | Alanlar | Anlamı |
|---|---|---|
| Öğrenme | `repetitions == 0`, `interval == 0` (veya `status == 'new'`) | Yeni kart, dakika adımlarında |
| Yeniden öğrenme | `repetitions == 0`, `interval > 0` | Unutulan kart; `interval` döneceği aralık |
| Tekrar | `repetitions > 0` | `interval` gün sonra sorulur |

**Öğrenildi** (`mastered`): tekrar fazında ve aralık ≥ 21 gün. Unutulunca
yeniden "öğreniliyor" olur.

## Kurallar

- **Öğrenme adımları:** 1dk → 10dk. Hard ilk adımda iki adımın ortası (5dk),
  sonraki adımlarda aynı adımın tekrarı. Son adımda Good → **1 gün**,
  her adımda Easy → **4 gün**. Öğrenmede ease değişmez.
- **Tekrar:** Hard = aralık × 1,2 (ease −0,15), Good = aralık × ease,
  Easy = aralık × ease × 1,3 (ease +0,15). Her zaman Hard < Good < Easy
  (yalnız 365 gün tavanında eşitlenebilir).
- **Unutma (Again):** ease −0,20; yeni aralık eski aralığın %25'i (en az 1 gün);
  10dk yeniden öğrenme adımından sonra Good ile bu aralığa döner.
- **Ease sınırları:** 1,3 – 3,0 (varsayılan 2,5). Bozuk değerler onarılır.
- **Gecikme:** Kart geç çalışılıp yine hatırlandıysa gecikmenin Hard için ¼'ü,
  Good için ½'si, Easy için tamamı aralığa eklenir. Erken çalışmada geçen süre
  esas alınır ve Good mevcut aralığı küçültmez.
- **Fuzz:** 3 gün ve üstü aralıklara ±%5 (en az ±1 gün) sapma eklenir. Sapma kart
  id'si ve tekrar sayısından hesaplanır (deterministik): aynı gün eklenen kartlar
  aynı güne yığılmaz, butonların üstündeki önizleme gerçek sonuçla aynıdır.
- **Gün sınırı:** Gün aralıkları yerel saatle **04:00**'te başlayan güne göre
  verilir. 23:00'te de 02:00'de de Good ile 1 gün verilen kart sabah 04:00'te
  açılır. Dakika adımları tam saattir. Tarihler UTC saklanır.
- **Tavan:** en fazla 365 gün.

## Örnek aralıklar (ease 2,5, zamanında çalışılan kart, fuzz hariç)

| Kartın durumu | Again | Hard | Good | Easy |
|---|---|---|---|---|
| Yeni kart | 1dk | 5dk | 10dk | 4g |
| 2. adım (10dk) | 1dk | 10dk | 1g | 4g |
| Aralık 1g | 10dk → 1g | 2g | 3g | 4g |
| Aralık 3g | 10dk → 1g | 4g | 8g | 10g |
| Aralık 8g | 10dk → 2g | 10g | 20g | 26g |
| Aralık 20g | 10dk → 5g | 24g | 50g ✓ | 65g ✓ |

✓ = öğrenildi. Hep Good basılan kart: 1dk → 10dk → 1g → 3g → 8g → 20g → 50g.

## Neden FSRS değil?

FSRS daha isabetli tahmin yapar, ama kart başına "stability/difficulty" alanları
ve geçmiş tekrar kayıtları ister. Mevcut şemayla en iyi uygulanabilen seçenek
bu SM-2 varyantıdır; ileride şema genişletilirse FSRS'e geçiş değerlendirilebilir.
