import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../system_memory.dart';
import '../../models/task_model.dart';
import '../../models/inventory_item_model.dart';
import '../../core/audio_system.dart';
import '../../core/translation_manager.dart';

class MemoryCombatRanks {
  static void bossGuncelle({int? gunIndex}) {
    int bugun = gunIndex ?? DateTime.now().weekday;
    if (bugun == 7) { 
      if (SystemMemory.bossMaxHP == 0 || SystemMemory.bossMaxHP < SystemMemory.level.value * 100) {
        SystemMemory.bossMaxHP = SystemMemory.level.value * 100;
        SystemMemory.bossTuru = SystemMemory.level.value % 2 == 0 ? "Zihinsel" : "Fiziksel";
        SystemMemory.bossIsim = SystemMemory.bossTuru == "Fiziksel" ? "Steel-Fanged Wolf (Beast)" : "Ancient Lich (Undead)";
      }

      int hasar = 0;
      for (int gun = 1; gun <= 7; gun++) {
        if (SystemMemory.haftalikPlan.containsKey(gun)) {
          for (var g in SystemMemory.haftalikPlan[gun]!) {
            if (g.yapildiMi) {
              hasar += (g.tip == SystemMemory.bossTuru) ? (SystemMemory.level.value * 15) : (SystemMemory.level.value * 5);
            }
          }
        }
      }
      if (SystemMemory.bugunAlinanKalori > 0 && SystemMemory.bugunAlinanKalori <= SystemMemory.gunlukHedefKalori) {
        hasar += (SystemMemory.level.value * 30);
      }
      
      int kalan = SystemMemory.bossMaxHP - hasar;
      SystemMemory.bossHP.value = kalan < 0 ? 0 : kalan;
    } else {
      SystemMemory.bossMaxHP = 0;
      SystemMemory.bossHP.value = 0;
    }
  }

  static bool basarimKademeGuncelle(String basarimAnahtari, int yeniKademe, String basarimAdi, String hedefMetin) {
    int eskiKademe = SystemMemory.basarimKademeleri[basarimAnahtari] ?? 0;
    if (yeniKademe > eskiKademe) {
      SystemMemory.basarimKademeleri[basarimAnahtari] = yeniKademe;
      final tr = TranslationManager.isTurkish;
      SystemMemory.yeniBasarimBildirimi.value = tr
          ? "[BAŞARIM YÜKSELDİ]\n$basarimAdi (Kademe $yeniKademe)\nAçılan Hedef: $hedefMetin"
          : "[ACHIEVEMENT ASCENDED]\n$basarimAdi (Tier $yeniKademe)\nTarget Unlocked: $hedefMetin";
      AudioSystem.playSuccess();
      SystemMemory.kaydet();
      return true;
    }
    return false;
  }

  static String hesaplaHunterRank({
    required double bench,
    required double squat,
    required double deadlift,
    double? kilo,
  }) {
    final double k = (kilo != null && kilo > 0) ? kilo : (SystemMemory.kilo > 0 ? SystemMemory.kilo : 70.0);
    final double totalLift = bench + squat + deadlift;
    final double ratio = totalLift / k;

    if (ratio >= 5.5) return "S-Rank (Monarch)";
    if (ratio >= 4.5) return "A-Rank (National)";
    if (ratio >= 3.5) return "B-Rank (Elite)";
    if (ratio >= 2.5) return "C-Rank (Knight)";
    if (ratio >= 1.5) return "D-Rank (Hunter)";
    return "E-Rank (Rookie)";
  }

  static String hesaplaDovusRank({
    required int patlayiciSinav,
    required int burpeeKondisyon,
    required int plankSaniye,
    required int barfiks,
    double? bench,
    double? squat,
    double? deadlift,
    double? kilo,
  }) {
    double score = (patlayiciSinav * 2.0) +
        (burpeeKondisyon * 3.0) +
        ((plankSaniye / 10).clamp(0, 18) * 2.0) +
        (barfiks * 4.0);

    final double b = bench ?? 0.0;
    final double s = squat ?? 0.0;
    final double d = deadlift ?? 0.0;
    final double k = (kilo != null && kilo > 0) ? kilo : 70.0;
    final double big3 = b + s + d;
    if (big3 > 0 && k > 0) {
      final double ratio = big3 / k;
      score += (ratio * 6.0).clamp(0.0, 25.0);
    }

    if (score >= 260) return "S-Rank (Monarch)";
    if (score >= 200) return "A-Rank (National)";
    if (score >= 150) return "B-Rank (Elite)";
    if (score >= 100) return "C-Rank (Knight)";
    if (score >= 60) return "D-Rank (Hunter)";
    return "E-Rank (Rookie)";
  }

  static void dovusTestiKaydet({
    required int patlayiciSinav,
    required int burpeeKondisyon,
    required int plankSaniye,
    required int barfiks,
    required String rank,
    String? brans,
    List<String>? branslar,
    int? idmanGunu,
    double? bench,
    double? squat,
    double? deadlift,
  }) {
    final bool isFirstAwakening = SystemMemory.hunterRank == "Unranked";
    SystemMemory.dovusSporuYapiyorMu = true;
    if (branslar != null && branslar.isNotEmpty) {
      SystemMemory.dovusBranslari = List<String>.from(branslar);
      SystemMemory.dovusBransi = SystemMemory.dovusBranslari.join(', ');
    } else if (brans != null && brans.isNotEmpty) {
      SystemMemory.dovusBransi = brans;
      SystemMemory.dovusBranslari = [brans];
    }
    SystemMemory.maxPatlayiciSinav = patlayiciSinav;
    SystemMemory.maxBurpeeKondisyon = burpeeKondisyon;
    SystemMemory.maxPlankSaniye = plankSaniye;
    SystemMemory.maxBarfiks = barfiks;
    if (bench != null && bench > 0) SystemMemory.maxBench = bench;
    if (squat != null && squat > 0) SystemMemory.maxSquat = squat;
    if (deadlift != null && deadlift > 0) SystemMemory.maxDeadlift = deadlift;
    SystemMemory.hunterRank = rank;
    SystemMemory.sonTestTarihi = DateTime.now().toIso8601String();
    SystemMemory.sonTesttenBeriIdmanSayisi = 0;

    if (isFirstAwakening) {
      SystemMemory.exp.value += 100;
      SystemMemory.ap.value += 3;
    }

    SystemMemory.baslangicPrograminiAta(
      ekipman: SystemMemory.ekipmanTuru,
      rank: SystemMemory.hunterRank,
      idmanGunu: idmanGunu ?? 3,
      hedef: SystemMemory.aktifHedef,
      eklemKisitlari: SystemMemory.eklemKisiti,
    );

    SystemMemory.kaydet();
  }

  static void awakeningTestKaydet({
    required double bench,
    required double squat,
    required double deadlift,
    required String rank,
    int? idmanGunu,
  }) {
    final bool isFirstAwakening = SystemMemory.hunterRank == "Unranked";
    SystemMemory.maxBench = bench;
    SystemMemory.maxSquat = squat;
    SystemMemory.maxDeadlift = deadlift;
    SystemMemory.hunterRank = rank;
    SystemMemory.sonTestTarihi = DateTime.now().toIso8601String();
    SystemMemory.sonTesttenBeriIdmanSayisi = 0;

    if (isFirstAwakening) {
      SystemMemory.exp.value += 100;
      SystemMemory.ap.value += 3;
    }

    SystemMemory.baslangicPrograminiAta(
      ekipman: SystemMemory.ekipmanTuru,
      rank: SystemMemory.hunterRank,
      idmanGunu: idmanGunu ?? 3,
      hedef: SystemMemory.aktifHedef,
      eklemKisitlari: SystemMemory.eklemKisiti,
    );

    SystemMemory.kaydet();
  }

  static String expKazan(int miktar) {
    SystemMemory.exp.value += miktar;
    String levelUpMesaji = "";
    final tr = TranslationManager.isTurkish;
    while (SystemMemory.exp.value >= SystemMemory.maxExp.value) {
      SystemMemory.exp.value -= SystemMemory.maxExp.value;
      SystemMemory.level.value++;
      SystemMemory.maxExp.value = (SystemMemory.maxExp.value * 1.5).round();
      SystemMemory.ap.value += 3; 
      SystemMemory.hp.value = SystemMemory.maxHp;
      SystemMemory.mp.value = SystemMemory.maxMp;
      SystemMemory.fatigue.value = 0;
      levelUpMesaji += tr
          ? "\n🌟 SEVİYE ATLADIN! Seviye ${SystemMemory.level.value} oldun! (+3 AP)\n[BİLGİ] Durum İyileştirmesi uygulandı."
          : "\n🌟 LEVEL UP! You reached Level ${SystemMemory.level.value}! (+3 AP)\n[INFO] Status Recovery applied.";
      AudioSystem.playLevelUp();
    }
    SystemMemory.kaydet();
    return levelUpMesaji;
  }

  static void statuYukselt(String statAdi) {
    if (SystemMemory.ap.value > 0) {
      SystemMemory.ap.value--;
      if (statAdi == 'STR') {
        SystemMemory.str.value++;
      } else if (statAdi == 'AGI') {
        SystemMemory.agi.value++;
      } else if (statAdi == 'VIT') {
        SystemMemory.vit.value++;
        SystemMemory.maxHp += 10;
        SystemMemory.hp.value += 10;
      } else if (statAdi == 'INT') {
        SystemMemory.intStat.value++;
        SystemMemory.maxMp += 2;
        SystemMemory.mp.value += 2;
      } else if (statAdi == 'PER') {
        SystemMemory.per.value++;
      }
      SystemMemory.kaydet(); 
    } 
  }

  static Map<String, int> otomatikStatDagit({int? miktar}) {
    int dagitilacak = miktar ?? SystemMemory.ap.value;
    if (dagitilacak <= 0) return {'STR': 0, 'AGI': 0, 'VIT': 0, 'INT': 0, 'PER': 0};
    if (dagitilacak > SystemMemory.ap.value) dagitilacak = SystemMemory.ap.value;

    Map<String, double> agirliklar;
    final hedef = SystemMemory.aktifHedef.toLowerCase();
    final brans = SystemMemory.dovusBransi.toLowerCase();

    if (SystemMemory.dovusSporuYapiyorMu) {
      if (brans.contains('boks') || brans.contains('kick') || brans.contains('muay')) {
        agirliklar = {'STR': 0.30, 'AGI': 0.35, 'VIT': 0.20, 'PER': 0.10, 'INT': 0.05};
      } else if (brans.contains('gures') || brans.contains('güreş') || brans.contains('bjj') || brans.contains('judo')) {
        agirliklar = {'STR': 0.35, 'VIT': 0.30, 'AGI': 0.20, 'PER': 0.10, 'INT': 0.05};
      } else {
        agirliklar = {'STR': 0.30, 'AGI': 0.25, 'VIT': 0.25, 'PER': 0.10, 'INT': 0.10};
      }
    } else if (hedef.contains('kilo al') || hedef.contains('kas')) {
      agirliklar = {'STR': 0.45, 'VIT': 0.30, 'AGI': 0.10, 'PER': 0.05, 'INT': 0.10};
    } else if (hedef.contains('kilo ver') || hedef.contains('yağ')) {
      agirliklar = {'AGI': 0.40, 'VIT': 0.25, 'STR': 0.20, 'PER': 0.10, 'INT': 0.05};
    } else {
      agirliklar = {'STR': 0.25, 'AGI': 0.25, 'VIT': 0.25, 'PER': 0.15, 'INT': 0.10};
    }

    Map<String, int> dagitilanlar = {'STR': 0, 'AGI': 0, 'VIT': 0, 'INT': 0, 'PER': 0};
    Map<String, double> kusuratlar = {};
    int harcanan = 0;

    agirliklar.forEach((stat, oran) {
      double tamPay = dagitilacak * oran;
      int tabanPay = tamPay.floor();
      dagitilanlar[stat] = tabanPay;
      kusuratlar[stat] = tamPay - tabanPay;
      harcanan += tabanPay;
    });

    int kalan = dagitilacak - harcanan;
    if (kalan > 0) {
      var siraliKusuratlar = kusuratlar.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      for (int i = 0; i < kalan; i++) {
        String secilenStat = siraliKusuratlar[i % siraliKusuratlar.length].key;
        dagitilanlar[secilenStat] = dagitilanlar[secilenStat]! + 1;
      }
    }

    int gercekDagitilan = 0;
    dagitilanlar.forEach((stat, adet) {
      if (adet > 0) {
        if (stat == 'STR') {
          SystemMemory.str.value += adet;
        } else if (stat == 'AGI') {
          SystemMemory.agi.value += adet;
        } else if (stat == 'VIT') {
          SystemMemory.vit.value += adet;
          SystemMemory.maxHp += adet * 10;
          SystemMemory.hp.value += adet * 10;
        } else if (stat == 'INT') {
          SystemMemory.intStat.value += adet;
          SystemMemory.maxMp += adet * 2;
          SystemMemory.mp.value += adet * 2;
        } else if (stat == 'PER') {
          SystemMemory.per.value += adet;
        }
        gercekDagitilan += adet;
      }
    });

    SystemMemory.ap.value -= gercekDagitilan;
    if (SystemMemory.ap.value < 0) SystemMemory.ap.value = 0;
    SystemMemory.kaydet();
    return dagitilanlar;
  }

  static void acilSifa() {
    SystemMemory.hp.value = SystemMemory.maxHp;
    SystemMemory.kaydet();
  }
  
  static void tamMana() {
    SystemMemory.mp.value = SystemMemory.maxMp;
    SystemMemory.kaydet();
  }
  
  static void statuleriSifirla() {
    int geriVerilecekAP = (SystemMemory.str.value - 10) +
        (SystemMemory.agi.value - 10) +
        (SystemMemory.vit.value - 10) +
        (SystemMemory.intStat.value - 10) +
        (SystemMemory.per.value - 10);
    SystemMemory.ap.value += geriVerilecekAP;
    SystemMemory.str.value = 10;
    SystemMemory.agi.value = 10;
    SystemMemory.vit.value = 10;
    SystemMemory.intStat.value = 10;
    SystemMemory.per.value = 10;
    SystemMemory.maxHp = 100;
    SystemMemory.maxMp = 10;
    if (SystemMemory.hp.value > SystemMemory.maxHp) SystemMemory.hp.value = SystemMemory.maxHp;
    if (SystemMemory.mp.value > SystemMemory.maxMp) SystemMemory.mp.value = SystemMemory.maxMp;
    SystemMemory.kaydet();
  }

  static Future<void> sistemiSifirla() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    SystemMemory.kayitBulundu = false;
    SystemMemory.geminiApiKey = "";
    SystemMemory.redGateAktif = false;
    SystemMemory.golgeModuAktif = false;
    SystemMemory.haftalikPlan.clear();
    for (int i = 1; i <= 7; i++) {
      SystemMemory.haftalikPlan[i] = [];
    }
    SystemMemory.normalHaftalikPlan.clear();
    for (int i = 1; i <= 7; i++) {
      SystemMemory.normalHaftalikPlan[i] = [];
    }
    SystemMemory.overloadGecmisi.clear();
    SystemMemory.level.value = 1;
    SystemMemory.exp.value = 0;
    SystemMemory.hp.value = 100;
    SystemMemory.profilFotoByte = null;
  }

  static void kirmiziGecideGir(int secilenGun, [int? hedefKalori, String? secilenPlan]) {
    if (!SystemMemory.redGateAktif) {
      SystemMemory.normalGunlukHedefKalori = SystemMemory.gunlukHedefKalori;
      SystemMemory.normalHaftalikPlan.clear();
      SystemMemory.haftalikPlan.forEach((key, value) {
        SystemMemory.normalHaftalikPlan[key] = value.map((e) => Gorev(e.ad, false, e.tip)).toList();
      });

      if (secilenPlan != null) {
        SystemMemory.haftalikPlan.clear();
        for (int i = 1; i <= 7; i++) {
          SystemMemory.haftalikPlan[i] = [];
        }

        if (secilenPlan == "Full Body + Cardio") {
          for (int i = 1; i <= 7; i++) {
            SystemMemory.haftalikPlan[i]!.addAll([
              Gorev("[PHY] Upper Body (Chest/Back/Arms)", false, "Fiziksel"),
              Gorev("[PHY] Lower Body (Quads/Hams/Calves)", false, "Fiziksel"),
              Gorev("[PHY] Core & Abs", false, "Fiziksel"),
              Gorev("[PHY] Intense Cardio", false, "Fiziksel"),
            ]);
          }
        } else if (secilenPlan == "Push / Pull / Legs") {
          SystemMemory.haftalikPlan[1]!.addAll([Gorev("[PHY] Push (Chest/Shoulders/Triceps)", false, "Fiziksel"), Gorev("[PHY] Core", false, "Fiziksel")]);
          SystemMemory.haftalikPlan[4]!.addAll([Gorev("[PHY] Push (Chest/Shoulders/Triceps)", false, "Fiziksel"), Gorev("[PHY] Core", false, "Fiziksel")]);
          SystemMemory.haftalikPlan[2]!.addAll([Gorev("[PHY] Pull (Back/Biceps/Rear Delts)", false, "Fiziksel"), Gorev("[PHY] Light Cardio", false, "Fiziksel")]);
          SystemMemory.haftalikPlan[5]!.addAll([Gorev("[PHY] Pull (Back/Biceps/Rear Delts)", false, "Fiziksel"), Gorev("[PHY] Light Cardio", false, "Fiziksel")]);
          SystemMemory.haftalikPlan[3]!.addAll([Gorev("[PHY] Legs (Quads/Hamstrings/Calves)", false, "Fiziksel")]);
          SystemMemory.haftalikPlan[6]!.addAll([Gorev("[PHY] Legs (Quads/Hamstrings/Calves)", false, "Fiziksel")]);
          SystemMemory.haftalikPlan[7]!.addAll([Gorev("[PHY] Active Recovery & Stretch", false, "Fiziksel"), Gorev("[PHY] Heavy Cardio", false, "Fiziksel")]);
        } else if (secilenPlan == "Saitama Hell") {
          for (int i = 1; i <= 7; i++) {
            SystemMemory.haftalikPlan[i]!.addAll([
              Gorev("[PHY] 100 Push-ups", false, "Fiziksel"),
              Gorev("[PHY] 100 Sit-ups", false, "Fiziksel"),
              Gorev("[PHY] 100 Squats", false, "Fiziksel"),
              Gorev("[PHY] 10km Run", false, "Fiziksel"),
            ]);
          }
        }
      }

      SystemMemory.redGateAktif = true;
      SystemMemory.redGateKalanGun = secilenGun;
      SystemMemory.redGateToplamGun = secilenGun;
      if (hedefKalori != null && hedefKalori > 0) {
        SystemMemory.gunlukHedefKalori = hedefKalori;
      }
      SystemMemory.golgeModuAktif = false;
      SystemMemory.kaydet();
    }
  }

  static void kirmiziGeciteGir(int secilenGun, [int? hedefKalori, String? secilenPlan]) =>
      kirmiziGecideGir(secilenGun, hedefKalori, secilenPlan);

  static void kirmiziGecittenCik() {
    SystemMemory.redGateAktif = false;
    SystemMemory.redGateKalanGun = 0;
    SystemMemory.redGateToplamGun = 0;
    if (SystemMemory.normalGunlukHedefKalori > 0) {
      SystemMemory.gunlukHedefKalori = SystemMemory.normalGunlukHedefKalori;
      SystemMemory.normalGunlukHedefKalori = 0;
    }
    if (SystemMemory.normalHaftalikPlan.isNotEmpty) {
      SystemMemory.haftalikPlan.clear();
      SystemMemory.normalHaftalikPlan.forEach((key, value) {
        SystemMemory.haftalikPlan[key] = value.map((e) => Gorev(e.ad, false, e.tip)).toList();
      });
      SystemMemory.normalHaftalikPlan.clear();
    }
    SystemMemory.kaydet();
  }

  static void golgeModuDegistir(bool aktif) {
    SystemMemory.golgeModuAktif = aktif;
    SystemMemory.kaydet();
  }

  static void esyaEkle(InventoryItem yeniEsya) {
    final index = SystemMemory.canta.indexWhere((e) => e.aksiyon == yeniEsya.aksiyon);
    if (index != -1) {
      SystemMemory.canta[index].adet += yeniEsya.adet;
    } else {
      SystemMemory.canta.add(yeniEsya);
    }
    SystemMemory.kaydet();
  }

  static String esyaKullan(String aksiyon) {
    final index = SystemMemory.canta.indexWhere((e) => e.aksiyon == aksiyon);
    if (index == -1 || SystemMemory.canta[index].adet <= 0) {
      return "SYSTEM WARNING: Item not found in inventory!";
    }

    final esya = SystemMemory.canta[index];
    String rapor = "";

    if (aksiyon == "hp_full") {
      acilSifa();
      rapor = "[HP FULL] Life force completely restored!";
    } else if (aksiyon == "stat_reset") {
      statuleriSifirla();
      rapor = "[STAT RESET] All stats reset to 10. AP refunded!";
    } else if (aksiyon == "cheat_meal" || aksiyon == "minor_cheat" || aksiyon == "endless_feast") {
      SystemMemory.bugunCheatMealAktif = true;
      rapor = "[CHEAT PASS ACTIVATED] Calorie penalty will be bypassed tonight!";
    } else if (aksiyon == "sloth_day") {
      SystemMemory.bugunSlothDayAktif = true;
      rapor = "[SLOTH DAY ACTIVATED] Daily quest penalties waived for today!";
    } else if (aksiyon == "gaming_pass") {
      SystemMemory.bugunGamingPassAktif = true;
      rapor = "[GAMING PASS ACTIVATED] 2-hour entertainment pass granted. Rest, Hunter.";
    } else {
      rapor = "[REWARD USED] ${esya.ad} claimed in real world!";
    }

    esya.adet--;
    if (esya.adet <= 0) {
      SystemMemory.canta.removeAt(index);
    }
    AudioSystem.playSuccess();
    SystemMemory.kaydet();
    return rapor;
  }

  static String exportBackupJson() {
    final data = {
      'oyuncuIsmi': SystemMemory.oyuncuIsmi,
      'cinsiyet': SystemMemory.cinsiyet,
      'level': SystemMemory.level.value,
      'exp': SystemMemory.exp.value,
      'maxExp': SystemMemory.maxExp.value,
      'ap': SystemMemory.ap.value,
      'altin': SystemMemory.altin.value,
      'hp': SystemMemory.hp.value,
      'maxHp': SystemMemory.maxHp,
      'mp': SystemMemory.mp.value,
      'maxMp': SystemMemory.maxMp,
      'str': SystemMemory.str.value,
      'agi': SystemMemory.agi.value,
      'vit': SystemMemory.vit.value,
      'intStat': SystemMemory.intStat.value,
      'per': SystemMemory.per.value,
      'boy': SystemMemory.boy,
      'kilo': SystemMemory.kilo,
      'hedefKilo': SystemMemory.hedefKilo,
      'avciDiyetNotu': SystemMemory.avciDiyetNotu,
      'baslangicKilosu': SystemMemory.baslangicKilosu,
      'streakGunSayisi': SystemMemory.streakGunSayisi,
      'bitenGorevSayisi': SystemMemory.bitenGorevSayisi,
      'suHedefiMl': SystemMemory.suHedefiMl,
      'bugunIcilenSuMl': SystemMemory.bugunIcilenSuMl.value,
      'gunlukHedefKalori': SystemMemory.gunlukHedefKalori,
      'vucutSinifi': SystemMemory.vucutSinifi,
      'aktifHedef': SystemMemory.aktifHedef,
      'aktifZorluk': SystemMemory.aktifZorluk,
      'maxBench': SystemMemory.maxBench,
      'maxSquat': SystemMemory.maxSquat,
      'maxDeadlift': SystemMemory.maxDeadlift,
      'hunterRank': SystemMemory.hunterRank,
      'ekipmanTuru': SystemMemory.ekipmanTuru,
      'antrenmanGecmisi': SystemMemory.antrenmanGecmisi,
      'eklemKisiti': SystemMemory.eklemKisiti,
      'odakBolgeleri': SystemMemory.odakBolgeleri,
      'sonTestTarihi': SystemMemory.sonTestTarihi,
      'sonTesttenBeriIdmanSayisi': SystemMemory.sonTesttenBeriIdmanSayisi,
      'dovusSporuYapiyorMu': SystemMemory.dovusSporuYapiyorMu,
      'dovusBransi': SystemMemory.dovusBransi,
      'dovusBranslari': SystemMemory.dovusBranslari,
      'maxPatlayiciSinav': SystemMemory.maxPatlayiciSinav,
      'maxBurpeeKondisyon': SystemMemory.maxBurpeeKondisyon,
      'maxPlankSaniye': SystemMemory.maxPlankSaniye,
      'maxBarfiks': SystemMemory.maxBarfiks,
      'gogusCm': SystemMemory.gogusCm,
      'belCm': SystemMemory.belCm,
      'kolCm': SystemMemory.kolCm,
      'bacakCm': SystemMemory.bacakCm,
      'kiloGecmisi': SystemMemory.kiloGecmisi,
      'idmanGecmisi': SystemMemory.idmanGecmisi,
      'yemekGecmisi': SystemMemory.yemekGecmisi,
      'toplamIdmanDakikasi': SystemMemory.toplamIdmanDakikasi,
      'geminiApiKey': SystemMemory.geminiApiKey,
      'geminiActiveModel': SystemMemory.geminiActiveModel,
      'canta': SystemMemory.canta.map((e) => e.toJson()).toList(),
      'backupTimestamp': DateTime.now().toIso8601String(),
    };
    return jsonEncode(data);
  }

  static bool importBackupJson(String rawJson) {
    try {
      final Map<String, dynamic> data = jsonDecode(rawJson);
      if (data.containsKey('level') && data.containsKey('oyuncuIsmi')) {
        SystemMemory.oyuncuIsmi = data['oyuncuIsmi']?.toString() ?? SystemMemory.oyuncuIsmi;
        SystemMemory.cinsiyet = data['cinsiyet']?.toString() ?? SystemMemory.cinsiyet;
        SystemMemory.level.value = (data['level'] as num?)?.toInt() ?? SystemMemory.level.value;
        SystemMemory.exp.value = (data['exp'] as num?)?.toInt() ?? SystemMemory.exp.value;
        SystemMemory.maxExp.value = (data['maxExp'] as num?)?.toInt() ?? SystemMemory.maxExp.value;
        SystemMemory.ap.value = (data['ap'] as num?)?.toInt() ?? SystemMemory.ap.value;
        SystemMemory.altin.value = (data['altin'] as num?)?.toInt() ?? SystemMemory.altin.value;
        SystemMemory.hp.value = (data['hp'] as num?)?.toInt() ?? SystemMemory.hp.value;
        SystemMemory.maxHp = (data['maxHp'] as num?)?.toInt() ?? SystemMemory.maxHp;
        SystemMemory.mp.value = (data['mp'] as num?)?.toInt() ?? SystemMemory.mp.value;
        SystemMemory.maxMp = (data['maxMp'] as num?)?.toInt() ?? SystemMemory.maxMp;
        SystemMemory.str.value = (data['str'] as num?)?.toInt() ?? SystemMemory.str.value;
        SystemMemory.agi.value = (data['agi'] as num?)?.toInt() ?? SystemMemory.agi.value;
        SystemMemory.vit.value = (data['vit'] as num?)?.toInt() ?? SystemMemory.vit.value;
        SystemMemory.intStat.value = (data['intStat'] as num?)?.toInt() ?? SystemMemory.intStat.value;
        SystemMemory.per.value = (data['per'] as num?)?.toInt() ?? SystemMemory.per.value;
        SystemMemory.boy = (data['boy'] as num?)?.toDouble() ?? SystemMemory.boy;
        SystemMemory.kilo = (data['kilo'] as num?)?.toDouble() ?? SystemMemory.kilo;
        if (data['hedefKilo'] != null) {
          SystemMemory.hedefKilo = (data['hedefKilo'] as num).toDouble();
        }
        if (data['avciDiyetNotu'] != null) {
          SystemMemory.avciDiyetNotu = data['avciDiyetNotu'].toString();
        }
        SystemMemory.baslangicKilosu = (data['baslangicKilosu'] as num?)?.toDouble() ?? SystemMemory.baslangicKilosu;
        SystemMemory.streakGunSayisi = (data['streakGunSayisi'] as num?)?.toInt() ?? SystemMemory.streakGunSayisi;
        SystemMemory.bitenGorevSayisi = (data['bitenGorevSayisi'] as num?)?.toInt() ?? SystemMemory.bitenGorevSayisi;
        SystemMemory.suHedefiMl = (data['suHedefiMl'] as num?)?.toInt() ?? SystemMemory.suHedefiMl;

        if (data['bugunIcilenSuMl'] != null) {
          SystemMemory.bugunIcilenSuMl.value = (data['bugunIcilenSuMl'] as num).toInt();
        }
        if (data['gunlukHedefKalori'] != null) {
          SystemMemory.gunlukHedefKalori = (data['gunlukHedefKalori'] as num).toInt();
        }
        if (data['vucutSinifi'] != null) {
          SystemMemory.vucutSinifi = data['vucutSinifi'].toString();
        }
        if (data['aktifHedef'] != null) {
          SystemMemory.aktifHedef = data['aktifHedef'].toString();
        }
        if (data['aktifZorluk'] != null) {
          SystemMemory.aktifZorluk = data['aktifZorluk'].toString();
        }
        if (data['maxBench'] != null) {
          SystemMemory.maxBench = (data['maxBench'] as num).toDouble();
        }
        if (data['maxSquat'] != null) {
          SystemMemory.maxSquat = (data['maxSquat'] as num).toDouble();
        }
        if (data['maxDeadlift'] != null) {
          SystemMemory.maxDeadlift = (data['maxDeadlift'] as num).toDouble();
        }
        if (data['hunterRank'] != null) {
          SystemMemory.hunterRank = data['hunterRank'].toString();
        }
        if (data['ekipmanTuru'] != null) {
          SystemMemory.ekipmanTuru = data['ekipmanTuru'].toString();
        }
        if (data['antrenmanGecmisi'] != null) {
          SystemMemory.antrenmanGecmisi = data['antrenmanGecmisi'].toString();
        }
        if (data['eklemKisiti'] != null && data['eklemKisiti'] is List) {
          SystemMemory.eklemKisiti = List<String>.from((data['eklemKisiti'] as List).map((e) => e.toString()));
        }
        if (data['odakBolgeleri'] != null && data['odakBolgeleri'] is List) {
          SystemMemory.odakBolgeleri = List<String>.from((data['odakBolgeleri'] as List).map((e) => e.toString()));
        }
        if (data['sonTestTarihi'] != null) {
          SystemMemory.sonTestTarihi = data['sonTestTarihi'].toString();
        }
        if (data['sonTesttenBeriIdmanSayisi'] != null) {
          SystemMemory.sonTesttenBeriIdmanSayisi = (data['sonTesttenBeriIdmanSayisi'] as num).toInt();
        }
        if (data['dovusSporuYapiyorMu'] != null) {
          SystemMemory.dovusSporuYapiyorMu = data['dovusSporuYapiyorMu'] == true;
        }
        if (data['dovusBransi'] != null) {
          SystemMemory.dovusBransi = data['dovusBransi'].toString();
        }
        if (data['dovusBranslari'] != null && data['dovusBranslari'] is List) {
          SystemMemory.dovusBranslari = List<String>.from((data['dovusBranslari'] as List).map((e) => e.toString()));
        }
        if (data['maxPatlayiciSinav'] != null) {
          SystemMemory.maxPatlayiciSinav = (data['maxPatlayiciSinav'] as num).toInt();
        }
        if (data['maxBurpeeKondisyon'] != null) {
          SystemMemory.maxBurpeeKondisyon = (data['maxBurpeeKondisyon'] as num).toInt();
        }
        if (data['maxPlankSaniye'] != null) {
          SystemMemory.maxPlankSaniye = (data['maxPlankSaniye'] as num).toInt();
        }
        if (data['maxBarfiks'] != null) {
          SystemMemory.maxBarfiks = (data['maxBarfiks'] as num).toInt();
        }
        if (data['gogusCm'] != null) {
          SystemMemory.gogusCm = (data['gogusCm'] as num).toDouble();
        }
        if (data['belCm'] != null) {
          SystemMemory.belCm = (data['belCm'] as num).toDouble();
        }
        if (data['kolCm'] != null) {
          SystemMemory.kolCm = (data['kolCm'] as num).toDouble();
        }
        if (data['bacakCm'] != null) {
          SystemMemory.bacakCm = (data['bacakCm'] as num).toDouble();
        }
        if (data['toplamIdmanDakikasi'] != null) {
          SystemMemory.toplamIdmanDakikasi = (data['toplamIdmanDakikasi'] as num).toInt();
        }
        if (data['geminiApiKey'] != null) {
          SystemMemory.geminiApiKey = data['geminiApiKey'].toString();
        }
        if (data['geminiActiveModel'] != null) {
          SystemMemory.geminiActiveModel = data['geminiActiveModel'].toString();
        }

        if (data['kiloGecmisi'] != null && data['kiloGecmisi'] is List) {
          SystemMemory.kiloGecmisi = List<Map<String, dynamic>>.from(
            (data['kiloGecmisi'] as List).map((x) => Map<String, dynamic>.from(x as Map)),
          );
        }
        if (data['idmanGecmisi'] != null && data['idmanGecmisi'] is List) {
          SystemMemory.idmanGecmisi = List<Map<String, dynamic>>.from(
            (data['idmanGecmisi'] as List).map((x) => Map<String, dynamic>.from(x as Map)),
          );
        }
        if (data['yemekGecmisi'] != null && data['yemekGecmisi'] is List) {
          SystemMemory.yemekGecmisi = List<Map<String, dynamic>>.from(
            (data['yemekGecmisi'] as List).map((x) => Map<String, dynamic>.from(x as Map)),
          );
        }

        if (data['canta'] != null) {
          final List<dynamic> cList = data['canta'];
          SystemMemory.canta = cList.map((e) => InventoryItem.fromJson(e)).toList();
        }
        SystemMemory.kaydet();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
