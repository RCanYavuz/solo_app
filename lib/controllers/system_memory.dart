// lib/controllers/system_memory.dart
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/audio_system.dart';
import '../models/task_model.dart';
import '../models/food_model.dart';

class SystemMemory {
  static bool kayitBulundu = false; 

  static ValueNotifier<int> hp = ValueNotifier(100);
  static ValueNotifier<int> mp = ValueNotifier(10);
  static ValueNotifier<int> fatigue = ValueNotifier(0); 

  static int maxHp = 100; static int maxMp = 10;
  static ValueNotifier<int> level = ValueNotifier(1);
  static ValueNotifier<int> exp = ValueNotifier(0);
  static ValueNotifier<int> maxExp = ValueNotifier(100);
  static ValueNotifier<int> ap = ValueNotifier(0); 

  static ValueNotifier<int> altin = ValueNotifier(0);

  static ValueNotifier<int> str = ValueNotifier(10);
  static ValueNotifier<int> agi = ValueNotifier(10);
  static ValueNotifier<int> vit = ValueNotifier(10);
  static ValueNotifier<int> intStat = ValueNotifier(10);
  static ValueNotifier<int> per = ValueNotifier(10);

  // YENİ: OYUNCU İSMİ
  static String oyuncuIsmi = "PLAYER";

  static Uint8List? profilFotoByte; 
  static DateTime? dogumTarihi;     
  static String cinsiyet = "Erkek";
  static double boy = 175; 
  static double kilo = 70; 

  static double baslangicKilosu = 0; 
  static int streakGunSayisi = 0;    
  static int bitenGorevSayisi = 0;   
  static List<Map<String, dynamic>> kiloGecmisi = [];

  static int toplamIdmanDakikasi = 0; 
  static List<Map<String, dynamic>> idmanGecmisi = [];

  static int gunlukHedefKalori = 0; 
  static String vucutSinifi = "Bilinmiyor";
  static String aktifHedef = "Bilinmiyor";
  static String aktifZorluk = "Bilinmiyor";

  static int bugunAlinanKalori = 0;    
  static List<TuketilenYemek> bugununYemekleri = [];
  static int uyunanSaat = 0;           

  static Map<int, List<Gorev>> haftalikPlan = { 1: [], 2: [], 3: [], 4: [], 5: [], 6: [], 7: [] };

  static ValueNotifier<int> bossHP = ValueNotifier(0);
  static int bossMaxHP = 0;
  static String bossTuru = "Fiziksel";
  static String bossIsim = "Unknown";

  static int get yas {
    if (dogumTarihi == null) return 20;
    DateTime bugun = DateTime.now();
    int hesaplananYas = bugun.year - dogumTarihi!.year;
    if (bugun.month < dogumTarihi!.month || (bugun.month == dogumTarihi!.month && bugun.day < dogumTarihi!.day)) hesaplananYas--;
    return hesaplananYas;
  }

  static Future<void> baslat() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (prefs.containsKey('level')) {
      kayitBulundu = true;
      
      hp.value = prefs.getInt('hp') ?? 100; mp.value = prefs.getInt('mp') ?? 10;
      maxHp = prefs.getInt('maxHp') ?? 100; maxMp = prefs.getInt('maxMp') ?? 10;
      level.value = prefs.getInt('level') ?? 1; exp.value = prefs.getInt('exp') ?? 0;
      maxExp.value = prefs.getInt('maxExp') ?? 100; ap.value = prefs.getInt('ap') ?? 0;
      altin.value = prefs.getInt('altin') ?? 0; 
      
      str.value = prefs.getInt('str') ?? 10; agi.value = prefs.getInt('agi') ?? 10;
      vit.value = prefs.getInt('vit') ?? 10; intStat.value = prefs.getInt('intStat') ?? 10;
      per.value = prefs.getInt('per') ?? 10;

      // YENİ: İSMİ OKU
      oyuncuIsmi = prefs.getString('oyuncuIsmi') ?? "PLAYER";

      cinsiyet = prefs.getString('cinsiyet') ?? "Erkek";
      boy = prefs.getDouble('boy') ?? 175; kilo = prefs.getDouble('kilo') ?? 70;
      
      baslangicKilosu = prefs.getDouble('baslangicKilosu') ?? kilo;
      streakGunSayisi = prefs.getInt('streakGunSayisi') ?? 0;
      bitenGorevSayisi = prefs.getInt('bitenGorevSayisi') ?? 0;

      String gecmisJson = prefs.getString('kiloGecmisi') ?? '[]';
      kiloGecmisi = List<Map<String, dynamic>>.from(jsonDecode(gecmisJson));

      toplamIdmanDakikasi = prefs.getInt('toplamIdmanDakikasi') ?? 0;
      String idmanJson = prefs.getString('idmanGecmisi') ?? '[]';
      idmanGecmisi = List<Map<String, dynamic>>.from(jsonDecode(idmanJson));

      gunlukHedefKalori = prefs.getInt('gunlukHedefKalori') ?? 0;
      vucutSinifi = prefs.getString('vucutSinifi') ?? "Unknown";
      aktifHedef = prefs.getString('aktifHedef') ?? "Unknown";
      aktifZorluk = prefs.getString('aktifZorluk') ?? "Unknown";
      
      String dtStr = prefs.getString('dogumTarihi') ?? '';
      if (dtStr.isNotEmpty) dogumTarihi = DateTime.parse(dtStr);

      String fotoB64 = prefs.getString('profilFoto') ?? '';
      if (fotoB64.isNotEmpty) profilFotoByte = base64Decode(fotoB64);

      bugunAlinanKalori = prefs.getInt('bugunAlinanKalori') ?? 0;
      uyunanSaat = prefs.getInt('uyunanSaat') ?? 0;

      String yemeklerJson = prefs.getString('bugununYemekleri') ?? '[]';
      List<dynamic> yList = jsonDecode(yemeklerJson);
      bugununYemekleri = yList.map((e) => TuketilenYemek.fromJson(e)).toList();

      String planJson = prefs.getString('haftalikPlan') ?? '{}';
      Map<String, dynamic> pMap = jsonDecode(planJson);
      pMap.forEach((key, value) { haftalikPlan[int.parse(key)] = (value as List).map((e) => Gorev.fromJson(e)).toList(); });
      
      bossGuncelle();
    }
  }

  static Future<void> kaydet() async {
    final prefs = await SharedPreferences.getInstance();
    
    prefs.setInt('hp', hp.value); prefs.setInt('mp', mp.value);
    prefs.setInt('maxHp', maxHp); prefs.setInt('maxMp', maxMp);
    prefs.setInt('level', level.value); prefs.setInt('exp', exp.value); prefs.setInt('maxExp', maxExp.value); prefs.setInt('ap', ap.value);
    prefs.setInt('altin', altin.value); 
    
    prefs.setInt('str', str.value); prefs.setInt('agi', agi.value); prefs.setInt('vit', vit.value); prefs.setInt('intStat', intStat.value); prefs.setInt('per', per.value);
    
    // YENİ: İSMİ KAYDET
    prefs.setString('oyuncuIsmi', oyuncuIsmi);

    prefs.setString('cinsiyet', cinsiyet); prefs.setDouble('boy', boy); prefs.setDouble('kilo', kilo);
    
    prefs.setDouble('baslangicKilosu', baslangicKilosu);
    prefs.setInt('streakGunSayisi', streakGunSayisi);
    prefs.setInt('bitenGorevSayisi', bitenGorevSayisi);
    prefs.setString('kiloGecmisi', jsonEncode(kiloGecmisi));

    prefs.setInt('toplamIdmanDakikasi', toplamIdmanDakikasi);
    prefs.setString('idmanGecmisi', jsonEncode(idmanGecmisi));

    prefs.setInt('gunlukHedefKalori', gunlukHedefKalori); prefs.setString('vucutSinifi', vucutSinifi);
    prefs.setString('aktifHedef', aktifHedef); prefs.setString('aktifZorluk', aktifZorluk);
    
    if (dogumTarihi != null) prefs.setString('dogumTarihi', dogumTarihi!.toIso8601String());
    if (profilFotoByte != null) prefs.setString('profilFoto', base64Encode(profilFotoByte!));

    prefs.setInt('bugunAlinanKalori', bugunAlinanKalori); prefs.setInt('uyunanSaat', uyunanSaat);
    prefs.setString('bugununYemekleri', jsonEncode(bugununYemekleri.map((e) => e.toJson()).toList()));
    
    Map<String, dynamic> planKayit = {};
    haftalikPlan.forEach((key, value) { planKayit[key.toString()] = value.map((e) => e.toJson()).toList(); });
    prefs.setString('haftalikPlan', jsonEncode(planKayit));

    bossGuncelle();
  }

  static String zindanAkiniBitir(int gecenSaniye) {
    int dakika = gecenSaniye ~/ 60;
    
    int bugun = DateTime.now().weekday;
    int bitenGorevSayisiSimdi = haftalikPlan[bugun]!.where((g) => g.yapildiMi).length;

    toplamIdmanDakikasi += dakika;
    idmanGecmisi.add({
      'tarih': DateTime.now().toIso8601String(),
      'dakika': dakika,
      'gorevSayisi': bitenGorevSayisiSimdi
    });

    int kazanilanAltin = dakika * 2; 
    altin.value += kazanilanAltin;
    
    kaydet();
    AudioSystem.playSuccess();
    
    return "[RAID COMPLETED]\nTime in Dungeon: $dakika Min\nQuests Completed: $bitenGorevSayisiSimdi\nTime Reward: +$kazanilanAltin Gold";
  }

  static void protokolGuncelle(String yeniHedef, String yeniZorluk) {
    aktifHedef = yeniHedef;
    aktifZorluk = yeniZorluk;

    double bmr = (cinsiyet == "Erkek") ? (10 * kilo) + (6.25 * boy) - (5 * yas) + 5 : (10 * kilo) + (6.25 * boy) - (5 * yas) - 161;
    double gunlukIhtiyac = bmr * 1.375;
    int kaloriFarki = 0;

    if (aktifHedef == "Kilo Ver (Yağ Yak)") { 
      if (aktifZorluk == "Normal") kaloriFarki = -500; 
      else if (aktifZorluk == "Yüksek") kaloriFarki = -1000; 
      else if (aktifZorluk == "Cehennem") kaloriFarki = -1500; 
    } 
    else if (aktifHedef == "Kilo Al (Kas İnşa Et)") { 
      if (aktifZorluk == "Normal") kaloriFarki = 300; 
      else if (aktifZorluk == "Yüksek") kaloriFarki = 500; 
      else if (aktifZorluk == "Canavar") kaloriFarki = 1000; 
    }

    gunlukHedefKalori = (gunlukIhtiyac + kaloriFarki).round();
    if (gunlukHedefKalori < 1200) gunlukHedefKalori = 1200; 
    
    kaydet();
  }

  static void bossGuncelle() {
    int bugun = DateTime.now().weekday;
    if (bugun == 7) { 
      if (bossMaxHP == 0 || bossMaxHP < level.value * 100) {
        bossMaxHP = level.value * 100;
        bossTuru = level.value % 2 == 0 ? "Zihinsel" : "Fiziksel";
        bossIsim = bossTuru == "Fiziksel" ? "Steel-Fanged Wolf (Beast)" : "Ancient Lich (Undead)";
      }

      int hasar = 0;
      for (var g in haftalikPlan[7]!) {
        if (g.yapildiMi) {
          if (g.tip == bossTuru) {
            hasar += (level.value * 25); 
          } else {
            hasar += (level.value * 5); 
          }
        }
      }

      if (bugunAlinanKalori > 0 && bugunAlinanKalori <= gunlukHedefKalori) {
        hasar += (level.value * 30); 
      }
      
      int kalan = bossMaxHP - hasar;
      bossHP.value = kalan < 0 ? 0 : kalan;
    } else {
      bossMaxHP = 0;
      bossHP.value = 0;
    }
  }

  static void oyuncuyuAnalizEt(String secilenCinsiyet, DateTime girilenDogumTarihi, double girilenBoy, double girilenKilo, String hedef, String zorluk, Uint8List? foto) {
    cinsiyet = secilenCinsiyet; dogumTarihi = girilenDogumTarihi; boy = girilenBoy; kilo = girilenKilo;
    aktifHedef = hedef; aktifZorluk = zorluk; if (foto != null) profilFotoByte = foto;

    if (baslangicKilosu == 0) {
      baslangicKilosu = kilo;
      kiloGecmisi.add({ 'tarih': DateTime.now().toIso8601String(), 'kilo': kilo, 'kalori': bugunAlinanKalori });
    }

    double boyMetre = boy / 100; double bmi = kilo / (boyMetre * boyMetre);
    if (bmi < 18.5) vucutSinifi = "Underweight"; else if (bmi < 24.9) vucutSinifi = "Normal"; else if (bmi < 29.9) vucutSinifi = "Overweight"; else vucutSinifi = "Obese";

    double bmr = (cinsiyet == "Erkek") ? (10 * kilo) + (6.25 * boy) - (5 * yas) + 5 : (10 * kilo) + (6.25 * boy) - (5 * yas) - 161;
    double gunlukIhtiyac = bmr * 1.375;
    int kaloriFarki = 0;

    if (hedef == "Kilo Ver (Yağ Yak)") { if (zorluk == "Normal") kaloriFarki = -500; else if (zorluk == "Yüksek") kaloriFarki = -1000; else if (zorluk == "Cehennem") kaloriFarki = -1500; } 
    else if (hedef == "Kilo Al (Kas İnşa Et)") { if (zorluk == "Normal") kaloriFarki = 300; else if (zorluk == "Yüksek") kaloriFarki = 500; else if (zorluk == "Canavar") kaloriFarki = 1000; }

    gunlukHedefKalori = (gunlukIhtiyac + kaloriFarki).round();
    if (gunlukHedefKalori < 1200) gunlukHedefKalori = 1200; 
    
    kaydet();
  }

  static String tartiGuncelle(double yeniKilo) {
    double eskiKilo = kilo;
    double fark = eskiKilo - yeniKilo; 
    
    oyuncuyuAnalizEt(cinsiyet, dogumTarihi!, boy, yeniKilo, aktifHedef, aktifZorluk, profilFotoByte);
    kiloGecmisi.add({ 'tarih': DateTime.now().toIso8601String(), 'kilo': yeniKilo, 'kalori': bugunAlinanKalori });
    
    if (fark == 0) return "[SYSTEM] No change in body mass detected.";

    String rapor = "";
    if (aktifHedef == 'Kilo Ver (Yağ Yak)') {
      if (fark > 0) { 
        int kazanilanAltin = (fark * 500).toInt();
        int kazanilanAP = fark.toInt();
        if (kazanilanAP < 1) kazanilanAP = 1; 
        altin.value += kazanilanAltin;
        ap.value += kazanilanAP;
        rapor = "[ACHIEVEMENT UNLOCKED] $fark kg mass shed!\nREWARD: +$kazanilanAltin Gold | +$kazanilanAP AP";
        AudioSystem.playSuccess();
      } else { 
        hp.value -= 20; if(hp.value < 0) hp.value = 0;
        rapor = "[SYSTEM WARNING] ${fark.abs()} kg mass regained. Discipline violated!\nPENALTY: -20 HP";
      }
    } 
    else if (aktifHedef == 'Kilo Al (Kas İnşa Et)') {
      if (fark < 0) { 
        double alinan = fark.abs();
        int kazanilanAltin = (alinan * 500).toInt();
        int kazanilanAP = alinan.toInt();
        if (kazanilanAP < 1) kazanilanAP = 1;
        altin.value += kazanilanAltin;
        ap.value += kazanilanAP;
        rapor = "[ACHIEVEMENT UNLOCKED] $alinan kg muscle built!\nREWARD: +$kazanilanAltin Gold | +$kazanilanAP AP";
        AudioSystem.playSuccess();
      } else { 
        hp.value -= 20; if(hp.value < 0) hp.value = 0;
        rapor = "[SYSTEM WARNING] $fark kg mass lost. Insufficient nutrition!\nPENALTY: -20 HP";
      }
    } else {
      rapor = "[SYSTEM] Weight updated. Maintain the balance.";
    }
    kaydet();
    return rapor;
  }

  static String expKazan(int miktar) {
    exp.value += miktar; String levelUpMesaji = "";
    while (exp.value >= maxExp.value) {
      exp.value -= maxExp.value; level.value++; maxExp.value = (maxExp.value * 1.5).round(); ap.value += 3; 
      hp.value = maxHp; mp.value = maxMp; fatigue.value = 0;
      levelUpMesaji += "\n🌟 LEVEL UP! You reached Level ${level.value}! (+3 AP)\n[INFO] Status Recovery applied.";
      AudioSystem.playLevelUp();
    }
    kaydet(); 
    return levelUpMesaji;
  }

  static String gunSonuHesaplasmasi() {
    String rapor = ""; int hpFarki = 0; int mpFarki = 0; int kazanilanExp = 0;
    int kazanilanSTR = 0; int kazanilanAGI = 0; int kazanilanVIT = 0; int kazanilanINT = 0; int kazanilanPER = 0;
    int kazanilanAltin = 0; 

    if (bugunAlinanKalori > gunlukHedefKalori) { hpFarki -= 20; rapor += "[PENALTY] Calorie Limit Exceeded: -20 HP\n"; } 
    else { hpFarki += 10; kazanilanExp += 20; kazanilanVIT += 1; kazanilanAltin += 20; rapor += "[REWARD] Ideal Diet: +10 HP, +20 EXP, +1 VIT, +20 G\n"; }

    if (uyunanSaat < 7) { mpFarki -= 4; rapor += "[PENALTY] Insufficient Sleep: -4 MP\n"; } 
    else { mpFarki += 2; kazanilanExp += 10; kazanilanVIT += 1; kazanilanAltin += 10; rapor += "[REWARD] Solid Rest: +2 MP, +10 EXP, +1 VIT, +10 G\n"; }

    int bugun = DateTime.now().weekday;
    List<Gorev> bugununProgrami = haftalikPlan[bugun]!;
    
    int topFiziksel = 0; int bitenFiziksel = 0; int topZihinsel = 0; int bitenZihinsel = 0;
    int strGorevleri = 0; int agiGorevleri = 0; int intGorevleri = 0; int perGorevleri = 0;

    for (var g in bugununProgrami) { 
      if (g.tip == "Fiziksel") { 
        topFiziksel++; 
        if (g.yapildiMi) { 
          bitenFiziksel++; 
          if (g.ad.contains("Kardiyo") || g.ad.contains("Bacak") || g.ad.contains("Kalf")) agiGorevleri++;
          else strGorevleri++;
        } 
      } else { 
        topZihinsel++; 
        if (g.yapildiMi) { 
          bitenZihinsel++; 
          if (g.ad.contains("Meditasyon") || g.ad.contains("Strateji")) perGorevleri++;
          else intGorevleri++; 
        } 
      } 
    }

    int toplamGorev = topFiziksel + topZihinsel;
    int toplamBiten = bitenFiziksel + bitenZihinsel;
    bitenGorevSayisi += toplamBiten; 

    if (toplamGorev > 0) {
      if (toplamBiten == toplamGorev) {
        streakGunSayisi++;
        rapor += "[STREAK] Flawless Day Streak: $streakGunSayisi Days!\n";
      } else {
        streakGunSayisi = 0;
        rapor += "[STREAK BROKEN] Discipline lost, Streak reset.\n";
      }
    }

    if (bugun == 7) {
      bossGuncelle(); 
      if (bossHP.value <= 0 && bossMaxHP > 0) {
        kazanilanAltin += 1000;
        ap.value += 2;
        kazanilanExp += 500;
        rapor += "\n[BOSS DEFEATED] $bossIsim was annihilated!\nREWARD: +1000 G | +2 AP | +500 EXP\n";
        AudioSystem.playSuccess();
      } else if (bossMaxHP > 0) {
        int cezaHp = (hp.value / 2).round();
        hpFarki -= cezaHp; 
        rapor += "\n[DUNGEON DEFEAT] $bossIsim heavily wounded you!\nPENALTY: -$cezaHp HP\n";
      }
    }

    if (topFiziksel > 0) {
      int kacan = topFiziksel - bitenFiziksel; 
      hpFarki += (bitenFiziksel * 15); kazanilanExp += (bitenFiziksel * 25); hpFarki -= (kacan * 15); 
      kazanilanAltin += (bitenFiziksel * 50); 
      
      if (strGorevleri > 0) kazanilanSTR += 1;
      if (agiGorevleri > 0) kazanilanAGI += 1;

      String statMesaji = "";
      if (kazanilanSTR > 0) statMesaji += "+$kazanilanSTR STR ";
      if (kazanilanAGI > 0) statMesaji += "+$kazanilanAGI AGI ";

      if (kacan == 0 && bitenFiziksel > 0) { 
        kazanilanVIT += 1; kazanilanAltin += 50; 
        statMesaji += "+1 VIT ";
        rapor += "[REWARD] Flawless Workout: +${bitenFiziksel*15} HP, $statMesaji, +${(bitenFiziksel*50)+50} G\n"; 
      } 
      else if (bitenFiziksel > 0) { 
        rapor += "[INFO] Partial Workout: +${bitenFiziksel*15} HP, -${kacan*15} HP, $statMesaji, +${bitenFiziksel*50} G\n"; 
      } 
      else { rapor += "[PENALTY] Workout Neglected: -${kacan*15} HP\n"; }
    }

    if (topZihinsel > 0) {
      int kacan = topZihinsel - bitenZihinsel; 
      mpFarki += (bitenZihinsel * 5); kazanilanExp += (bitenZihinsel * 20); mpFarki -= (kacan * 5); 
      kazanilanAltin += (bitenZihinsel * 30); 
      
      if (intGorevleri > 0) kazanilanINT += 1;
      if (perGorevleri > 0) kazanilanPER += 1;

      String statMesaji = "";
      if (kazanilanINT > 0) statMesaji += "+$kazanilanINT INT ";
      if (kazanilanPER > 0) statMesaji += "+$kazanilanPER PER ";

      if (kacan == 0 && bitenZihinsel > 0) { 
        kazanilanAltin += 30;
        rapor += "[REWARD] Flawless Mental Training: +${bitenZihinsel*5} MP, $statMesaji, +${(bitenZihinsel*30)+30} G\n"; 
      } 
      else if (bitenZihinsel > 0) { 
        rapor += "[INFO] Partial Mental Training: +${bitenZihinsel*5} MP, -${kacan*5} MP, $statMesaji, +${bitenZihinsel*30} G\n"; 
      } 
      else { rapor += "[PENALTY] Mind Neglected: -${kacan*5} MP\n"; }
    }

    hp.value += hpFarki; if (hp.value > maxHp) hp.value = maxHp; if (hp.value < 0) hp.value = 0;         
    mp.value += mpFarki; if (mp.value > maxMp) mp.value = maxMp; if (mp.value < 0) mp.value = 0;
    altin.value += kazanilanAltin; 

    str.value += kazanilanSTR; agi.value += kazanilanAGI; vit.value += kazanilanVIT; intStat.value += kazanilanINT; per.value += kazanilanPER;
    maxHp += (kazanilanVIT * 10); maxMp += (kazanilanINT * 2);

    String levelRaporu = expKazan(kazanilanExp);

    bugunAlinanKalori = 0; bugununYemekleri.clear(); uyunanSaat = 0;
    for (var g in bugununProgrami) { g.yapildiMi = false; }

    kaydet(); 
    return "$rapor\n[QUEST LOG]\nNET HP: ${hpFarki > 0 ? '+' : ''}$hpFarki | GOLD EARNED: $kazanilanAltin 🪙 | EXP EARNED: $kazanilanExp$levelRaporu";
  }

  static void statuYukselt(String statAdi) {
    if (ap.value > 0) {
      ap.value--;
      if (statAdi == 'STR') str.value++; else if (statAdi == 'AGI') agi.value++;
      else if (statAdi == 'VIT') { vit.value++; maxHp += 10; hp.value += 10; } 
      else if (statAdi == 'INT') { intStat.value++; maxMp += 2; mp.value += 2; } 
      else if (statAdi == 'PER') per.value++;
      kaydet(); 
    } 
  }

  static void acilSifa() { hp.value = maxHp; kaydet(); }
  static void tamMana() { mp.value = maxMp; kaydet(); }
  static void statuleriSifirla() {
    int geriVerilecekAP = (str.value - 10) + (agi.value - 10) + (vit.value - 10) + (intStat.value - 10) + (per.value - 10);
    ap.value += geriVerilecekAP;
    str.value = 10; agi.value = 10; vit.value = 10; intStat.value = 10; per.value = 10;
    maxHp = 100; maxMp = 10;
    if (hp.value > maxHp) hp.value = maxHp;
    if (mp.value > maxMp) mp.value = maxMp;
    kaydet();
  }
}