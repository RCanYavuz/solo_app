import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../system_memory.dart';
import '../../models/task_model.dart';
import '../../models/food_model.dart';
import '../../models/inventory_item_model.dart';
import '../../models/mental_task_model.dart';
import '../../core/progressive_overload_engine.dart';
import '../../core/services/photo_storage_service.dart';

class MemoryStorage {
  static const int maxGecmisKayitSayisi = 200;


  /// Geçmiş listelerinin aşırı büyümesini engelleyerek SharedPreferences I/O darboğazını önler.
  static void _gecmisVerileriniOptimizeEt() {
    if (SystemMemory.idmanGecmisi.length > maxGecmisKayitSayisi) {
      SystemMemory.idmanGecmisi = SystemMemory.idmanGecmisi.sublist(
        SystemMemory.idmanGecmisi.length - maxGecmisKayitSayisi,
      );
    }
    if (SystemMemory.yemekGecmisi.length > maxGecmisKayitSayisi) {
      SystemMemory.yemekGecmisi = SystemMemory.yemekGecmisi.sublist(
        SystemMemory.yemekGecmisi.length - maxGecmisKayitSayisi,
      );
    }
    if (SystemMemory.kiloGecmisi.length > maxGecmisKayitSayisi) {
      SystemMemory.kiloGecmisi = SystemMemory.kiloGecmisi.sublist(
        SystemMemory.kiloGecmisi.length - maxGecmisKayitSayisi,
      );
    }
    if (SystemMemory.ilerlemeFotolari.length > 50) {
      SystemMemory.ilerlemeFotolari = SystemMemory.ilerlemeFotolari.sublist(
        SystemMemory.ilerlemeFotolari.length - 50,
      );
    }
  }

  static Future<void> baslat() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (prefs.containsKey('level')) {
      SystemMemory.kayitBulundu = true;
      
      SystemMemory.golgeModuAktif = prefs.getBool('golgeModuAktif') ?? false;
      SystemMemory.redGateAktif = prefs.getBool('redGateAktif') ?? false;
      SystemMemory.redGateKalanGun = prefs.getInt('redGateKalanGun') ?? 0;
      SystemMemory.redGateToplamGun = prefs.getInt('redGateToplamGun') ?? 0;
      SystemMemory.normalGunlukHedefKalori = prefs.getInt('normalGunlukHedefKalori') ?? 0;
      
      SystemMemory.hp.value = prefs.getInt('hp') ?? 100;
      SystemMemory.mp.value = prefs.getInt('mp') ?? 10;
      SystemMemory.fatigue.value = prefs.getInt('fatigue') ?? 0;
      SystemMemory.maxHp = prefs.getInt('maxHp') ?? 100;
      SystemMemory.maxMp = prefs.getInt('maxMp') ?? 10;
      SystemMemory.level.value = prefs.getInt('level') ?? 1;
      SystemMemory.exp.value = prefs.getInt('exp') ?? 0;
      SystemMemory.maxExp.value = prefs.getInt('maxExp') ?? 100;
      SystemMemory.ap.value = prefs.getInt('ap') ?? 0;
      SystemMemory.altin.value = prefs.getInt('altin') ?? 0; 
      
      SystemMemory.str.value = prefs.getInt('str') ?? 10;
      SystemMemory.agi.value = prefs.getInt('agi') ?? 10;
      SystemMemory.vit.value = prefs.getInt('vit') ?? 10;
      SystemMemory.intStat.value = prefs.getInt('intStat') ?? 10;
      SystemMemory.per.value = prefs.getInt('per') ?? 10;

      SystemMemory.oyuncuIsmi = prefs.getString('oyuncuIsmi') ?? "PLAYER";
      SystemMemory.appLanguage.value = prefs.getString('appLanguage') ?? "en";
      if (!SystemMemory.isTest) {
        try {
          const secureStorage = FlutterSecureStorage();
          SystemMemory.geminiApiKey = await secureStorage.read(key: 'gemini_api_key') ?? prefs.getString('gemini_api_key') ?? "";
        } catch (_) {
          SystemMemory.geminiApiKey = prefs.getString('gemini_api_key') ?? "";
        }
      } else {
        SystemMemory.geminiApiKey = prefs.getString('gemini_api_key') ?? "";
      }
      final savedModel = prefs.getString('gemini_active_model');
      if (savedModel != null && savedModel.isNotEmpty) {
        SystemMemory.geminiActiveModel = savedModel;
      } else {
        SystemMemory.geminiActiveModel = "gemini-3.6-flash";
      }
      SystemMemory.sonGirisTarihi = prefs.getString('sonGirisTarihi') ?? "";

      SystemMemory.cinsiyet = prefs.getString('cinsiyet') ?? "Erkek";
      SystemMemory.boy = prefs.getDouble('boy') ?? 175;
      SystemMemory.kilo = prefs.getDouble('kilo') ?? 70;
      
      SystemMemory.baslangicKilosu = prefs.getDouble('baslangicKilosu') ?? SystemMemory.kilo;
      SystemMemory.streakGunSayisi = prefs.getInt('streakGunSayisi') ?? 0;
      SystemMemory.bitenGorevSayisi = prefs.getInt('bitenGorevSayisi') ?? 0;

      String gecmisJson = prefs.getString('kiloGecmisi') ?? '[]';
      SystemMemory.kiloGecmisi = List<Map<String, dynamic>>.from(jsonDecode(gecmisJson));

      SystemMemory.toplamIdmanDakikasi = prefs.getInt('toplamIdmanDakikasi') ?? 0;
      String idmanJson = prefs.getString('idmanGecmisi') ?? '[]';
      SystemMemory.idmanGecmisi = List<Map<String, dynamic>>.from(jsonDecode(idmanJson));

      String yGecmisJson = prefs.getString('yemekGecmisi') ?? '[]';
      SystemMemory.yemekGecmisi = List<Map<String, dynamic>>.from(jsonDecode(yGecmisJson));

      SystemMemory.gunlukHedefKalori = prefs.getInt('gunlukHedefKalori') ?? 0;
      SystemMemory.vucutSinifi = prefs.getString('vucutSinifi') ?? "Unknown";
      SystemMemory.aktifHedef = prefs.getString('aktifHedef') ?? "Unknown";
      SystemMemory.aktifZorluk = prefs.getString('aktifZorluk') ?? "Unknown";
      
      SystemMemory.maxBench = prefs.getDouble('maxBench') ?? 0.0;
      SystemMemory.maxSquat = prefs.getDouble('maxSquat') ?? 0.0;
      SystemMemory.maxDeadlift = prefs.getDouble('maxDeadlift') ?? 0.0;
      SystemMemory.hunterRank = prefs.getString('hunterRank') ?? "Unranked";
      SystemMemory.ekipmanTuru = prefs.getString('ekipmanTuru') ?? "Salon";
      SystemMemory.antrenmanGecmisi = prefs.getString('antrenmanGecmisi') ?? "Başlangıç";
      SystemMemory.eklemKisiti = prefs.getStringList('eklemKisiti') ?? [];
      SystemMemory.odakBolgeleri = prefs.getStringList('odakBolgeleri') ?? [];
      SystemMemory.sonTestTarihi = prefs.getString('sonTestTarihi') ?? "";
      SystemMemory.sonTesttenBeriIdmanSayisi = prefs.getInt('sonTesttenBeriIdmanSayisi') ?? 0;
      SystemMemory.otomatikStatDagitimiAktif.value = prefs.getBool('otomatikStatDagitimiAktif') ?? false;

      SystemMemory.dovusSporuYapiyorMu = prefs.getBool('dovusSporuYapiyorMu') ?? false;
      SystemMemory.dovusBransi = prefs.getString('dovusBransi') ?? "Boks";
      SystemMemory.dovusBranslari = prefs.getStringList('dovusBranslari') ?? (SystemMemory.dovusBransi.isNotEmpty ? [SystemMemory.dovusBransi] : ["Boks"]);
      SystemMemory.maxPatlayiciSinav = prefs.getInt('maxPatlayiciSinav') ?? 0;
      SystemMemory.maxBurpeeKondisyon = prefs.getInt('maxBurpeeKondisyon') ?? 0;
      SystemMemory.maxPlankSaniye = prefs.getInt('maxPlankSaniye') ?? 0;
      SystemMemory.maxBarfiks = prefs.getInt('maxBarfiks') ?? 0;
      SystemMemory.gogusCm = prefs.getDouble('gogusCm') ?? 0.0;
      SystemMemory.belCm = prefs.getDouble('belCm') ?? 0.0;
      SystemMemory.kolCm = prefs.getDouble('kolCm') ?? 0.0;
      SystemMemory.bacakCm = prefs.getDouble('bacakCm') ?? 0.0;
      
      String dtStr = prefs.getString('dogumTarihi') ?? '';
      if (dtStr.isNotEmpty) SystemMemory.dogumTarihi = DateTime.parse(dtStr);

      // Profil Fotoğrafı (Dosya sistemi & Legacy Base64 Migration)
      String profilPath = prefs.getString('profilFotoPath') ?? '';
      if (profilPath.isNotEmpty) {
        final pBytes = await PhotoStorageService.instance.loadPhotoBytes(profilPath);
        if (pBytes != null) SystemMemory.profilFotoByte = pBytes;
      }
      if (SystemMemory.profilFotoByte == null) {
        String fotoB64 = prefs.getString('profilFoto') ?? '';
        if (fotoB64.isNotEmpty) {
          try {
            SystemMemory.profilFotoByte = base64Decode(fotoB64);
            final savedPath = await PhotoStorageService.instance.saveProfilePhoto(SystemMemory.profilFotoByte!);
            await prefs.setString('profilFotoPath', savedPath);
            await prefs.remove('profilFoto');
          } catch (_) {}
        }
      }
      
      // Avatar Fotoğrafı (Dosya sistemi & Legacy Base64 Migration)
      String avatarPath = prefs.getString('avatarFotoPath') ?? '';
      if (avatarPath.isNotEmpty) {
        final aBytes = await PhotoStorageService.instance.loadPhotoBytes(avatarPath);
        if (aBytes != null) SystemMemory.avatarFotoByte = aBytes;
      }
      if (SystemMemory.avatarFotoByte == null) {
        String avatarB64 = prefs.getString('avatarFoto') ?? '';
        if (avatarB64.isNotEmpty) {
          try {
            SystemMemory.avatarFotoByte = base64Decode(avatarB64);
            final savedPath = await PhotoStorageService.instance.saveAvatarPhoto(SystemMemory.avatarFotoByte!);
            await prefs.setString('avatarFotoPath', savedPath);
            await prefs.remove('avatarFoto');
          } catch (_) {}
        }
      }

      SystemMemory.bugunAlinanKalori = prefs.getInt('bugunAlinanKalori') ?? 0;
      SystemMemory.uyunanSaat = prefs.getInt('uyunanSaat') ?? 0;

      String yemeklerJson = prefs.getString('bugununYemekleri') ?? '[]';
      List<dynamic> yList = jsonDecode(yemeklerJson);
      SystemMemory.bugununYemekleri = yList.map((e) => TuketilenYemek.fromJson(e)).toList();

      String planJson = prefs.getString('haftalikPlan') ?? '{}';
      Map<String, dynamic> pMap = jsonDecode(planJson);
      pMap.forEach((key, value) { SystemMemory.haftalikPlan[int.parse(key)] = (value as List).map((e) => Gorev.fromJson(e)).toList(); });
      
      String normalPlanJson = prefs.getString('normalHaftalikPlan') ?? '{}';
      Map<String, dynamic> npMap = jsonDecode(normalPlanJson);
      npMap.forEach((key, value) { SystemMemory.normalHaftalikPlan[int.parse(key)] = (value as List).map((e) => Gorev.fromJson(e)).toList(); });

      // Su ve Envanter Yükle
      SystemMemory.suHedefiMl = prefs.getInt('suHedefiMl') ?? 3000;
      SystemMemory.bugunIcilenSuMl.value = prefs.getInt('bugunIcilenSuMl') ?? prefs.getInt('bugunIçilenSuMl') ?? 0;
      SystemMemory.bugunCheatMealAktif = prefs.getBool('bugunCheatMealAktif') ?? false;
      SystemMemory.bugunSlothDayAktif = prefs.getBool('bugunSlothDayAktif') ?? false;
      SystemMemory.bugunGamingPassAktif = prefs.getBool('bugunGamingPassAktif') ?? false;

      String cantaJson = prefs.getString('canta') ?? '[]';
      List<dynamic> cList = jsonDecode(cantaJson);
      SystemMemory.canta = cList.map((e) => InventoryItem.fromJson(e)).toList();

      SystemMemory.hedefKilo = prefs.getDouble('hedefKilo') ?? (SystemMemory.kilo > 0 ? (SystemMemory.aktifHedef.contains('Kilo Al') ? SystemMemory.kilo + 4 : SystemMemory.kilo - 5) : 70.0);
      SystemMemory.avciDiyetNotu = prefs.getString('avciDiyetNotu') ?? "";
      SystemMemory.sonAiHedefKiloYorumu = prefs.getString('sonAiHedefKiloYorumu') ?? "";
      SystemMemory.diyetisyenListesiAktif = prefs.getBool('diyetisyenListesiAktif') ?? false;
      SystemMemory.diyetisyenBazKalori = prefs.getInt('diyetisyenBazKalori') ?? 0;
      SystemMemory.diyetisyenBazProtein = prefs.getInt('diyetisyenBazProtein') ?? 0;
      SystemMemory.diyetisyenBazKarb = prefs.getInt('diyetisyenBazKarb') ?? 0;
      SystemMemory.diyetisyenBazYag = prefs.getInt('diyetisyenBazYag') ?? 0;
      String dOgunlerJson = prefs.getString('diyetisyenOgunleri') ?? '[]';
      try {
        List<dynamic> doList = jsonDecode(dOgunlerJson);
        SystemMemory.diyetisyenOgunleri = doList.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      } catch (_) {}
      SystemMemory.diyetisyenBaslangicTarihi = prefs.getString('diyetisyenBaslangicTarihi') ?? "";
      String dPlanlarJson = prefs.getString('diyetisyenGunlukPlanlar') ?? '{}';
      try {
        SystemMemory.diyetisyenGunlukPlanlar = Map<String, dynamic>.from(jsonDecode(dPlanlarJson) as Map);
      } catch (_) {}

      String overloadJson = prefs.getString('overloadGecmisi') ?? '{}';
      try {
        Map<String, dynamic> oMap = jsonDecode(overloadJson);
        SystemMemory.overloadGecmisi = oMap.map((key, value) => MapEntry(key, OverloadKaydi.fromJson(value)));
      } catch (_) {}

      String bKademeJson = prefs.getString('basarimKademeleri') ?? '{}';
      try {
        Map<String, dynamic> bkMap = jsonDecode(bKademeJson);
        SystemMemory.basarimKademeleri = bkMap.map((key, value) => MapEntry(key, (value as num).toInt()));
      } catch (_) {}

      SystemMemory.kusanilanSuplementler = prefs.getStringList('kusanilanSuplementler') ?? [];
      SystemMemory.sesliKocAktif.value = prefs.getBool('sesliKocAktif') ?? true;

      // Bildirim Tercihleri
      SystemMemory.suBildirimiAktif = prefs.getBool('suBildirimiAktif') ?? true;
      SystemMemory.suBildirimAraligiSaat = prefs.getInt('suBildirimAraligiSaat') ?? 2;
      SystemMemory.idmanBildirimiAktif = prefs.getBool('idmanBildirimiAktif') ?? true;
      SystemMemory.idmanBildirimSaati = prefs.getInt('idmanBildirimSaati') ?? 18;
      SystemMemory.idmanBildirimDakikasi = prefs.getInt('idmanBildirimDakikasi') ?? 0;
      SystemMemory.geceBildirimiAktif = prefs.getBool('geceBildirimiAktif') ?? true;

      // İlerleme Fotoğrafları Arşivi (Dosya sistemi & Legacy Base64 Migration)
      String fotolarJson = prefs.getString('ilerlemeFotolari') ?? '[]';
      try {
        List<dynamic> fList = jsonDecode(fotolarJson);
        final list = fList.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        bool needsSave = false;
        for (var item in list) {
          final p = item['fotoPath']?.toString();
          final b64 = item['fotoBase64']?.toString();
          if ((p == null || p.isEmpty) && b64 != null && b64.isNotEmpty) {
            try {
              final id = item['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
              final bytes = base64Decode(b64);
              final savedPath = await PhotoStorageService.instance.saveProgressPhoto(bytes, id);
              item['fotoPath'] = savedPath;
              item.remove('fotoBase64');
              needsSave = true;
            } catch (_) {}
          }
        }
        SystemMemory.ilerlemeFotolari = list;
        if (needsSave) {
          final clean = list.map((e) {
            final copy = Map<String, dynamic>.from(e);
            copy.remove('fotoBase64');
            return copy;
          }).toList();
          await prefs.setString('ilerlemeFotolari', jsonEncode(clean));
        }
      } catch (_) {}

      // Zihinsel Görevler & Odaklanma Arşivi
      SystemMemory.toplamOkunanSayfaSayisi = prefs.getInt('toplamOkunanSayfaSayisi') ?? 0;
      SystemMemory.toplamOdaklanmaDakikasi = prefs.getInt('toplamOdaklanmaDakikasi') ?? 0;
      SystemMemory.aktifUzmanlikAlani = prefs.getString('aktifUzmanlikAlani') ?? "Yazılım & AI";
      SystemMemory.tamamlananKitaplar = prefs.getStringList('tamamlananKitaplar') ?? [];
      
      String zihinselJson = prefs.getString('gunlukZihinselGorevler') ?? '[]';
      try {
        List<dynamic> mList = jsonDecode(zihinselJson);
        SystemMemory.gunlukZihinselGorevler.value = mList.map((e) => MentalTask.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {}

      SystemMemory.suHedefiGuncelle();

      SystemMemory.bossGuncelle();
    }
  }

  static Future<void> kaydet() async {
    _gecmisVerileriniOptimizeEt();
    final prefs = await SharedPreferences.getInstance();
      
      await prefs.setBool('golgeModuAktif', SystemMemory.golgeModuAktif);
      await prefs.setBool('redGateAktif', SystemMemory.redGateAktif);
      await prefs.setInt('redGateKalanGun', SystemMemory.redGateKalanGun);
      await prefs.setInt('redGateToplamGun', SystemMemory.redGateToplamGun);
      await prefs.setInt('normalGunlukHedefKalori', SystemMemory.normalGunlukHedefKalori);
      
      await prefs.setInt('hp', SystemMemory.hp.value);
      await prefs.setInt('mp', SystemMemory.mp.value);
      await prefs.setInt('fatigue', SystemMemory.fatigue.value);
      await prefs.setInt('maxHp', SystemMemory.maxHp);
      await prefs.setInt('maxMp', SystemMemory.maxMp);
      await prefs.setInt('level', SystemMemory.level.value);
      await prefs.setInt('exp', SystemMemory.exp.value);
      await prefs.setInt('maxExp', SystemMemory.maxExp.value);
      await prefs.setInt('ap', SystemMemory.ap.value);
      await prefs.setInt('altin', SystemMemory.altin.value); 
      
      await prefs.setInt('str', SystemMemory.str.value);
      await prefs.setInt('agi', SystemMemory.agi.value);
      await prefs.setInt('vit', SystemMemory.vit.value);
      await prefs.setInt('intStat', SystemMemory.intStat.value);
      await prefs.setInt('per', SystemMemory.per.value);
      
      await prefs.setString('oyuncuIsmi', SystemMemory.oyuncuIsmi);
      await prefs.setString('sonGirisTarihi', SystemMemory.sonGirisTarihi);

      await prefs.setString('cinsiyet', SystemMemory.cinsiyet);
      await prefs.setDouble('boy', SystemMemory.boy);
      await prefs.setDouble('kilo', SystemMemory.kilo);
      await prefs.setDouble('hedefKilo', SystemMemory.hedefKilo);
      await prefs.setString('avciDiyetNotu', SystemMemory.avciDiyetNotu);
      await prefs.setString('sonAiHedefKiloYorumu', SystemMemory.sonAiHedefKiloYorumu);
      await prefs.setBool('diyetisyenListesiAktif', SystemMemory.diyetisyenListesiAktif);
      await prefs.setInt('diyetisyenBazKalori', SystemMemory.diyetisyenBazKalori);
      await prefs.setInt('diyetisyenBazProtein', SystemMemory.diyetisyenBazProtein);
      await prefs.setInt('diyetisyenBazKarb', SystemMemory.diyetisyenBazKarb);
      await prefs.setInt('diyetisyenBazYag', SystemMemory.diyetisyenBazYag);
      await prefs.setString('diyetisyenOgunleri', jsonEncode(SystemMemory.diyetisyenOgunleri));
      await prefs.setString('diyetisyenBaslangicTarihi', SystemMemory.diyetisyenBaslangicTarihi);
      await prefs.setString('diyetisyenGunlukPlanlar', jsonEncode(SystemMemory.diyetisyenGunlukPlanlar));

      await prefs.setDouble('baslangicKilosu', SystemMemory.baslangicKilosu);
      await prefs.setInt('streakGunSayisi', SystemMemory.streakGunSayisi);
      await prefs.setInt('bitenGorevSayisi', SystemMemory.bitenGorevSayisi);

      await prefs.setString('kiloGecmisi', jsonEncode(SystemMemory.kiloGecmisi));

      await prefs.setInt('toplamIdmanDakikasi', SystemMemory.toplamIdmanDakikasi);
      await prefs.setString('idmanGecmisi', jsonEncode(SystemMemory.idmanGecmisi));
      await prefs.setString('yemekGecmisi', jsonEncode(SystemMemory.yemekGecmisi));

      await prefs.setInt('gunlukHedefKalori', SystemMemory.gunlukHedefKalori);
      await prefs.setString('vucutSinifi', SystemMemory.vucutSinifi);
      await prefs.setString('aktifHedef', SystemMemory.aktifHedef);
      await prefs.setString('aktifZorluk', SystemMemory.aktifZorluk);

      await prefs.setDouble('maxBench', SystemMemory.maxBench);
      await prefs.setDouble('maxSquat', SystemMemory.maxSquat);
      await prefs.setDouble('maxDeadlift', SystemMemory.maxDeadlift);
      await prefs.setString('hunterRank', SystemMemory.hunterRank);
      await prefs.setString('ekipmanTuru', SystemMemory.ekipmanTuru);
      await prefs.setString('antrenmanGecmisi', SystemMemory.antrenmanGecmisi);
      await prefs.setStringList('eklemKisiti', SystemMemory.eklemKisiti);
      await prefs.setStringList('odakBolgeleri', SystemMemory.odakBolgeleri);
      await prefs.setString('sonTestTarihi', SystemMemory.sonTestTarihi);
      await prefs.setInt('sonTesttenBeriIdmanSayisi', SystemMemory.sonTesttenBeriIdmanSayisi);
      await prefs.setBool('otomatikStatDagitimiAktif', SystemMemory.otomatikStatDagitimiAktif.value);

      await prefs.setBool('dovusSporuYapiyorMu', SystemMemory.dovusSporuYapiyorMu);
      await prefs.setString('dovusBransi', SystemMemory.dovusBransi);
      await prefs.setStringList('dovusBranslari', SystemMemory.dovusBranslari);
      await prefs.setInt('maxPatlayiciSinav', SystemMemory.maxPatlayiciSinav);
      await prefs.setInt('maxBurpeeKondisyon', SystemMemory.maxBurpeeKondisyon);
      await prefs.setInt('maxPlankSaniye', SystemMemory.maxPlankSaniye);
      await prefs.setInt('maxBarfiks', SystemMemory.maxBarfiks);
      await prefs.setDouble('gogusCm', SystemMemory.gogusCm);
      await prefs.setDouble('belCm', SystemMemory.belCm);
      await prefs.setDouble('kolCm', SystemMemory.kolCm);
      await prefs.setDouble('bacakCm', SystemMemory.bacakCm);

      await prefs.setString('oyuncuIsmi', SystemMemory.oyuncuIsmi);
      await prefs.setString('appLanguage', SystemMemory.appLanguage.value);
      await prefs.setString('gemini_api_key', SystemMemory.geminiApiKey);
      if (!SystemMemory.isTest) {
        try {
          const secureStorage = FlutterSecureStorage();
          await secureStorage.write(key: 'gemini_api_key', value: SystemMemory.geminiApiKey);
        } catch (_) {}
      }
      await prefs.setString('gemini_active_model', SystemMemory.geminiActiveModel);
      
      if (SystemMemory.dogumTarihi != null) {
        await prefs.setString('dogumTarihi', SystemMemory.dogumTarihi!.toIso8601String());
      }
      if (SystemMemory.profilFotoByte != null) {
        String? pPath = prefs.getString('profilFotoPath');
        if (pPath == null || pPath.isEmpty) {
          pPath = await PhotoStorageService.instance.saveProfilePhoto(SystemMemory.profilFotoByte!);
          await prefs.setString('profilFotoPath', pPath);
        }
      } else {
        await prefs.remove('profilFotoPath');
      }
      if (SystemMemory.avatarFotoByte != null) {
        String? aPath = prefs.getString('avatarFotoPath');
        if (aPath == null || aPath.isEmpty) {
          aPath = await PhotoStorageService.instance.saveAvatarPhoto(SystemMemory.avatarFotoByte!);
          await prefs.setString('avatarFotoPath', aPath);
        }
      } else {
        await prefs.remove('avatarFotoPath');
      }
      await prefs.setInt('bugunAlinanKalori', SystemMemory.bugunAlinanKalori);
      await prefs.setInt('uyunanSaat', SystemMemory.uyunanSaat);
      await prefs.setString('bugununYemekleri', jsonEncode(SystemMemory.bugununYemekleri.map((e) => e.toJson()).toList()));
      
      await prefs.setInt('suHedefiMl', SystemMemory.suHedefiMl);
      await prefs.setInt('bugunIcilenSuMl', SystemMemory.bugunIcilenSuMl.value);
      await prefs.setBool('bugunCheatMealAktif', SystemMemory.bugunCheatMealAktif);
      await prefs.setBool('bugunSlothDayAktif', SystemMemory.bugunSlothDayAktif);
      await prefs.setBool('bugunGamingPassAktif', SystemMemory.bugunGamingPassAktif);
      await prefs.setString('canta', jsonEncode(SystemMemory.canta.map((e) => e.toJson()).toList()));

      Map<String, dynamic> planKayit = {};
      SystemMemory.haftalikPlan.forEach((key, value) {
        planKayit[key.toString()] = value.map((e) => e.toJson()).toList();
      });
      await prefs.setString('haftalikPlan', jsonEncode(planKayit));

      Map<String, dynamic> nPlanKayit = {};
      SystemMemory.normalHaftalikPlan.forEach((key, value) {
        nPlanKayit[key.toString()] = value.map((e) => e.toJson()).toList();
      });
      await prefs.setString('normalHaftalikPlan', jsonEncode(nPlanKayit));
      await prefs.setString('overloadGecmisi', jsonEncode(
        SystemMemory.overloadGecmisi.map((key, value) => MapEntry(key, value.toJson())),
      ));
      await prefs.setString('basarimKademeleri', jsonEncode(SystemMemory.basarimKademeleri));
      await prefs.setStringList('kusanilanSuplementler', SystemMemory.kusanilanSuplementler);
      await prefs.setBool('sesliKocAktif', SystemMemory.sesliKocAktif.value);

      // Bildirim Tercihleri
      await prefs.setBool('suBildirimiAktif', SystemMemory.suBildirimiAktif);
      await prefs.setInt('suBildirimAraligiSaat', SystemMemory.suBildirimAraligiSaat);
      await prefs.setBool('idmanBildirimiAktif', SystemMemory.idmanBildirimiAktif);
      await prefs.setInt('idmanBildirimSaati', SystemMemory.idmanBildirimSaati);
      await prefs.setInt('idmanBildirimDakikasi', SystemMemory.idmanBildirimDakikasi);
      await prefs.setBool('geceBildirimiAktif', SystemMemory.geceBildirimiAktif);

      // İlerleme Fotoğrafları Arşivi (Dosya yolu ve meta veriler, Base64 içermez)
      final cleanFotolar = SystemMemory.ilerlemeFotolari.map((item) {
        final copy = Map<String, dynamic>.from(item);
        copy.remove('fotoBase64');
        return copy;
      }).toList();
      await prefs.setString('ilerlemeFotolari', jsonEncode(cleanFotolar));

      // Zihinsel Görevler & Odaklanma Arşivi
      await prefs.setInt('toplamOkunanSayfaSayisi', SystemMemory.toplamOkunanSayfaSayisi);
      await prefs.setInt('toplamOdaklanmaDakikasi', SystemMemory.toplamOdaklanmaDakikasi);
      await prefs.setString('aktifUzmanlikAlani', SystemMemory.aktifUzmanlikAlani);
      await prefs.setStringList('tamamlananKitaplar', SystemMemory.tamamlananKitaplar);
      await prefs.setString('gunlukZihinselGorevler', jsonEncode(SystemMemory.gunlukZihinselGorevler.value.map((e) => e.toJson()).toList()));

      SystemMemory.bossGuncelle();
  }
}
