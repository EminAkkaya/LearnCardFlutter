/// LearnCard SRS (Spaced Repetition System) algoritması.
///
/// Anki'nin SM-2 varyantını izler (ayrıntılar ve örnek tablo: `docs/SRS.md`):
/// - **Öğrenme** (yeni kart): dakika bazlı adımlar ([learningSteps], 1dk → 10dk),
///   son adımda Good ile [graduatingIntervalDays] gün, Easy ile hemen
///   [easyIntervalDays] gün sonra "tekrar" fazına geçer. Öğrenmede ease değişmez.
/// - **Tekrar** (review): Hard = aralık × [hardIntervalMultiplier],
///   Good = aralık × ease, Easy = aralık × ease × [easyBonus]. Her zaman
///   Hard < Good < Easy (yalnız [maxIntervalDays] tavanında eşitlenebilir).
///   Geciken (overdue) kartta gecikmenin Hard için ¼'ü, Good için ½'si, Easy
///   için tamamı aralığa eklenir: geç de olsa hatırlanan kart daha güçlüdür.
/// - **Unutma** (lapse, tekrar fazında Again): ease −[lapseEasePenalty], yeni
///   aralık eski aralığın [lapseIntervalMultiplier] katı (en az 1 gün) olarak
///   saklanır ve kart [relearningSteps] adımından sonra bu aralıkla döner.
/// - Gün aralıkları yerel saatle [dayStartHour]:00'da başlayan "çalışma günü"ne
///   yuvarlanır; böylece aynı gün çalışılan kartlar ertesi sabah birlikte açılır.
/// - Aralıklara kart id'si ve tekrar sayısından türetilen deterministik ±%5
///   ([fuzzFraction]) sapma eklenir: aynı gün eklenen kartlar aynı güne yığılmaz,
///   önizleme ile gerçek sonuç birebir aynı kalır.
///
/// Durum alanlarının anlamı (şema değişmeden, eski kartlarla uyumlu):
/// - `repetitions == 0` (veya `status == 'new'`): kart öğrenme adımlarında.
///   `interval > 0` ise bu bir yeniden öğrenmedir ve `interval` mezuniyet
///   sonrası kullanılacak (unutma sonrası) aralıktır.
/// - `repetitions > 0`: kart tekrar fazında, `interval` gün cinsinden aralık.
/// - `learningStep`: öğrenme/yeniden öğrenme adımının sırası.
///
/// FSRS daha isabetli tahmin yapar ama "stability/difficulty" alanları ve
/// geçmiş kayıtları ister; mevcut şemayla uygulanabilen en iyi seçenek bu SM-2
/// varyantıdır.
library;

import 'dart:math' as math;

import '../models/flashcard_model.dart';

enum ReviewRating { again, hard, good, easy }

class SRSService {
  // ---------------------------------------------------------------------------
  // Öğrenme / yeniden öğrenme
  // ---------------------------------------------------------------------------

  /// Yeni kartın öğrenme adımları. Son adımda Good kartı mezun eder.
  static const List<Duration> learningSteps = [
    Duration(minutes: 1),
    Duration(minutes: 10),
  ];

  /// Unutulan (lapse) kartın yeniden öğrenme adımları.
  static const List<Duration> relearningSteps = [
    Duration(minutes: 10),
  ];

  /// Öğrenmenin son adımında Good ile verilen ilk aralık (gün).
  static const int graduatingIntervalDays = 1;

  /// Öğrenmede Easy ile adımları atlayıp verilen ilk aralık (gün).
  static const int easyIntervalDays = 4;

  // ---------------------------------------------------------------------------
  // Tekrar fazı
  // ---------------------------------------------------------------------------

  /// Hard: mevcut aralık bu katsayıyla büyür (ease'den bağımsız).
  static const double hardIntervalMultiplier = 1.2;

  /// Easy: Good aralığına ek çarpan.
  static const double easyBonus = 1.3;

  /// Unutmada (Again) yeni aralık = eski aralık × bu katsayı (en az
  /// [minLapseIntervalDays]).
  static const double lapseIntervalMultiplier = 0.25;
  static const int minLapseIntervalDays = 1;

  /// Ease (kolaylık) katsayısı sınırları ve değişimleri.
  static const double defaultEase = 2.5;
  static const double minEase = 1.3;
  static const double maxEase = 3.0;
  static const double lapseEasePenalty = 0.20;
  static const double hardEasePenalty = 0.15;
  static const double easyEaseBonus = 0.15;

  /// Aralık tavanı (gün).
  static const int maxIntervalDays = 365;

  /// Aralığı en az bu kadar gün olan tekrar kartı "öğrenildi" sayılır
  /// (Anki'deki "olgun kart" eşiği).
  static const int masteredMinIntervalDays = 21;

  // ---------------------------------------------------------------------------
  // Fuzz ve gün sınırı
  // ---------------------------------------------------------------------------

  /// Gün aralıklarına uygulanan deterministik sapma oranı (±%5, en az ±1 gün).
  static const double fuzzFraction = 0.05;

  /// Bu değerden kısa aralıklara sapma uygulanmaz (1-2 gün tam kalır).
  static const int fuzzMinIntervalDays = 3;

  /// Çalışma günü yerel saatle bu saatte başlar; gece 02:00'de yapılan tekrar
  /// önceki güne sayılır.
  static const int dayStartHour = 4;

  // ---------------------------------------------------------------------------
  // Genel API
  // ---------------------------------------------------------------------------

  /// Derecelendirmeye göre kartın yeni SRS durumunu hesaplar.
  static FlashcardModel calculateSRS(
    FlashcardModel card,
    ReviewRating rating, {
    DateTime? now,
  }) {
    final at = now ?? DateTime.now();
    final outcome = _outcomes(card, at)[rating]!;
    return card.copyWith(
      easeFactor: double.parse(outcome.ease.toStringAsFixed(2)),
      interval: outcome.interval,
      repetitions: outcome.repetitions,
      learningStep: outcome.learningStep,
      nextReviewDate: formatReviewDate(outcome.dueDate(at)),
      status: outcome.status,
    );
  }

  /// Her derecelendirme için bir sonraki tekrarın ne kadar sonra olacağını
  /// (ör. `1dk`, `10dk`, `1g`, `4g`) verir. [calculateSRS] ile aynı hesabı
  /// kullanır; gösterilen değer gerçek sonuçla birebir aynıdır.
  static Map<ReviewRating, String> getNextIntervalPreviews(
    FlashcardModel card, {
    DateTime? now,
  }) {
    final at = now ?? DateTime.now();
    return {
      for (final entry in _outcomes(card, at).entries)
        entry.key: entry.value.label,
    };
  }

  /// Yeni tekrar tarihleri her zaman UTC ISO-8601 olarak saklanır
  /// (ör. `2026-11-07T09:30:00.000Z`).
  static String formatReviewDate(DateTime date) => date.toUtc().toIso8601String();

  static final RegExp _dateOnly = RegExp(r'^\d{4}-\d{2}-\d{2}$');

  /// Saklanan tekrar tarihini ayrıştırır; eski kayıtlarla geriye uyumludur:
  /// - `YYYY-MM-DD` (eski, yalnız tarih): o günün yerel gece yarısı.
  /// - Ofsetsiz tarih-saat (eski, yerel saat): yerel saat olarak.
  /// - `Z` veya `+03:00` / `+00` ofsetli (yeni ve Supabase timestamptz):
  ///   ofset korunarak gerçek an olarak.
  /// Ayrıştırılamazsa null döner.
  static DateTime? parseReviewDate(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    if (_dateOnly.hasMatch(trimmed)) {
      final parts = trimmed.split('-').map(int.parse).toList();
      return DateTime(parts[0], parts[1], parts[2]);
    }
    return DateTime.tryParse(trimmed);
  }

  /// Kartın planlanan anı geldiyse (veya geçtiyse) true.
  static bool isCardDue(FlashcardModel card, {DateTime? now}) {
    if (card.status == 'new') return true;
    final reviewDate = parseReviewDate(card.nextReviewDate);
    if (reviewDate == null) return true;
    return !reviewDate.isAfter(now ?? DateTime.now());
  }

  /// [now] anının ait olduğu çalışma gününün başlangıcı (yerel [dayStartHour]:00).
  static DateTime studyDayStart(DateTime now) {
    final shifted = now.toLocal().subtract(const Duration(hours: dayStartHour));
    return DateTime(shifted.year, shifted.month, shifted.day, dayStartHour);
  }

  /// [now] anından [days] çalışma günü sonrasının başlangıcı (yerel saat;
  /// takvim aritmetiği olduğundan yaz saati geçişlerinde kaymaz).
  static DateTime dueDateAfterDays(DateTime now, int days) {
    final start = studyDayStart(now);
    return DateTime(start.year, start.month, start.day + days, dayStartHour);
  }

  /// [days] günlük aralığa kart ve [seed]'e bağlı deterministik sapma uygular.
  /// Sonuç `days ± max(1, round(days × fuzzFraction))` aralığındadır.
  static int applyFuzz(int days, String seed) {
    if (days < fuzzMinIntervalDays) return days;
    final range = math.max(1, (days * fuzzFraction).round());
    final offset = _fnv1a(seed) % (2 * range + 1) - range;
    return days + offset;
  }

  // ---------------------------------------------------------------------------
  // Hesaplama
  // ---------------------------------------------------------------------------

  /// Dört derecelendirmenin sonuçlarını birlikte hesaplar; Hard < Good < Easy
  /// sıralaması ancak hepsi birlikte bilinince garanti edilebilir.
  static Map<ReviewRating, _Outcome> _outcomes(FlashcardModel card, DateTime now) {
    final ease = _sanitizeEase(card.easeFactor);
    final interval = card.interval.clamp(0, maxIntervalDays);
    final inSteps = card.status == 'new' || card.repetitions <= 0;
    if (!inSteps) return _reviewOutcomes(card, ease, interval, now);
    // 'new' kartın eski aralık değeri yok sayılır; öğrenmedeki kartın
    // interval > 0 değeri ise unutma sonrası saklanan aralıktır.
    final relearning = card.status != 'new' && interval > 0;
    return _stepOutcomes(card, ease, relearning ? interval : 0);
  }

  static double _sanitizeEase(double ease) {
    if (ease.isNaN || ease <= 0) return defaultEase;
    return ease.clamp(minEase, maxEase).toDouble();
  }

  /// Öğrenme (lapseInterval == 0) veya yeniden öğrenme adımları.
  static Map<ReviewRating, _Outcome> _stepOutcomes(
    FlashcardModel card,
    double ease,
    int lapseInterval,
  ) {
    final relearning = lapseInterval > 0;
    final steps = relearning ? relearningSteps : learningSteps;
    // 'new' kart hiç çalışılmamıştır; adım her zaman baştan başlar.
    final step = card.status == 'new' ? 0 : card.learningStep.clamp(0, steps.length - 1);

    _Outcome inStep(int index, Duration delay) => _Outcome.step(
          learningStep: index,
          interval: lapseInterval,
          ease: ease,
          delay: delay,
        );

    // Hard ilk adımda ilk iki adımın ortalaması (tek adım varsa 1.5 katı,
    // en fazla +1 gün), sonraki adımlarda mevcut adımın tekrarıdır.
    final Duration hardDelay;
    if (step == 0 && steps.length > 1) {
      hardDelay = (steps[0] + steps[1]) ~/ 2;
    } else if (step == 0) {
      final scaled = steps[0] * 1.5;
      final capped = steps[0] + const Duration(days: 1);
      hardDelay = scaled < capped ? scaled : capped;
    } else {
      hardDelay = steps[step];
    }

    final seed = '${card.id}|${card.repetitions}|$lapseInterval';
    final graduate = relearning
        ? math.min(applyFuzz(lapseInterval, '$seed|good'), maxIntervalDays)
        : graduatingIntervalDays;
    final easy = math.min(
      math.max(
        applyFuzz(relearning ? lapseInterval + 1 : easyIntervalDays, '$seed|easy'),
        graduate + 1,
      ),
      maxIntervalDays,
    );

    final next = step + 1;
    return {
      ReviewRating.again: inStep(0, steps[0]),
      ReviewRating.hard: inStep(step, hardDelay),
      ReviewRating.good: next < steps.length
          ? inStep(next, steps[next])
          : _Outcome.review(interval: graduate, repetitions: 1, ease: ease),
      ReviewRating.easy: _Outcome.review(interval: easy, repetitions: 1, ease: ease),
    };
  }

  /// Tekrar fazı: Again unutma, diğerleri aralığı büyütür.
  static Map<ReviewRating, _Outcome> _reviewOutcomes(
    FlashcardModel card,
    double ease,
    int storedInterval,
    DateTime now,
  ) {
    final current = math.max(1, storedInterval);
    final delay = _daysOverdue(card, now);
    final seed = '${card.id}|${card.repetitions}';
    int fuzz(double days, String rating) =>
        applyFuzz(days.round(), '$seed|$rating');

    final double hardRaw, goodRaw, easyRaw;
    final int hardFloor, goodFloor;
    if (delay >= 0) {
      hardRaw = (current + delay ~/ 4) * hardIntervalMultiplier;
      goodRaw = (current + delay ~/ 2) * ease;
      easyRaw = (current + delay) * ease * easyBonus;
      hardFloor = current + 1;
      goodFloor = 0;
    } else {
      // Erken tekrar (ör. özel çalışma listesi): geçen süre üzerinden
      // hesaplanır, Good mevcut aralığı küçültmez.
      final elapsed = math.max(1, current + delay);
      hardRaw = elapsed * hardIntervalMultiplier;
      goodRaw = elapsed * ease;
      easyRaw = elapsed * ease * easyBonus;
      hardFloor = 1;
      goodFloor = current;
    }

    int cap(int days) => math.min(days, maxIntervalDays);
    final hard = cap(math.max(fuzz(hardRaw, 'hard'), hardFloor));
    final good = cap(math.max(math.max(fuzz(goodRaw, 'good'), hard + 1), goodFloor));
    final easy = cap(math.max(fuzz(easyRaw, 'easy'), good + 1));

    final reps = card.repetitions + 1;
    final lapseInterval = math.min(
      math.max(minLapseIntervalDays, (current * lapseIntervalMultiplier).round()),
      maxIntervalDays,
    );
    return {
      ReviewRating.again: _Outcome.step(
        learningStep: 0,
        interval: lapseInterval,
        ease: _clampEase(ease - lapseEasePenalty),
        delay: relearningSteps.first,
      ),
      ReviewRating.hard: _Outcome.review(
        interval: hard,
        repetitions: reps,
        ease: _clampEase(ease - hardEasePenalty),
      ),
      ReviewRating.good: _Outcome.review(interval: good, repetitions: reps, ease: ease),
      ReviewRating.easy: _Outcome.review(
        interval: easy,
        repetitions: reps,
        ease: _clampEase(ease + easyEaseBonus),
      ),
    };
  }

  static double _clampEase(double ease) => ease.clamp(minEase, maxEase).toDouble();

  /// Planlanan tarihten bu yana geçen tam gün (erken tekrarda negatif).
  static int _daysOverdue(FlashcardModel card, DateTime now) {
    final due = parseReviewDate(card.nextReviewDate);
    if (due == null) return 0;
    return (now.difference(due).inMinutes / Duration.minutesPerDay).floor();
  }

  /// Platformdan bağımsız, kararlı 32-bit FNV-1a özeti.
  static int _fnv1a(String input) {
    var hash = 0x811c9dc5;
    for (final unit in input.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash;
  }
}

/// Bir derecelendirmenin sonucu: ya dakika bazlı bir adım ([delay]) ya da gün
/// bazlı bir tekrar aralığı ([interval], [_Outcome.isReview]).
class _Outcome {
  final String status;
  final int interval;
  final int repetitions;
  final int learningStep;
  final double ease;
  final Duration? delay;

  const _Outcome.step({
    required this.learningStep,
    required this.interval,
    required this.ease,
    required Duration this.delay,
  })  : status = 'learning',
        repetitions = 0;

  _Outcome.review({
    required this.interval,
    required this.repetitions,
    required this.ease,
  })  : status = interval >= SRSService.masteredMinIntervalDays ? 'mastered' : 'learning',
        learningStep = SRSService.learningSteps.length,
        delay = null;

  bool get isReview => delay == null;

  DateTime dueDate(DateTime now) =>
      isReview ? SRSService.dueDateAfterDays(now, interval) : now.add(delay!);

  String get label {
    if (isReview) return '${interval}g';
    final d = delay!;
    if (d.inMinutes < 60) return '${math.max(1, d.inMinutes)}dk';
    if (d.inHours < 24) return '${d.inHours}sa';
    return '${d.inDays}g';
  }
}
