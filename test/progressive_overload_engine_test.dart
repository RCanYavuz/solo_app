// test/progressive_overload_engine_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:solo_leveling_app/core/progressive_overload_engine.dart';
import 'package:solo_leveling_app/controllers/system_memory.dart';
import 'package:solo_leveling_app/widgets/rir_feedback_modal.dart';
import 'package:solo_leveling_app/models/task_model.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    SystemMemory.overloadGecmisi.clear();
  });

  group('Progressive Overload Engine Kural Testleri', () {
    test('Egzersiz sınıflandırma kuralları doğru çalışmalı', () {
      expect(ProgressiveOverloadEngine.bacakHareketiMi('Barbell Back Squat'), isTrue);
      expect(ProgressiveOverloadEngine.bacakHareketiMi('Leg Press'), isTrue);
      expect(ProgressiveOverloadEngine.bacakHareketiMi('Romanian Deadlift'), isTrue);
      expect(ProgressiveOverloadEngine.bacakHareketiMi('Incline Bench Press'), isFalse);

      expect(ProgressiveOverloadEngine.ustGovdeCompoundMu('Bench Press'), isTrue);
      expect(ProgressiveOverloadEngine.ustGovdeCompoundMu('Barbell Overhead Press'), isTrue);
      expect(ProgressiveOverloadEngine.ustGovdeCompoundMu('Pull Up'), isTrue);
      expect(ProgressiveOverloadEngine.ustGovdeCompoundMu('Bicep Curl'), isFalse);
    });

    test('RIR 4+ (Çok Kolay) durumunda üst gövdeye +2.5 kg, bacağa +5.0 kg artış vermeli', () {
      // Üst Gövde
      final benchSonuc = ProgressiveOverloadEngine.hesaplaGelecekSeans(
        egzersizAdi: 'Bench Press',
        sonKilo: 80.0,
        sonTekrar: 10,
        rir: 4,
      );
      expect(benchSonuc.onerilenKilo, equals(82.5));
      expect(benchSonuc.onerilenTekrar, equals(10));
      expect(benchSonuc.sistemMesaji, contains('+2.5 kg'));

      // Bacak
      final squatSonuc = ProgressiveOverloadEngine.hesaplaGelecekSeans(
        egzersizAdi: 'Barbell Squat',
        sonKilo: 100.0,
        sonTekrar: 8,
        rir: 5,
      );
      expect(squatSonuc.onerilenKilo, equals(105.0));
      expect(squatSonuc.onerilenTekrar, equals(8));
      expect(squatSonuc.sistemMesaji, contains('+5 kg'));
    });

    test('RIR 4+ vücut ağırlığı egzersizinde tekrarı +2 artırmalı', () {
      final pushupSonuc = ProgressiveOverloadEngine.hesaplaGelecekSeans(
        egzersizAdi: 'Push Up',
        sonKilo: 0.0,
        sonTekrar: 20,
        rir: 4,
      );
      expect(pushupSonuc.onerilenKilo, equals(0.0));
      expect(pushupSonuc.onerilenTekrar, equals(22));
      expect(pushupSonuc.sistemMesaji, contains('+2 tekrar'));
    });

    test('RIR 2-3 (Optimum Hipertrofi) durumunda Double Progression kuralı işlemeli', () {
      // 12 tekrarın altındaysa: Ağırlık sabit, tekrar +1
      final sonuc1 = ProgressiveOverloadEngine.hesaplaGelecekSeans(
        egzersizAdi: 'Incline Dumbbell Press',
        sonKilo: 30.0,
        sonTekrar: 9,
        rir: 2,
      );
      expect(sonuc1.onerilenKilo, equals(30.0));
      expect(sonuc1.onerilenTekrar, equals(10));
      expect(sonuc1.sistemMesaji, contains('+1 tekrar'));

      // 12 tekrara ulaştıysa: Ağırlık artmalı ve tekrar 8'e sıfırlanmalı
      final sonuc2 = ProgressiveOverloadEngine.hesaplaGelecekSeans(
        egzersizAdi: 'Incline Bench Press',
        sonKilo: 70.0,
        sonTekrar: 12,
        rir: 3,
      );
      expect(sonuc2.onerilenKilo, equals(72.5));
      expect(sonuc2.onerilenTekrar, equals(8));
      expect(sonuc2.sistemMesaji, contains('12 tekrar barajı aşıldı'));
    });

    test('RIR 0-1 (Tükeniş / Limit) durumunda ağırlık ve tekrar korunmalı, toparlanma emredilmeli', () {
      final sonuc = ProgressiveOverloadEngine.hesaplaGelecekSeans(
        egzersizAdi: 'Deadlift',
        sonKilo: 140.0,
        sonTekrar: 5,
        rir: 1,
      );
      expect(sonuc.onerilenKilo, equals(140.0));
      expect(sonuc.onerilenTekrar, equals(5));
      expect(sonuc.sistemMesaji, contains('Toparlanma'));
    });

    test('Eklem ağrısı bildirildiğinde güvenli alternatif egzersiz atanmalı', () {
      final sonuc = ProgressiveOverloadEngine.hesaplaGelecekSeans(
        egzersizAdi: 'Bench Press',
        sonKilo: 90.0,
        sonTekrar: 8,
        rir: 2,
        agriVarMi: true,
      );
      expect(sonuc.agriBildirildiMi, isTrue);
      expect(sonuc.onerilenAlternatif, isNotNull);
      expect(sonuc.sistemMesaji, contains('EKLEM KORUMA PROTOKOLÜ'));
    });
  });

  group('OverloadKaydi ve SystemMemory Entegrasyon Testleri', () {
    test('OverloadKaydi JSON serileştirme ve geri okuma kayıpsız çalışmalı', () {
      final kayit = OverloadKaydi(
        egzersizAdi: 'Squat',
        sonKilo: 110.0,
        sonTekrar: 8,
        sonRir: 4,
        sonTarih: DateTime(2026, 9, 21),
        onerilenKilo: 115.0,
        onerilenTekrar: 8,
        sistemMesaji: 'Güç artışı!',
        agriBildirildiMi: false,
        onerilenAlternatif: null,
      );

      final json = kayit.toJson();
      final restore = OverloadKaydi.fromJson(json);

      expect(restore.egzersizAdi, equals('Squat'));
      expect(restore.sonKilo, equals(110.0));
      expect(restore.onerilenKilo, equals(115.0));
      expect(restore.sonRir, equals(4));
    });

    test('SystemMemory overload kayıtlarını saklamalı ve isim benzerliğine göre getirmeli', () {
      final kayit = OverloadKaydi(
        egzersizAdi: 'Barbell Bench Press',
        sonKilo: 85.0,
        sonTekrar: 10,
        sonRir: 4,
        sonTarih: DateTime.now(),
        onerilenKilo: 87.5,
        onerilenTekrar: 10,
        sistemMesaji: 'Bench artışı',
      );

      SystemMemory.overloadKaydiEkle(kayit);

      // Birebir eşleşme
      final tamEslesme = SystemMemory.getOverloadOneri('Barbell Bench Press');
      expect(tamEslesme, isNotNull);
      expect(tamEslesme!.onerilenKilo, equals(87.5));

      // Alt dize / benzerlik eşleşmesi
      final benzerEslesme = SystemMemory.getOverloadOneri('Bench Press');
      expect(benzerEslesme, isNotNull);
      expect(benzerEslesme!.onerilenKilo, equals(87.5));
    });

    test('Gorev modeli rirDegeri ve hedefKilo alanlarını doğru serileştirmeli', () {
      final gorev = Gorev(
        'Barbell Squat',
        false,
        'Fiziksel',
        [SetKaydi(setNo: 1, kilo: 100, tekrar: 10, tamamlandi: true)],
        3,
        105.0,
      );

      final json = gorev.toJson();
      expect(json['rirDegeri'], equals(3));
      expect(json['hedefKilo'], equals(105.0));

      final decoded = Gorev.fromJson(json);
      expect(decoded.rirDegeri, equals(3));
      expect(decoded.hedefKilo, equals(105.0));
      expect(decoded.setler.length, equals(1));
    });
  });

  group('RirFeedbackModal Widget Testleri', () {
    testWidgets('RirFeedbackModal ekranda açılır ve RIR 4+ seçilince başarı direktifini sunar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () {
                  RirFeedbackModal.goster(
                    ctx,
                    egzersizAdi: 'Bench Press',
                    sonKilo: 80.0,
                    sonTekrar: 10,
                  );
                },
                child: const Text('RIR Aç'),
              ),
            ),
          ),
        ),
      );

      // Modalı aç
      await tester.tap(find.text('RIR Aç'));
      await tester.pumpAndSettle();

      // Modal bileşenlerini doğrula
      expect(find.text('[ SİSTEM ANALİZİ ]'), findsOneWidget);
      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('RIR 4+ (Çok Kolay)'), findsOneWidget);
      expect(find.text('RIR 2-3 (İdeal Hipertrofi)'), findsOneWidget);
      expect(find.text('RIR 0-1 (Tükeniş / Aşırı Zor)'), findsOneWidget);

      // RIR 4+ seçeneğine dokun
      await tester.tap(find.text('RIR 4+ (Çok Kolay)'));
      await tester.pumpAndSettle();

      // Direktif ekranı açılmalı ve SystemMemory'ye kaydedilmeli
      expect(find.text('[ SİSTEM DİREKTİFİ ONAYLANDI ]'), findsOneWidget);
      expect(find.text('EMRİ KABUL ET & DEVAM ET'), findsOneWidget);
      expect(SystemMemory.getOverloadOneri('Bench Press'), isNotNull);
      expect(SystemMemory.getOverloadOneri('Bench Press')!.onerilenKilo, equals(82.5));

      // Emri kabul et ve kapat
      await tester.tap(find.text('EMRİ KABUL ET & DEVAM ET'));
      await tester.pumpAndSettle();

      // Modal kapanmış olmalı
      expect(find.text('[ SİSTEM DİREKTİFİ ONAYLANDI ]'), findsNothing);
    });
  });
}
