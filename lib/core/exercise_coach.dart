// lib/core/exercise_coach.dart
// ============================================================
// AVCI TAKTİK KOÇU & AKILLI HAREKET DEĞİŞTİRİCİ
// Egzersizlerin anatomik hedeflerini, dövüş sporlarına katkısını,
// kritik form kurallarını ve akıllı alternatiflerini sunar.
// ============================================================

import '../controllers/system_memory.dart';
import '../models/task_model.dart';
import 'youtube_helper.dart';

class ExerciseTactics {
  final String ad;
  final String bolge;
  final String hedefKaslar;
  final String dovusKatkisi;
  final List<String> formKurallari;
  final List<String> alternatifler;
  final String eklemKorumaNotu;

  const ExerciseTactics({
    required this.ad,
    required this.bolge,
    required this.hedefKaslar,
    required this.dovusKatkisi,
    required this.formKurallari,
    required this.alternatifler,
    this.eklemKorumaNotu = 'Hareket esnasında ağrı veya batma olursa derhal durun.',
  });
}

class ExerciseCoach {
  /// Bilinen hareketler için taktik veri tabanı
  static final Map<String, ExerciseTactics> _bilgiTabani = {
    'push up': const ExerciseTactics(
      ad: 'Şınav (Push-up)',
      bolge: 'Göğüs & İtiş',
      hedefKaslar: 'Göğüs (Pectoralis Major), Ön Omuz, Triceps, Core',
      dovusKatkisi: 'Direkt yumruk patlayıcılığı, gard tutma dayanıklılığı ve gövde sertliği sağlar.',
      formKurallari: [
        'Dirseklerini gövdeye 45 derece açıyla tut, dışarı doğru kanat açma.',
        'Core ve kalçanı sıkarak belinin aşağı çökmesini engelle (tahta gibi düz ol).',
        'Göğsün yere 2-3 cm yaklaşana kadar kontrollü in, patlayıcı bir şekilde yukarı it.',
      ],
      alternatifler: [
        'Dumbbell Floor Press (3x12)',
        'Incline Dumbbell Press (3x10)',
        'Dips / Sehpada İtiş (3x10)',
        'Plyo Patlayıcı Şınav (4x8)',
      ],
      eklemKorumaNotu: 'Bilek ağrısı varsa yumruk üzerinde veya şınav barı ile yapın.',
    ),

    'bench': const ExerciseTactics(
      ad: 'Bench Press',
      bolge: 'Göğüs & İtiş',
      hedefKaslar: 'Göğüs, Ön Omuz, Triceps',
      dovusKatkisi: 'Maksimum itiş torku ve rakibi kafes/ring iplerine iterken üstün gövde kuvveti sağlar.',
      formKurallari: [
        'Kürek kemiklerini (scapula) sehpaya kilitle ve göğüs kafesini öne çıkar.',
        'Barı meme ucunun hemen altına kontrollü indir, patlayıcı it.',
        'Ayaklarını yere sıkıca basarak bacak itişini (leg drive) aktif kullan.',
      ],
      alternatifler: [
        'Dumbbell Bench Press (4x10)',
        'Dumbbell Floor Press (Omuz Dostu) (4x10)',
        'Ağırlıklı Şınav (4x12)',
        'Landmine Punch Press (4x8)',
      ],
      eklemKorumaNotu: 'Omuzda batma varsa Dumbbell Floor Press veya Neutral Grip tercih edin.',
    ),

    'squat': const ExerciseTactics(
      ad: 'Squat (Çömelme)',
      bolge: 'Bacak & Kalça',
      hedefKaslar: 'Kuadriseps, Gluteus (Kalça), Hamstrings, Core',
      dovusKatkisi: 'Takedown patlayıcılığı, tekme gücü ve darbeleri sönümleyen alt gövde köklenmesi sağlar.',
      formKurallari: [
        'Dizlerini ayak parmak yönünde dışarı doğru it, içeri çökmelerine asla izin verme.',
        'Topuklarını yerden kaldırma, ağırlık merkezini ayağın ortasında tut.',
        'Omurganı nötr pozisyonda koruyarak kalçayı geriye doğru indir.',
      ],
      alternatifler: [
        'Bulgarian Split Squat (Tek Bacak) (3x10)',
        'Goblet Squat (Dambıl ile) (4x12)',
        'Leg Press (Diz Dostu) (4x12)',
        'Zıplamalı Squat (Jump Squat) (4x15)',
      ],
      eklemKorumaNotu: 'Diz batması varsa açıyı 90 derecede sınırlandırın veya Box Squat yapın.',
    ),

    'deadlift': const ExerciseTactics(
      ad: 'Deadlift',
      bolge: 'Arka Zincir & Sırt',
      hedefKaslar: 'Hamstrings, Kalça, Bel, Sırt, Trapez, Ön Kol (Kavrama)',
      dovusKatkisi: 'Güreş klincinde rakibi yerden söküp kaldırma (slam) ve kırılmaz boyun/sırt zırhı kazandırır.',
      formKurallari: [
        'Barı bacaklarına olabildiğince yakın tut, bar sürtünerek yukarı çıksın.',
        'Beli bükme, göğsü dik tutarak kalça menteşesi (hip hinge) hareketini yap.',
        'Yukarı kalktığında kalçanı sık, geriye aşırı hiperekstansiyon yapma.',
      ],
      alternatifler: [
        'Romanian Deadlift (Dambıl ile) (4x10)',
        'Trap Bar Deadlift (Bel Dostu) (4x8)',
        'Barbell Hip Thrust (4x12)',
        'Kettlebell Swing (4x20)',
      ],
      eklemKorumaNotu: 'Bel hassasiyetinde Trap Bar veya Dumbbell Romanian Deadlift kullanın.',
    ),

    'pull up': const ExerciseTactics(
      ad: 'Barfiks (Pull-up / Chin-up)',
      bolge: 'Sırt & Biceps',
      hedefKaslar: 'Latissimus Dorsi (Kanat), Biceps, Arka Omuz, Core',
      dovusKatkisi: 'Rakibi kendine çekme (clinch kontrolü), boğma (choke) ve gardı içeri çekme kuvveti sağlar.',
      formKurallari: [
        'Kolları tam kilitten başlatıp çene barın üzerine geçene kadar çek.',
        'Sallanmadan (kipping yapmadan) göğsü bara doğru yükselt.',
        'İniş fazını (negatif) en az 2 saniye yavaş ve kontrollü yap.',
      ],
      alternatifler: [
        'Lat Pulldown (Makineli) (4x10)',
        'Dumbbell Row / Testere Çekiş (4x10)',
        'Avustralya Barfiksi (Inverted Row) (4x12)',
        'Resistance Band Destekli Barfiks (4x8)',
      ],
      eklemKorumaNotu: 'Omuz sıkışması varsa avuç içleri yüze bakan Chin-up veya nötr tutuş deneyin.',
    ),

    'plank': const ExerciseTactics(
      ad: 'Plank & Core Dayanıklılığı',
      bolge: 'Karın & Core',
      hedefKaslar: 'Transverse Abdominis, Rektus Abdominis, Bel Kasları',
      dovusKatkisi: 'Karaciğere ve gövdeye gelen sert tekmeleri/yumrukları dağıtan çelik zırh oluşturur.',
      formKurallari: [
        'Dirsekler doğrudan omuzların altında olsun.',
        'Kalçayı yukarı kaldırma veya belin çökmesine izin verme, kalçayı ve karnı sonuna kadar sık.',
        'Derin ve ritmik diyafram nefesi alarak süreyi koru.',
      ],
      alternatifler: [
        'Ab Wheel Rollout (3x10)',
        'Hollow Body Hold (4x30 sn)',
        'Deadbug Hareketi (Bel Dostu) (3x15)',
        'Russian Twist (Dambıl ile) (4x20)',
      ],
      eklemKorumaNotu: 'Belde acı hissedilirse Deadbug veya Bird-Dog hareketine geçin.',
    ),

    'boks': const ExerciseTactics(
      ad: 'Boks Kombinasyonları & Gölge Boksu',
      bolge: 'Dövüş & Kondisyon',
      hedefKaslar: 'Tüm Vücut, Omuzlar, Rotasyonel Core, Bacaklar',
      dovusKatkisi: 'Mesafe yönetimi, el-ayak koordinasyonu, refleks ve yüksek tempolu anaerobik kapasite.',
      formKurallari: [
        'Yumruk atarken gücü ayak parmak ucundan ve kalça rotasyonundan al.',
        'Diğer el daima çeneni korusun (gardı düşürme).',
        'Her yumruk vuruşunda sert nefes ver (tıss/hıss sesi).',
      ],
      alternatifler: [
        'Ağır Kum Torbası Kombinasyonları (5 Raund x 3 Dk)',
        'İp Atlama (Hızlı Tempolu) (5 Set x 2 Dk)',
        'Dambıl ile Hafif Gölge Boksu (1-2 kg) (4 Raund)',
        'Plyometrik Burpee Drill (4x12)',
      ],
    ),
  };

  /// Bilinen hareketler için anahtar kelime haritası
  static final Map<List<String>, ExerciseTactics> _kategoriHaritasi = {
    ['push up', 'push-up', 'pushup', 'şınav', 'sinav']: _bilgiTabani['push up']!,
    ['bench', 'chest press', 'göğüs pres']: _bilgiTabani['bench']!,
    ['squat', 'çömelme', 'comelme', 'leg press', 'split squat']: _bilgiTabani['squat']!,
    ['deadlift', 'yerden kesme', 'romanian']: _bilgiTabani['deadlift']!,
    ['pull up', 'pull-up', 'chin up', 'chin-up', 'barfiks', 'row', 'çekiş', 'cekis']: _bilgiTabani['pull up']!,
    ['plank', 'core', 'karın', 'karin', 'mekik', 'sit-up', 'abs']: _bilgiTabani['plank']!,
    ['boks', 'boxing', 'striking', 'gölge boksu', 'golge boksu', 'torba', 'combat']: _bilgiTabani['boks']!,
  };

  /// Görev adını analiz ederek en uygun taktik kartını döndürür
  static ExerciseTactics getTactics(String gorevAdi) {
    final arama = gorevAdi.toLowerCase();

    for (var entry in _kategoriHaritasi.entries) {
      for (var anahtar in entry.key) {
        if (arama.contains(anahtar)) {
          return entry.value;
        }
      }
    }

    // Özel eşleşme bulunamazsa akıllı dinamik kart üret
    final temizAd = YoutubeHelper.gorevAdiniTemizle(gorevAdi).replaceAll('egzersizi nasıl yapılır form', '').trim();
    return ExerciseTactics(
      ad: temizAd.isNotEmpty ? temizAd : gorevAdi,
      bolge: gorevAdi.contains('[COMBAT]') ? 'Dövüş Sporu & Güç' : (gorevAdi.contains('[CORE') ? 'Karın & Core' : 'Genel Kuvvet'),
      hedefKaslar: 'Hedeflenen ana kas grubu, stabilizasyon kasları ve core.',
      dovusKatkisi: 'Patlayıcı güç aktarımı, kas dayanıklılığı ve genel atletik koordinasyon sağlar.',
      formKurallari: const [
        'Hareketi acele etmeden, tam hareket menzilinde (Full ROM) tamamlayın.',
        'Zorlanma anında nefes verin, gevşeme anında derin nefes alın.',
        'Omurganızı dik ve nötr tutarak yükü doğrudan eklemlere değil kaslara bindirin.',
      ],
      alternatifler: const [
        'Dumbbell Varyasyonu (3x10)',
        'Calisthenics / Vücut Ağırlığı (4x12)',
        'Kablo / Direnç Lastiği Varyasyonu (3x15)',
      ],
      eklemKorumaNotu: 'Eklem bölgesinde rahatsızlık hissederseniz ağırlığı düşürün veya varyasyonu değiştirin.',
    );
  }

  /// Bir görevi listede alternatif hareketle değiştirir ve kaydeder
  static Future<bool> swapExercise({
    required int gun,
    required int index,
    required String yeniHareketAdi,
  }) async {
    try {
      if (SystemMemory.haftalikPlan.containsKey(gun) &&
          index >= 0 &&
          index < SystemMemory.haftalikPlan[gun]!.length) {
        final eskiGorev = SystemMemory.haftalikPlan[gun]![index];
        SystemMemory.haftalikPlan[gun]![index] = Gorev(
          yeniHareketAdi,
          false,
          eskiGorev.tip,
        );
        await SystemMemory.kaydet();
        return true;
      }
    } catch (e) {
      // Hata yakalama
    }
    return false;
  }
}
