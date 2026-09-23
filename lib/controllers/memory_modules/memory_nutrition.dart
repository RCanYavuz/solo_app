import 'dart:typed_data';
import '../system_memory.dart';
import '../../models/task_model.dart';
import '../../models/food_model.dart';
import '../../core/advanced_metabolic_engine.dart';
import '../../core/supplement_engine.dart';
import '../../core/audio_system.dart';
import '../../core/translation_manager.dart';

class MemoryNutrition {
  static void suEkle(int miktarMl) {
    SystemMemory.bugunIcilenSuMl.value += miktarMl;
    SystemMemory.kaydet();
  }

  static void suSifirla() {
    SystemMemory.bugunIcilenSuMl.value = 0;
    SystemMemory.kaydet();
  }

  static void suplementKusan(String id) {
    if (!SystemMemory.kusanilanSuplementler.contains(id)) {
      SystemMemory.kusanilanSuplementler.add(id);
      suHedefiGuncelle();
      SystemMemory.kaydet();
    }
  }

  static void suplementCikar(String id) {
    if (SystemMemory.kusanilanSuplementler.contains(id)) {
      SystemMemory.kusanilanSuplementler.remove(id);
      suHedefiGuncelle();
      SystemMemory.kaydet();
    }
  }

  static bool suplementKusanildiMi(String id) {
    return SystemMemory.kusanilanSuplementler.contains(id);
  }

  static void suHedefiGuncelle() {
    int bazSu = 3000;
    int ekSu = SupplementEngine.hesaplaToplamSuArtisi(SystemMemory.kusanilanSuplementler);
    SystemMemory.suHedefiMl = bazSu + ekSu;
  }

  static void protokolGuncelle(String yeniHedef, String yeniZorluk) {
    SystemMemory.aktifHedef = yeniHedef;
    SystemMemory.aktifZorluk = yeniZorluk;

    double bmr = (SystemMemory.cinsiyet == "Erkek")
        ? (10 * SystemMemory.kilo) + (6.25 * SystemMemory.boy) - (5 * SystemMemory.yas) + 5
        : (10 * SystemMemory.kilo) + (6.25 * SystemMemory.boy) - (5 * SystemMemory.yas) - 161;
    double gunlukIhtiyac = bmr * 1.375;
    int kaloriFarki = 0;

    if (yeniHedef == "Kilo Ver (Yağ Yak)") {
      if (yeniZorluk == "Normal") {
        kaloriFarki = -500;
      } else if (yeniZorluk == "Yüksek") {
        kaloriFarki = -1000;
      } else if (yeniZorluk == "Cehennem") {
        kaloriFarki = -1500;
      }
    } else if (yeniHedef == "Kilo Al (Kas İnşa Et)") {
      if (yeniZorluk == "Normal") {
        kaloriFarki = 300;
      } else if (yeniZorluk == "Yüksek") {
        kaloriFarki = 500;
      } else if (yeniZorluk == "Cehennem") {
        kaloriFarki = 800;
      }
    }

    int hesaplanan = (gunlukIhtiyac + kaloriFarki).round();
    if (hesaplanan < 1200) hesaplanan = 1200;

    if (SystemMemory.redGateAktif) {
      SystemMemory.normalGunlukHedefKalori = hesaplanan; 
    } else {
      SystemMemory.gunlukHedefKalori = hesaplanan;
    }
    
    SystemMemory.kaydet();
  }

  static void oyuncuyuAnalizEt(
    String secilenCinsiyet,
    DateTime girilenDogumTarihi,
    double girilenBoy,
    double girilenKilo,
    String hedef,
    String zorluk,
    Uint8List? foto,
    [int? idmanGunu,
    String? ekipman,
    String? tecrube,
    List<String>? eklemKisitlari,
    List<String>? hedefOdakBolgeleri]
  ) {
    SystemMemory.cinsiyet = secilenCinsiyet;
    SystemMemory.dogumTarihi = girilenDogumTarihi;
    SystemMemory.boy = girilenBoy;
    SystemMemory.kilo = girilenKilo;
    SystemMemory.aktifHedef = hedef;
    SystemMemory.aktifZorluk = zorluk;
    if (foto != null) SystemMemory.profilFotoByte = foto;
    if (ekipman != null) SystemMemory.ekipmanTuru = ekipman;
    if (tecrube != null) SystemMemory.antrenmanGecmisi = tecrube;
    if (eklemKisitlari != null) SystemMemory.eklemKisiti = eklemKisitlari;
    if (hedefOdakBolgeleri != null) SystemMemory.odakBolgeleri = hedefOdakBolgeleri;

    if (SystemMemory.baslangicKilosu == 0) {
      SystemMemory.baslangicKilosu = SystemMemory.kilo;
      SystemMemory.kiloGecmisi.add({
        'tarih': DateTime.now().toIso8601String(),
        'kilo': SystemMemory.kilo,
        'kalori': SystemMemory.bugunAlinanKalori,
      });
    }

    if (SystemMemory.sonGirisTarihi.isEmpty) {
      DateTime bugun = DateTime.now();
      SystemMemory.sonGirisTarihi = "${bugun.year}-${bugun.month.toString().padLeft(2,'0')}-${bugun.day.toString().padLeft(2,'0')}";
    }

    double boyMetre = SystemMemory.boy / 100;
    double bmi = SystemMemory.kilo / (boyMetre * boyMetre);
    if (bmi < 18.5) {
      SystemMemory.vucutSinifi = "Underweight";
    } else if (bmi < 24.9) {
      SystemMemory.vucutSinifi = "Normal";
    } else if (bmi < 29.9) {
      SystemMemory.vucutSinifi = "Overweight";
    } else {
      SystemMemory.vucutSinifi = "Obese";
    }

    double bmr = (SystemMemory.cinsiyet == "Erkek")
        ? (10 * SystemMemory.kilo) + (6.25 * SystemMemory.boy) - (5 * SystemMemory.yas) + 5
        : (10 * SystemMemory.kilo) + (6.25 * SystemMemory.boy) - (5 * SystemMemory.yas) - 161;
    double gunlukIhtiyac = bmr * 1.375;
    int kaloriFarki = 0;

    if (hedef == "Kilo Ver (Yağ Yak)") {
      if (zorluk == "Normal") {
        kaloriFarki = -500;
      } else if (zorluk == "Yüksek") {
        kaloriFarki = -1000;
      } else if (zorluk == "Cehennem") {
        kaloriFarki = -1500;
      }
    } else if (hedef == "Kilo Al (Kas İnşa Et)") {
      if (zorluk == "Normal") {
        kaloriFarki = 300;
      } else if (zorluk == "Yüksek") {
        kaloriFarki = 500;
      } else if (zorluk == "Cehennem") {
        kaloriFarki = 800;
      }
    }

    int hesaplanan = (gunlukIhtiyac + kaloriFarki).round();
    if (hesaplanan < 1200) hesaplanan = 1200;

    if (SystemMemory.redGateAktif) {
      SystemMemory.normalGunlukHedefKalori = hesaplanan; 
    } else {
      SystemMemory.gunlukHedefKalori = hesaplanan;
    }

    if (!SystemMemory.diyetisyenListesiAktif || SystemMemory.diyetisyenOgunleri.isEmpty) {
      diyetisyenOgunleriniOlustur(
        hedefKalori: SystemMemory.gunlukHedefKalori,
        hedef: hedef,
        kilo: SystemMemory.kilo,
      );
    }

    SystemMemory.kaydet();
  }

  static String tartiGuncelle(double yeniKilo) {
    double eskiKilo = SystemMemory.kilo;
    double fark = eskiKilo - yeniKilo; 
    DateTime effectiveDogum = SystemMemory.dogumTarihi ?? DateTime(2000, 1, 1);
    oyuncuyuAnalizEt(SystemMemory.cinsiyet, effectiveDogum, SystemMemory.boy, yeniKilo, SystemMemory.aktifHedef, SystemMemory.aktifZorluk, SystemMemory.profilFotoByte);
    SystemMemory.kiloGecmisi.add({
      'tarih': DateTime.now().toIso8601String(),
      'kilo': yeniKilo,
      'kalori': SystemMemory.bugunAlinanKalori,
    });
    
    final tr = TranslationManager.isTurkish;
    if (fark == 0) {
      return tr ? "[SİSTEM] Vücut kütlesinde değişim algılanmadı." : "[SYSTEM] No change in body mass detected.";
    }

    String rapor = "";
    if (SystemMemory.aktifHedef == 'Kilo Ver (Yağ Yak)' || SystemMemory.aktifHedef.contains('Ver') || SystemMemory.aktifHedef.contains('Lose')) {
      if (fark > 0) { 
        int kazanilanAltin = (fark * 500).toInt();
        int kazanilanAP = fark.toInt();
        if (kazanilanAP < 1) kazanilanAP = 1; 
        SystemMemory.altin.value += kazanilanAltin;
        SystemMemory.ap.value += kazanilanAP;
        rapor = tr 
            ? "[BAŞARIM AÇILDI] $fark kg kütle verildi!\nÖDÜL: +$kazanilanAltin Altın | +$kazanilanAP AP"
            : "[ACHIEVEMENT UNLOCKED] $fark kg mass shed!\nREWARD: +$kazanilanAltin Gold | +$kazanilanAP AP";
        AudioSystem.playSuccess();
      } else { 
        if (!SystemMemory.golgeModuAktif) {
          SystemMemory.hp.value -= 20;
          if (SystemMemory.hp.value < 0) SystemMemory.hp.value = 0;
          rapor = tr
              ? "[SİSTEM UYARISI] ${fark.abs()} kg kütle alındı. Disiplin ihlali!\nCEZA: -20 HP"
              : "[SYSTEM WARNING] ${fark.abs()} kg mass regained. Discipline violated!\nPENALTY: -20 HP";
        } else {
          rapor = tr
              ? "[GÖLGE MODU] Kütle alındı fakat ceza engellendi."
              : "[STEALTH MODE] Mass regained, but penalty bypassed.";
        }
      }
    } 
    else if (SystemMemory.aktifHedef == 'Kilo Al (Kas İnşa Et)' || SystemMemory.aktifHedef.contains('Al') || SystemMemory.aktifHedef.contains('Gain')) {
      if (fark < 0) { 
        double alinan = fark.abs();
        int kazanilanAltin = (alinan * 500).toInt();
        int kazanilanAP = alinan.toInt();
        if (kazanilanAP < 1) kazanilanAP = 1;
        SystemMemory.altin.value += kazanilanAltin;
        SystemMemory.ap.value += kazanilanAP;
        rapor = tr
            ? "[BAŞARIM AÇILDI] $alinan kg kas inşa edildi!\nÖDÜL: +$kazanilanAltin Altın | +$kazanilanAP AP"
            : "[ACHIEVEMENT UNLOCKED] $alinan kg muscle built!\nREWARD: +$kazanilanAltin Gold | +$kazanilanAP AP";
        AudioSystem.playSuccess();
      } else {
        if (!SystemMemory.golgeModuAktif) {
          SystemMemory.hp.value -= 20;
          if (SystemMemory.hp.value < 0) SystemMemory.hp.value = 0;
          rapor = tr
              ? "[SİSTEM UYARISI] $fark kg kütle kaybedildi. Kalori fazlası şart!\nCEZA: -20 HP"
              : "[SYSTEM WARNING] $fark kg mass lost. Caloric surplus required!\nPENALTY: -20 HP";
        } else {
          rapor = tr
              ? "[GÖLGE MODU] Kütle kaybedildi fakat ceza engellendi."
              : "[STEALTH MODE] Mass lost, but penalty bypassed.";
        }
      }
    }

    SystemMemory.kaydet();
    return rapor;
  }

  static void yeniGunKontrolu() {
    DateTime bugun = DateTime.now();
    String bugunStr = "${bugun.year}-${bugun.month.toString().padLeft(2,'0')}-${bugun.day.toString().padLeft(2,'0')}";

    if (SystemMemory.sonGirisTarihi.isEmpty) {
      if (SystemMemory.bugunAlinanKalori > 0 || SystemMemory.bugununYemekleri.isNotEmpty) {
        DateTime dun = bugun.subtract(const Duration(days: 1));
        SystemMemory.sonGirisTarihi = "${dun.year}-${dun.month.toString().padLeft(2,'0')}-${dun.day.toString().padLeft(2,'0')}";
      } else {
        SystemMemory.sonGirisTarihi = bugunStr;
        SystemMemory.kaydet();
        return;
      }
    }

    if (SystemMemory.sonGirisTarihi != bugunStr) {
      DateTime sonGiris = DateTime.parse(SystemMemory.sonGirisTarihi);
      
      SystemMemory.geceRaporu = gunSonuHesaplasmasi(sonGiris.weekday);

      int gunFarki = bugun.difference(sonGiris).inDays;
      if (gunFarki > 1 && !SystemMemory.golgeModuAktif && !SystemMemory.redGateAktif) {
        SystemMemory.streakGunSayisi = 0; 
        int kacirilanEkGun = gunFarki - 1;
        int ekCeza = kacirilanEkGun * 15;
        SystemMemory.hp.value = (SystemMemory.hp.value - ekCeza).clamp(0, SystemMemory.maxHp);
        final tr = TranslationManager.isTurkish;
        SystemMemory.geceRaporu = tr
            ? "${SystemMemory.geceRaporu}\n[SİSTEM CEZASI] Gölge modu olmadan $kacirilanEkGun ek gün kaçırıldı!\nCEZA: -$ekCeza HP"
            : "${SystemMemory.geceRaporu}\n[SYSTEM PENALTY] Missed $kacirilanEkGun additional day(s) without stealth!\nPENALTY: -$ekCeza HP";
      }

      SystemMemory.sonGirisTarihi = bugunStr;
      SystemMemory.kaydet();
    }
  }

  static String gunSonuHesaplasmasi(int degerlendirilenGun) {
    final tr = TranslationManager.isTurkish;
    int hpFarki = 0;
    int mpFarki = 0;
    int kazanilanExp = 0;
    int kazanilanAltin = 0;
    int kazanilanSTR = 0;
    int kazanilanAGI = 0;
    int kazanilanVIT = 0;
    int kazanilanINT = 0;
    int kazanilanPER = 0;

    String rapor = tr
        ? "[GÜNLÜK HESAPLAŞMA RAPORU - GÜN $degerlendirilenGun]\n"
        : "[DAILY SETTLEMENT REPORT - DAY $degerlendirilenGun]\n";

    if (SystemMemory.bugunCheatMealAktif) {
      rapor += tr
          ? "[ 🍔 KAÇAMAK HAKKI AKTİF ] Bugünlük kalori aşım cezası affedildi!\n"
          : "[ 🍔 CHEAT PASS ACTIVE ] Calorie excess penalty waived for today!\n";
    } else if (SystemMemory.bugunAlinanKalori > SystemMemory.gunlukHedefKalori) { 
      if (SystemMemory.redGateAktif) {
        hpFarki -= 60;
        rapor += tr
            ? "[ÖLÜMCÜL CEZA] Cehennemde Kalori Sınırı Aşıldı: -60 HP\n"
            : "[FATAL PENALTY] Calorie Limit Exceeded in Hell: -60 HP\n";
      } else if (!SystemMemory.golgeModuAktif) {
        hpFarki -= 20;
        rapor += tr
            ? "[CEZA] Kalori Sınırı Aşıldı: -20 HP\n"
            : "[PENALTY] Calorie Limit Exceeded: -20 HP\n";
      } else {
        rapor += tr
            ? "[GÖLGE MODU] Kalori Fazlası Görmezden Gelindi.\n"
            : "[STEALTH] Calorie Excess Ignored.\n";
      }
    } else {
      hpFarki += 10;
      kazanilanExp += 20;
      kazanilanVIT += 1;
      kazanilanAltin += 20;
      rapor += tr
          ? "[ÖDÜL] İdeal Beslenme: +10 HP, +20 EXP, +1 VIT, +20 Altın\n"
          : "[REWARD] Ideal Diet: +10 HP, +20 EXP, +1 VIT, +20 G\n";
    }

    if (SystemMemory.uyunanSaat < 7) { 
      if (SystemMemory.redGateAktif) {
        mpFarki -= 15;
        rapor += tr
            ? "[ÖLÜMCÜL CEZA] Cehennemde Yetersiz Dinlenme: -15 MP\n"
            : "[FATAL PENALTY] Insufficient Rest in Hell: -15 MP\n";
      } else if (!SystemMemory.golgeModuAktif) {
        mpFarki -= 4;
        rapor += tr
            ? "[CEZA] Yetersiz Uyku: -4 MP\n"
            : "[PENALTY] Insufficient Sleep: -4 MP\n";
      } else {
        rapor += tr
            ? "[GÖLGE MODU] Uyku Açığı Görmezden Gelindi.\n"
            : "[STEALTH] Sleep Deficit Ignored.\n";
      }
    } else {
      mpFarki += 2;
      kazanilanExp += 10;
      kazanilanVIT += 1;
      kazanilanAltin += 10;
      rapor += tr
          ? "[ÖDÜL] Kaliteli Dinlenme: +2 MP, +10 EXP, +1 VIT, +10 Altın\n"
          : "[REWARD] Solid Rest: +2 MP, +10 EXP, +1 VIT, +10 G\n";
    }

    // SU HEDEFİ KONTROLÜ
    if (SystemMemory.bugunIcilenSuMl.value >= SystemMemory.suHedefiMl && SystemMemory.suHedefiMl > 0) {
      hpFarki += 5;
      kazanilanExp += 10;
      rapor += tr
          ? "[ÖDÜL] Hidrasyon Hedefine Ulaşıldı (${SystemMemory.bugunIcilenSuMl.value}ml): +5 HP, +10 EXP\n"
          : "[REWARD] Hydration Goal Achieved (${SystemMemory.bugunIcilenSuMl.value}ml): +5 HP, +10 EXP\n";
    }

    List<Gorev> oGununProgrami = SystemMemory.haftalikPlan[degerlendirilenGun] ?? [];
    
    int topFiziksel = 0;
    int bitenFiziksel = 0;
    int topZihinsel = 0;
    int bitenZihinsel = 0;
    int strGorevleri = 0;
    int agiGorevleri = 0;
    int intGorevleri = 0;
    int perGorevleri = 0;

    for (var g in oGununProgrami) { 
      if (g.tip == "Fiziksel") { 
        topFiziksel++; 
        if (g.yapildiMi) { 
          bitenFiziksel++; 
          if (g.ad.contains("Kardiyo") || g.ad.contains("Bacak") || g.ad.contains("Kalf") || g.ad.contains("Legs") || g.ad.contains("Cardio") || g.ad.contains("Run")) {
            agiGorevleri++;
          } else {
            strGorevleri++;
          }
        } 
      } else { 
        topZihinsel++; 
        if (g.yapildiMi) { 
          bitenZihinsel++; 
          if (g.ad.contains("Meditasyon") || g.ad.contains("Strateji") || g.ad.contains("PERCEPTION")) {
            perGorevleri++;
          } else {
            intGorevleri++;
          } 
        } 
      } 
    }

    int toplamGorev = topFiziksel + topZihinsel;
    int toplamBiten = bitenFiziksel + bitenZihinsel;
    SystemMemory.bitenGorevSayisi += toplamBiten; 

    if (SystemMemory.bugunGamingPassAktif) {
      rapor += tr
          ? "[ 🎮 OYUN İZNİ AKTİF ] 2 saatlik eğlence ayrıcalığı tanındı. Ceza yok.\n"
          : "[ 🎮 GAMING PASS ACTIVE ] 2-hour entertainment privilege granted. No penalty.\n";
    }

    if (SystemMemory.bugunSlothDayAktif) {
      rapor += tr
          ? "[ 🦥 TEMBELLİK GÜNÜ AKTİF ] Görevler bugün mazur görüldü. Seri korundu!\n"
          : "[ 🦥 SLOTH PASS ACTIVE ] Quests excused today. Streak preserved without penalty!\n";
    } else if (toplamGorev > 0) {
      if (toplamBiten == toplamGorev) {
        SystemMemory.streakGunSayisi++;
        rapor += tr
            ? "[SERİ] Kusursuz Gün Serisi: ${SystemMemory.streakGunSayisi} Gün!\n"
            : "[STREAK] Flawless Day Streak: ${SystemMemory.streakGunSayisi} Days!\n";
      } else {
        if (!SystemMemory.golgeModuAktif || SystemMemory.redGateAktif) {
          SystemMemory.streakGunSayisi = 0;
          rapor += tr
              ? "[SERİ BOZULDU] Disiplin kaybedildi, Seri sıfırlandı.\n"
              : "[STREAK BROKEN] Discipline lost, Streak reset.\n";
        } else {
          rapor += tr
              ? "[GÖLGE MODU] Seri Donduruldu. Ceza uygulanmadı.\n"
              : "[STEALTH] Streak Frozen. No penalty applied.\n";
        }
      }
    }

    if (degerlendirilenGun == 7) {
      SystemMemory.bossGuncelle(gunIndex: 7); 
      if (SystemMemory.bossHP.value <= 0 && SystemMemory.bossMaxHP > 0) {
        kazanilanAltin += 1000;
        SystemMemory.ap.value += 2;
        kazanilanExp += 500;
        rapor += tr
            ? "\n[BOSS YENİLDİ] ${SystemMemory.bossIsim} yok edildi!\nÖDÜL: +1000 Altın | +2 AP | +500 EXP\n"
            : "\n[BOSS DEFEATED] ${SystemMemory.bossIsim} was annihilated!\nREWARD: +1000 G | +2 AP | +500 EXP\n";
        AudioSystem.playSuccess();
      } else if (SystemMemory.bossMaxHP > 0) {
        if (!SystemMemory.golgeModuAktif) {
          int cezaHp = SystemMemory.level.value * 10;
          if (SystemMemory.redGateAktif) {
            rapor += tr
                ? "\n[KIRMIZI GEÇİT] Haftalık Boss bu Cehenneme adım atamaz.\n"
                : "\n[RED GATE] The Weekly Boss dares not enter this Hell.\n";
          } else {
            hpFarki -= cezaHp;
            rapor += tr
                ? "\n[ZİNDAN YENİLGİSİ] ${SystemMemory.bossIsim} seni ağır yaraladı!\nCEZA: -$cezaHp HP\n"
                : "\n[DUNGEON DEFEAT] ${SystemMemory.bossIsim} heavily wounded you!\nPENALTY: -$cezaHp HP\n";
          }
        } else {
          rapor += tr
              ? "\n[GÖLGE MODU] Haftalık Boss uykudaki varlığını fark etmedi.\n"
              : "\n[STEALTH] Weekly Boss ignored your dormant presence.\n";
        }
      }
    }

    if (bitenFiziksel > 0) {
      kazanilanExp += bitenFiziksel * 15;
      kazanilanAltin += bitenFiziksel * 10;
      kazanilanSTR += (strGorevleri / 2).floor();
      kazanilanAGI += (agiGorevleri / 2).floor();
      kazanilanVIT += (bitenFiziksel / 3).floor();
    }
    if (bitenZihinsel > 0) {
      kazanilanExp += bitenZihinsel * 20;
      kazanilanAltin += bitenZihinsel * 15;
      kazanilanINT += (intGorevleri / 1).floor();
      kazanilanPER += (perGorevleri / 1).floor();
    }

    int bitmeyenFiziksel = topFiziksel - bitenFiziksel;
    int bitmeyenZihinsel = topZihinsel - bitenZihinsel;

    if (!SystemMemory.bugunSlothDayAktif) {
      if (SystemMemory.redGateAktif) {
        hpFarki -= (bitmeyenFiziksel * 30);
        mpFarki -= (bitmeyenZihinsel * 15);
      } else if (!SystemMemory.golgeModuAktif) {
        hpFarki -= (bitmeyenFiziksel * 10);
        mpFarki -= (bitmeyenZihinsel * 5);
      }
    }

    if (SystemMemory.redGateAktif) {
      SystemMemory.redGateKalanGun--;
      if (SystemMemory.redGateKalanGun < 0) SystemMemory.redGateKalanGun = 0;
      rapor += tr
          ? "\n[KIRMIZI GEÇİTTE HAYATTA KALMA] Kalan Gün: ${SystemMemory.redGateKalanGun} / ${SystemMemory.redGateToplamGun}\n"
          : "\n[RED GATE SURVIVAL] Days Remaining: ${SystemMemory.redGateKalanGun} / ${SystemMemory.redGateToplamGun}\n";
    }

    SystemMemory.hp.value += hpFarki;
    if (SystemMemory.hp.value > SystemMemory.maxHp) SystemMemory.hp.value = SystemMemory.maxHp;
    if (SystemMemory.hp.value < 0) SystemMemory.hp.value = 0;
    
    SystemMemory.mp.value += mpFarki;
    if (SystemMemory.mp.value > SystemMemory.maxMp) SystemMemory.mp.value = SystemMemory.maxMp;
    if (SystemMemory.mp.value < 0) SystemMemory.mp.value = 0;
    SystemMemory.altin.value += kazanilanAltin; 

    SystemMemory.str.value += kazanilanSTR;
    SystemMemory.agi.value += kazanilanAGI;
    SystemMemory.vit.value += kazanilanVIT;
    SystemMemory.intStat.value += kazanilanINT;
    SystemMemory.per.value += kazanilanPER;
    SystemMemory.maxHp += (kazanilanVIT * 10);
    SystemMemory.maxMp += (kazanilanINT * 2);

    String levelRaporu = SystemMemory.expKazan(kazanilanExp);

    if (SystemMemory.redGateAktif && SystemMemory.redGateKalanGun <= 0 && SystemMemory.hp.value > 0) {
      int odulAP = SystemMemory.redGateToplamGun * 1;
      int odulAltin = SystemMemory.redGateToplamGun * 1500;
      int odulEXP = SystemMemory.redGateToplamGun * 300;

      rapor += tr
          ? "\n[ 👑 KIRMIZI GEÇİT TEMİZLENDİ 👑 ]\nTam ${SystemMemory.redGateToplamGun} Günlük mutlak Cehennemden sağ çıktın.\nNİHAİ ÖDÜL: +$odulAP AP, +$odulAltin Altın, +$odulEXP EXP, TAM İYİLEŞME!\n"
          : "\n[ 👑 RED GATE CLEARED 👑 ]\nYou survived ${SystemMemory.redGateToplamGun} Days of absolute Hell.\nULTIMATE REWARD: +$odulAP AP, +$odulAltin G, +$odulEXP EXP, FULL RECOVERY!\n";
      SystemMemory.ap.value += odulAP; 
      SystemMemory.altin.value += odulAltin; 
      SystemMemory.hp.value = SystemMemory.maxHp;  
      SystemMemory.mp.value = SystemMemory.maxMp; 
      
      SystemMemory.kirmiziGecittenCik();
      levelRaporu += SystemMemory.expKazan(odulEXP);
      AudioSystem.playLevelUp();
    }

    if (SystemMemory.bugununYemekleri.isNotEmpty || SystemMemory.bugunAlinanKalori > 0) {
      SystemMemory.yemekGecmisi.add({
        'tarih': SystemMemory.sonGirisTarihi,
        'toplamKalori': SystemMemory.bugunAlinanKalori,
        'yemekler': SystemMemory.bugununYemekleri.map((e) => e.toJson()).toList(),
      });
    }

    int yorgunlukDususu = SystemMemory.uyunanSaat > 0 ? (SystemMemory.uyunanSaat * 12) : 25;
    SystemMemory.fatigue.value = (SystemMemory.fatigue.value - yorgunlukDususu).clamp(0, 100);

    SystemMemory.bugunAlinanKalori = 0; 
    SystemMemory.bugununYemekleri.clear(); 
    SystemMemory.uyunanSaat = 0;
    SystemMemory.bugunIcilenSuMl.value = 0;
    SystemMemory.bugunCheatMealAktif = false;
    SystemMemory.bugunSlothDayAktif = false;
    SystemMemory.bugunGamingPassAktif = false;
    SystemMemory.bugunYakilanIdmanKalorisi = 0;
    SystemMemory.bugunTelafiProteini = 0;
    SystemMemory.bugunTelafiKarbonhidrati = 0;
    SystemMemory.sonIdmanYipranmaRaporu = null;
    
    if (SystemMemory.haftalikPlan.containsKey(degerlendirilenGun)) {
      for (var g in SystemMemory.haftalikPlan[degerlendirilenGun]!) {
        g.yapildiMi = false;
      }
    }

    if (SystemMemory.gunlukZihinselGorevler.value.isNotEmpty) {
      for (var mt in SystemMemory.gunlukZihinselGorevler.value) {
        mt.isCompleted = false;
        mt.completedMinutes = 0;
        mt.completedPages = 0;
      }
    }

    return "$rapor\n[QUEST LOG]\nNET HP: ${hpFarki > 0 ? '+' : ''}$hpFarki | GOLD EARNED: $kazanilanAltin 🪙 | EXP EARNED: $kazanilanExp$levelRaporu";
  }

  static WorkloadImpactResult idmanYipranmasiIsle({
    required int dakika,
    required String idmanTuru,
    int rpeZorluk = 8,
  }) {
    if (dakika <= 0) {
      return const WorkloadImpactResult(
        yakilanKalori: 0,
        telafiProteiniGram: 0,
        telafiKarbonhidratiGram: 0,
        katabolizmaSeviyesi: 'Düşük',
        sistemUyarisi: '',
      );
    }
    final sonuc = AdvancedMetabolicEngine.hesaplaIdmanYipranmasi(
      sureDakika: dakika,
      kiloKg: SystemMemory.kilo > 0 ? SystemMemory.kilo : 70.0,
      idmanTuru: idmanTuru,
      rpeZorluk: rpeZorluk,
    );

    SystemMemory.bugunYakilanIdmanKalorisi += sonuc.yakilanKalori;
    SystemMemory.bugunTelafiProteini += sonuc.telafiProteiniGram;
    SystemMemory.bugunTelafiKarbonhidrati += sonuc.telafiKarbonhidratiGram;
    SystemMemory.sonIdmanYipranmaRaporu = {
      'idmanTuru': idmanTuru,
      'dakika': dakika,
      'yakilanKalori': sonuc.yakilanKalori,
      'telafiProteini': sonuc.telafiProteiniGram,
      'telafiKarbonhidrati': sonuc.telafiKarbonhidratiGram,
      'katabolizmaRiski': sonuc.katabolizmaSeviyesi,
      'sistemUyarisi': sonuc.sistemUyarisi,
      'tarih': DateTime.now().toIso8601String(),
    };
    SystemMemory.kaydet();
    return sonuc;
  }

  static void diyetisyenListesiniKaydet({
    required int kalori,
    required int protein,
    required int karb,
    required int yag,
    List<Map<String, dynamic>> ogunler = const [],
  }) {
    SystemMemory.diyetisyenListesiAktif = true;
    SystemMemory.diyetisyenBazKalori = kalori;
    SystemMemory.diyetisyenBazProtein = protein;
    SystemMemory.diyetisyenBazKarb = karb;
    SystemMemory.diyetisyenBazYag = yag;
    SystemMemory.diyetisyenOgunleri = List<Map<String, dynamic>>.from(ogunler);
    SystemMemory.gunlukHedefKalori = kalori;
    SystemMemory.kaydet();
  }

  static void diyetisyenListesiniSifirla() {
    SystemMemory.diyetisyenListesiAktif = false;
    SystemMemory.diyetisyenBazKalori = 0;
    SystemMemory.diyetisyenBazProtein = 0;
    SystemMemory.diyetisyenBazKarb = 0;
    SystemMemory.diyetisyenBazYag = 0;
    SystemMemory.diyetisyenOgunleri = [];
    protokolGuncelle(SystemMemory.aktifHedef, SystemMemory.aktifZorluk);
    SystemMemory.kaydet();
  }

  static void diyetisyenOgunleriniOlustur({
    required int hedefKalori,
    required String hedef,
    required double kilo,
  }) {
    double proteinCarpan = hedef.contains('Kilo Al') ? 2.0 : (hedef.contains('Kilo Ver') ? 2.2 : 1.8);
    int bazProtein = (kilo * proteinCarpan).round();
    if (bazProtein < 100) bazProtein = 100;

    int proteinKalori = bazProtein * 4;
    int yagKalori = (hedefKalori * 0.25).round();
    int bazYag = (yagKalori / 9).round();
    int karbKalori = hedefKalori - (proteinKalori + yagKalori);
    if (karbKalori < 0) karbKalori = 0;
    int bazKarb = (karbKalori / 4).round();

    SystemMemory.diyetisyenBazKalori = hedefKalori;
    SystemMemory.diyetisyenBazProtein = bazProtein;
    SystemMemory.diyetisyenBazKarb = bazKarb;
    SystemMemory.diyetisyenBazYag = bazYag;
    SystemMemory.diyetisyenListesiAktif = true;

    SystemMemory.diyetisyenOgunleri = [
      {
        'id': 'ogun_1',
        'baslik': 'Kahvaltı (Avcı Yakıtı)',
        'besinler': '3 Tam Yumurta + 2 Yumurta Beyazı, 60g Yulaf, 1 Muz, 1 Tatlı Kaşığı Fıstık Ezmesi',
        'kalori': (hedefKalori * 0.30).round(),
        'protein': (bazProtein * 0.30).round(),
        'karb': (bazKarb * 0.35).round(),
        'yag': (bazYag * 0.30).round(),
        'tamamlandi': false,
      },
      {
        'id': 'ogun_2',
        'baslik': 'Öğle (Kas Yenileme & Kuvvet)',
        'besinler': '180g Tavuk Göğsü / Yağsız Dana Kıyma, 150g Haşlanmış Pirinç / Bulgur, Bol Yeşil Salata',
        'kalori': (hedefKalori * 0.35).round(),
        'protein': (bazProtein * 0.35).round(),
        'karb': (bazKarb * 0.40).round(),
        'yag': (bazYag * 0.35).round(),
        'tamamlandi': false,
      },
      {
        'id': 'ogun_3',
        'baslik': 'Akşam (Katabolizma Koruma)',
        'besinler': '160g Somon / Hindi / Biftek, Fırınlanmış Patates veya Tatlı Patates (150g), Buharda Brokoli',
        'kalori': (hedefKalori * 0.25).round(),
        'protein': (bazProtein * 0.25).round(),
        'karb': (bazKarb * 0.20).round(),
        'yag': (bazYag * 0.25).round(),
        'tamamlandi': false,
      },
      {
        'id': 'ogun_4',
        'baslik': 'Ara Öğün / Gece Toparlanması',
        'besinler': '200g Lor Peyniri / Süzme Yoğurt / Kazein, 1 Avuç Badem / Ceviz',
        'kalori': (hedefKalori * 0.10).round(),
        'protein': (bazProtein * 0.10).round(),
        'karb': (bazKarb * 0.05).round(),
        'yag': (bazYag * 0.10).round(),
        'tamamlandi': false,
      },
    ];

    SystemMemory.kaydet();
  }

  static void diyetisyenOgunDurumuGuncelle(String ogunId, bool tamamlandi) {
    for (var ogun in SystemMemory.diyetisyenOgunleri) {
      if (ogun['id'] == ogunId) {
        ogun['tamamlandi'] = tamamlandi;
        if (tamamlandi) {
          int k = (ogun['kalori'] as num?)?.toInt() ?? 0;
          int p = (ogun['protein'] as num?)?.toInt() ?? 0;
          int carb = (ogun['karb'] as num?)?.toInt() ?? 0;
          int y = (ogun['yag'] as num?)?.toInt() ?? 0;
          String b = ogun['baslik']?.toString() ?? 'Öğün';

          SystemMemory.bugunAlinanKalori += k;
          SystemMemory.bugununYemekleri.add(
            TuketilenYemek(b, k, protein: p, karbonhidrat: carb, yag: y),
          );
          AudioSystem.playSuccess();
        }
        break;
      }
    }
    SystemMemory.kaydet();
  }

  static void diyetisyenYeniOgunEkle(Map<String, dynamic> yeniOgun) {
    SystemMemory.diyetisyenOgunleri.add(yeniOgun);
    SystemMemory.kaydet();
  }

  static void diyetisyenOgunSil(String ogunId) {
    SystemMemory.diyetisyenOgunleri.removeWhere((o) => o['id'] == ogunId);
    SystemMemory.kaydet();
  }
}
