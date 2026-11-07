import 'package:flutter_test/flutter_test.dart';
import 'package:learncard_flutter/services/seed_gate.dart';

void main() {
  test('aynı anda gelen iki yükleme örnekleri bir kez ekler', () async {
    final store = <String>[];
    var seeds = 0;
    final gate = SeedGate();
    Future<List<String>> read() async {
      await Future<void>.delayed(const Duration(milliseconds: 5));
      return List.of(store);
    }

    Future<void> seed() async {
      seeds++;
      await Future<void>.delayed(const Duration(milliseconds: 5));
      store.addAll(['a', 'b']);
    }

    final results = await Future.wait([
      gate.fillIfEmpty(read: read, seed: seed),
      gate.fillIfEmpty(read: read, seed: seed),
    ]);
    expect(seeds, 1);
    expect(store, ['a', 'b']);
    expect(results, [
      ['a', 'b'],
      ['a', 'b'],
    ]);
  });

  test('hata sonraki çağrıyı kilitlemez', () async {
    final gate = SeedGate();
    await expectLater(
      gate.fillIfEmpty<String>(read: () async => [], seed: () async => throw StateError('x')),
      throwsStateError,
    );
    expect(await gate.fillIfEmpty(read: () async => ['ok'], seed: () async {}), ['ok']);
  });
}
