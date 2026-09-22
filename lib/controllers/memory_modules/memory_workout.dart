import 'package:flutter/foundation.dart';
import '../system_memory.dart';
import '../../models/task_model.dart';
import '../../core/progressive_overload_engine.dart';
import '../../core/services/gemini_service.dart';
import '../../core/audio_system.dart';

class MemoryWorkout {
  static void overloadKaydiEkle(OverloadKaydi kayit) {
    SystemMemory.overloadGecmisi[kayit.egzersizAdi] = kayit;
    SystemMemory.kaydet();
  }

  static OverloadKaydi? getOverloadOneri(String egzersizAdi) {
    if (SystemMemory.overloadGecmisi.containsKey(egzersizAdi)) {
      return SystemMemory.overloadGecmisi[egzersizAdi];
    }
    for (var entry in SystemMemory.overloadGecmisi.entries) {
      if (entry.key.toLowerCase().contains(egzersizAdi.toLowerCase()) ||
          egzersizAdi.toLowerCase().contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }

  static String zindanAkiniBitir(int gecenSaniye) {
    int dakika = gecenSaniye ~/ 60;
    if (dakika == 0 && gecenSaniye > 0) dakika = 1;
    
    int bugun = DateTime.now().weekday;
    int bitenGorevSayisiSimdi = SystemMemory.haftalikPlan[bugun]?.where((g) => g.yapildiMi).length ?? 0;

    SystemMemory.toplamIdmanDakikasi += dakika;
    SystemMemory.sonTesttenBeriIdmanSayisi++;
    SystemMemory.idmanGecmisi.add({
      'tarih': DateTime.now().toIso8601String(),
      'dakika': dakika,
      'gorevSayisi': bitenGorevSayisiSimdi
    });

    // İdman Yıpranma ve Kalori/Katabolizma Telafisini Tetikle
    SystemMemory.idmanYipranmasiIsle(
      dakika: dakika,
      idmanTuru: SystemMemory.dovusSporuYapiyorMu ? 'Dövüş & Zindan' : 'Ağırlık & Zindan',
    );

    // Solo Leveling Fatigue (Yorgunluk) artışı: Zindan eforu yorgunluğu artırır
    int yorgunlukArtisi = (dakika * 0.4).toInt().clamp(5, 30);
    SystemMemory.fatigue.value = (SystemMemory.fatigue.value + yorgunlukArtisi).clamp(0, 100);

    int kazanilanAltin = dakika * (SystemMemory.redGateAktif ? 10 : 2); 
    SystemMemory.altin.value += kazanilanAltin;
    
    int kazanilanExp = dakika * 5;
    String lvlUp = SystemMemory.expKazan(kazanilanExp);
    
    SystemMemory.kaydet();
    AudioSystem.playSuccess();
    
    return "[RAID COMPLETED]\nTime in Dungeon: $dakika Min\nQuests Completed: $bitenGorevSayisiSimdi\nTime Reward: +$kazanilanAltin Gold | +$kazanilanExp EXP$lvlUp";
  }

  /// Dövüş sporuna özel 5 raundluk uzatılmış gölge boksu ve kombinasyon protokolü üretir
  static List<Gorev> dovusGolgeBoksuKombinasyonlari({String? brans, int raundSayisi = 5}) {
    final seciliBrans = (brans ?? SystemMemory.dovusBransi).toLowerCase();

    if (seciliBrans.contains('kick')) {
      return [
        Gorev("[COMBAT-SHADOW] Kickboks R1: Dutch Volume 1-2 + Sol Kroşe + Sağ Low Kick (3 Dk)", false, "Fiziksel"),
        Gorev("[COMBAT-SHADOW] Kickboks R2: Mesafe Kontrolü Teep + Cross + Sol High Kick (3 Dk)", false, "Fiziksel"),
        Gorev("[COMBAT-SHADOW] Kickboks R3: Savunma Blok + Sağ Karaciğer Vuruşu + Low Kick (3 Dk)", false, "Fiziksel"),
        Gorev("[COMBAT-SHADOW] Kickboks R4: Açı Baskısı Sol Hook + Sağ Düz + Step Middle Kick (3 Dk)", false, "Fiziksel"),
        Gorev("[COMBAT-SHADOW] Kickboks R5: Hacim Burnout 4 Yumruk + Çift Low Kick (3 Dk)", false, "Fiziksel"),
      ];
    } else if (seciliBrans.contains('muay') || seciliBrans.contains('thai')) {
      return [
        Gorev("[COMBAT-SHADOW] Muay Thai R1: Muay Mat Teep + 1-2 + Yatay Dirsek + Sol Diz (3 Dk)", false, "Fiziksel"),
        Gorev("[COMBAT-SHADOW] Muay Thai R2: Clinch Kontrolü Hayali Çekiş + Dönerek Diz + Dirsek (3 Dk)", false, "Fiziksel"),
        Gorev("[COMBAT-SHADOW] Muay Thai R3: Denge Bozma Sol Teep + Sağ Low Kick + Sol Hook (3 Dk)", false, "Fiziksel"),
        Gorev("[COMBAT-SHADOW] Muay Thai R4: Shin Check Blok + Sağ Middle Kick + Düz Dirsek (3 Dk)", false, "Fiziksel"),
        Gorev("[COMBAT-SHADOW] Muay Thai R5: Muay Finisher Seri Dizler + Çift Teep & Dirsek (3 Dk)", false, "Fiziksel"),
      ];
    } else if (seciliBrans.contains('mma')) {
      return [
        Gorev("[COMBAT-SHADOW] MMA R1: Striking to Grapple 1-2 + Takedown Sahtesi + Overhand (3 Dk)", false, "Fiziksel"),
        Gorev("[COMBAT-SHADOW] MMA R2: Savunma Reaksiyonu Jab-Cross + Ani Sprawl + Kalkış (3 Dk)", false, "Fiziksel"),
        Gorev("[COMBAT-SHADOW] MMA R3: Kafes Baskısı Duvara İtme + Clinch Dizleri (3 Dk)", false, "Fiziksel"),
        Gorev("[COMBAT-SHADOW] MMA R4: Seviye Değişimi Düşük Sahte + Karaciğer Kroşe + Sağ Diz (3 Dk)", false, "Fiziksel"),
        Gorev("[COMBAT-SHADOW] MMA R5: Şampiyonluk Raundu Tüm Vuruşlar, Sprawl & Kalkış (3 Dk)", false, "Fiziksel"),
      ];
    } else if (seciliBrans.contains('güreş') || seciliBrans.contains('gures') || seciliBrans.contains('bjj') || seciliBrans.contains('judo')) {
      return [
        Gorev("[COMBAT-SHADOW] Güreş R1: Pummeling & Seviye Değişimi Drilli (3 Dk)", false, "Fiziksel"),
        Gorev("[COMBAT-SHADOW] Güreş R2: Snapdown + Ani Sprawl + Bacak Yakalama (3 Dk)", false, "Fiziksel"),
        Gorev("[COMBAT-SHADOW] Güreş R3: Takedown Sahtesi + Arm Drag + Arkaya Geçiş (3 Dk)", false, "Fiziksel"),
        Gorev("[COMBAT-SHADOW] Güreş R4: Yerden Patlayıcı Kalkış & Sprawl Reaksiyonu (3 Dk)", false, "Fiziksel"),
        Gorev("[COMBAT-SHADOW] Güreş R5: Aralıksız Tempo Pummeling & Sprawl Maratonu (3 Dk)", false, "Fiziksel"),
      ];
    } else {
      return [
        Gorev("[COMBAT-SHADOW] Boks R1: Out-Boxer Double Jab + Cross + Sol Pivot (3 Dk)", false, "Fiziksel"),
        Gorev("[COMBAT-SHADOW] Boks R2: Peek-a-boo Bob & Weave + 1-2-Roll-3-2 (3 Dk)", false, "Fiziksel"),
        Gorev("[COMBAT-SHADOW] Boks R3: İç Dövüş 1-2 + Sol Karaciğer Kroşesi + Aparkat (3 Dk)", false, "Fiziksel"),
        Gorev("[COMBAT-SHADOW] Boks R4: Step-around + Check Hook + Sağ Direkt (3 Dk)", false, "Fiziksel"),
        Gorev("[COMBAT-SHADOW] Boks R5: Şampiyonluk Raundu Burnout (Sürekli 1-2 & Hız) (3 Dk)", false, "Fiziksel"),
      ];
    }
  }

  static void baslangicPrograminiAta({
    required String ekipman,
    required String rank,
    required int idmanGunu,
    required String hedef,
    List<String>? eklemKisitlari,
    List<String>? hedefOdakBolgeleri,
  }) {
    SystemMemory.ekipmanTuru = ekipman;
    List<String> kisitlar = eklemKisitlari ?? SystemMemory.eklemKisiti;
    SystemMemory.eklemKisiti = kisitlar;
    List<String> odaklar = hedefOdakBolgeleri ?? SystemMemory.odakBolgeleri;
    SystemMemory.odakBolgeleri = odaklar;

    SystemMemory.haftalikPlan.clear();
    for (int i = 1; i <= 7; i++) {
      SystemMemory.haftalikPlan[i] = [];
    }

    bool omuzHassas = kisitlar.any((k) => k.toLowerCase().contains('omuz'));
    bool dizHassas = kisitlar.any((k) => k.toLowerCase().contains('diz'));
    bool belHassas = kisitlar.any((k) => k.toLowerCase().contains('bel'));

    String setRepLabel;
    final rUpper = rank.toUpperCase();
    if (rUpper.startsWith('S') || rUpper.startsWith('A')) {
      setRepLabel = "5 Sets x 8-12 Reps (Monarch Overload & Volume)";
    } else if (rUpper.startsWith('B') || rUpper.startsWith('C')) {
      setRepLabel = "4-5 Sets x 10-12 Reps (Knight Hypertrophy & Volume)";
    } else {
      setRepLabel = "4-5 Sets x 12-15 Reps (Extended Foundation)";
    }

    if (SystemMemory.dovusSporuYapiyorMu) {
      String dovusAdi = SystemMemory.dovusBransi;
      final combShadows = dovusGolgeBoksuKombinasyonlari(brans: SystemMemory.dovusBransi);
      if (idmanGunu <= 3) {
        SystemMemory.haftalikPlan[1]!.addAll([
          Gorev("[COMBAT] $dovusAdi: Patlayıcı İtiş & Plyo Şınav ($setRepLabel)", false, "Fiziksel"),
          Gorev("[COMBAT] Rotational Punch Press / Landmine ($setRepLabel)", false, "Fiziksel"),
          Gorev("[COMBAT] Strict Barfiks / Pull-up ($setRepLabel)", false, "Fiziksel"),
          Gorev("[COMBAT] Dumbbell Row & Çekiş Kuvveti ($setRepLabel)", false, "Fiziksel"),
          Gorev("[COMBAT] Boyun & Rotasyonel Core (Plank / Russian Twist)", false, "Fiziksel"),
          Gorev("[CARDIO] 20 Dk Hızlı İp Atlama & Ayak Çalışması", false, "Fiziksel"),
        ]);
        SystemMemory.haftalikPlan[3]!.addAll([
          ...combShadows.take(3),
          Gorev("[COMBAT] Hızlı İp Atlama / Footwork Drills (15 Dk)", false, "Fiziksel"),
          Gorev("[COMBAT] Burpee Sprawl Kondisyon (5 Set x 15)", false, "Fiziksel"),
          Gorev("[COMBAT] Ağır Kum Torbası Kombinasyonları (5 Raund x 3 Dk)", false, "Fiziksel"),
          Gorev("[COMBAT] Asılı Bacak Kaldırma (Hanging Leg Raise) (4 Set x 15)", false, "Fiziksel"),
          Gorev("[CARDIO] 20 Dk Interval Sprint Koşusu (Zone 4)", false, "Fiziksel"),
        ]);
        SystemMemory.haftalikPlan[5]!.addAll([
          ...combShadows.skip(3).take(2),
          Gorev("[COMBAT] Boksör Bacak Patlayıcılığı: Box Jumps / Squat Jump ($setRepLabel)", false, "Fiziksel"),
          Gorev("[COMBAT] Darbe Dayanıklılığı: Zercher / Goblet Squat ($setRepLabel)", false, "Fiziksel"),
          Gorev("[COMBAT] Bulgarian Split Squat ($setRepLabel)", false, "Fiziksel"),
          Gorev("[COMBAT] Kum Torbası / Pad Work Kombinasyonları (5 Raund x 3 Dk)", false, "Fiziksel"),
          Gorev("[COMBAT] Farmer's Walk & Bilek/Kavrama Gücü (4 Set)", false, "Fiziksel"),
          Gorev("[COMBAT] Karın & Hollow Body Plank Dayanıklılığı (4 Set)", false, "Fiziksel"),
          Gorev("[CARDIO] 20 Dk Dövüş Kondisyonu & Burpee Sprawl MetCon", false, "Fiziksel"),
        ]);
      } else if (idmanGunu == 4) {
        SystemMemory.haftalikPlan[1]!.addAll([
          Gorev("[COMBAT] Güç & İtiş: Patlayıcı Şınav & DB Punch Press ($setRepLabel)", false, "Fiziksel"),
          Gorev("[COMBAT] Barfiks / Çekiş & Face Pull ($setRepLabel)", false, "Fiziksel"),
          Gorev("[COMBAT] Incline Dumbbell Press ($setRepLabel)", false, "Fiziksel"),
          Gorev("[COMBAT] Rotasyonel Core & Russian Twist", false, "Fiziksel"),
          Gorev("[CARDIO] 20 Dk İp Atlama & Footwork Drills", false, "Fiziksel"),
        ]);
        SystemMemory.haftalikPlan[2]!.addAll([
          Gorev("[COMBAT] Dövüş Kondisyonu: Gölge Boksu (6 Raund x 3 Dk)", false, "Fiziksel"),
          Gorev("[COMBAT] Hızlı İp Atlama & Ayak Çalışması (20 Dk)", false, "Fiziksel"),
          Gorev("[COMBAT] Burpee Sprawl & Sıçrama (5 Set x 15)", false, "Fiziksel"),
          Gorev("[COMBAT] Asılı Bacak Kaldırma (4 Set x 15)", false, "Fiziksel"),
          Gorev("[CARDIO] 20 Dk Zone 2 Efor Koşusu", false, "Fiziksel"),
        ]);
        SystemMemory.haftalikPlan[4]!.addAll([
          Gorev("[COMBAT] Alt Gövde & Patlayıcılık: Box Jump & Split Squat ($setRepLabel)", false, "Fiziksel"),
          Gorev("[COMBAT] Zercher Squat / Goblet Squat ($setRepLabel)", false, "Fiziksel"),
          Gorev("[COMBAT] Romanian Deadlift / Hip Thrust ($setRepLabel)", false, "Fiziksel"),
          Gorev("[COMBAT] Boyun Köprüsü / Direnç Egzersizi & Plank", false, "Fiziksel"),
          Gorev("[CARDIO] 20 Dk İnterval Kürek / Bisiklet Sprint", false, "Fiziksel"),
        ]);
        SystemMemory.haftalikPlan[5]!.addAll([
          Gorev("[COMBAT] Ağır Kum Torbası Kombinasyonları (6 Raund x 3 Dk)", false, "Fiziksel"),
          Gorev("[COMBAT] Slip Bag / Head Movement & Reaksiyon Hızı", false, "Fiziksel"),
          Gorev("[COMBAT] Farmer's Walk & Tutuş Dayanıklılığı", false, "Fiziksel"),
          Gorev("[COMBAT] Rotasyonel Landmine Core (4 Set)", false, "Fiziksel"),
          Gorev("[CARDIO] 20 Dk MetCon Yüksek Yoğunluklu Kardiyo", false, "Fiziksel"),
        ]);
      } else {
        SystemMemory.haftalikPlan[1]!.addAll([
          Gorev("[COMBAT] Dövüş İtiş Gücü: Plyo Push-up & DB Shoulder Press ($setRepLabel)", false, "Fiziksel"),
          Gorev("[COMBAT] Çekiş: Ağırlıklı/Strict Barfiks ($setRepLabel)", false, "Fiziksel"),
          Gorev("[COMBAT] Dumbbell Floor Press ($setRepLabel)", false, "Fiziksel"),
          Gorev("[COMBAT] Karın & Boyun Güçlendirme", false, "Fiziksel"),
          Gorev("[CARDIO] 20 Dk Hızlı İp Atlama & Gölge Boksu", false, "Fiziksel"),
        ]);
        SystemMemory.haftalikPlan[2]!.addAll([
          Gorev("[COMBAT] Bacak Gücü: Bulgarian Split Squat & Zercher Squat ($setRepLabel)", false, "Fiziksel"),
          Gorev("[COMBAT] Patlayıcı Sıçrama & Box Jumps (5 Set x 10)", false, "Fiziksel"),
          Gorev("[COMBAT] Glute Ham Developer / Romanian Deadlift ($setRepLabel)", false, "Fiziksel"),
          Gorev("[COMBAT] Farmer's Walk Ağır Taşıma (4 Set)", false, "Fiziksel"),
          Gorev("[CARDIO] 20 Dk HIIT İnterval Koşu", false, "Fiziksel"),
        ]);
        SystemMemory.haftalikPlan[3]!.addAll([
          ...combShadows.take(4),
          Gorev("[COMBAT] Kum Torbası Hız & Kombinasyon Çalışması (5 Raund x 3 Dk)", false, "Fiziksel"),
          Gorev("[COMBAT] Core & Rotasyonel Med Ball Slams", false, "Fiziksel"),
          Gorev("[CARDIO] 25 Dk Düşük Nabız Zone 2 Yenilenme Koşusu", false, "Fiziksel"),
        ]);
        SystemMemory.haftalikPlan[5]!.addAll([
          Gorev("[COMBAT] Fonksiyonel Dövüş Zindeliği: Barbell Clean / Dumbbell Snatch ($setRepLabel)", false, "Fiziksel"),
          Gorev("[COMBAT] Çekiş & Sırt: Kroc Rows ($setRepLabel)", false, "Fiziksel"),
          Gorev("[COMBAT] Dips & Triceps Güçlendirici ($setRepLabel)", false, "Fiziksel"),
          Gorev("[COMBAT] Asılı Bacak Kaldırma (Hanging Leg Raise) (4 Set x 15)", false, "Fiziksel"),
          Gorev("[CARDIO] 20 Dk Burpee Sprawl & İp MetCon", false, "Fiziksel"),
        ]);
        SystemMemory.haftalikPlan[6]!.addAll([
          ...combShadows.skip(2).take(3),
          Gorev("[COMBAT] Yoğun Kum Torbası Güç Raundları (5 Raund x 3 Dk)", false, "Fiziksel"),
          Gorev("[COMBAT] Boksör Ayak Çalışması & Reaksiyon Topu (20 Dk)", false, "Fiziksel"),
          Gorev("[COMBAT] Boyun & Core İzometrik Dayanıklılık", false, "Fiziksel"),
          Gorev("[CARDIO] 20 Dk Zone 4 İnterval Kondisyon Koşusu", false, "Fiziksel"),
        ]);
      }
    } else if (ekipman.toLowerCase() == 'salon') {
      String squatVar = dizHassas ? "Leg Press / Box Squat" : "Barbell Squat";
      String pressVar = omuzHassas ? "Incline DB Press (Neutral Grip)" : "Barbell Bench Press";
      String deadliftVar = belHassas ? "Chest Supported T-Bar Row" : "Barbell Deadlift";

      if (idmanGunu <= 3) {
        SystemMemory.haftalikPlan[1]!.addAll([
          Gorev("[PHY] $pressVar ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Incline Dumbbell Press ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] $squatVar ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Lat Pulldown / Cable Row ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Dips / Triceps Pushdown ($setRepLabel)", false, "Fiziksel"),
          Gorev("[CORE / ABS] Hanging Leg Raise (4 Set x 15)", false, "Fiziksel"),
          Gorev("[CARDIO] 20 Dk Eğimli Koşu Bandı Zone 2", false, "Fiziksel"),
        ]);
        SystemMemory.haftalikPlan[3]!.addAll([
          Gorev("[PHY] Overhead Shoulder Press ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Lateral Raise (Dumbbell) (5 Set x 12)", false, "Fiziksel"),
          Gorev("[PHY] $deadliftVar ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Leg Curl / Extension ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Barbell Biceps Curl ($setRepLabel)", false, "Fiziksel"),
          Gorev("[CORE / ABS] Cable Crunch & Plank (4 Set)", false, "Fiziksel"),
          Gorev("[CARDIO] 25 Dk Kürek / Bisiklet Zone 2 Kardiyo", false, "Fiziksel"),
        ]);
        SystemMemory.haftalikPlan[5]!.addAll([
          Gorev("[PHY] Incline Dumbbell Press ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Barbell Bench Press / Dips ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Romanian Deadlift ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Barbell / Dumbbell Curl ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Triceps Cable Pushdown ($setRepLabel)", false, "Fiziksel"),
          Gorev("[CORE / ABS] Plank & Cable Crunch (4 Set)", false, "Fiziksel"),
          Gorev("[CARDIO] 20 Dk Yüksek Yoğunluklu İp Atlama HIIT", false, "Fiziksel"),
        ]);
      } else if (idmanGunu == 4) {
        SystemMemory.haftalikPlan[1]!.addAll([
          Gorev("[PHY] Upper A: $pressVar ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Upper A: Lat Pulldown ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Upper A: DB Lateral Raise ($setRepLabel)", false, "Fiziksel"),
        ]);
        SystemMemory.haftalikPlan[2]!.addAll([
          Gorev("[PHY] Lower A: $squatVar ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Lower A: Romanian Deadlift ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Lower A: Calves & Core", false, "Fiziksel"),
        ]);
        SystemMemory.haftalikPlan[4]!.addAll([
          Gorev("[PHY] Upper B: Incline DB Press ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Upper B: Cable Row ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Upper B: Overhead Press ($setRepLabel)", false, "Fiziksel"),
        ]);
        SystemMemory.haftalikPlan[5]!.addAll([
          Gorev("[PHY] Lower B: $deadliftVar ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Lower B: Leg Press ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Lower B: Hamstring Curl & Planks", false, "Fiziksel"),
        ]);
      } else {
        SystemMemory.haftalikPlan[1]!.addAll([
          Gorev("[PHY] Push: $pressVar ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Push: Incline DB Press ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Push: Lateral Raise ($setRepLabel)", false, "Fiziksel"),
        ]);
        SystemMemory.haftalikPlan[2]!.addAll([
          Gorev("[PHY] Pull: $deadliftVar ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Pull: Lat Pulldown ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Pull: Face Pull & Biceps ($setRepLabel)", false, "Fiziksel"),
        ]);
        SystemMemory.haftalikPlan[3]!.addAll([
          Gorev("[PHY] Legs: $squatVar ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Legs: Romanian Deadlift ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Legs: Calves & Core", false, "Fiziksel"),
        ]);
        SystemMemory.haftalikPlan[4]!.addAll([
          Gorev("[PHY] Push 2: Overhead Press ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Push 2: Triceps Pushdown ($setRepLabel)", false, "Fiziksel"),
        ]);
        SystemMemory.haftalikPlan[5]!.addAll([
          Gorev("[PHY] Pull 2: Barbell/DB Row ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Pull 2: Hammer Curls ($setRepLabel)", false, "Fiziksel"),
        ]);
        if (idmanGunu >= 6) {
          SystemMemory.haftalikPlan[6]!.addAll([
            Gorev("[PHY] Legs 2: Bulgarian Split Squat ($setRepLabel)", false, "Fiziksel"),
            Gorev("[PHY] Legs 2: Leg Extension & Core ($setRepLabel)", false, "Fiziksel"),
          ]);
        }
      }
    } else if (ekipman == 'Ev-Dambil') {
      String squatVar = dizHassas ? "Dumbbell Box Squat" : "Goblet Squat";
      String pressVar = omuzHassas ? "Dumbbell Floor Press (Neutral Grip)" : "Dumbbell Floor/Bench Press";
      String deadliftVar = belHassas ? "DB Romanian Deadlift (Slow Tempo)" : "Dumbbell Romanian Deadlift";

      SystemMemory.haftalikPlan[1]!.addAll([
        Gorev("[PHY] $pressVar ($setRepLabel)", false, "Fiziksel"),
        Gorev("[PHY] $squatVar ($setRepLabel)", false, "Fiziksel"),
        Gorev("[PHY] Two-Arm Dumbbell Row ($setRepLabel)", false, "Fiziksel"),
        Gorev("[PHY] Core: Floor Crunch & Hollow Body", false, "Fiziksel"),
      ]);
      SystemMemory.haftalikPlan[3]!.addAll([
        Gorev("[PHY] Seated DB Shoulder Press ($setRepLabel)", false, "Fiziksel"),
        Gorev("[PHY] $deadliftVar ($setRepLabel)", false, "Fiziksel"),
        Gorev("[PHY] Dumbbell Bicep Hammer Curl ($setRepLabel)", false, "Fiziksel"),
        Gorev("[PHY] Overhead DB Triceps Extension ($setRepLabel)", false, "Fiziksel"),
      ]);
      SystemMemory.haftalikPlan[5]!.addAll([
        Gorev("[PHY] Bulgarian Split Squat (Dumbbell) ($setRepLabel)", false, "Fiziksel"),
        Gorev("[PHY] Dumbbell Push-ups / Floor Fly ($setRepLabel)", false, "Fiziksel"),
        Gorev("[PHY] Single Arm DB Row ($setRepLabel)", false, "Fiziksel"),
        Gorev("[PHY] Lateral Raise & Core Plank", false, "Fiziksel"),
      ]);
    } else {
      // Vücut Ağırlığı (Calisthenics)
      String pushVar = omuzHassas ? "Push-ups (Elevated Hands)" : (rUpper.startsWith('S') || rUpper.startsWith('A') ? "Archer / Decline Push-ups" : "Standard Push-ups");
      String squatVar = dizHassas ? "Bodyweight Box Squat / Wall Sit" : (rUpper.startsWith('S') || rUpper.startsWith('A') ? "Pistol Squats / Jump Squats" : "Air Squats & Lunges");
      String pullVar = (rUpper.startsWith('S') || rUpper.startsWith('A')) ? "Strict Pull-ups / Muscle-up Prep" : "Inverted Rows / Band Pulls";

      SystemMemory.haftalikPlan[1]!.addAll([
        Gorev("[PHY] Calisthenics: $pushVar ($setRepLabel)", false, "Fiziksel"),
        Gorev("[PHY] Calisthenics: $squatVar ($setRepLabel)", false, "Fiziksel"),
        Gorev("[PHY] Calisthenics: $pullVar ($setRepLabel)", false, "Fiziksel"),
        Gorev("[PHY] Calisthenics: Hollow Body Hold (3 x 45s)", false, "Fiziksel"),
      ]);
      SystemMemory.haftalikPlan[3]!.addAll([
        Gorev("[PHY] Calisthenics: Pike Push-ups ($setRepLabel)", false, "Fiziksel"),
        Gorev("[PHY] Calisthenics: Walking Lunges ($setRepLabel)", false, "Fiziksel"),
        Gorev("[PHY] Calisthenics: Chin-ups / Inverted Row ($setRepLabel)", false, "Fiziksel"),
        Gorev("[PHY] Cardio: Shadow Boxing / Burpees (15 Min)", false, "Fiziksel"),
      ]);
      SystemMemory.haftalikPlan[5]!.addAll([
        Gorev("[PHY] Calisthenics: Diamond / Wide Push-ups ($setRepLabel)", false, "Fiziksel"),
        Gorev("[PHY] Calisthenics: Single Leg Glute Bridges ($setRepLabel)", false, "Fiziksel"),
        Gorev("[PHY] Calisthenics: Hanging / Lying Leg Raises", false, "Fiziksel"),
        Gorev("[PHY] Calisthenics: Plank to Push-up Finisher", false, "Fiziksel"),
      ]);
    }

    // --- ÖNCELİKLİ ODAK & YAĞ YAKIM PROTOKOLÜ (TARGET FOCUS INJECTION) ---
    if (odaklar.isNotEmpty) {
      for (int gun = 1; gun <= 7; gun++) {
        if (SystemMemory.haftalikPlan[gun]!.isNotEmpty) {
          if (odaklar.any((o) => o.contains('Karın') || o.contains('Göbek') || o.contains('Abs'))) {
            SystemMemory.haftalikPlan[gun]!.add(
              Gorev("[FOCUS-CORE] Karın & Yağ Yakımı: Asılı Bacak Kaldırma & Plank Finisher", false, "Fiziksel"),
            );
          }
          if (odaklar.any((o) => o.contains('Göğüs') || o.contains('Chest'))) {
            SystemMemory.haftalikPlan[gun]!.add(
              Gorev("[FOCUS-CHEST] Göğüs Sıkılaştırma: Deficit Push-up / DB Flye Finisher", false, "Fiziksel"),
            );
          }
          if (odaklar.any((o) => o.contains('Kol') || o.contains('Arm'))) {
            SystemMemory.haftalikPlan[gun]!.add(
              Gorev("[FOCUS-ARMS] Kol Gelişimi: Biceps Curl & Triceps Pushdown", false, "Fiziksel"),
            );
          }
          if (odaklar.any((o) => o.contains('Omuz') || o.contains('Shoulder'))) {
            SystemMemory.haftalikPlan[gun]!.add(
              Gorev("[FOCUS-SHOULDER] Omuz Genişletme: Lateral Raise & Face Pull", false, "Fiziksel"),
            );
          }
          if (odaklar.any((o) => o.contains('Bacak') || o.contains('Kalça') || o.contains('Leg'))) {
            SystemMemory.haftalikPlan[gun]!.add(
              Gorev("[FOCUS-LEGS] Bacak & Kalça Sıkılaştırma: Walking Lunges / Split Squat", false, "Fiziksel"),
            );
          }
          if (odaklar.any((o) => o.contains('Sırt') || o.contains('Back'))) {
            SystemMemory.haftalikPlan[gun]!.add(
              Gorev("[FOCUS-BACK] Sırt & V-Taper: Inverted Row / Pulldown Finisher", false, "Fiziksel"),
            );
          }
        }
      }
    }

    // --- DİNLENME & ZİHİNSEL GELİŞİM PROTOKOLÜ (REST DAYS & MENTAL MASTERY) ---
    for (int gun = 1; gun <= 7; gun++) {
      if (SystemMemory.haftalikPlan[gun]!.isEmpty) {
        SystemMemory.haftalikPlan[gun]!.addAll([
          Gorev("[MIND] 20 Dk Taktiksel Kitap / Makale Okuma & Zihinsel Odaklanma", false, "Zihinsel"),
          Gorev("[PERCEPTION] 10 Dk Derin Meditasyon & Nefes Protokolü (Box Breathing)", false, "Zihinsel"),
          Gorev("[REST] Kas Toparlanması & Mobilite / Esneme Seansı", false, "Fiziksel"),
        ]);
      }
    }

    SystemMemory.normalHaftalikPlan.clear();
    SystemMemory.haftalikPlan.forEach((key, value) {
      SystemMemory.normalHaftalikPlan[key] = value.map((e) => Gorev(e.ad, false, e.tip)).toList();
    });
  }

  static Future<bool> aiPrograminiUygula({String? ozelTalep, int? idmanGunu}) async {
    final int gunSayisi = idmanGunu ?? 3;
    if (SystemMemory.geminiApiKey.trim().isEmpty) {
      baslangicPrograminiAta(
        ekipman: SystemMemory.ekipmanTuru,
        rank: SystemMemory.hunterRank,
        idmanGunu: gunSayisi,
        hedef: SystemMemory.aktifHedef,
        eklemKisitlari: SystemMemory.eklemKisiti,
        hedefOdakBolgeleri: SystemMemory.odakBolgeleri,
      );
      SystemMemory.kaydet();
      return false;
    }

    try {
      final aiPlan = await GeminiService.haftalikProgramUret(
        kilo: SystemMemory.kilo > 0 ? SystemMemory.kilo : 70.0,
        boy: SystemMemory.boy > 0 ? SystemMemory.boy : 175.0,
        rank: SystemMemory.hunterRank,
        hedef: SystemMemory.aktifHedef,
        zorluk: SystemMemory.aktifZorluk,
        ekipman: SystemMemory.ekipmanTuru,
        idmanGunu: gunSayisi,
        dovuscuMu: SystemMemory.dovusSporuYapiyorMu,
        dovusBranslari: SystemMemory.dovusBranslari.isNotEmpty ? SystemMemory.dovusBranslari : [SystemMemory.dovusBransi],
        eklemKisitlari: SystemMemory.eklemKisiti,
        odakBolgeleri: SystemMemory.odakBolgeleri,
        maxBench: SystemMemory.maxBench > 0 ? SystemMemory.maxBench : null,
        maxSquat: SystemMemory.maxSquat > 0 ? SystemMemory.maxSquat : null,
        deadlift: SystemMemory.maxDeadlift > 0 ? SystemMemory.maxDeadlift : null,
        ozelTalep: ozelTalep,
      );

      if (aiPlan != null && aiPlan.values.any((list) => list.isNotEmpty)) {
        SystemMemory.haftalikPlan.clear();
        for (int i = 1; i <= 7; i++) {
          SystemMemory.haftalikPlan[i] = aiPlan[i] ?? [];
        }
        SystemMemory.normalHaftalikPlan.clear();
        SystemMemory.haftalikPlan.forEach((key, value) {
          SystemMemory.normalHaftalikPlan[key] = value.map((e) => Gorev(e.ad, false, e.tip)).toList();
        });
        SystemMemory.kaydet();
        return true;
      }
    } catch (e) {
      debugPrint("AI program generation error: $e");
    }

    baslangicPrograminiAta(
      ekipman: SystemMemory.ekipmanTuru,
      rank: SystemMemory.hunterRank,
      idmanGunu: gunSayisi,
      hedef: SystemMemory.aktifHedef,
      eklemKisitlari: SystemMemory.eklemKisiti,
      hedefOdakBolgeleri: SystemMemory.odakBolgeleri,
    );
    SystemMemory.kaydet();
    return false;
  }

  static Future<List<Gorev>> aiEkIdmanBoosterUret({int? gun, bool sadeceBunuYap = false}) async {
    final hedefGun = gun ?? DateTime.now().weekday;
    List<Gorev>? boosterGorevler;

    if (SystemMemory.geminiApiKey.trim().isNotEmpty) {
      try {
        boosterGorevler = await GeminiService.aiEkIdmanUret(
          rank: SystemMemory.hunterRank,
          dovuscuMu: SystemMemory.dovusSporuYapiyorMu,
          dovusBranslari: SystemMemory.dovusBranslari.isNotEmpty ? SystemMemory.dovusBranslari : [SystemMemory.dovusBransi],
          odakBolgeleri: SystemMemory.odakBolgeleri,
          eklemKisitlari: SystemMemory.eklemKisiti,
        );
      } catch (e) {
        debugPrint("AI booster error: $e");
      }
    }

    if (boosterGorevler == null || boosterGorevler.isEmpty) {
      boosterGorevler = [];
      if (SystemMemory.dovusSporuYapiyorMu) {
        final shadows = dovusGolgeBoksuKombinasyonlari(brans: SystemMemory.dovusBransi);
        boosterGorevler.addAll([
          Gorev("[COMBAT] ${SystemMemory.dovusBransi}: Patlayıcı Şınav & Yumruk Torku (4 Set x 12)", false, "Fiziksel"),
          ...shadows.take(2),
          Gorev("[COMBAT] Burpee Sprawl & Darbe Direnci Core (5 Set x 15)", false, "Fiziksel"),
          Gorev("[CARDIO] 20 Dk Yüksek Yoğunluklu İp Atlama HIIT & Ayak Çevikliği", false, "Fiziksel"),
        ]);
      } else if (SystemMemory.odakBolgeleri.any((o) => o.contains('Karın') || o.contains('Göbek'))) {
        boosterGorevler.addAll([
          Gorev("[FOCUS-CORE] Asılı Bacak Kaldırma (Hanging Leg Raise) (4 Set x 15)", false, "Fiziksel"),
          Gorev("[FOCUS-CORE] Plank to Push-up & Hollow Body (4 Set x 60sn)", false, "Fiziksel"),
          Gorev("[PHY] Dumbbell Farmers Walk (Gövde Sıkılığı) (4 Set)", false, "Fiziksel"),
          Gorev("[CORE / ABS] Cable / Floor Crunch (4 Set x 20)", false, "Fiziksel"),
          Gorev("[CARDIO] 25 Dk Eğimli Yürüyüş Bandı Zone 2 Yağ Yakımı", false, "Fiziksel"),
        ]);
      } else {
        boosterGorevler.addAll([
          Gorev("[PHY] Dips / Dumbbell Push-ups (4 Set x 12)", false, "Fiziksel"),
          Gorev("[PHY] Dumbbell Lateral Raise & Face Pull (4 Set x 15)", false, "Fiziksel"),
          Gorev("[CORE / ABS] Cable / Floor Crunch (4 Set x 15)", false, "Fiziksel"),
          Gorev("[PHY] Dumbbell Biceps & Triceps Finisher (4 Set x 12)", false, "Fiziksel"),
          Gorev("[CARDIO] 20 Dk Eğimli Koşu Bandı & Sprint Kardiyosu", false, "Fiziksel"),
        ]);
      }
    }

    SystemMemory.haftalikPlan.putIfAbsent(hedefGun, () => []);
    if (sadeceBunuYap) {
      SystemMemory.haftalikPlan[hedefGun]!.clear();
    }
    SystemMemory.haftalikPlan[hedefGun]!.addAll(boosterGorevler);
    SystemMemory.kaydet();
    return boosterGorevler;
  }
}
