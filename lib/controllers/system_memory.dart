// lib/controllers/system_memory.dart
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../core/audio_system.dart';
import '../models/task_model.dart';
import '../models/food_model.dart';
import '../models/inventory_item_model.dart';
import '../core/services/gemini_service.dart';
import '../core/advanced_metabolic_engine.dart';
import '../core/progressive_overload_engine.dart';
import '../core/supplement_engine.dart';

class SystemMemory {
  static bool get _isTest {
    if (kIsWeb) return false;
    try {
      return Platform.environment.containsKey('FLUTTER_TEST');
    } catch (_) {
      return false;
    }
  }

  static bool kayitBulundu = false; 

  static bool golgeModuAktif = false;
  
  static ValueNotifier<String> appLanguage = ValueNotifier('en');

  // ==========================================
  // ÖZELLEŞTİRİLEBİLİR KIRMIZI GEÇİT (RED GATE)
  // ==========================================
  static bool redGateAktif = false;
  static int redGateKalanGun = 0;
  static int redGateToplamGun = 0; 
  static int normalGunlukHedefKalori = 0;
  static Map<int, List<Gorev>> normalHaftalikPlan = {};

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

  static String oyuncuIsmi = "PLAYER";
  static String geminiApiKey = "";
  static String geminiActiveModel = "gemini-3.6-flash";

  // SU TAKİBİ (HYDRATION CORE)
  static int suHedefiMl = 3000;
  static ValueNotifier<int> bugunIcilenSuMl = ValueNotifier(0);

  // AVCI ÇANTASI (INVENTORY) & GÜNLÜK BUFFLAR
  static List<InventoryItem> canta = [];
  static bool bugunCheatMealAktif = false;
  static bool bugunSlothDayAktif = false;
  static bool bugunGamingPassAktif = false;

  // MAKRO BESİN DİNAMİK HESAPLAYICILARI
  static int get bugunProtein => bugununYemekleri.fold(0, (sum, item) => sum + item.protein);
  static int get bugunKarb => bugununYemekleri.fold(0, (sum, item) => sum + item.karbonhidrat);
  static int get bugunYag => bugununYemekleri.fold(0, (sum, item) => sum + item.yag);

  static String sonGirisTarihi = "";
  static String geceRaporu = ""; 

  static Uint8List? profilFotoByte; 
  static Uint8List? avatarFotoByte;
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
  static List<Map<String, dynamic>> yemekGecmisi = [];

  static int gunlukHedefKalori = 0; 
  static String vucutSinifi = "Bilinmiyor";
  static String aktifHedef = "Bilinmiyor";
  static String aktifZorluk = "Bilinmiyor";

  // --- AWAKENING TEST & RETEST SİSTEMİ ---
  static double maxBench = 0.0;
  static double maxSquat = 0.0;
  static double maxDeadlift = 0.0;
  static String hunterRank = "Unranked";
  static String ekipmanTuru = "Salon"; // 'Salon', 'Ev-Dambil', 'Vucut-Agirligi'
  static String antrenmanGecmisi = "Başlangıç"; // 'Başlangıç', 'Orta', 'İleri'
  static List<String> eklemKisiti = [];
  static List<String> odakBolgeleri = []; // Öncelikli Odak & Yağ Yakım Bölgeleri
  static String sonTestTarihi = "";
  static int sonTesttenBeriIdmanSayisi = 0;

  // Dövüş Sporları & Boksör Profili
  static bool dovusSporuYapiyorMu = false;
  static String dovusBransi = "Boks"; // 'Boks', 'Kickboks', 'MMA', 'Güreş'
  static List<String> dovusBranslari = ["Boks"]; // Birden fazla branş desteği
  static int maxPatlayiciSinav = 0;
  static int maxBurpeeKondisyon = 0;
  static int maxPlankSaniye = 0;
  static int maxBarfiks = 0;

  // Detaylı Vücut Ölçümleri (Full Body Tracking cm)
  static double gogusCm = 0.0;
  static double belCm = 0.0;
  static double kolCm = 0.0;
  static double bacakCm = 0.0;

  // ==========================================
  // FAZ 2: DİYETİSYEN LİSTESİ & DİNAMİK İDMAN YIPRANMA TELAFİSİ
  // ==========================================
  static bool diyetisyenListesiAktif = false;
  static int diyetisyenBazKalori = 0;
  static int diyetisyenBazProtein = 0;
  static int diyetisyenBazKarb = 0;
  static int diyetisyenBazYag = 0;
  static List<Map<String, dynamic>> diyetisyenOgunleri = [];
  static bool get dovuscuMu => dovusSporuYapiyorMu;
  static set dovuscuMu(bool val) => dovusSporuYapiyorMu = val;

  static int get haftalikIdmanGunuSayisi {
    int count = haftalikPlan.values.where((list) => list.isNotEmpty).length;
    return count > 0 ? count : 4;
  }

  // Günlük İdman Yıpranma & Telafi Havuzu
  static int bugunYakilanIdmanKalorisi = 0;
  static int bugunTelafiProteini = 0;
  static int bugunTelafiKarbonhidrati = 0;
  static Map<String, dynamic>? sonIdmanYipranmaRaporu;

  static BodyCompositionResult get guncelVucutKompozisyonu =>
      AdvancedMetabolicEngine.hesaplaVucutKompozisyonu(
        boyCm: boy > 0 ? boy : 178.0,
        kiloKg: kilo > 0 ? kilo : 75.0,
        cinsiyet: cinsiyet.isNotEmpty ? cinsiyet : 'erkek',
        belCm: belCm > 0 ? belCm : 82.0,
        haftalikIdmanSayisi: haftalikIdmanGunuSayisi,
        dovuscuMu: dovusSporuYapiyorMu,
      );

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
      kiloKg: kilo > 0 ? kilo : 70.0,
      idmanTuru: idmanTuru,
      rpeZorluk: rpeZorluk,
    );

    bugunYakilanIdmanKalorisi += sonuc.yakilanKalori;
    bugunTelafiProteini += sonuc.telafiProteiniGram;
    bugunTelafiKarbonhidrati += sonuc.telafiKarbonhidratiGram;
    sonIdmanYipranmaRaporu = {
      'idmanTuru': idmanTuru,
      'dakika': dakika,
      'yakilanKalori': sonuc.yakilanKalori,
      'telafiProteini': sonuc.telafiProteiniGram,
      'telafiKarbonhidrati': sonuc.telafiKarbonhidratiGram,
      'katabolizmaRiski': sonuc.katabolizmaSeviyesi,
      'sistemUyarisi': sonuc.sistemUyarisi,
      'tarih': DateTime.now().toIso8601String(),
    };
    kaydet();
    return sonuc;
  }

  static void diyetisyenListesiniKaydet({
    required int kalori,
    required int protein,
    required int karb,
    required int yag,
    List<Map<String, dynamic>> ogunler = const [],
  }) {
    diyetisyenListesiAktif = true;
    diyetisyenBazKalori = kalori;
    diyetisyenBazProtein = protein;
    diyetisyenBazKarb = karb;
    diyetisyenBazYag = yag;
    diyetisyenOgunleri = List<Map<String, dynamic>>.from(ogunler);

    gunlukHedefKalori = kalori;
    kaydet();
  }

  static void diyetisyenListesiniSifirla() {
    diyetisyenListesiAktif = false;
    diyetisyenBazKalori = 0;
    diyetisyenBazProtein = 0;
    diyetisyenBazKarb = 0;
    diyetisyenBazYag = 0;
    diyetisyenOgunleri = [];
    protokolGuncelle(aktifHedef, aktifZorluk);
    kaydet();
  }

  // ==========================================
  // HEDEF KİLO & KULLANICI STRATEJİ ENTEGRASYONU
  // ==========================================
  static double hedefKilo = 0.0;
  static String avciDiyetNotu = "";
  static String sonAiHedefKiloYorumu = "";

  static double get hedefKiloIlerlemeYuzdesi {
    if (baslangicKilosu == 0 || hedefKilo == 0 || baslangicKilosu == hedefKilo) return 0.0;
    double toplamHedeflenenFark = (baslangicKilosu - hedefKilo).abs();
    double suAnaKadarVerilenFark = (baslangicKilosu - kilo).abs();
    if (toplamHedeflenenFark <= 0) return 0.0;
    return (suAnaKadarVerilenFark / toplamHedeflenenFark).clamp(0.0, 1.0);
  }

  static void hedefleriSistemeEntegreEt({
    required double yeniHedefKilo,
    required int yeniKalori,
    String? not,
    Map<String, int>? makrolar,
  }) {
    hedefKilo = yeniHedefKilo;
    gunlukHedefKalori = yeniKalori;
    normalGunlukHedefKalori = yeniKalori;
    if (not != null && not.trim().isNotEmpty) {
      avciDiyetNotu = not.trim();
    }
    kaydet();
  }

  static int get rankIcinGerekliIdmanKotasi {
    final r = hunterRank.toUpperCase();
    if (r.startsWith('E')) return 8;
    if (r.startsWith('D')) return 12;
    if (r.startsWith('C')) return 16;
    if (r.startsWith('B')) return 24;
    if (r.startsWith('A') || r.startsWith('S')) return 32;
    return 8;
  }

  static bool get retestGerekiyorMu {
    if (hunterRank == "Unranked") return false;
    return sonTesttenBeriIdmanSayisi >= rankIcinGerekliIdmanKotasi;
  }

  static double get retestIlerlemeYuzdesi {
    if (rankIcinGerekliIdmanKotasi <= 0) return 1.0;
    return (sonTesttenBeriIdmanSayisi / rankIcinGerekliIdmanKotasi).clamp(0.0, 1.0);
  }

  static int bugunAlinanKalori = 0;    
  static List<TuketilenYemek> bugununYemekleri = [];
  static int uyunanSaat = 0;           

  static Map<int, List<Gorev>> haftalikPlan = { 1: [], 2: [], 3: [], 4: [], 5: [], 6: [], 7: [] };
  static Map<String, OverloadKaydi> overloadGecmisi = {};
  static List<String> kusanilanSuplementler = [];
  static ValueNotifier<bool> sesliKocAktif = ValueNotifier(true);

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
      
      golgeModuAktif = prefs.getBool('golgeModuAktif') ?? false;
      redGateAktif = prefs.getBool('redGateAktif') ?? false;
      redGateKalanGun = prefs.getInt('redGateKalanGun') ?? 0;
      redGateToplamGun = prefs.getInt('redGateToplamGun') ?? 0;
      normalGunlukHedefKalori = prefs.getInt('normalGunlukHedefKalori') ?? 0;
      
      hp.value = prefs.getInt('hp') ?? 100; mp.value = prefs.getInt('mp') ?? 10;
      maxHp = prefs.getInt('maxHp') ?? 100; maxMp = prefs.getInt('maxMp') ?? 10;
      level.value = prefs.getInt('level') ?? 1; exp.value = prefs.getInt('exp') ?? 0;
      maxExp.value = prefs.getInt('maxExp') ?? 100; ap.value = prefs.getInt('ap') ?? 0;
      altin.value = prefs.getInt('altin') ?? 0; 
      
      str.value = prefs.getInt('str') ?? 10; agi.value = prefs.getInt('agi') ?? 10;
      vit.value = prefs.getInt('vit') ?? 10; intStat.value = prefs.getInt('intStat') ?? 10;
      per.value = prefs.getInt('per') ?? 10;

      oyuncuIsmi = prefs.getString('oyuncuIsmi') ?? "PLAYER";
      appLanguage.value = prefs.getString('appLanguage') ?? "en";
      if (!_isTest) {
        try {
          const secureStorage = FlutterSecureStorage();
          geminiApiKey = await secureStorage.read(key: 'gemini_api_key') ?? prefs.getString('gemini_api_key') ?? "";
        } catch (_) {
          geminiApiKey = prefs.getString('gemini_api_key') ?? "";
        }
      } else {
        geminiApiKey = prefs.getString('gemini_api_key') ?? "";
      }
      final savedModel = prefs.getString('gemini_active_model');
      if (savedModel != null && savedModel.isNotEmpty) {
        geminiActiveModel = savedModel;
      } else {
        geminiActiveModel = "gemini-3.6-flash";
      }
      sonGirisTarihi = prefs.getString('sonGirisTarihi') ?? "";

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

      String yGecmisJson = prefs.getString('yemekGecmisi') ?? '[]';
      yemekGecmisi = List<Map<String, dynamic>>.from(jsonDecode(yGecmisJson));

      gunlukHedefKalori = prefs.getInt('gunlukHedefKalori') ?? 0;
      vucutSinifi = prefs.getString('vucutSinifi') ?? "Unknown";
      aktifHedef = prefs.getString('aktifHedef') ?? "Unknown";
      aktifZorluk = prefs.getString('aktifZorluk') ?? "Unknown";
      
      maxBench = prefs.getDouble('maxBench') ?? 0.0;
      maxSquat = prefs.getDouble('maxSquat') ?? 0.0;
      maxDeadlift = prefs.getDouble('maxDeadlift') ?? 0.0;
      hunterRank = prefs.getString('hunterRank') ?? "Unranked";
      ekipmanTuru = prefs.getString('ekipmanTuru') ?? "Salon";
      antrenmanGecmisi = prefs.getString('antrenmanGecmisi') ?? "Başlangıç";
      eklemKisiti = prefs.getStringList('eklemKisiti') ?? [];
      odakBolgeleri = prefs.getStringList('odakBolgeleri') ?? [];
      sonTestTarihi = prefs.getString('sonTestTarihi') ?? "";
      sonTesttenBeriIdmanSayisi = prefs.getInt('sonTesttenBeriIdmanSayisi') ?? 0;

      dovusSporuYapiyorMu = prefs.getBool('dovusSporuYapiyorMu') ?? false;
      dovusBransi = prefs.getString('dovusBransi') ?? "Boks";
      dovusBranslari = prefs.getStringList('dovusBranslari') ?? (dovusBransi.isNotEmpty ? [dovusBransi] : ["Boks"]);
      maxPatlayiciSinav = prefs.getInt('maxPatlayiciSinav') ?? 0;
      maxBurpeeKondisyon = prefs.getInt('maxBurpeeKondisyon') ?? 0;
      maxPlankSaniye = prefs.getInt('maxPlankSaniye') ?? 0;
      maxBarfiks = prefs.getInt('maxBarfiks') ?? 0;
      gogusCm = prefs.getDouble('gogusCm') ?? 0.0;
      belCm = prefs.getDouble('belCm') ?? 0.0;
      kolCm = prefs.getDouble('kolCm') ?? 0.0;
      bacakCm = prefs.getDouble('bacakCm') ?? 0.0;
      
      String dtStr = prefs.getString('dogumTarihi') ?? '';
      if (dtStr.isNotEmpty) dogumTarihi = DateTime.parse(dtStr);

      String fotoB64 = prefs.getString('profilFoto') ?? '';
      if (fotoB64.isNotEmpty) profilFotoByte = base64Decode(fotoB64);
      
      String avatarB64 = prefs.getString('avatarFoto') ?? '';
      if (avatarB64.isNotEmpty) avatarFotoByte = base64Decode(avatarB64);

      bugunAlinanKalori = prefs.getInt('bugunAlinanKalori') ?? 0;
      uyunanSaat = prefs.getInt('uyunanSaat') ?? 0;

      String yemeklerJson = prefs.getString('bugununYemekleri') ?? '[]';
      List<dynamic> yList = jsonDecode(yemeklerJson);
      bugununYemekleri = yList.map((e) => TuketilenYemek.fromJson(e)).toList();

      String planJson = prefs.getString('haftalikPlan') ?? '{}';
      Map<String, dynamic> pMap = jsonDecode(planJson);
      pMap.forEach((key, value) { haftalikPlan[int.parse(key)] = (value as List).map((e) => Gorev.fromJson(e)).toList(); });
      
      String normalPlanJson = prefs.getString('normalHaftalikPlan') ?? '{}';
      Map<String, dynamic> npMap = jsonDecode(normalPlanJson);
      npMap.forEach((key, value) { normalHaftalikPlan[int.parse(key)] = (value as List).map((e) => Gorev.fromJson(e)).toList(); });

      // Su ve Envanter Yükle
      suHedefiMl = prefs.getInt('suHedefiMl') ?? 3000;
      bugunIcilenSuMl.value = prefs.getInt('bugunIcilenSuMl') ?? prefs.getInt('bugunIçilenSuMl') ?? 0;
      bugunCheatMealAktif = prefs.getBool('bugunCheatMealAktif') ?? false;
      bugunSlothDayAktif = prefs.getBool('bugunSlothDayAktif') ?? false;
      bugunGamingPassAktif = prefs.getBool('bugunGamingPassAktif') ?? false;

      String cantaJson = prefs.getString('canta') ?? '[]';
      List<dynamic> cList = jsonDecode(cantaJson);
      canta = cList.map((e) => InventoryItem.fromJson(e)).toList();

      hedefKilo = prefs.getDouble('hedefKilo') ?? (kilo > 0 ? (aktifHedef.contains('Kilo Al') ? kilo + 4 : kilo - 5) : 70.0);
      avciDiyetNotu = prefs.getString('avciDiyetNotu') ?? "";
      sonAiHedefKiloYorumu = prefs.getString('sonAiHedefKiloYorumu') ?? "";
      diyetisyenListesiAktif = prefs.getBool('diyetisyenListesiAktif') ?? false;
      diyetisyenBazKalori = prefs.getInt('diyetisyenBazKalori') ?? 0;
      diyetisyenBazProtein = prefs.getInt('diyetisyenBazProtein') ?? 0;
      diyetisyenBazKarb = prefs.getInt('diyetisyenBazKarb') ?? 0;
      diyetisyenBazYag = prefs.getInt('diyetisyenBazYag') ?? 0;
      String dOgunlerJson = prefs.getString('diyetisyenOgunleri') ?? '[]';
      try {
        List<dynamic> doList = jsonDecode(dOgunlerJson);
        diyetisyenOgunleri = doList.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      } catch (_) {}

      String overloadJson = prefs.getString('overloadGecmisi') ?? '{}';
      try {
        Map<String, dynamic> oMap = jsonDecode(overloadJson);
        overloadGecmisi = oMap.map((key, value) => MapEntry(key, OverloadKaydi.fromJson(value)));
      } catch (_) {}

      kusanilanSuplementler = prefs.getStringList('kusanilanSuplementler') ?? [];
      sesliKocAktif.value = prefs.getBool('sesliKocAktif') ?? true;
      suHedefiGuncelle();

      bossGuncelle();
    }
  }

  static Future<void> kaydet() async {
    final prefs = await SharedPreferences.getInstance();
    
    prefs.setBool('golgeModuAktif', golgeModuAktif);
    prefs.setBool('redGateAktif', redGateAktif);
    prefs.setInt('redGateKalanGun', redGateKalanGun);
    prefs.setInt('redGateToplamGun', redGateToplamGun);
    prefs.setInt('normalGunlukHedefKalori', normalGunlukHedefKalori);
    
    prefs.setInt('hp', hp.value); prefs.setInt('mp', mp.value);
    prefs.setInt('maxHp', maxHp); prefs.setInt('maxMp', maxMp);
    prefs.setInt('level', level.value); prefs.setInt('exp', exp.value); prefs.setInt('maxExp', maxExp.value); prefs.setInt('ap', ap.value);
    prefs.setInt('altin', altin.value); 
    
    prefs.setInt('str', str.value); prefs.setInt('agi', agi.value); prefs.setInt('vit', vit.value); prefs.setInt('intStat', intStat.value); prefs.setInt('per', per.value);
    
    prefs.setString('oyuncuIsmi', oyuncuIsmi);
    prefs.setString('sonGirisTarihi', sonGirisTarihi);

    prefs.setString('cinsiyet', cinsiyet); prefs.setDouble('boy', boy); prefs.setDouble('kilo', kilo);
    prefs.setDouble('hedefKilo', hedefKilo);
    prefs.setString('avciDiyetNotu', avciDiyetNotu);
    prefs.setString('sonAiHedefKiloYorumu', sonAiHedefKiloYorumu);
    prefs.setBool('diyetisyenListesiAktif', diyetisyenListesiAktif);
    prefs.setInt('diyetisyenBazKalori', diyetisyenBazKalori);
    prefs.setInt('diyetisyenBazProtein', diyetisyenBazProtein);
    prefs.setInt('diyetisyenBazKarb', diyetisyenBazKarb);
    prefs.setInt('diyetisyenBazYag', diyetisyenBazYag);
    prefs.setString('diyetisyenOgunleri', jsonEncode(diyetisyenOgunleri));
    
    prefs.setDouble('baslangicKilosu', baslangicKilosu);
    prefs.setInt('streakGunSayisi', streakGunSayisi);
    prefs.setInt('bitenGorevSayisi', bitenGorevSayisi);
    prefs.setString('kiloGecmisi', jsonEncode(kiloGecmisi));

    prefs.setInt('toplamIdmanDakikasi', toplamIdmanDakikasi);
    prefs.setString('idmanGecmisi', jsonEncode(idmanGecmisi));
    prefs.setString('yemekGecmisi', jsonEncode(yemekGecmisi));

    prefs.setInt('gunlukHedefKalori', gunlukHedefKalori);    prefs.setString('vucutSinifi', vucutSinifi);
    prefs.setString('aktifHedef', aktifHedef);
    prefs.setString('aktifZorluk', aktifZorluk);

    prefs.setDouble('maxBench', maxBench);
    prefs.setDouble('maxSquat', maxSquat);
    prefs.setDouble('maxDeadlift', maxDeadlift);
    prefs.setString('hunterRank', hunterRank);
    prefs.setString('ekipmanTuru', ekipmanTuru);
    prefs.setString('antrenmanGecmisi', antrenmanGecmisi);
    prefs.setStringList('eklemKisiti', eklemKisiti);
    prefs.setStringList('odakBolgeleri', odakBolgeleri);
    prefs.setString('sonTestTarihi', sonTestTarihi);
    prefs.setInt('sonTesttenBeriIdmanSayisi', sonTesttenBeriIdmanSayisi);
    prefs.setBool('dovusSporuYapiyorMu', dovusSporuYapiyorMu);
    prefs.setString('dovusBransi', dovusBransi);
    prefs.setStringList('dovusBranslari', dovusBranslari);
    prefs.setInt('maxPatlayiciSinav', maxPatlayiciSinav);
    prefs.setInt('maxBurpeeKondisyon', maxBurpeeKondisyon);
    prefs.setInt('maxPlankSaniye', maxPlankSaniye);
    prefs.setInt('maxBarfiks', maxBarfiks);
    prefs.setDouble('gogusCm', gogusCm);
    prefs.setDouble('belCm', belCm);
    prefs.setDouble('kolCm', kolCm);
    prefs.setDouble('bacakCm', bacakCm);
    await prefs.setString('oyuncuIsmi', oyuncuIsmi);
    await prefs.setString('appLanguage', appLanguage.value);
    await prefs.setString('gemini_api_key', geminiApiKey);
    if (!_isTest) {
      try {
        const secureStorage = FlutterSecureStorage();
        await secureStorage.write(key: 'gemini_api_key', value: geminiApiKey);
      } catch (_) {}
    }
    prefs.setString('gemini_active_model', geminiActiveModel);
    
    if (dogumTarihi != null) prefs.setString('dogumTarihi', dogumTarihi!.toIso8601String());
    if (profilFotoByte != null) {
      prefs.setString('profilFoto', base64Encode(profilFotoByte!));
    }
    if (avatarFotoByte != null) {
      prefs.setString('avatarFoto', base64Encode(avatarFotoByte!));
    }
    prefs.setInt('bugunAlinanKalori', bugunAlinanKalori); prefs.setInt('uyunanSaat', uyunanSaat);
    prefs.setString('bugununYemekleri', jsonEncode(bugununYemekleri.map((e) => e.toJson()).toList()));
    
    prefs.setInt('suHedefiMl', suHedefiMl);
    prefs.setInt('bugunIcilenSuMl', bugunIcilenSuMl.value);
    prefs.setBool('bugunCheatMealAktif', bugunCheatMealAktif);
    prefs.setBool('bugunSlothDayAktif', bugunSlothDayAktif);
    prefs.setBool('bugunGamingPassAktif', bugunGamingPassAktif);
    prefs.setString('canta', jsonEncode(canta.map((e) => e.toJson()).toList()));

    Map<String, dynamic> planKayit = {};
    haftalikPlan.forEach((key, value) { planKayit[key.toString()] = value.map((e) => e.toJson()).toList(); });
    prefs.setString('haftalikPlan', jsonEncode(planKayit));

    Map<String, dynamic> nPlanKayit = {};
    normalHaftalikPlan.forEach((key, value) { nPlanKayit[key.toString()] = value.map((e) => e.toJson()).toList(); });
    prefs.setString('normalHaftalikPlan', jsonEncode(nPlanKayit));
    prefs.setString('overloadGecmisi', jsonEncode(
      overloadGecmisi.map((key, value) => MapEntry(key, value.toJson())),
    ));
    prefs.setStringList('kusanilanSuplementler', kusanilanSuplementler);
    prefs.setBool('sesliKocAktif', sesliKocAktif.value);

    bossGuncelle();
  }

  static void suplementKusan(String id) {
    if (!kusanilanSuplementler.contains(id)) {
      kusanilanSuplementler.add(id);
      suHedefiGuncelle();
      kaydet();
    }
  }

  static void suplementCikar(String id) {
    if (kusanilanSuplementler.contains(id)) {
      kusanilanSuplementler.remove(id);
      suHedefiGuncelle();
      kaydet();
    }
  }

  static bool suplementKusanildiMi(String id) {
    return kusanilanSuplementler.contains(id);
  }

  static void suHedefiGuncelle() {
    int bazSu = 3000;
    int ekSu = SupplementEngine.hesaplaToplamSuArtisi(kusanilanSuplementler);
    suHedefiMl = bazSu + ekSu;
  }

  static void overloadKaydiEkle(OverloadKaydi kayit) {
    overloadGecmisi[kayit.egzersizAdi] = kayit;
    kaydet();
  }

  static OverloadKaydi? getOverloadOneri(String egzersizAdi) {
    if (overloadGecmisi.containsKey(egzersizAdi)) {
      return overloadGecmisi[egzersizAdi];
    }
    for (var entry in overloadGecmisi.entries) {
      if (entry.key.toLowerCase().contains(egzersizAdi.toLowerCase()) ||
          egzersizAdi.toLowerCase().contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }

  static void kirmiziGecideGir(int secilenGun, int hedefKalori, String secilenPlan) {
    if (!redGateAktif) {
      normalGunlukHedefKalori = gunlukHedefKalori;
      normalHaftalikPlan.clear();
      haftalikPlan.forEach((key, value) {
        normalHaftalikPlan[key] = value.map((e) => Gorev(e.ad, false, e.tip)).toList();
      });

      haftalikPlan.clear();
      for(int i = 1; i <= 7; i++) {
        haftalikPlan[i] = [];
      }

      if (secilenPlan == "Full Body + Cardio") {
        for(int i = 1; i <= 7; i++) {
          haftalikPlan[i]!.addAll([
            Gorev("[PHY] Upper Body (Chest/Back/Arms)", false, "Fiziksel"),
            Gorev("[PHY] Lower Body (Quads/Hams/Calves)", false, "Fiziksel"),
            Gorev("[PHY] Core & Abs", false, "Fiziksel"),
            Gorev("[PHY] Intense Cardio", false, "Fiziksel"),
          ]);
        }
      } 
      else if (secilenPlan == "Push / Pull / Legs") {
        haftalikPlan[1]!.addAll([
          Gorev("[PHY] Push (Chest/Shoulders/Triceps)", false, "Fiziksel"),
          Gorev("[PHY] Core", false, "Fiziksel"),
          Gorev("[CARDIO] 20 Dk Eğimli Koşu Bandı", false, "Fiziksel"),
        ]);
        haftalikPlan[4]!.addAll([
          Gorev("[PHY] Push (Chest/Shoulders/Triceps)", false, "Fiziksel"),
          Gorev("[PHY] Core", false, "Fiziksel"),
          Gorev("[CARDIO] 20 Dk Eğimli Koşu Bandı", false, "Fiziksel"),
        ]);
        haftalikPlan[2]!.addAll([
          Gorev("[PHY] Pull (Back/Biceps/Rear Delts)", false, "Fiziksel"),
          Gorev("[PHY] Light Cardio", false, "Fiziksel"),
          Gorev("[CARDIO] 15 Dk Yüksek Yoğunluklu İp Atlama HIIT", false, "Fiziksel"),
        ]);
        haftalikPlan[5]!.addAll([
          Gorev("[PHY] Pull (Back/Biceps/Rear Delts)", false, "Fiziksel"),
          Gorev("[PHY] Light Cardio", false, "Fiziksel"),
          Gorev("[CARDIO] 15 Dk Yüksek Yoğunluklu İp Atlama HIIT", false, "Fiziksel"),
        ]);
        haftalikPlan[3]!.addAll([
          Gorev("[PHY] Legs (Quads/Hamstrings/Calves)", false, "Fiziksel"),
          Gorev("[CARDIO] 20 Dk Bisiklet & İnterval Koşu", false, "Fiziksel"),
        ]);
        haftalikPlan[6]!.addAll([
          Gorev("[PHY] Legs (Quads/Hamstrings/Calves)", false, "Fiziksel"),
          Gorev("[CARDIO] 20 Dk Bisiklet & İnterval Koşu", false, "Fiziksel"),
        ]);
        haftalikPlan[7]!.addAll([
          Gorev("[PHY] Active Recovery & Stretch", false, "Fiziksel"),
          Gorev("[CARDIO] 30 Dk Heavy Cardio & 5 KM Avcı Koşusu", false, "Fiziksel"),
        ]);
      } 
      else if (secilenPlan == "Saitama Hell") {
        for(int i = 1; i <= 7; i++) {
          haftalikPlan[i]!.addAll([
            Gorev("[PHY] 100 Push-ups", false, "Fiziksel"),
            Gorev("[PHY] 100 Sit-ups", false, "Fiziksel"),
            Gorev("[PHY] 100 Squats", false, "Fiziksel"),
            Gorev("[PHY] 10km Run", false, "Fiziksel"),
          ]);
        }
      }

      redGateAktif = true;
      redGateKalanGun = secilenGun;
      redGateToplamGun = secilenGun;
      gunlukHedefKalori = hedefKalori;
      golgeModuAktif = false; 
      
      kaydet();
    }
  }

  static void kirmiziGecittenCik() {
    redGateAktif = false;
    redGateKalanGun = 0;
    
    if (normalGunlukHedefKalori > 0) {
      gunlukHedefKalori = normalGunlukHedefKalori;
    }
    
    if (normalHaftalikPlan.isNotEmpty) {
      haftalikPlan.clear();
      normalHaftalikPlan.forEach((key, value) {
        haftalikPlan[key] = value.map((e) => Gorev(e.ad, false, e.tip)).toList();
      });
    }
    kaydet();
  }

  static void yeniGunKontrolu() {
    DateTime bugun = DateTime.now();
    String bugunStr = "${bugun.year}-${bugun.month.toString().padLeft(2,'0')}-${bugun.day.toString().padLeft(2,'0')}";

    if (sonGirisTarihi.isEmpty) {
      if (bugunAlinanKalori > 0 || bugununYemekleri.isNotEmpty) {
        DateTime dun = bugun.subtract(const Duration(days: 1));
        sonGirisTarihi = "${dun.year}-${dun.month.toString().padLeft(2,'0')}-${dun.day.toString().padLeft(2,'0')}";
      } else {
        sonGirisTarihi = bugunStr; kaydet(); return;
      }
    }

    if (sonGirisTarihi != bugunStr) {
      DateTime sonGiris = DateTime.parse(sonGirisTarihi);
      
      geceRaporu = _gunSonuHesaplasmasi(sonGiris.weekday);

      int gunFarki = bugun.difference(sonGiris).inDays;
      if (gunFarki > 1 && !golgeModuAktif && !redGateAktif) {
        streakGunSayisi = 0; 
      }

      sonGirisTarihi = bugunStr; kaydet();
    }
  }

  static String zindanAkiniBitir(int gecenSaniye) {
    int dakika = gecenSaniye ~/ 60;
    if (dakika == 0 && gecenSaniye > 0) dakika = 1;
    
    int bugun = DateTime.now().weekday;
    int bitenGorevSayisiSimdi = haftalikPlan[bugun]?.where((g) => g.yapildiMi).length ?? 0;

    toplamIdmanDakikasi += dakika;
    sonTesttenBeriIdmanSayisi++;
    idmanGecmisi.add({
      'tarih': DateTime.now().toIso8601String(),
      'dakika': dakika,
      'gorevSayisi': bitenGorevSayisiSimdi
    });

    // İdman Yıpranma ve Kalori/Katabolizma Telafisini Tetikle
    idmanYipranmasiIsle(
      dakika: dakika,
      idmanTuru: dovusSporuYapiyorMu ? 'Dövüş & Zindan' : 'Ağırlık & Zindan',
    );

    int kazanilanAltin = dakika * (redGateAktif ? 10 : 2); 
    altin.value += kazanilanAltin;
    
    int kazanilanExp = dakika * 5;
    String lvlUp = expKazan(kazanilanExp);
    
    kaydet();
    AudioSystem.playSuccess();
    
    return "[RAID COMPLETED]\nTime in Dungeon: $dakika Min\nQuests Completed: $bitenGorevSayisiSimdi\nTime Reward: +$kazanilanAltin Gold | +$kazanilanExp EXP$lvlUp";
  }

  // ========================================================
  // YENİ DÜZELTME: KALORİ YEDEKLEME KORUMASI (PROTOKOL)
  // ========================================================
  static void protokolGuncelle(String yeniHedef, String yeniZorluk) {
    aktifHedef = yeniHedef; aktifZorluk = yeniZorluk;

    double bmr = (cinsiyet == "Erkek") ? (10 * kilo) + (6.25 * boy) - (5 * yas) + 5 : (10 * kilo) + (6.25 * boy) - (5 * yas) - 161;
    double gunlukIhtiyac = bmr * 1.375; int kaloriFarki = 0;

    if (aktifHedef == "Kilo Ver (Yağ Yak)") { 
      if (aktifZorluk == "Normal") {
        kaloriFarki = -500;
      } else if (aktifZorluk == "Yüksek") {
        kaloriFarki = -1000;
      } else if (aktifZorluk == "Cehennem") {
        kaloriFarki = -1500;
      } 
    } 
    else if (aktifHedef == "Kilo Al (Kas İnşa Et)") { 
      if (aktifZorluk == "Normal") {
        kaloriFarki = 300;
      } else if (aktifZorluk == "Yüksek") {
        kaloriFarki = 500;
      } else if (aktifZorluk == "Canavar") {
        kaloriFarki = 1000;
      } 
    }

    int hesaplanan = (gunlukIhtiyac + kaloriFarki).round();
    if (hesaplanan < 1200) hesaplanan = 1200; 
    
    // EĞER RED GATE AKTİFSE, CEHENNEM KALORİSİNİ BOZMA, SADECE YEDEĞİ GÜNCELLE!
    if (redGateAktif) {
      normalGunlukHedefKalori = hesaplanan; 
    } else {
      gunlukHedefKalori = hesaplanan;
    }
    
    kaydet();
  }

  static void bossGuncelle({int? gunIndex}) {
    int bugun = gunIndex ?? DateTime.now().weekday;
    if (bugun == 7) { 
      if (bossMaxHP == 0 || bossMaxHP < level.value * 100) {
        bossMaxHP = level.value * 100;
        bossTuru = level.value % 2 == 0 ? "Zihinsel" : "Fiziksel";
        bossIsim = bossTuru == "Fiziksel" ? "Steel-Fanged Wolf (Beast)" : "Ancient Lich (Undead)";
      }

      int hasar = 0;
      for (var g in haftalikPlan[7]!) {
        if (g.yapildiMi) { hasar += (g.tip == bossTuru) ? (level.value * 25) : (level.value * 5); }
      }
      if (bugunAlinanKalori > 0 && bugunAlinanKalori <= gunlukHedefKalori) { hasar += (level.value * 30); }
      
      int kalan = bossMaxHP - hasar; bossHP.value = kalan < 0 ? 0 : kalan;
    } else { bossMaxHP = 0; bossHP.value = 0; }
  }

  // ========================================================
  // YENİ DÜZELTME: KALORİ YEDEKLEME KORUMASI (TARTI)
  // ========================================================
  static void oyuncuyuAnalizEt(String secilenCinsiyet, DateTime girilenDogumTarihi, double girilenBoy, double girilenKilo, String hedef, String zorluk, Uint8List? foto, [int? idmanGunu, String? ekipman, String? tecrube, List<String>? eklemKisitlari, List<String>? hedefOdakBolgeleri]) {
    cinsiyet = secilenCinsiyet; dogumTarihi = girilenDogumTarihi; boy = girilenBoy; kilo = girilenKilo;
    aktifHedef = hedef; aktifZorluk = zorluk; if (foto != null) profilFotoByte = foto;
    if (ekipman != null) ekipmanTuru = ekipman;
    if (tecrube != null) antrenmanGecmisi = tecrube;
    if (eklemKisitlari != null) eklemKisiti = eklemKisitlari;
    if (hedefOdakBolgeleri != null) odakBolgeleri = hedefOdakBolgeleri;

    if (baslangicKilosu == 0) {
      baslangicKilosu = kilo; kiloGecmisi.add({ 'tarih': DateTime.now().toIso8601String(), 'kilo': kilo, 'kalori': bugunAlinanKalori });
    }

    if (sonGirisTarihi.isEmpty) {
      DateTime bugun = DateTime.now(); sonGirisTarihi = "${bugun.year}-${bugun.month.toString().padLeft(2,'0')}-${bugun.day.toString().padLeft(2,'0')}";
    }

    double boyMetre = boy / 100; double bmi = kilo / (boyMetre * boyMetre);
    if (bmi < 18.5) {
      vucutSinifi = "Underweight";
    } else if (bmi < 24.9) {
      vucutSinifi = "Normal";
    } else if (bmi < 29.9) {
      vucutSinifi = "Overweight";
    } else {
      vucutSinifi = "Obese";
    }

    double bmr = (cinsiyet == "Erkek") ? (10 * kilo) + (6.25 * boy) - (5 * yas) + 5 : (10 * kilo) + (6.25 * boy) - (5 * yas) - 161;
    double gunlukIhtiyac = bmr * 1.375; int kaloriFarki = 0;

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
      } else if (zorluk == "Canavar") {
        kaloriFarki = 1000;
      }
    }

    int hesaplanan = (gunlukIhtiyac + kaloriFarki).round();
    if (hesaplanan < 1200) hesaplanan = 1200; 
    
    // EĞER RED GATE AKTİFSE, CEHENNEM KALORİSİNİ BOZMA, SADECE YEDEĞİ GÜNCELLE!
    if (redGateAktif) {
      normalGunlukHedefKalori = hesaplanan; 
    } else {
      gunlukHedefKalori = hesaplanan;
    }

    if (idmanGunu != null && !redGateAktif) {
      baslangicPrograminiAta(
        ekipman: ekipmanTuru,
        rank: hunterRank,
        idmanGunu: idmanGunu,
        hedef: hedef,
        eklemKisitlari: eklemKisiti,
        hedefOdakBolgeleri: odakBolgeleri,
      );
    }

    kaydet();
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

    // Ağırlık / 1RM kuvvet katkısı (Combat Strength Bonus - dengeli destekleyici katkı)
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
    final bool isFirstAwakening = hunterRank == "Unranked";
    dovusSporuYapiyorMu = true;
    if (branslar != null && branslar.isNotEmpty) {
      dovusBranslari = List<String>.from(branslar);
      dovusBransi = dovusBranslari.join(', ');
    } else if (brans != null && brans.isNotEmpty) {
      dovusBransi = brans;
      dovusBranslari = [brans];
    }
    maxPatlayiciSinav = patlayiciSinav;
    maxBurpeeKondisyon = burpeeKondisyon;
    maxPlankSaniye = plankSaniye;
    maxBarfiks = barfiks;
    if (bench != null && bench > 0) maxBench = bench;
    if (squat != null && squat > 0) maxSquat = squat;
    if (deadlift != null && deadlift > 0) maxDeadlift = deadlift;
    hunterRank = rank;
    sonTestTarihi = DateTime.now().toIso8601String();
    sonTesttenBeriIdmanSayisi = 0;

    if (isFirstAwakening) {
      exp.value += 100;
      ap.value += 3;
    }

    baslangicPrograminiAta(
      ekipman: ekipmanTuru,
      rank: hunterRank,
      idmanGunu: idmanGunu ?? 3,
      hedef: aktifHedef,
      eklemKisitlari: eklemKisiti,
    );

    kaydet();
  }

  static void awakeningTestKaydet({
    required double bench,
    required double squat,
    required double deadlift,
    required String rank,
    int? idmanGunu,
  }) {
    final bool isFirstAwakening = hunterRank == "Unranked";
    maxBench = bench;
    maxSquat = squat;
    maxDeadlift = deadlift;
    hunterRank = rank;
    sonTestTarihi = DateTime.now().toIso8601String();
    sonTesttenBeriIdmanSayisi = 0;

    if (isFirstAwakening) {
      exp.value += 100;
      ap.value += 3;
    }

    // Programı yeni rank'a ve ekipmana göre uyarla
    baslangicPrograminiAta(
      ekipman: ekipmanTuru,
      rank: hunterRank,
      idmanGunu: idmanGunu ?? 3,
      hedef: aktifHedef,
      eklemKisitlari: eklemKisiti,
    );

    kaydet();
  }

  /// Dövüş sporuna özel 5 raundluk uzatılmış gölge boksu ve kombinasyon protokolü üretir
  static List<Gorev> dovusGolgeBoksuKombinasyonlari({String? brans, int raundSayisi = 5}) {
    final seciliBrans = (brans ?? dovusBransi).toLowerCase();

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
      // Varsayılan Boks (Peek-a-boo & Out-boxer)
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
    ekipmanTuru = ekipman;
    List<String> kisitlar = eklemKisitlari ?? eklemKisiti;
    eklemKisiti = kisitlar;
    List<String> odaklar = hedefOdakBolgeleri ?? odakBolgeleri;
    odakBolgeleri = odaklar;

    haftalikPlan.clear();
    for (int i = 1; i <= 7; i++) {
      haftalikPlan[i] = [];
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

    if (dovusSporuYapiyorMu) {
      String dovusAdi = dovusBransi;
      final combShadows = dovusGolgeBoksuKombinasyonlari(brans: dovusBransi);
      if (idmanGunu <= 3) {
        haftalikPlan[1]!.addAll([
          Gorev("[COMBAT] $dovusAdi: Patlayıcı İtiş & Plyo Şınav ($setRepLabel)", false, "Fiziksel"),
          Gorev("[COMBAT] Rotational Punch Press / Landmine ($setRepLabel)", false, "Fiziksel"),
          Gorev("[COMBAT] Strict Barfiks / Pull-up ($setRepLabel)", false, "Fiziksel"),
          Gorev("[COMBAT] Dumbbell Row & Çekiş Kuvveti ($setRepLabel)", false, "Fiziksel"),
          Gorev("[COMBAT] Boyun & Rotasyonel Core (Plank / Russian Twist)", false, "Fiziksel"),
          Gorev("[CARDIO] 20 Dk Hızlı İp Atlama & Ayak Çalışması", false, "Fiziksel"),
        ]);
        haftalikPlan[3]!.addAll([
          ...combShadows.take(3),
          Gorev("[COMBAT] Hızlı İp Atlama / Footwork Drills (15 Dk)", false, "Fiziksel"),
          Gorev("[COMBAT] Burpee Sprawl Kondisyon (5 Set x 15)", false, "Fiziksel"),
          Gorev("[COMBAT] Ağır Kum Torbası Kombinasyonları (5 Raund x 3 Dk)", false, "Fiziksel"),
          Gorev("[COMBAT] Asılı Bacak Kaldırma (Hanging Leg Raise) (4 Set x 15)", false, "Fiziksel"),
          Gorev("[CARDIO] 20 Dk Interval Sprint Koşusu (Zone 4)", false, "Fiziksel"),
        ]);
        haftalikPlan[5]!.addAll([
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
        haftalikPlan[1]!.addAll([
          Gorev("[COMBAT] Güç & İtiş: Patlayıcı Şınav & DB Punch Press ($setRepLabel)", false, "Fiziksel"),
          Gorev("[COMBAT] Barfiks / Çekiş & Face Pull ($setRepLabel)", false, "Fiziksel"),
          Gorev("[COMBAT] Incline Dumbbell Press ($setRepLabel)", false, "Fiziksel"),
          Gorev("[COMBAT] Rotasyonel Core & Russian Twist", false, "Fiziksel"),
          Gorev("[CARDIO] 20 Dk İp Atlama & Footwork Drills", false, "Fiziksel"),
        ]);
        haftalikPlan[2]!.addAll([
          Gorev("[COMBAT] Dövüş Kondisyonu: Gölge Boksu (6 Raund x 3 Dk)", false, "Fiziksel"),
          Gorev("[COMBAT] Hızlı İp Atlama & Ayak Çalışması (20 Dk)", false, "Fiziksel"),
          Gorev("[COMBAT] Burpee Sprawl & Sıçrama (5 Set x 15)", false, "Fiziksel"),
          Gorev("[COMBAT] Asılı Bacak Kaldırma (4 Set x 15)", false, "Fiziksel"),
          Gorev("[CARDIO] 20 Dk Zone 2 Efor Koşusu", false, "Fiziksel"),
        ]);
        haftalikPlan[4]!.addAll([
          Gorev("[COMBAT] Alt Gövde & Patlayıcılık: Box Jump & Split Squat ($setRepLabel)", false, "Fiziksel"),
          Gorev("[COMBAT] Zercher Squat / Goblet Squat ($setRepLabel)", false, "Fiziksel"),
          Gorev("[COMBAT] Romanian Deadlift / Hip Thrust ($setRepLabel)", false, "Fiziksel"),
          Gorev("[COMBAT] Boyun Köprüsü / Direnç Egzersizi & Plank", false, "Fiziksel"),
          Gorev("[CARDIO] 20 Dk İnterval Kürek / Bisiklet Sprint", false, "Fiziksel"),
        ]);
        haftalikPlan[5]!.addAll([
          Gorev("[COMBAT] Ağır Kum Torbası Kombinasyonları (6 Raund x 3 Dk)", false, "Fiziksel"),
          Gorev("[COMBAT] Slip Bag / Head Movement & Reaksiyon Hızı", false, "Fiziksel"),
          Gorev("[COMBAT] Farmer's Walk & Tutuş Dayanıklılığı", false, "Fiziksel"),
          Gorev("[COMBAT] Rotasyonel Landmine Core (4 Set)", false, "Fiziksel"),
          Gorev("[CARDIO] 20 Dk MetCon Yüksek Yoğunluklu Kardiyo", false, "Fiziksel"),
        ]);
      } else {
        haftalikPlan[1]!.addAll([
          Gorev("[COMBAT] Patlayıcı Üst Vücut: Plyo Push-up & Punch Press ($setRepLabel)", false, "Fiziksel"),
          Gorev("[COMBAT] Ağırlıklı Barfiks / Lat Row ($setRepLabel)", false, "Fiziksel"),
          Gorev("[COMBAT] Dumbbell Floor Press ($setRepLabel)", false, "Fiziksel"),
          Gorev("[COMBAT] Rotasyonel Core & Plank", false, "Fiziksel"),
          Gorev("[CARDIO] 20 Dk İp Atlama Kardiyosu", false, "Fiziksel"),
        ]);
        haftalikPlan[2]!.addAll([
          Gorev("[COMBAT] Gölge Boksu & Reaksiyon Hızı (6 Raund x 3 Dk)", false, "Fiziksel"),
          Gorev("[COMBAT] Hızlı İp Atlama & Çeviklik (20 Dk)", false, "Fiziksel"),
          Gorev("[COMBAT] Burpee Sprawl Kondisyon (5 Set x 15)", false, "Fiziksel"),
          Gorev("[COMBAT] Asılı Bacak Kaldırma (4 Set x 15)", false, "Fiziksel"),
          Gorev("[CARDIO] 15 Dk Zone 4 İnterval Sprint", false, "Fiziksel"),
        ]);
        haftalikPlan[3]!.addAll([
          Gorev("[COMBAT] Alt Gövde Gücü: Box Jump & Zercher Squat ($setRepLabel)", false, "Fiziksel"),
          Gorev("[COMBAT] Bulgarian Split Squat ($setRepLabel)", false, "Fiziksel"),
          Gorev("[COMBAT] Romanian Deadlift ($setRepLabel)", false, "Fiziksel"),
          Gorev("[COMBAT] Darbe Dayanıklılığı Core & Asılma", false, "Fiziksel"),
          Gorev("[CARDIO] 20 Dk Zone 2 Dinamik Yürüyüş Bandı", false, "Fiziksel"),
        ]);
        haftalikPlan[4]!.addAll([
          Gorev("[COMBAT] Kum Torbası / Sparring / Pad Work (6 Raund x 3 Dk)", false, "Fiziksel"),
          Gorev("[COMBAT] Slip Bag / Head Movement & Savunma Refleks", false, "Fiziksel"),
          Gorev("[COMBAT] Boyun Direnci & Trapezius Güçlendirme", false, "Fiziksel"),
          Gorev("[COMBAT] Rus Dönüşü (Russian Twist) (4 Set x 20)", false, "Fiziksel"),
          Gorev("[CARDIO] 20 Dk Yüksek Yoğunluklu İp Atlama HIIT", false, "Fiziksel"),
        ]);
        haftalikPlan[5]!.addAll([
          Gorev("[COMBAT] Dövüş MetCon: Interval Koşu / Sprint (15 Dk)", false, "Fiziksel"),
          Gorev("[COMBAT] Farmer's Walk & Grip Strength (4 Set)", false, "Fiziksel"),
          Gorev("[COMBAT] Landmine Punch Press ($setRepLabel)", false, "Fiziksel"),
          Gorev("[COMBAT] Hollow Body & Plank (4 Set x 60sn)", false, "Fiziksel"),
          Gorev("[COMBAT] Dinamik Mobilite & Esneme", false, "Fiziksel"),
          Gorev("[CARDIO] 20 Dk Dövüş Kondisyonu & Burpee Sprawl Finisher", false, "Fiziksel"),
        ]);
      }
    } else if (ekipman == 'Salon') {
      String squatVar = dizHassas ? "Leg Press / Box Squat" : "Barbell Squat";
      String pressVar = omuzHassas ? "Incline DB Press (Neutral Grip)" : "Barbell Bench Press";
      String deadliftVar = belHassas ? "Chest Supported T-Bar Row" : "Barbell Deadlift";

      if (idmanGunu <= 3) {
        haftalikPlan[1]!.addAll([
          Gorev("[PHY] $pressVar ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Incline Dumbbell Press ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] $squatVar ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Lat Pulldown / Cable Row ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Dips / Triceps Pushdown ($setRepLabel)", false, "Fiziksel"),
          Gorev("[CORE / ABS] Hanging Leg Raise (4 Set x 15)", false, "Fiziksel"),
          Gorev("[CARDIO] 20 Dk Eğimli Koşu Bandı Zone 2", false, "Fiziksel"),
        ]);
        haftalikPlan[3]!.addAll([
          Gorev("[PHY] Overhead Shoulder Press ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Lateral Raise (Dumbbell) (5 Set x 12)", false, "Fiziksel"),
          Gorev("[PHY] $deadliftVar ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Leg Curl / Extension ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Barbell Biceps Curl ($setRepLabel)", false, "Fiziksel"),
          Gorev("[CORE / ABS] Cable Crunch & Plank (4 Set)", false, "Fiziksel"),
          Gorev("[CARDIO] 25 Dk Kürek / Bisiklet Zone 2 Kardiyo", false, "Fiziksel"),
        ]);
        haftalikPlan[5]!.addAll([
          Gorev("[PHY] Incline Dumbbell Press ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Dips / Göğüs İtiş ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Romanian Deadlift ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Barbell / Dumbbell Curl ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Triceps Cable Pushdown ($setRepLabel)", false, "Fiziksel"),
          Gorev("[CORE / ABS] Plank & Cable Crunch (4 Set)", false, "Fiziksel"),
          Gorev("[CARDIO] 20 Dk Yüksek Yoğunluklu İp Atlama HIIT", false, "Fiziksel"),
        ]);
      } else if (idmanGunu == 4) {
        haftalikPlan[1]!.addAll([
          Gorev("[PHY] Upper A: $pressVar ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Upper A: Incline DB Press ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Upper A: Lat Pulldown ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Upper A: DB Lateral Raise ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Upper A: Triceps Rope Pushdown ($setRepLabel)", false, "Fiziksel"),
          Gorev("[CORE / ABS] Cable Crunch & Plank (4 Set)", false, "Fiziksel"),
          Gorev("[CARDIO] 20 Dk Eğimli Yürüyüş Bandı", false, "Fiziksel"),
        ]);
        haftalikPlan[2]!.addAll([
          Gorev("[PHY] Lower A: $squatVar ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Lower A: Romanian Deadlift ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Lower A: Leg Extension / Lunge ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Lower A: Standing Calf Raise (4 Set x 15)", false, "Fiziksel"),
          Gorev("[CORE / ABS] Hanging Leg Raise (4 Set x 15)", false, "Fiziksel"),
          Gorev("[CARDIO] 20 Dk Bisiklet & İnterval Koşu", false, "Fiziksel"),
        ]);
        haftalikPlan[4]!.addAll([
          Gorev("[PHY] Upper B: Overhead Press ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Upper B: Incline DB Press ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Upper B: Cable Row ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Upper B: Face Pull ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Upper B: Barbell Bicep Curl ($setRepLabel)", false, "Fiziksel"),
          Gorev("[CORE / ABS] Plank & Hollow Body (4 Set)", false, "Fiziksel"),
          Gorev("[CARDIO] 20 Dk İp Atlama / Kürek Kardiyosu", false, "Fiziksel"),
        ]);
        haftalikPlan[5]!.addAll([
          Gorev("[PHY] Lower B: $deadliftVar ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Lower B: Leg Press ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Lower B: Hamstring Curl ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Lower B: Bulgarian Split Squat ($setRepLabel)", false, "Fiziksel"),
          Gorev("[CORE / ABS] Plank & Ab Wheel Rollout (4 Set)", false, "Fiziksel"),
          Gorev("[CARDIO] 20 Dk Zone 2 Efor Koşusu", false, "Fiziksel"),
        ]);
      } else {
        haftalikPlan[1]!.addAll([
          Gorev("[PHY] Push: $pressVar ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Push: Incline DB Press ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Push: Dips ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Push: DB Lateral Raise (5 Set x 12)", false, "Fiziksel"),
          Gorev("[PHY] Push: Triceps Rope Pushdown ($setRepLabel)", false, "Fiziksel"),
          Gorev("[CORE / ABS] Plank & Hollow Body (4 Set)", false, "Fiziksel"),
          Gorev("[CARDIO] 20 Dk Eğimli Koşu Bandı", false, "Fiziksel"),
        ]);
        haftalikPlan[2]!.addAll([
          Gorev("[PHY] Pull: $deadliftVar ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Pull: Lat Pulldown ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Pull: Seated Cable Row ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Pull: Face Pull (Rear Delts) ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Pull: Incline Dumbbell Biceps Curl ($setRepLabel)", false, "Fiziksel"),
          Gorev("[CORE / ABS] Asılı Bacak Kaldırma (4 Set)", false, "Fiziksel"),
          Gorev("[CARDIO] 20 Dk Yüksek Yoğunluklu İp Atlama HIIT", false, "Fiziksel"),
        ]);
        haftalikPlan[3]!.addAll([
          Gorev("[PHY] Legs: $squatVar ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Legs: Romanian Deadlift ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Legs: Leg Press ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Legs: Hamstring Curl ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Legs: Calves & Ab Wheel (4 Set)", false, "Fiziksel"),
          Gorev("[CARDIO] 20 Dk Bisiklet & İnterval Koşu", false, "Fiziksel"),
        ]);
        haftalikPlan[4]!.addAll([
          Gorev("[PHY] Push 2: Overhead Shoulder Press ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Push 2: Dumbbell Fly ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Push 2: Cable Lateral Raise (5 Set x 15)", false, "Fiziksel"),
          Gorev("[PHY] Push 2: Overhead Triceps Extension ($setRepLabel)", false, "Fiziksel"),
          Gorev("[CORE / ABS] Plank & Hollow Body (4 Set)", false, "Fiziksel"),
          Gorev("[CARDIO] 20 Dk Yüksek Yoğunluklu İp Atlama", false, "Fiziksel"),
        ]);
        haftalikPlan[5]!.addAll([
          Gorev("[PHY] Pull 2: Barbell/DB Row ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Pull 2: Neutral Grip Pulldown ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Pull 2: Hammer Curls ($setRepLabel)", false, "Fiziksel"),
          Gorev("[PHY] Pull 2: Preacher Curl ($setRepLabel)", false, "Fiziksel"),
          Gorev("[CORE / ABS] Cable Crunch (4 Set x 15)", false, "Fiziksel"),
          Gorev("[CARDIO] 25 Dk Zone 2 Kürek / Koşu", false, "Fiziksel"),
        ]);
        if (idmanGunu >= 6) {
          haftalikPlan[6]!.addAll([
            Gorev("[PHY] Legs 2: Bulgarian Split Squat ($setRepLabel)", false, "Fiziksel"),
            Gorev("[PHY] Legs 2: Goblet Squat / Leg Press ($setRepLabel)", false, "Fiziksel"),
            Gorev("[PHY] Legs 2: Leg Extension ($setRepLabel)", false, "Fiziksel"),
            Gorev("[PHY] Legs 2: Standing Calf Raise (4 Set x 15)", false, "Fiziksel"),
            Gorev("[CORE / ABS] Russian Twist & Plank (4 Set)", false, "Fiziksel"),
            Gorev("[CARDIO] 20 Dk MetCon / İnterval Koşu", false, "Fiziksel"),
          ]);
        }
      }
    } else if (ekipman == 'Ev-Dambil') {
      String squatVar = dizHassas ? "Dumbbell Box Squat" : "Goblet Squat";
      String pressVar = omuzHassas ? "Dumbbell Floor Press (Neutral Grip)" : "Dumbbell Floor/Bench Press";
      String deadliftVar = belHassas ? "DB Romanian Deadlift (Slow Tempo)" : "Dumbbell Romanian Deadlift";

      haftalikPlan[1]!.addAll([
        Gorev("[PHY] $pressVar ($setRepLabel)", false, "Fiziksel"),
        Gorev("[PHY] Incline Dumbbell Press ($setRepLabel)", false, "Fiziksel"),
        Gorev("[PHY] $squatVar ($setRepLabel)", false, "Fiziksel"),
        Gorev("[PHY] Two-Arm Dumbbell Row ($setRepLabel)", false, "Fiziksel"),
        Gorev("[PHY] DB Lateral Raise (5 Set x 12)", false, "Fiziksel"),
        Gorev("[CORE / ABS] Floor Crunch & Hollow Body (4 Set)", false, "Fiziksel"),
        Gorev("[CARDIO] 20 Dk Eforlu İp Atlama & Gölge Boksu", false, "Fiziksel"),
      ]);
      haftalikPlan[3]!.addAll([
        Gorev("[PHY] Seated DB Shoulder Press ($setRepLabel)", false, "Fiziksel"),
        Gorev("[PHY] $deadliftVar ($setRepLabel)", false, "Fiziksel"),
        Gorev("[PHY] Single Arm DB Row ($setRepLabel)", false, "Fiziksel"),
        Gorev("[PHY] Dumbbell Bicep Hammer Curl ($setRepLabel)", false, "Fiziksel"),
        Gorev("[PHY] Overhead DB Triceps Extension ($setRepLabel)", false, "Fiziksel"),
        Gorev("[CORE / ABS] Plank (4 Set x 60sn)", false, "Fiziksel"),
        Gorev("[CARDIO] 25 Dk Zone 2 Efor Yürüyüşü / Koşu", false, "Fiziksel"),
      ]);
      haftalikPlan[5]!.addAll([
        Gorev("[PHY] Bulgarian Split Squat (Dumbbell) ($setRepLabel)", false, "Fiziksel"),
        Gorev("[PHY] Dumbbell Push-ups / Floor Fly ($setRepLabel)", false, "Fiziksel"),
        Gorev("[PHY] Dumbbell Romanian Deadlift ($setRepLabel)", false, "Fiziksel"),
        Gorev("[PHY] Lateral Raise & Biceps 21s ($setRepLabel)", false, "Fiziksel"),
        Gorev("[PHY] DB Farmers Walk (4 Set)", false, "Fiziksel"),
        Gorev("[CORE / ABS] Russian Twist & Leg Raise (4 Set)", false, "Fiziksel"),
        Gorev("[CARDIO] 20 Dk Yüksek Yoğunluklu Kardiyo & Burpees", false, "Fiziksel"),
      ]);
    } else {
      // Vücut Ağırlığı (Calisthenics)
      String pushVar = omuzHassas ? "Push-ups (Elevated Hands)" : (rUpper.startsWith('S') || rUpper.startsWith('A') ? "Archer / Decline Push-ups" : "Standard Push-ups");
      String squatVar = dizHassas ? "Bodyweight Box Squat / Wall Sit" : (rUpper.startsWith('S') || rUpper.startsWith('A') ? "Pistol Squats / Jump Squats" : "Air Squats & Lunges");
      String pullVar = (rUpper.startsWith('S') || rUpper.startsWith('A')) ? "Strict Pull-ups / Muscle-up Prep" : "Inverted Rows / Band Pulls";

      haftalikPlan[1]!.addAll([
        Gorev("[PHY] Calisthenics: $pushVar ($setRepLabel)", false, "Fiziksel"),
        Gorev("[PHY] Calisthenics: Dips / Chair Dips ($setRepLabel)", false, "Fiziksel"),
        Gorev("[PHY] Calisthenics: $squatVar ($setRepLabel)", false, "Fiziksel"),
        Gorev("[PHY] Calisthenics: $pullVar ($setRepLabel)", false, "Fiziksel"),
        Gorev("[CORE / ABS] Hollow Body Hold (4 x 45s)", false, "Fiziksel"),
        Gorev("[CARDIO] 20 Dk İp Atlama & Avcı Koşusu", false, "Fiziksel"),
      ]);
      haftalikPlan[3]!.addAll([
        Gorev("[PHY] Calisthenics: Pike Push-ups ($setRepLabel)", false, "Fiziksel"),
        Gorev("[PHY] Calisthenics: Walking Lunges ($setRepLabel)", false, "Fiziksel"),
        Gorev("[PHY] Calisthenics: Chin-ups / Inverted Row ($setRepLabel)", false, "Fiziksel"),
        Gorev("[PHY] Calisthenics: Single Leg Calf Raise (4 Set x 15)", false, "Fiziksel"),
        Gorev("[CORE / ABS] L-Sit / Hanging Knee Raise (4 Set)", false, "Fiziksel"),
        Gorev("[CARDIO] 25 Dk Zone 2 Efor Koşusu / Yürüyüşü", false, "Fiziksel"),
      ]);
      haftalikPlan[5]!.addAll([
        Gorev("[PHY] Calisthenics: Diamond Push-ups ($setRepLabel)", false, "Fiziksel"),
        Gorev("[PHY] Calisthenics: Explosive Jump Squats ($setRepLabel)", false, "Fiziksel"),
        Gorev("[PHY] Calisthenics: Single Leg Glute Bridges ($setRepLabel)", false, "Fiziksel"),
        Gorev("[CORE / ABS] Plank to Push-up (4 Set x 12)", false, "Fiziksel"),
        Gorev("[CORE / ABS] Hanging / Lying Leg Raises (4 Set x 15)", false, "Fiziksel"),
        Gorev("[CARDIO] 20 Dk Burpees & Sıçrama Kondisyonu HIIT", false, "Fiziksel"),
      ]);
    }

    // --- ÖNCELİKLİ ODAK & YAĞ YAKIM PROTOKOLÜ (TARGET FOCUS INJECTION) ---
    if (odaklar.isNotEmpty) {
      for (int gun = 1; gun <= 7; gun++) {
        if (haftalikPlan[gun]!.isNotEmpty) {
          if (odaklar.any((o) => o.contains('Karın') || o.contains('Göbek') || o.contains('Abs'))) {
            haftalikPlan[gun]!.add(
              Gorev("[FOCUS-CORE] Karın & Yağ Yakımı: Asılı Bacak Kaldırma & Plank Finisher", false, "Fiziksel"),
            );
          }
          if (odaklar.any((o) => o.contains('Göğüs') || o.contains('Chest'))) {
            haftalikPlan[gun]!.add(
              Gorev("[FOCUS-CHEST] Göğüs Sıkılaştırma: Deficit Push-up / DB Flye Finisher", false, "Fiziksel"),
            );
          }
          if (odaklar.any((o) => o.contains('Kol') || o.contains('Arm'))) {
            haftalikPlan[gun]!.add(
              Gorev("[FOCUS-ARMS] Kol Gelişimi: Biceps Curl & Triceps Pushdown", false, "Fiziksel"),
            );
          }
          if (odaklar.any((o) => o.contains('Omuz') || o.contains('Shoulder'))) {
            haftalikPlan[gun]!.add(
              Gorev("[FOCUS-SHOULDER] Omuz Genişletme: Lateral Raise & Face Pull", false, "Fiziksel"),
            );
          }
          if (odaklar.any((o) => o.contains('Bacak') || o.contains('Kalça') || o.contains('Leg'))) {
            haftalikPlan[gun]!.add(
              Gorev("[FOCUS-LEGS] Bacak & Kalça Sıkılaştırma: Walking Lunges / Split Squat", false, "Fiziksel"),
            );
          }
          if (odaklar.any((o) => o.contains('Sırt') || o.contains('Back'))) {
            haftalikPlan[gun]!.add(
              Gorev("[FOCUS-BACK] Sırt & V-Taper: Inverted Row / Pulldown Finisher", false, "Fiziksel"),
            );
          }
        }
      }
    }

    normalHaftalikPlan.clear();
    haftalikPlan.forEach((key, value) {
      normalHaftalikPlan[key] = value.map((e) => Gorev(e.ad, false, e.tip)).toList();
    });
  }

  /// Gemini AI ile kişiselleştirilmiş haftalık antrenman planını oluşturur ve haftalık plana aktarır.
  /// API anahtarı boşsa veya bağlantı başarısız olursa yerel kural motoruna (baslangicPrograminiAta) geri döner (fail-safe).
  static Future<bool> aiPrograminiUygula({String? ozelTalep, int? idmanGunu}) async {
    final int gunSayisi = idmanGunu ?? 3;
    if (geminiApiKey.trim().isEmpty) {
      baslangicPrograminiAta(
        ekipman: ekipmanTuru,
        rank: hunterRank,
        idmanGunu: gunSayisi,
        hedef: aktifHedef,
        eklemKisitlari: eklemKisiti,
        hedefOdakBolgeleri: odakBolgeleri,
      );
      kaydet();
      return false;
    }

    try {
      final aiPlan = await GeminiService.haftalikProgramUret(
        kilo: kilo > 0 ? kilo : 70.0,
        boy: boy > 0 ? boy : 175.0,
        rank: hunterRank,
        hedef: aktifHedef,
        zorluk: aktifZorluk,
        ekipman: ekipmanTuru,
        idmanGunu: gunSayisi,
        dovuscuMu: dovusSporuYapiyorMu,
        dovusBranslari: dovusBranslari.isNotEmpty ? dovusBranslari : [dovusBransi],
        eklemKisitlari: eklemKisiti,
        odakBolgeleri: odakBolgeleri,
        maxBench: maxBench > 0 ? maxBench : null,
        maxSquat: maxSquat > 0 ? maxSquat : null,
        deadlift: maxDeadlift > 0 ? maxDeadlift : null,
        ozelTalep: ozelTalep,
      );

      if (aiPlan != null && aiPlan.values.any((list) => list.isNotEmpty)) {
        haftalikPlan.clear();
        for (int i = 1; i <= 7; i++) {
          haftalikPlan[i] = aiPlan[i] ?? [];
        }
        normalHaftalikPlan.clear();
        haftalikPlan.forEach((key, value) {
          normalHaftalikPlan[key] = value.map((e) => Gorev(e.ad, false, e.tip)).toList();
        });
        kaydet();
        return true;
      }
    } catch (e) {
      debugPrint("AI program generation error: $e");
    }

    // Fail-safe: Yerel algoritmik kural motoru
    baslangicPrograminiAta(
      ekipman: ekipmanTuru,
      rank: hunterRank,
      idmanGunu: gunSayisi,
      hedef: aktifHedef,
      eklemKisitlari: eklemKisiti,
      hedefOdakBolgeleri: odakBolgeleri,
    );
    kaydet();
    return false;
  }

  /// Avcının rütbe, odak bölgesi ve dövüş durumuna göre tek tıkla 3-4 hareketlik "AI Booster / Finisher" üretir.
  /// API varsa Gemini'den alır; yoksa yerel akıllı kural motorundan anında üretir.
  /// [sadeceBunuYap] true ise günün mevcut hareketlerini siler; false ise altına ekler (append).
  static Future<List<Gorev>> aiEkIdmanBoosterUret({int? gun, bool sadeceBunuYap = false}) async {
    final hedefGun = gun ?? DateTime.now().weekday;
    List<Gorev>? boosterGorevler;

    if (geminiApiKey.trim().isNotEmpty) {
      try {
        boosterGorevler = await GeminiService.aiEkIdmanUret(
          rank: hunterRank,
          dovuscuMu: dovusSporuYapiyorMu,
          dovusBranslari: dovusBranslari.isNotEmpty ? dovusBranslari : [dovusBransi],
          odakBolgeleri: odakBolgeleri,
          eklemKisitlari: eklemKisiti,
        );
      } catch (e) {
        debugPrint("AI booster error: $e");
      }
    }

    // Yerel akıllı yedek motor (Fail-safe)
    if (boosterGorevler == null || boosterGorevler.isEmpty) {
      boosterGorevler = [];
      if (dovusSporuYapiyorMu) {
        final shadows = dovusGolgeBoksuKombinasyonlari(brans: dovusBransi);
        boosterGorevler.addAll([
          Gorev("[COMBAT] $dovusBransi: Patlayıcı Şınav & Yumruk Torku (4 Set x 12)", false, "Fiziksel"),
          ...shadows.take(2),
          Gorev("[COMBAT] Burpee Sprawl & Darbe Direnci Core (5 Set x 15)", false, "Fiziksel"),
          Gorev("[CARDIO] 20 Dk Yüksek Yoğunluklu İp Atlama HIIT & Ayak Çevikliği", false, "Fiziksel"),
        ]);
      } else if (odakBolgeleri.any((o) => o.contains('Karın') || o.contains('Göbek'))) {
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

    haftalikPlan.putIfAbsent(hedefGun, () => []);
    if (sadeceBunuYap) {
      haftalikPlan[hedefGun]!.clear();
    }
    haftalikPlan[hedefGun]!.addAll(boosterGorevler);
    kaydet();
    return boosterGorevler;
  }

  static String tartiGuncelle(double yeniKilo) {
    double eskiKilo = kilo; double fark = eskiKilo - yeniKilo; 
    oyuncuyuAnalizEt(cinsiyet, dogumTarihi!, boy, yeniKilo, aktifHedef, aktifZorluk, profilFotoByte);
    kiloGecmisi.add({ 'tarih': DateTime.now().toIso8601String(), 'kilo': yeniKilo, 'kalori': bugunAlinanKalori });
    
    if (fark == 0) return "[SYSTEM] No change in body mass detected.";

    String rapor = "";
    if (aktifHedef == 'Kilo Ver (Yağ Yak)') {
      if (fark > 0) { 
        int kazanilanAltin = (fark * 500).toInt(); int kazanilanAP = fark.toInt(); if (kazanilanAP < 1) kazanilanAP = 1; 
        altin.value += kazanilanAltin; ap.value += kazanilanAP;
        rapor = "[ACHIEVEMENT UNLOCKED] $fark kg mass shed!\nREWARD: +$kazanilanAltin Gold | +$kazanilanAP AP"; AudioSystem.playSuccess();
      } else { 
        if(!golgeModuAktif) { hp.value -= 20; if(hp.value < 0) hp.value = 0; rapor = "[SYSTEM WARNING] ${fark.abs()} kg mass regained. Discipline violated!\nPENALTY: -20 HP"; }
        else { rapor = "[STEALTH MODE] Mass regained, but penalty bypassed."; }
      }
    } 
    else if (aktifHedef == 'Kilo Al (Kas İnşa Et)') {
      if (fark < 0) { 
        double alinan = fark.abs(); int kazanilanAltin = (alinan * 500).toInt(); int kazanilanAP = alinan.toInt(); if (kazanilanAP < 1) kazanilanAP = 1;
        altin.value += kazanilanAltin; ap.value += kazanilanAP;
        rapor = "[ACHIEVEMENT UNLOCKED] $alinan kg muscle built!\nREWARD: +$kazanilanAltin Gold | +$kazanilanAP AP"; AudioSystem.playSuccess();
      } else { 
        if(!golgeModuAktif) { hp.value -= 20; if(hp.value < 0) hp.value = 0; rapor = "[SYSTEM WARNING] $fark kg mass lost. Insufficient nutrition!\nPENALTY: -20 HP"; }
        else { rapor = "[STEALTH MODE] Mass lost, but penalty bypassed."; }
      }
    } else { rapor = "[SYSTEM] Weight updated. Maintain the balance."; }
    kaydet(); return rapor;
  }

  static String expKazan(int miktar) {
    exp.value += miktar; String levelUpMesaji = "";
    while (exp.value >= maxExp.value) {
      exp.value -= maxExp.value; level.value++; maxExp.value = (maxExp.value * 1.5).round(); ap.value += 3; 
      hp.value = maxHp; mp.value = maxMp; fatigue.value = 0;
      levelUpMesaji += "\n🌟 LEVEL UP! You reached Level ${level.value}! (+3 AP)\n[INFO] Status Recovery applied.";
      AudioSystem.playLevelUp();
    }
    kaydet(); return levelUpMesaji;
  }

  static String _gunSonuHesaplasmasi(int degerlendirilenGun) {
    String rapor = ""; int hpFarki = 0; int mpFarki = 0; int kazanilanExp = 0;
    int kazanilanSTR = 0; int kazanilanAGI = 0; int kazanilanVIT = 0; int kazanilanINT = 0; int kazanilanPER = 0;
    int kazanilanAltin = 0; 

    if (redGateAktif) {
      redGateKalanGun--;
      rapor += "[ 🩸 RED GATE ACTIVE: NO ESCAPE. $redGateKalanGun DAYS REMAINING ]\n\n";
    } else if (golgeModuAktif) {
      rapor += "[ 🌙 STEALTH MODE ACTIVE: All Penalties Disabled ]\n\n";
    }

    if (bugunCheatMealAktif) {
      rapor += "[ 🍔 CHEAT PASS ACTIVE ] Calorie excess penalty waived for today!\n";
    } else if (bugunAlinanKalori > gunlukHedefKalori) { 
      if (redGateAktif) { hpFarki -= 60; rapor += "[FATAL PENALTY] Calorie Limit Exceeded in Hell: -60 HP\n"; }
      else if (!golgeModuAktif) { hpFarki -= 20; rapor += "[PENALTY] Calorie Limit Exceeded: -20 HP\n"; }
      else { rapor += "[STEALTH] Calorie Excess Ignored.\n"; }
    } 
    else { hpFarki += 10; kazanilanExp += 20; kazanilanVIT += 1; kazanilanAltin += 20; rapor += "[REWARD] Ideal Diet: +10 HP, +20 EXP, +1 VIT, +20 G\n"; }

    if (uyunanSaat < 7) { 
      if (redGateAktif) { mpFarki -= 15; rapor += "[FATAL PENALTY] Insufficient Rest in Hell: -15 MP\n"; }
      else if (!golgeModuAktif) { mpFarki -= 4; rapor += "[PENALTY] Insufficient Sleep: -4 MP\n"; }
      else { rapor += "[STEALTH] Sleep Deficit Ignored.\n"; }
    } 
    else { mpFarki += 2; kazanilanExp += 10; kazanilanVIT += 1; kazanilanAltin += 10; rapor += "[REWARD] Solid Rest: +2 MP, +10 EXP, +1 VIT, +10 G\n"; }

    // SU HEDEFİ KONTROLÜ
    if (bugunIcilenSuMl.value >= suHedefiMl && suHedefiMl > 0) {
      hpFarki += 5;
      kazanilanExp += 10;
      rapor += "[REWARD] Hydration Goal Achieved (${bugunIcilenSuMl.value}ml): +5 HP, +10 EXP\n";
    }

    List<Gorev> oGununProgrami = haftalikPlan[degerlendirilenGun]!;
    
    int topFiziksel = 0; int bitenFiziksel = 0; int topZihinsel = 0; int bitenZihinsel = 0;
    int strGorevleri = 0; int agiGorevleri = 0; int intGorevleri = 0; int perGorevleri = 0;

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
          if (g.ad.contains("Meditasyon") || g.ad.contains("Strateji")) {
            perGorevleri++;
          } else {
            intGorevleri++;
          } 
        } 
      } 
    }

    int toplamGorev = topFiziksel + topZihinsel;
    int toplamBiten = bitenFiziksel + bitenZihinsel;
    bitenGorevSayisi += toplamBiten; 

    if (bugunGamingPassAktif) {
      rapor += "[ 🎮 GAMING PASS ACTIVE ] 2-hour entertainment privilege granted. No penalty.\n";
    }

    if (bugunSlothDayAktif) {
      rapor += "[ 🦥 SLOTH PASS ACTIVE ] Quests excused today. Streak preserved without penalty!\n";
    } else if (toplamGorev > 0) {
      if (toplamBiten == toplamGorev) {
        streakGunSayisi++;
        rapor += "[STREAK] Flawless Day Streak: $streakGunSayisi Days!\n";
      } else {
        if (!golgeModuAktif || redGateAktif) {
          streakGunSayisi = 0;
          rapor += "[STREAK BROKEN] Discipline lost, Streak reset.\n";
        } else {
          rapor += "[STEALTH] Streak Frozen. No penalty applied.\n";
        }
      }
    }

    if (degerlendirilenGun == 7) {
      bossGuncelle(gunIndex: 7); 
      if (bossHP.value <= 0 && bossMaxHP > 0) {
        kazanilanAltin += 1000; ap.value += 2; kazanilanExp += 500;
        rapor += "\n[BOSS DEFEATED] $bossIsim was annihilated!\nREWARD: +1000 G | +2 AP | +500 EXP\n";
        AudioSystem.playSuccess();
      } else if (bossMaxHP > 0) {
        if (redGateAktif) {
           rapor += "\n[RED GATE] The Weekly Boss dares not enter this Hell.\n";
        } else if (!golgeModuAktif) {
          int cezaHp = (hp.value / 2).round(); hpFarki -= cezaHp; 
          rapor += "\n[DUNGEON DEFEAT] $bossIsim heavily wounded you!\nPENALTY: -$cezaHp HP\n";
        } else {
          rapor += "\n[STEALTH] Weekly Boss ignored your dormant presence.\n";
        }
      }
    }

    if (topFiziksel > 0) {
      int kacan = topFiziksel - bitenFiziksel; 
      hpFarki += (bitenFiziksel * 15); 
      kazanilanExp += (bitenFiziksel * (redGateAktif ? 75 : 25)); 
      kazanilanAltin += (bitenFiziksel * (redGateAktif ? 150 : 50)); 
      
      if (redGateAktif) {
        hpFarki -= (kacan * 45);
      } else if (!golgeModuAktif && !bugunSlothDayAktif) {
        hpFarki -= (kacan * 15);
      } 
      
      if (strGorevleri > 0) kazanilanSTR += 1;
      if (agiGorevleri > 0) kazanilanAGI += 1;

      String statMesaji = "";
      if (kazanilanSTR > 0) statMesaji += "+$kazanilanSTR STR ";
      if (kazanilanAGI > 0) statMesaji += "+$kazanilanAGI AGI ";

      if (kacan == 0 && bitenFiziksel > 0) { 
        kazanilanVIT += 1; kazanilanAltin += 50; statMesaji += "+1 VIT ";
        rapor += "[REWARD] Flawless Workout: +${bitenFiziksel*15} HP, $statMesaji\n"; 
      } 
      else if (bitenFiziksel > 0) { rapor += "[INFO] Partial Workout: +${bitenFiziksel*15} HP, ${(golgeModuAktif || bugunSlothDayAktif) ? '0' : '-${kacan*15}'} HP, $statMesaji\n"; } 
      else { rapor += redGateAktif ? "[FATAL PENALTY] Workout Neglected: -${kacan*45} HP\n" : ((golgeModuAktif || bugunSlothDayAktif) ? "[STEALTH/SLOTH] Workout Ignored safely.\n" : "[PENALTY] Workout Neglected: -${kacan*15} HP\n"); }
    }

    if (topZihinsel > 0) {
      int kacan = topZihinsel - bitenZihinsel; 
      mpFarki += (bitenZihinsel * 5); 
      kazanilanExp += (bitenZihinsel * (redGateAktif ? 60 : 20)); 
      kazanilanAltin += (bitenZihinsel * (redGateAktif ? 90 : 30)); 
      
      if (redGateAktif) {
        mpFarki -= (kacan * 15);
      } else if (!golgeModuAktif && !bugunSlothDayAktif) {
        mpFarki -= (kacan * 5);
      }
      
      if (intGorevleri > 0) kazanilanINT += 1;
      if (perGorevleri > 0) kazanilanPER += 1;

      String statMesaji = "";
      if (kazanilanINT > 0) statMesaji += "+$kazanilanINT INT ";
      if (kazanilanPER > 0) statMesaji += "+$kazanilanPER PER ";

      if (kacan == 0 && bitenZihinsel > 0) { 
        kazanilanAltin += 30;
        rapor += "[REWARD] Flawless Mental Training: +${bitenZihinsel*5} MP, $statMesaji\n"; 
      } 
      else if (bitenZihinsel > 0) { rapor += "[INFO] Partial Mental Training: +${bitenZihinsel*5} MP, ${(golgeModuAktif || bugunSlothDayAktif) ? '0' : '-${kacan*5}'} MP, $statMesaji\n"; } 
      else { rapor += redGateAktif ? "[FATAL PENALTY] Mind Neglected: -${kacan*15} MP\n" : ((golgeModuAktif || bugunSlothDayAktif) ? "[STEALTH/SLOTH] Mind Training Ignored safely.\n" : "[PENALTY] Mind Neglected: -${kacan*5} MP\n"); }
    }

    hp.value += hpFarki; 
    
    if (hp.value <= 0 && redGateAktif) {
      rapor += "\n[ 💀 DEATH IN RED GATE 💀 ]\nYou failed to survive the hell. Your life force was drained.\nPENALTY: -1 LEVEL, 0 EXP.\n";
      level.value = level.value > 1 ? level.value - 1 : 1; 
      exp.value = 0; 
      hp.value = maxHp; 
      kirmiziGecittenCik();
    }
    else if (hp.value < 0) { hp.value = 0; }
    else if (hp.value > maxHp) { hp.value = maxHp; }
    
    mp.value += mpFarki; if (mp.value > maxMp) mp.value = maxMp; if (mp.value < 0) mp.value = 0;
    altin.value += kazanilanAltin; 

    str.value += kazanilanSTR; agi.value += kazanilanAGI; vit.value += kazanilanVIT; intStat.value += kazanilanINT; per.value += kazanilanPER;
    maxHp += (kazanilanVIT * 10); maxMp += (kazanilanINT * 2);

    String levelRaporu = expKazan(kazanilanExp);

    if (redGateAktif && redGateKalanGun <= 0 && hp.value > 0) {
      int odulAP = redGateToplamGun * 1;
      int odulAltin = redGateToplamGun * 1500;
      int odulEXP = redGateToplamGun * 300;

      rapor += "\n[ 👑 RED GATE CLEARED 👑 ]\nYou survived $redGateToplamGun Days of absolute Hell.\nULTIMATE REWARD: +$odulAP AP, +$odulAltin G, +$odulEXP EXP, FULL RECOVERY!\n";
      ap.value += odulAP; 
      altin.value += odulAltin; 
      hp.value = maxHp; 
      mp.value = maxMp; 
      
      kirmiziGecittenCik();
      levelRaporu += expKazan(odulEXP);
      AudioSystem.playLevelUp();
    }

    if (bugununYemekleri.isNotEmpty || bugunAlinanKalori > 0) {
      yemekGecmisi.add({
        'tarih': sonGirisTarihi,
        'toplamKalori': bugunAlinanKalori,
        'yemekler': bugununYemekleri.map((e) => e.toJson()).toList()
      });
    }

    bugunAlinanKalori = 0; 
    bugununYemekleri.clear(); 
    uyunanSaat = 0;
    bugunIcilenSuMl.value = 0;
    bugunCheatMealAktif = false;
    bugunSlothDayAktif = false;
    bugunGamingPassAktif = false;
    
    // Yalnızca değerlendirilen günün görevleri sıfırlanır (haftanın diğer günleri korunur)
    if (haftalikPlan.containsKey(degerlendirilenGun)) {
      for (var g in haftalikPlan[degerlendirilenGun]!) {
        g.yapildiMi = false;
      }
    }

    return "$rapor\n[QUEST LOG]\nNET HP: ${hpFarki > 0 ? '+' : ''}$hpFarki | GOLD EARNED: $kazanilanAltin 🪙 | EXP EARNED: $kazanilanExp$levelRaporu";
  }

  /// Test ve harici tetikleme için gün sonu hesaplaşması
  static String gunSonuHesaplasmasi(int degerlendirilenGun) => _gunSonuHesaplasmasi(degerlendirilenGun);

  static void statuYukselt(String statAdi) {
    if (ap.value > 0) {
      ap.value--;
      if (statAdi == 'STR') {
        str.value++;
      } else if (statAdi == 'AGI') {
        agi.value++;
      } else if (statAdi == 'VIT') {
        vit.value++; maxHp += 10; hp.value += 10;
      } else if (statAdi == 'INT') {
        intStat.value++; maxMp += 2; mp.value += 2;
      } else if (statAdi == 'PER') {
        per.value++;
      }
      kaydet(); 
    } 
  }

  /// Oyuncunun disiplinine, dövüş branşına ve antrenman hedefine göre AP puanlarını akıllıca dağıtır.
  static Map<String, int> otomatikStatDagit({int? miktar}) {
    int dagitilacak = miktar ?? ap.value;
    if (dagitilacak <= 0 || ap.value <= 0) return {};
    if (dagitilacak > ap.value) dagitilacak = ap.value;

    // 1. Profil ve hedefe göre stat ağırlık katsayılarını belirle
    double wStr = 1.0;
    double wAgi = 1.0;
    double wVit = 1.0;
    double wInt = 0.6;
    double wPer = 0.8;

    // Dövüşçü Profili
    if (dovusSporuYapiyorMu) {
      wAgi += 1.8; // Hızlı ayaklar, refleks, kombinasyon
      wStr += 1.4; // Vuruş ve nakavt patlayıcılığı
      wVit += 1.2; // Raund kondisyonu ve dayanıklılık
      wPer += 1.0; // Mesafe, ring zekası ve sezgi
    }

    // Hedef Kilo / Kas / Yağ
    if (aktifHedef.contains('Kilo Al') || aktifHedef.contains('Kas')) {
      wStr += 1.6; // Hipertrofi & Big 3 kuvveti
      wVit += 1.2; // Kas toparlanması
    } else if (aktifHedef.contains('Kilo Ver') || aktifHedef.contains('Yağ')) {
      wAgi += 1.4; // Yüksek kalori yakımı & hız
      wVit += 1.4; // Kardiyovasküler direnç
    }

    // Ekipman & Branş İnce Ayarı
    if (ekipmanTuru == 'Vucut-Agirligi') {
      wAgi += 1.0;
      wPer += 0.6;
    }

    final bransKucuk = (dovusBransi + dovusBranslari.join(' ')).toLowerCase();
    if (bransKucuk.contains('boks') || bransKucuk.contains('striking')) {
      wAgi += 0.8;
      wPer += 0.6;
    }
    if (bransKucuk.contains('güreş') || bransKucuk.contains('grappling') || bransKucuk.contains('mma')) {
      wStr += 1.0;
      wVit += 1.0;
    }

    Map<String, int> dagitilanlar = {'STR': 0, 'AGI': 0, 'VIT': 0, 'INT': 0, 'PER': 0};

    // Ağırlıklı dağıtım döngüsü
    for (int i = 0; i < dagitilacak; i++) {
      Map<String, double> oncelik = {
        'STR': wStr / (str.value + dagitilanlar['STR']! + 1),
        'AGI': wAgi / (agi.value + dagitilanlar['AGI']! + 1),
        'VIT': wVit / (vit.value + dagitilanlar['VIT']! + 1),
        'INT': wInt / (intStat.value + dagitilanlar['INT']! + 1),
        'PER': wPer / (per.value + dagitilanlar['PER']! + 1),
      };

      String secilen = oncelik.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
      dagitilanlar[secilen] = (dagitilanlar[secilen] ?? 0) + 1;
    }

    // Uygula
    int gercekDagitilan = 0;
    dagitilanlar.forEach((stat, adet) {
      if (adet > 0) {
        if (stat == 'STR') {
          str.value += adet;
        } else if (stat == 'AGI') {
          agi.value += adet;
        } else if (stat == 'VIT') {
          vit.value += adet;
          maxHp += adet * 10;
          hp.value += adet * 10;
        } else if (stat == 'INT') {
          intStat.value += adet;
          maxMp += adet * 2;
          mp.value += adet * 2;
        } else if (stat == 'PER') {
          per.value += adet;
        }
        gercekDagitilan += adet;
      }
    });

    ap.value -= gercekDagitilan;
    if (ap.value < 0) ap.value = 0;
    kaydet();
    return dagitilanlar;
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
  static Future<void> sistemiSifirla() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    kayitBulundu = false;
    geminiApiKey = "";
    redGateAktif = false;
    golgeModuAktif = false;
    haftalikPlan.clear();
    for(int i=1; i<=7; i++) {
      haftalikPlan[i] = [];
    }
    normalHaftalikPlan.clear();
    for(int i=1; i<=7; i++) {
      normalHaftalikPlan[i] = [];
    }
    overloadGecmisi.clear();
    level.value = 1;
    exp.value = 0;
    hp.value = 100;
    profilFotoByte = null;
  }

  // ==========================================
  // SHADOW PROTOCOL (ARKAPLAN İZİNLERİ & WAKELOCK)
  // ==========================================
  static void idmanModunuBaslat() {
    if (!_isTest) {
      try {
        WakelockPlus.enable(); // Ekranın kapanmasını engeller
      } catch (_) {}
    }
    // Arkaplan servisine idman başladığını bildir (İleride eklenecek)
  }

  static void idmanModunuBitir() {
    if (!_isTest) {
      try {
        WakelockPlus.disable(); // Normale dön
      } catch (_) {}
    }
  }

  // ========================================================
  // SU TAKİBİ METOTLARI
  // ========================================================
  static void suEkle(int miktarMl) {
    bugunIcilenSuMl.value += miktarMl;
    kaydet();
  }

  static void suSifirla() {
    bugunIcilenSuMl.value = 0;
    kaydet();
  }

  // ========================================================
  // AVCI ÇANTASI (INVENTORY) METOTLARI
  // ========================================================
  static void esyaEkle(InventoryItem yeniEsya) {
    final index = canta.indexWhere((e) => e.aksiyon == yeniEsya.aksiyon);
    if (index != -1) {
      canta[index].adet += yeniEsya.adet;
    } else {
      canta.add(yeniEsya);
    }
    kaydet();
  }

  static String esyaKullan(String aksiyon) {
    final index = canta.indexWhere((e) => e.aksiyon == aksiyon);
    if (index == -1 || canta[index].adet <= 0) {
      return "SYSTEM WARNING: Item not found in inventory!";
    }

    final esya = canta[index];
    String rapor = "";

    if (aksiyon == "hp_full") {
      acilSifa();
      rapor = "[HP FULL] Life force completely restored!";
    } else if (aksiyon == "stat_reset") {
      statuleriSifirla();
      rapor = "[STAT RESET] All stats reset to 10. AP refunded!";
    } else if (aksiyon == "cheat_meal" || aksiyon == "minor_cheat" || aksiyon == "endless_feast") {
      bugunCheatMealAktif = true;
      rapor = "[CHEAT PASS ACTIVATED] Calorie penalty will be bypassed tonight!";
    } else if (aksiyon == "sloth_day") {
      bugunSlothDayAktif = true;
      rapor = "[SLOTH DAY ACTIVATED] Daily quest penalties waived for today!";
    } else if (aksiyon == "gaming_pass") {
      bugunGamingPassAktif = true;
      rapor = "[GAMING PASS ACTIVATED] 2-hour entertainment pass granted. Rest, Hunter.";
    } else {
      rapor = "[REWARD USED] ${esya.ad} claimed in real world!";
    }

    esya.adet--;
    if (esya.adet <= 0) {
      canta.removeAt(index);
    }
    AudioSystem.playSuccess();
    kaydet();
    return rapor;
  }

  // ========================================================
  // VERİ YEDEKLEME VE GERİ YÜKLEME (BACKUP & RESTORE)
  // ========================================================
  static String exportBackupJson() {
    final data = {
      'oyuncuIsmi': oyuncuIsmi,
      'cinsiyet': cinsiyet,
      'level': level.value,
      'exp': exp.value,
      'maxExp': maxExp.value,
      'ap': ap.value,
      'altin': altin.value,
      'hp': hp.value,
      'maxHp': maxHp,
      'mp': mp.value,
      'maxMp': maxMp,
      'str': str.value,
      'agi': agi.value,
      'vit': vit.value,
      'intStat': intStat.value,
      'per': per.value,
      'boy': boy,
      'kilo': kilo,
      'hedefKilo': hedefKilo,
      'avciDiyetNotu': avciDiyetNotu,
      'baslangicKilosu': baslangicKilosu,
      'streakGunSayisi': streakGunSayisi,
      'bitenGorevSayisi': bitenGorevSayisi,
      'suHedefiMl': suHedefiMl,
      'bugunIcilenSuMl': bugunIcilenSuMl.value,
      'gunlukHedefKalori': gunlukHedefKalori,
      'vucutSinifi': vucutSinifi,
      'aktifHedef': aktifHedef,
      'aktifZorluk': aktifZorluk,
      'maxBench': maxBench,
      'maxSquat': maxSquat,
      'maxDeadlift': maxDeadlift,
      'hunterRank': hunterRank,
      'ekipmanTuru': ekipmanTuru,
      'antrenmanGecmisi': antrenmanGecmisi,
      'eklemKisiti': eklemKisiti,
      'odakBolgeleri': odakBolgeleri,
      'sonTestTarihi': sonTestTarihi,
      'sonTesttenBeriIdmanSayisi': sonTesttenBeriIdmanSayisi,
      'dovusSporuYapiyorMu': dovusSporuYapiyorMu,
      'dovusBransi': dovusBransi,
      'dovusBranslari': dovusBranslari,
      'maxPatlayiciSinav': maxPatlayiciSinav,
      'maxBurpeeKondisyon': maxBurpeeKondisyon,
      'maxPlankSaniye': maxPlankSaniye,
      'maxBarfiks': maxBarfiks,
      'gogusCm': gogusCm,
      'belCm': belCm,
      'kolCm': kolCm,
      'bacakCm': bacakCm,
      'kiloGecmisi': kiloGecmisi,
      'idmanGecmisi': idmanGecmisi,
      'yemekGecmisi': yemekGecmisi,
      'toplamIdmanDakikasi': toplamIdmanDakikasi,
      'geminiApiKey': geminiApiKey,
      'geminiActiveModel': geminiActiveModel,
      'canta': canta.map((e) => e.toJson()).toList(),
      'backupTimestamp': DateTime.now().toIso8601String(),
    };
    return jsonEncode(data);
  }

  static bool importBackupJson(String rawJson) {
    try {
      final Map<String, dynamic> data = jsonDecode(rawJson);
      if (data.containsKey('level') && data.containsKey('oyuncuIsmi')) {
        oyuncuIsmi = data['oyuncuIsmi']?.toString() ?? oyuncuIsmi;
        cinsiyet = data['cinsiyet']?.toString() ?? cinsiyet;
        level.value = (data['level'] as num?)?.toInt() ?? level.value;
        exp.value = (data['exp'] as num?)?.toInt() ?? exp.value;
        maxExp.value = (data['maxExp'] as num?)?.toInt() ?? maxExp.value;
        ap.value = (data['ap'] as num?)?.toInt() ?? ap.value;
        altin.value = (data['altin'] as num?)?.toInt() ?? altin.value;
        hp.value = (data['hp'] as num?)?.toInt() ?? hp.value;
        maxHp = (data['maxHp'] as num?)?.toInt() ?? maxHp;
        mp.value = (data['mp'] as num?)?.toInt() ?? mp.value;
        maxMp = (data['maxMp'] as num?)?.toInt() ?? maxMp;
        str.value = (data['str'] as num?)?.toInt() ?? str.value;
        agi.value = (data['agi'] as num?)?.toInt() ?? agi.value;
        vit.value = (data['vit'] as num?)?.toInt() ?? vit.value;
        intStat.value = (data['intStat'] as num?)?.toInt() ?? intStat.value;
        per.value = (data['per'] as num?)?.toInt() ?? per.value;
        boy = (data['boy'] as num?)?.toDouble() ?? boy;
        kilo = (data['kilo'] as num?)?.toDouble() ?? kilo;
        if (data['hedefKilo'] != null) {
          hedefKilo = (data['hedefKilo'] as num).toDouble();
        }
        if (data['avciDiyetNotu'] != null) {
          avciDiyetNotu = data['avciDiyetNotu'].toString();
        }
        baslangicKilosu = (data['baslangicKilosu'] as num?)?.toDouble() ?? baslangicKilosu;
        streakGunSayisi = (data['streakGunSayisi'] as num?)?.toInt() ?? streakGunSayisi;
        bitenGorevSayisi = (data['bitenGorevSayisi'] as num?)?.toInt() ?? bitenGorevSayisi;
        suHedefiMl = (data['suHedefiMl'] as num?)?.toInt() ?? suHedefiMl;

        if (data['bugunIcilenSuMl'] != null) {
          bugunIcilenSuMl.value = (data['bugunIcilenSuMl'] as num).toInt();
        }
        if (data['gunlukHedefKalori'] != null) {
          gunlukHedefKalori = (data['gunlukHedefKalori'] as num).toInt();
        }
        if (data['vucutSinifi'] != null) {
          vucutSinifi = data['vucutSinifi'].toString();
        }
        if (data['aktifHedef'] != null) {
          aktifHedef = data['aktifHedef'].toString();
        }
        if (data['aktifZorluk'] != null) {
          aktifZorluk = data['aktifZorluk'].toString();
        }
        if (data['maxBench'] != null) {
          maxBench = (data['maxBench'] as num).toDouble();
        }
        if (data['maxSquat'] != null) {
          maxSquat = (data['maxSquat'] as num).toDouble();
        }
        if (data['maxDeadlift'] != null) {
          maxDeadlift = (data['maxDeadlift'] as num).toDouble();
        }
        if (data['hunterRank'] != null) {
          hunterRank = data['hunterRank'].toString();
        }
        if (data['ekipmanTuru'] != null) {
          ekipmanTuru = data['ekipmanTuru'].toString();
        }
        if (data['antrenmanGecmisi'] != null) {
          antrenmanGecmisi = data['antrenmanGecmisi'].toString();
        }
        if (data['eklemKisiti'] != null && data['eklemKisiti'] is List) {
          eklemKisiti = List<String>.from((data['eklemKisiti'] as List).map((e) => e.toString()));
        }
        if (data['odakBolgeleri'] != null && data['odakBolgeleri'] is List) {
          odakBolgeleri = List<String>.from((data['odakBolgeleri'] as List).map((e) => e.toString()));
        }
        if (data['sonTestTarihi'] != null) {
          sonTestTarihi = data['sonTestTarihi'].toString();
        }
        if (data['sonTesttenBeriIdmanSayisi'] != null) {
          sonTesttenBeriIdmanSayisi = (data['sonTesttenBeriIdmanSayisi'] as num).toInt();
        }
        if (data['dovusSporuYapiyorMu'] != null) {
          dovusSporuYapiyorMu = data['dovusSporuYapiyorMu'] == true;
        }
        if (data['dovusBransi'] != null) {
          dovusBransi = data['dovusBransi'].toString();
        }
        if (data['dovusBranslari'] != null && data['dovusBranslari'] is List) {
          dovusBranslari = List<String>.from((data['dovusBranslari'] as List).map((e) => e.toString()));
        }
        if (data['maxPatlayiciSinav'] != null) {
          maxPatlayiciSinav = (data['maxPatlayiciSinav'] as num).toInt();
        }
        if (data['maxBurpeeKondisyon'] != null) {
          maxBurpeeKondisyon = (data['maxBurpeeKondisyon'] as num).toInt();
        }
        if (data['maxPlankSaniye'] != null) {
          maxPlankSaniye = (data['maxPlankSaniye'] as num).toInt();
        }
        if (data['maxBarfiks'] != null) {
          maxBarfiks = (data['maxBarfiks'] as num).toInt();
        }
        if (data['gogusCm'] != null) {
          gogusCm = (data['gogusCm'] as num).toDouble();
        }
        if (data['belCm'] != null) {
          belCm = (data['belCm'] as num).toDouble();
        }
        if (data['kolCm'] != null) {
          kolCm = (data['kolCm'] as num).toDouble();
        }
        if (data['bacakCm'] != null) {
          bacakCm = (data['bacakCm'] as num).toDouble();
        }
        if (data['toplamIdmanDakikasi'] != null) {
          toplamIdmanDakikasi = (data['toplamIdmanDakikasi'] as num).toInt();
        }
        if (data['geminiApiKey'] != null) {
          geminiApiKey = data['geminiApiKey'].toString();
        }
        if (data['geminiActiveModel'] != null) {
          geminiActiveModel = data['geminiActiveModel'].toString();
        }

        if (data['kiloGecmisi'] != null && data['kiloGecmisi'] is List) {
          kiloGecmisi = List<Map<String, dynamic>>.from(
            (data['kiloGecmisi'] as List).map((x) => Map<String, dynamic>.from(x as Map)),
          );
        }
        if (data['idmanGecmisi'] != null && data['idmanGecmisi'] is List) {
          idmanGecmisi = List<Map<String, dynamic>>.from(
            (data['idmanGecmisi'] as List).map((x) => Map<String, dynamic>.from(x as Map)),
          );
        }
        if (data['yemekGecmisi'] != null && data['yemekGecmisi'] is List) {
          yemekGecmisi = List<Map<String, dynamic>>.from(
            (data['yemekGecmisi'] as List).map((x) => Map<String, dynamic>.from(x as Map)),
          );
        }

        if (data['canta'] != null) {
          final List<dynamic> cList = data['canta'];
          canta = cList.map((e) => InventoryItem.fromJson(e)).toList();
        }
        kaydet();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}