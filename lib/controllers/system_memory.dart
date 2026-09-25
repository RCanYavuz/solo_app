import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../models/task_model.dart';
import '../models/food_model.dart';
import '../models/inventory_item_model.dart';
import '../models/mental_task_model.dart';
import '../core/progressive_overload_engine.dart';
import '../core/advanced_metabolic_engine.dart';

import 'memory_modules/memory_storage.dart';
import 'memory_modules/memory_workout.dart';
import 'memory_modules/memory_nutrition.dart';
import 'memory_modules/memory_combat_ranks.dart';
import '../core/services/notification_service.dart';
import '../core/services/photo_storage_service.dart';

class SystemMemory {
  // ==========================================
  // DURUM DEĞİŞKENLERİ & STATS (VALUE NOTIFIERS)
  // ==========================================
  static bool kayitBulundu = false;
  static bool golgeModuAktif = false;
  static bool redGateAktif = false;
  static int redGateKalanGun = 0;
  static int redGateToplamGun = 0;
  static int normalGunlukHedefKalori = 0;
  static Map<int, List<Gorev>> normalHaftalikPlan = {};

  static ValueNotifier<int> hp = ValueNotifier(100);
  static ValueNotifier<int> mp = ValueNotifier(10);
  static ValueNotifier<int> fatigue = ValueNotifier(0); 

  static int maxHp = 100;
  static int maxMp = 10;
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
  static ValueNotifier<String> appLanguage = ValueNotifier("en");
  static String geminiApiKey = "";
  static String geminiActiveModel = "gemini-3.6-flash";
  static String sonGirisTarihi = "";
  static String geceRaporu = "";

  static String cinsiyet = "Erkek";
  static DateTime? dogumTarihi;
  static double boy = 175;
  static double kilo = 70;
  static double hedefKilo = 70;
  static String avciDiyetNotu = "";
  static String sonAiHedefKiloYorumu = "";
  static double baslangicKilosu = 0;
  static int streakGunSayisi = 0;
  static int bitenGorevSayisi = 0;

  static List<Map<String, dynamic>> kiloGecmisi = [];
  static int toplamIdmanDakikasi = 0;
  static List<Map<String, dynamic>> idmanGecmisi = [];
  static List<Map<String, dynamic>> yemekGecmisi = [];

  static int gunlukHedefKalori = 0;
  static String vucutSinifi = "Unknown";
  static String aktifHedef = "Unknown";
  static String aktifZorluk = "Unknown";

  // Hunter Strength & Rank
  static double maxBench = 0.0;
  static double maxSquat = 0.0;
  static double maxDeadlift = 0.0;
  static String hunterRank = "Unranked";
  static String ekipmanTuru = "Salon";
  static String antrenmanGecmisi = "Başlangıç";
  static List<String> eklemKisiti = [];
  static List<String> odakBolgeleri = [];
  static String sonTestTarihi = "";
  static int sonTesttenBeriIdmanSayisi = 0;
  static ValueNotifier<bool> otomatikStatDagitimiAktif = ValueNotifier<bool>(false);

  // Dövüş Sanatları Statüleri
  static bool dovusSporuYapiyorMu = false;
  static String dovusBransi = "Boks";
  static List<String> dovusBranslari = ["Boks"];
  static int maxPatlayiciSinav = 0;
  static int maxBurpeeKondisyon = 0;
  static int maxPlankSaniye = 0;
  static int maxBarfiks = 0;
  static double gogusCm = 0.0;
  static double belCm = 0.0;
  static double kolCm = 0.0;
  static double bacakCm = 0.0;

  // Profil Fotoğrafları
  static Uint8List? profilFotoByte;
  static Uint8List? avatarFotoByte;

  static Future<void> profilFotoGuncelle(Uint8List bytes) async {
    profilFotoByte = bytes;
    await PhotoStorageService.instance.saveProfilePhoto(bytes);
    await kaydet();
  }

  static Future<void> avatarFotoGuncelle(Uint8List bytes) async {
    avatarFotoByte = bytes;
    await PhotoStorageService.instance.saveAvatarPhoto(bytes);
    await kaydet();
  }

  // Günlük Geçici Değerler
  static int bugunAlinanKalori = 0;    
  static List<TuketilenYemek> bugununYemekleri = [];
  static int uyunanSaat = 0;           

  // Planlar & Envanter & Su
  static Map<int, List<Gorev>> haftalikPlan = { 1: [], 2: [], 3: [], 4: [], 5: [], 6: [], 7: [] };
  static Map<String, OverloadKaydi> overloadGecmisi = {};
  static List<String> kusanilanSuplementler = [];
  static ValueNotifier<bool> sesliKocAktif = ValueNotifier(true);

  static int suHedefiMl = 3000;
  static ValueNotifier<int> bugunIcilenSuMl = ValueNotifier(0);
  static bool bugunCheatMealAktif = false;
  static bool bugunSlothDayAktif = false;
  static bool bugunGamingPassAktif = false;
  static List<InventoryItem> canta = [];

  // Diyetisyen Listesi
  static bool diyetisyenListesiAktif = false;
  static int diyetisyenBazKalori = 0;
  static int diyetisyenBazProtein = 0;
  static int diyetisyenBazKarb = 0;
  static int diyetisyenBazYag = 0;
  static List<Map<String, dynamic>> diyetisyenOgunleri = [];
  static String diyetisyenBaslangicTarihi = "";
  static Map<String, dynamic> diyetisyenGunlukPlanlar = {};

  // Dinamik Katabolizma & Telafi Takibi
  static int bugunYakilanIdmanKalorisi = 0;
  static int bugunTelafiProteini = 0;
  static int bugunTelafiKarbonhidrati = 0;
  static Map<String, dynamic>? sonIdmanYipranmaRaporu;

  // Boss Savaşı
  static ValueNotifier<int> bossHP = ValueNotifier(0);
  static int bossMaxHP = 0;
  static String bossTuru = "Fiziksel";
  static String bossIsim = "Unknown";
  static String bossHaftaId = "";
  static int bossAlinanHaftalikHasar = 0;
  static bool bossYenildiMi = false;

  // Başarımlar Takip Motoru
  static Map<String, int> basarimKademeleri = {};
  static ValueNotifier<String?> yeniBasarimBildirimi = ValueNotifier(null);

  // Bildirim Protokolleri & Tercihleri
  static bool suBildirimiAktif = true;
  static int suBildirimAraligiSaat = 2;
  static bool idmanBildirimiAktif = true;
  static int idmanBildirimSaati = 18;
  static int idmanBildirimDakikasi = 0;
  static bool geceBildirimiAktif = true;

  /// Bildirim tercihlerine göre zamanlamaları günceller
  static Future<void> bildirimleriSenkronizeEt() async {
    final notif = NotificationService.instance;
    if (suBildirimiAktif) {
      await notif.suHatirlaticisiPlanla(intervalHours: suBildirimAraligiSaat);
    } else {
      await notif.suHatirlaticisiIptal();
    }

    if (idmanBildirimiAktif) {
      await notif.idmanHatirlaticisiPlanla(hour: idmanBildirimSaati, minute: idmanBildirimDakikasi);
    } else {
      await notif.idmanHatirlaticisiIptal();
    }

    if (geceBildirimiAktif) {
      await notif.geceHesaplasmaHatirlaticisiPlanla();
    }
  }

  // ==========================================
  // FİZİKSEL GELİŞİM & İLERLEME FOTOĞRAFLARI (TRANSFORMATION VAULT)
  // ==========================================
  static List<Map<String, dynamic>> ilerlemeFotolari = [];

  static Future<void> ilerlemeFotoEkle({
    required Uint8List fotoBytes,
    required double kilo,
    String? not,
    DateTime? tarih,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final filePath = await PhotoStorageService.instance.saveProgressPhoto(fotoBytes, id);
    final entry = {
      'id': id,
      'tarih': (tarih ?? DateTime.now()).toIso8601String(),
      'kilo': kilo,
      'fotoPath': filePath,
      'not': not ?? '',
    };
    ilerlemeFotolari.add(entry);
    await kaydet();
  }

  static Future<void> ilerlemeFotoSil(int index) async {
    if (index >= 0 && index < ilerlemeFotolari.length) {
      final removed = ilerlemeFotolari.removeAt(index);
      final filePath = removed['fotoPath'] as String?;
      if (filePath != null && filePath.isNotEmpty) {
        await PhotoStorageService.instance.deletePhoto(filePath);
      }
      await kaydet();
    }
  }

  // ==========================================
  // ZİHİNSEL GELİŞİM & ÇALIŞMA PROTOKOLÜ (MIND & STUDY)
  // ==========================================
  static ValueNotifier<List<MentalTask>> gunlukZihinselGorevler = ValueNotifier([]);
  static int toplamOkunanSayfaSayisi = 0;
  static int toplamOdaklanmaDakikasi = 0;
  static String aktifUzmanlikAlani = "Yazılım & AI";
  static List<String> tamamlananKitaplar = [];

  static Future<void> zihinselGorevEkle(MentalTask task) async {
    final list = List<MentalTask>.from(gunlukZihinselGorevler.value);
    list.add(task);
    gunlukZihinselGorevler.value = list;
    await kaydet();
  }

  static Future<void> zihinselGorevSil(String id) async {
    final list = List<MentalTask>.from(gunlukZihinselGorevler.value);
    list.removeWhere((t) => t.id == id);
    gunlukZihinselGorevler.value = list;
    await kaydet();
  }

  static Future<void> zihinselGorevTamamla(String id) async {
    final list = List<MentalTask>.from(gunlukZihinselGorevler.value);
    final index = list.indexWhere((t) => t.id == id);
    if (index != -1 && !list[index].isCompleted) {
      final task = list[index];
      task.isCompleted = true;
      task.completedMinutes = task.targetMinutes;
      if (task.targetPages != null) {
        task.completedPages = task.targetPages!;
        toplamOkunanSayfaSayisi += task.targetPages!;
      }
      toplamOdaklanmaDakikasi += task.targetMinutes;
      bitenGorevSayisi++;

      // Stat ve EXP Ödülleri
      intStat.value += task.rewardInt;
      per.value += task.rewardPer;
      mp.value = (mp.value + 5).clamp(0, maxMp);
      expKazan(task.rewardExp);
      altin.value += 50;

      gunlukZihinselGorevler.value = list;
      await kaydet();
    }
  }

  static Future<void> zihinselGorevGeriAl(String id) async {
    final list = List<MentalTask>.from(gunlukZihinselGorevler.value);
    final index = list.indexWhere((t) => t.id == id);
    if (index != -1 && list[index].isCompleted) {
      final task = list[index];
      task.isCompleted = false;
      task.completedMinutes = 0;
      if (task.targetPages != null) {
        toplamOkunanSayfaSayisi = (toplamOkunanSayfaSayisi - task.completedPages).clamp(0, 999999);
        task.completedPages = 0;
      }
      toplamOdaklanmaDakikasi = (toplamOdaklanmaDakikasi - task.targetMinutes).clamp(0, 999999);
      bitenGorevSayisi = (bitenGorevSayisi - 1).clamp(0, 999999);

      intStat.value = (intStat.value - task.rewardInt).clamp(0, 99999);
      per.value = (per.value - task.rewardPer).clamp(0, 99999);
      exp.value = (exp.value - task.rewardExp).clamp(0, maxExp.value);
      altin.value = (altin.value - 50).clamp(0, 99999999);

      gunlukZihinselGorevler.value = list;
      await kaydet();
    }
  }

  static Future<void> deepWorkTamamlandi({required int dakika, required String baslik}) async {
    toplamOdaklanmaDakikasi += dakika;
    int exp = dakika * 3;
    int intArtis = (dakika / 25).floor().clamp(1, 5);
    int perArtis = (dakika / 30).floor().clamp(1, 3);
    
    intStat.value += intArtis;
    per.value += perArtis;
    expKazan(exp);
    altin.value += dakika * 2;
    mp.value = (mp.value + 4).clamp(0, maxMp);

    final list = List<MentalTask>.from(gunlukZihinselGorevler.value);
    final matchIdx = list.indexWhere((t) => !t.isCompleted && (t.title.toLowerCase().contains(baslik.toLowerCase()) || baslik.toLowerCase().contains(t.title.toLowerCase())));
    if (matchIdx != -1) {
      list[matchIdx].isCompleted = true;
      list[matchIdx].completedMinutes = dakika;
      bitenGorevSayisi++;
      gunlukZihinselGorevler.value = list;
    }
    await kaydet();
  }

  // Makro Besin Toplamları
  static int get bugunProtein => bugununYemekleri.fold(0, (sum, item) => sum + item.protein);
  static int get bugunKarb => bugununYemekleri.fold(0, (sum, item) => sum + item.karbonhidrat);
  static int get bugunYag => bugununYemekleri.fold(0, (sum, item) => sum + item.yag);

  // Dövüşçü ve İdman Sayısı Getters
  static bool get dovuscuMu => dovusSporuYapiyorMu;
  static set dovuscuMu(bool val) => dovusSporuYapiyorMu = val;

  static int get haftalikIdmanGunuSayisi {
    int count = haftalikPlan.values.where((list) => list.isNotEmpty).length;
    return count > 0 ? count : 4;
  }

  static double get hedefKiloIlerlemeYuzdesi {
    if (baslangicKilosu == 0 || hedefKilo == 0 || baslangicKilosu == hedefKilo) return 0.0;
    double toplamHedeflenenFark = (baslangicKilosu - hedefKilo).abs();
    double suAnaKadarVerilenFark = (baslangicKilosu - kilo).abs();
    if (toplamHedeflenenFark <= 0) return 0.0;
    return (suAnaKadarVerilenFark / toplamHedeflenenFark).clamp(0.0, 1.0);
  }

  static BodyCompositionResult get guncelVucutKompozisyonu =>
      AdvancedMetabolicEngine.hesaplaVucutKompozisyonu(
        boyCm: boy > 0 ? boy : 178.0,
        kiloKg: kilo > 0 ? kilo : 75.0,
        cinsiyet: cinsiyet.isNotEmpty ? cinsiyet : 'erkek',
        belCm: belCm > 0 ? belCm : 82.0,
        haftalikIdmanSayisi: haftalikIdmanGunuSayisi,
        dovuscuMu: dovusSporuYapiyorMu,
      );

  // Test modu
  static bool _isTest = false;
  static bool get isTest {
    if (_isTest) return true;
    try {
      return Platform.environment.containsKey('FLUTTER_TEST');
    } catch (_) {
      return false;
    }
  }
  static void testModunuAyarla(bool val) => _isTest = val;

  // ==========================================
  // GETTERS & HESAPLANAN DEĞERLER
  // ==========================================
  static int get yas {
    if (dogumTarihi == null) return 20;
    DateTime bugun = DateTime.now();
    int hesaplananYas = bugun.year - dogumTarihi!.year;
    if (bugun.month < dogumTarihi!.month || (bugun.month == dogumTarihi!.month && bugun.day < dogumTarihi!.day)) hesaplananYas--;
    return hesaplananYas;
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

  // ==========================================
  // DELEGE EDİLEN METOTLAR: STORAGE
  // ==========================================
  static Future<void> baslat() => MemoryStorage.baslat();
  static Future<void> kaydet() => MemoryStorage.kaydet();

  // ==========================================
  // DELEGE EDİLEN METOTLAR: WORKOUT
  // ==========================================
  static void overloadKaydiEkle(OverloadKaydi kayit) => MemoryWorkout.overloadKaydiEkle(kayit);
  static OverloadKaydi? getOverloadOneri(String egzersizAdi) => MemoryWorkout.getOverloadOneri(egzersizAdi);
  static String zindanAkiniBitir(int gecenSaniye) => MemoryWorkout.zindanAkiniBitir(gecenSaniye);
  static List<Gorev> dovusGolgeBoksuKombinasyonlari({String? brans, int raundSayisi = 5}) =>
      MemoryWorkout.dovusGolgeBoksuKombinasyonlari(brans: brans, raundSayisi: raundSayisi);
  static void baslangicPrograminiAta({
    required String ekipman,
    required String rank,
    required int idmanGunu,
    required String hedef,
    List<String>? eklemKisitlari,
    List<String>? hedefOdakBolgeleri,
  }) => MemoryWorkout.baslangicPrograminiAta(
    ekipman: ekipman,
    rank: rank,
    idmanGunu: idmanGunu,
    hedef: hedef,
    eklemKisitlari: eklemKisitlari,
    hedefOdakBolgeleri: hedefOdakBolgeleri,
  );
  static Future<bool> aiPrograminiUygula({String? ozelTalep, int? idmanGunu}) =>
      MemoryWorkout.aiPrograminiUygula(ozelTalep: ozelTalep, idmanGunu: idmanGunu);
  static Future<List<Gorev>> aiEkIdmanBoosterUret({int? gun, bool sadeceBunuYap = false}) =>
      MemoryWorkout.aiEkIdmanBoosterUret(gun: gun, sadeceBunuYap: sadeceBunuYap);

  // ==========================================
  // DELEGE EDİLEN METOTLAR: NUTRITION & SETTLEMENT
  // ==========================================
  static void suEkle(int miktarMl) => MemoryNutrition.suEkle(miktarMl);
  static void suSifirla() => MemoryNutrition.suSifirla();
  static void suplementKusan(String id) => MemoryNutrition.suplementKusan(id);
  static void suplementCikar(String id) => MemoryNutrition.suplementCikar(id);
  static bool suplementKusanildiMi(String id) => MemoryNutrition.suplementKusanildiMi(id);
  static void suHedefiGuncelle() => MemoryNutrition.suHedefiGuncelle();
  static void protokolGuncelle(String yeniHedef, String yeniZorluk) =>
      MemoryNutrition.protokolGuncelle(yeniHedef, yeniZorluk);
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
  ) => MemoryNutrition.oyuncuyuAnalizEt(
    secilenCinsiyet, girilenDogumTarihi, girilenBoy, girilenKilo, hedef, zorluk, foto,
    idmanGunu, ekipman, tecrube, eklemKisitlari, hedefOdakBolgeleri,
  );
  static String tartiGuncelle(double yeniKilo) => MemoryNutrition.tartiGuncelle(yeniKilo);
  static void yeniGunKontrolu() => MemoryNutrition.yeniGunKontrolu();
  static String gunSonuHesaplasmasi(int degerlendirilenGun) => MemoryNutrition.gunSonuHesaplasmasi(degerlendirilenGun);
  static WorkloadImpactResult idmanYipranmasiIsle({
    required int dakika,
    required String idmanTuru,
    int rpeZorluk = 8,
  }) => MemoryNutrition.idmanYipranmasiIsle(dakika: dakika, idmanTuru: idmanTuru, rpeZorluk: rpeZorluk);
  static void diyetisyenOgunleriniOlustur({required int hedefKalori, required String hedef, required double kilo}) =>
      MemoryNutrition.diyetisyenOgunleriniOlustur(hedefKalori: hedefKalori, hedef: hedef, kilo: kilo);
  static void diyetisyenListesiniKaydet({
    required int kalori,
    required int protein,
    required int karb,
    required int yag,
    List<Map<String, dynamic>> ogunler = const [],
    String baslangicTarihi = '',
    Map<String, dynamic> gunlukPlanlar = const {},
  }) => MemoryNutrition.diyetisyenListesiniKaydet(
        kalori: kalori,
        protein: protein,
        karb: karb,
        yag: yag,
        ogunler: ogunler,
        baslangicTarihi: baslangicTarihi,
        gunlukPlanlar: gunlukPlanlar,
      );
  static void diyetisyenListesiniSifirla() => MemoryNutrition.diyetisyenListesiniSifirla();
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
  static void diyetisyenOgunDurumuGuncelle(String ogunId, bool tamamlandi) =>
      MemoryNutrition.diyetisyenOgunDurumuGuncelle(ogunId, tamamlandi);
  static void diyetisyenYeniOgunEkle(Map<String, dynamic> yeniOgun) =>
      MemoryNutrition.diyetisyenYeniOgunEkle(yeniOgun);
  static void diyetisyenOgunSil(String ogunId) => MemoryNutrition.diyetisyenOgunSil(ogunId);

  static void bossGuncelle({int? gunIndex}) => MemoryCombatRanks.bossGuncelle(gunIndex: gunIndex);
  static void bossHasarVer(int damage) => MemoryCombatRanks.bossHasarVer(damage);
  static bool basarimKademeGuncelle(String basarimAnahtari, int yeniKademe, String basarimAdi, String hedefMetin) =>
      MemoryCombatRanks.basarimKademeGuncelle(basarimAnahtari, yeniKademe, basarimAdi, hedefMetin);
  static String hunterRankHesapla({required double bench, required double squat, required double deadlift, double? kilo}) =>
      MemoryCombatRanks.hesaplaHunterRank(bench: bench, squat: squat, deadlift: deadlift, kilo: kilo);
  static String hesaplaHunterRank({required double bench, required double squat, required double deadlift, double? kilo}) =>
      MemoryCombatRanks.hesaplaHunterRank(bench: bench, squat: squat, deadlift: deadlift, kilo: kilo);
  static String hesaplaDovusRank({
    required int patlayiciSinav,
    required int burpeeKondisyon,
    required int plankSaniye,
    required int barfiks,
    double? bench,
    double? squat,
    double? deadlift,
    double? kilo,
  }) => MemoryCombatRanks.hesaplaDovusRank(
    patlayiciSinav: patlayiciSinav, burpeeKondisyon: burpeeKondisyon, plankSaniye: plankSaniye,
    barfiks: barfiks, bench: bench, squat: squat, deadlift: deadlift, kilo: kilo,
  );
  static int rankKademesi(String rank) => MemoryCombatRanks.rankKademesi(rank);
  static Map<String, int> rankYukselisOduluHesapla(String eskiRank, String yeniRank) =>
      MemoryCombatRanks.rankYukselisOduluHesapla(eskiRank, yeniRank);
  static Map<String, dynamic> dovusTestiKaydet({
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
  }) => MemoryCombatRanks.dovusTestiKaydet(
    patlayiciSinav: patlayiciSinav, burpeeKondisyon: burpeeKondisyon, plankSaniye: plankSaniye,
    barfiks: barfiks, rank: rank, brans: brans, branslar: branslar, idmanGunu: idmanGunu,
    bench: bench, squat: squat, deadlift: deadlift,
  );
  static Map<String, dynamic> awakeningTestKaydet({
    required double bench,
    required double squat,
    required double deadlift,
    required String rank,
    int? idmanGunu,
  }) => MemoryCombatRanks.awakeningTestKaydet(
    bench: bench, squat: squat, deadlift: deadlift, rank: rank, idmanGunu: idmanGunu,
  );
  static String expKazan(int miktar) => MemoryCombatRanks.expKazan(miktar);
  static void statuYukselt(String statAdi) => MemoryCombatRanks.statuYukselt(statAdi);
  static Map<String, int> otomatikStatDagit({int? miktar}) => MemoryCombatRanks.otomatikStatDagit(miktar: miktar);
  static void acilSifa() => MemoryCombatRanks.acilSifa();
  static void tamMana() => MemoryCombatRanks.tamMana();
  static void statuleriSifirla() => MemoryCombatRanks.statuleriSifirla();
  static Future<void> sistemiSifirla() => MemoryCombatRanks.sistemiSifirla();
  static void kirmiziGeciteGir(int gunSayisi, [int? hedefKalori, String? secilenPlan]) =>
      MemoryCombatRanks.kirmiziGeciteGir(gunSayisi, hedefKalori, secilenPlan);
  static void kirmiziGecideGir(int gunSayisi, [int? hedefKalori, String? secilenPlan]) =>
      MemoryCombatRanks.kirmiziGecideGir(gunSayisi, hedefKalori, secilenPlan);
  static void kirmiziGecittenCik() => MemoryCombatRanks.kirmiziGecittenCik();
  static void golgeModuDegistir(bool aktif) => MemoryCombatRanks.golgeModuDegistir(aktif);
  static void esyaEkle(InventoryItem yeniEsya) => MemoryCombatRanks.esyaEkle(yeniEsya);
  static String esyaKullan(String aksiyon) => MemoryCombatRanks.esyaKullan(aksiyon);
  static String exportBackupJson() => MemoryCombatRanks.exportBackupJson();
  static bool importBackupJson(String rawJson) => MemoryCombatRanks.importBackupJson(rawJson);

  // Arkaplan Wakelock
  static void idmanModunuBaslat() {
    if (!_isTest) {
      try {
        WakelockPlus.enable();
      } catch (_) {}
    }
  }

  static void idmanModunuBitir() {
    if (!_isTest) {
      try {
        WakelockPlus.disable();
      } catch (_) {}
    }
  }
}