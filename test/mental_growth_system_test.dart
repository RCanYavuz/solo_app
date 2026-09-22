import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solo_leveling_app/models/mental_task_model.dart';
import 'package:solo_leveling_app/controllers/system_memory.dart';
import 'package:solo_leveling_app/core/services/gemini_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SystemMemory.baslat();
    SystemMemory.gunlukZihinselGorevler.value = [];
    SystemMemory.toplamOkunanSayfaSayisi = 0;
    SystemMemory.toplamOdaklanmaDakikasi = 0;
    SystemMemory.intStat.value = 10;
    SystemMemory.per.value = 10;
  });

  group('Faz 2: Çok Yönlü Avcı Gelişimi (Mental Tasks & Deep Work) Testleri', () {
    test('MentalTask Modeli JSON serileştirme ve copyWith doğru çalışır', () {
      final task = MentalTask(
        id: 'task_001',
        title: 'Clean Code Okuması',
        category: 'Book',
        targetMinutes: 30,
        rewardExp: 90,
        rewardInt: 2,
        rewardPer: 1,
        bookTitle: 'Clean Code',
        targetPages: 25,
      );

      final json = task.toJson();
      expect(json['id'], 'task_001');
      expect(json['title'], 'Clean Code Okuması');
      expect(json['category'], 'Book');
      expect(json['targetPages'], 25);

      final fromJson = MentalTask.fromJson(json);
      expect(fromJson.id, task.id);
      expect(fromJson.title, task.title);
      expect(fromJson.targetPages, 25);
      expect(fromJson.isCompleted, false);

      final copy = task.copyWith(isCompleted: true, completedPages: 25);
      expect(copy.isCompleted, true);
      expect(copy.completedPages, 25);
      expect(copy.title, 'Clean Code Okuması');
    });

    test('SystemMemory zihinsel görev ekleme ve tamamlama INT, PER ve EXP kazandırır', () async {
      final task = MentalTask(
        id: 'mental_test_1',
        title: 'Algoritma Analizi',
        category: 'Coding',
        targetMinutes: 40,
        rewardExp: 100,
        rewardInt: 3,
        rewardPer: 2,
      );

      await SystemMemory.zihinselGorevEkle(task);
      expect(SystemMemory.gunlukZihinselGorevler.value.length, 1);
      expect(SystemMemory.gunlukZihinselGorevler.value.first.isCompleted, false);

      final initialExp = SystemMemory.exp.value;
      final initialInt = SystemMemory.intStat.value;
      final initialPer = SystemMemory.per.value;

      await SystemMemory.zihinselGorevTamamla('mental_test_1');

      expect(SystemMemory.gunlukZihinselGorevler.value.first.isCompleted, true);
      expect(SystemMemory.intStat.value, initialInt + 3);
      expect(SystemMemory.per.value, initialPer + 2);
      expect(SystemMemory.level.value, greaterThanOrEqualTo(1));
      expect(SystemMemory.toplamOdaklanmaDakikasi, 40);
    });

    test('Kitap okuma görevi tamamlandığında okunan sayfa sayacı artar', () async {
      final bookTask = MentalTask(
        id: 'book_test_1',
        title: 'Atomik Alışkanlıklar',
        category: 'Book',
        targetMinutes: 25,
        targetPages: 20,
        rewardExp: 80,
        rewardInt: 2,
        rewardPer: 2,
      );

      await SystemMemory.zihinselGorevEkle(bookTask);
      await SystemMemory.zihinselGorevTamamla('book_test_1');

      expect(SystemMemory.toplamOkunanSayfaSayisi, 20);
      expect(SystemMemory.toplamOdaklanmaDakikasi, 25);
    });

    test('deepWorkTamamlandi hem süreyi hem statları artırır ve eşleşen görevi tamamlar', () async {
      final task = MentalTask(
        id: 'deep_work_match',
        title: 'Flutter İleri Mimari',
        category: 'Coding',
        targetMinutes: 50,
      );
      await SystemMemory.zihinselGorevEkle(task);

      final initialInt = SystemMemory.intStat.value;

      await SystemMemory.deepWorkTamamlandi(dakika: 50, baslik: 'Flutter İleri Mimari');

      expect(SystemMemory.toplamOdaklanmaDakikasi, 50);
      expect(SystemMemory.intStat.value, greaterThan(initialInt));
      expect(SystemMemory.gunlukZihinselGorevler.value.first.isCompleted, true);
    });

    test('GeminiService çevrimdışı çalışma protokolü şablonları üretir', () async {
      final codingTasks = await GeminiService.aiCalismaPlaniUret(
        alan: 'Yazılım & Kodlama',
        seviye: 'E-Rank',
        gunlukDakika: 45,
        hedef: 'Flutter ve Sistem Mimarisi',
      );

      expect(codingTasks.isNotEmpty, true);
      expect(codingTasks.any((t) => t.category == 'Coding' || t.category == 'Book'), true);

      final languageTasks = await GeminiService.aiCalismaPlaniUret(
        alan: 'Yabancı Dil (İngilizce)',
        seviye: 'C-Rank',
        gunlukDakika: 30,
      );

      expect(languageTasks.isNotEmpty, true);
      expect(languageTasks.any((t) => t.category == 'Language' || t.category == 'Book'), true);
    });

    test('GeminiService kitap ve konu için AI insight / çıkarım üretir', () async {
      final insight = await GeminiService.aiKitapCikarimiUret(
        kitapAdi: 'Savaş Sanatı',
        notlar: 'Strateji ve planlama ilkeleri',
      );

      expect(insight.contains('SİSTEM BİLGELİĞİ'), true);
      expect(insight.contains('Savaş Sanatı'), true);
    });
  });
}
