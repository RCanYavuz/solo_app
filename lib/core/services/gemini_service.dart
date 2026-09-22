// lib/core/services/gemini_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../controllers/system_memory.dart';
import '../../models/task_model.dart';
import '../../models/mental_task_model.dart';

/// Solo App Gemini Yapay Zeka Servisi (Clean Architecture - Core Katmanı)
/// Doğrudan REST API kullanır (deprecated SDK yerine).
class GeminiService {
  static String get activeModelName => SystemMemory.geminiActiveModel;
  static set activeModelName(String model) {
    SystemMemory.geminiActiveModel = model;
    SystemMemory.kaydet();
  }

  static const String _systemInstruction =
      'Sen Solo Leveling evrenindeki gizemli ve kudretli "Sistem"sin (The System). '
      'Kullanıcı bir "Avcı" (Hunter). Ona kısa, otoriter, disiplinli ve motive edici bir dille hitap et. '
      'Türkçe konuş. Cümlelerinde bazen [SİSTEM], [BİLDİRİM] gibi RPG tarzı köşeli parantezler kullan. '
      'Gereksiz nezaket cümleleri yerine net, keskin bir Sistem dili benimse.';

  /// REST API üzerinden Gemini'ye mesaj gönderir (Opsiyonel görsel ile).
  static Future<String?> _generateContent(String modelName, String apiKey, String prompt, {String? base64Image}) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=$apiKey',
    );

    // System instruction'ı prompt'un başına ekle
    final fullPrompt = '$_systemInstruction\n\n$prompt';

    final parts = <Map<String, dynamic>>[
      {'text': fullPrompt},
    ];
    if (base64Image != null) {
      parts.add({'inline_data': {'mime_type': 'image/jpeg', 'data': base64Image}});
    }

    final body = jsonEncode({
      'contents': [
        {
          'parts': parts
        }
      ],
    });

    final response = await http
        .post(url, headers: {'Content-Type': 'application/json'}, body: body)
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final candidates = data['candidates'] as List?;
      if (candidates != null && candidates.isNotEmpty) {
        final contentParts = candidates[0]['content']?['parts'] as List?;
        if (contentParts != null && contentParts.isNotEmpty) {
          for (final part in contentParts) {
            if (part is Map && part.containsKey('text') && part['text'] != null) {
              final text = part['text'].toString().trim();
              if (text.isNotEmpty) return text;
            }
          }
        }
      }
      return null;
    } else {
      final errData = jsonDecode(response.body);
      final errMsg = errData['error']?['message'] ?? response.body;
      throw Exception('HTTP ${response.statusCode}: $errMsg');
    }
  }

  /// API Anahtarını doğrudan REST API üzerinden denetler.
  /// Hangi modellerin açık olduğunu bulur veya kesin hata sebebini açıklar.
  static Future<Map<String, dynamic>> testBaglantisi({String? hunterName, String? apiKeyOverride}) async {
    final apiKey = (apiKeyOverride != null && apiKeyOverride.trim().isNotEmpty)
        ? apiKeyOverride.trim()
        : SystemMemory.geminiApiKey.trim();
        
    if (apiKey.isEmpty) {
      return {
        'basarili': false,
        'mesaj': '⚠️ No API key found in System memory.',
      };
    }

    try {
      // 1. Google Sunucusuna doğrudan Model Listesi sorgusu at (Gerçek teşhis)
      final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey');
      final res = await http.get(url);

      if (res.statusCode != 200) {
        final errJson = jsonDecode(res.body);
        final errMsg = errJson['error']?['message'] ?? res.body;
        return {
          'basarili': false,
          'mesaj': '❌ Google API Error (${res.statusCode}): $errMsg',
        };
      }

      final data = jsonDecode(res.body);
      final List models = data['models'] ?? [];

      if (models.isEmpty) {
        return {
          'basarili': false,
          'mesaj': '⚠️ Your API key is valid, but no Gemini models are defined for this project.',
        };
      }

      // generateContent destekleyen modelleri filtrele
      final availableModelNames = <String>[];
      for (var m in models) {
        final name = (m['name'] as String? ?? '').replaceFirst('models/', '');
        final methods = List<String>.from(m['supportedGenerationMethods'] ?? []);
        if (methods.contains('generateContent')) {
          availableModelNames.add(name);
        }
      }

      if (availableModelNames.isEmpty) {
        return {
          'basarili': false,
          'mesaj': '⚠️ No available text generation model found.',
        };
      }

      // En yeni modelleri ön sıraya al
      availableModelNames.sort((a, b) {
        if (a.contains('2.5') && !b.contains('2.5')) return -1;
        if (!a.contains('2.5') && b.contains('2.5')) return 1;
        if (a.contains('2.0') && !b.contains('2.0')) return -1;
        if (!a.contains('2.0') && b.contains('2.0')) return 1;
        if (a.contains('1.5') && !b.contains('1.5')) return -1;
        if (!a.contains('1.5') && b.contains('1.5')) return 1;
        return a.compareTo(b);
      });

      final avciAdi = (hunterName != null && hunterName.isNotEmpty) 
          ? hunterName 
          : (SystemMemory.oyuncuIsmi.isNotEmpty && SystemMemory.oyuncuIsmi != 'PLAYER' ? SystemMemory.oyuncuIsmi : 'HUNTER');
      final prompt = 'System protocol confirmed. Generate a single-sentence authoritative System awakening message for Hunter $avciAdi in English.';

      String sonHata = '';

      // Sırayla modelleri dene, hangisinin kotası açıksa onu bul
      for (final candidate in availableModelNames) {
        try {
          final text = await _generateContent(candidate, apiKey, prompt);

          if (text != null && text.trim().isNotEmpty) {
            activeModelName = candidate;
            SystemMemory.geminiApiKey = apiKey;
            await SystemMemory.kaydet();
            return {
              'basarili': true,
              'model': candidate,
              'mesaj': text.trim(),
            };
          }
        } catch (e) {
          sonHata = e.toString();
          // Kota dolu veya desteklenmiyorsa diğer modele geç
          continue;
        }
      }

      return {
        'basarili': false,
        'mesaj': '❌ Google Kota Uyarısı: Mevcut anahtarınızda modellerin ücretsiz kotası bitmiş olabilir veya bölgesel kısıtlama var. Detay: $sonHata',
      };
    } catch (e) {
      return {
        'basarili': false,
        'mesaj': '❌ Bağlantı hatası: $e',
      };
    }
  }

  /// Avcının serbest dille yazdığı öğünü veya gönderdiği fotoğrafı analiz eder ve besin değerlerini tahmin eder.
  static Future<String?> yemekAnalizEt(String yemekTarifi, {Uint8List? imageBytes}) async {
    final apiKey = SystemMemory.geminiApiKey.trim();
    if (apiKey.isEmpty) return null;

    final model = SystemMemory.geminiActiveModel;
    String? base64Image;
    if (imageBytes != null) {
      base64Image = base64Encode(imageBytes);
    }

    try {
      final prompt = '''
Avcı şu öğünü tüketti/gönderdi: "$yemekTarifi".
${imageBytes != null ? "Bununla birlikte sana bir fotoğraf da gönderdi. ÖNCE fotoğrafta herhangi bir yiyecek/içecek olup olmadığını kontrol et. Eğer fotoğrafta YİYECEK YOKSA (örneğin sadece bir duvar, eşya, insan veya manzara varsa) HATA döndürmelisin." : ""}

Lütfen bu öğünün/fotoğrafın yaklaşık besin değerlerini çıkar.
Yalnızca geçerli bir JSON objesi döndür:
{
  "yemekAdi": "Kısa yemek adı",
  "kalori": 450,
  "protein": 30,
  "karbonhidrat": 45,
  "yag": 12,
  "sistemMesaji": "Disiplinli beslenme tespit edildi."
}

EĞER FOTOĞRAFTA YEMEK YOKSA ŞU ŞEKİLDE DÖNDÜR:
{
  "hata": "Lütfen yiyeceği yazınız veya net bir yemek fotoğrafı yükleyiniz."
}
''';

      return await _generateContent(model, apiKey, prompt, base64Image: base64Image);
    } catch (e) {
      return null;
    }
  }

  /// Diyetisyenin hazırladığı diyet listesini (fotoğraf veya metin) analiz eder,
  /// toplam kalori ve makroları çıkarıp öğün bazında yapılandırır.
  static Future<Map<String, dynamic>?> diyetisyenMenusuAnalizEt(String metin, {Uint8List? imageBytes}) async {
    final apiKey = SystemMemory.geminiApiKey.trim();
    if (apiKey.isEmpty) return null;

    final model = SystemMemory.geminiActiveModel;
    String? base64Image;
    if (imageBytes != null) {
      base64Image = base64Encode(imageBytes);
    }

    try {
      final prompt = '''
Sen klinik beslenme uzmanı ve diyetisyen verilerini inceleyen "Sistem" metabolik analiz ünitesisin.
Avcı sana diyetisyeninin hazırladığı beslenme listesini/menüsünü gönderdi.
\${metin.isNotEmpty ? 'METİN NOTLARI: "$metin"' : ''}
\${imageBytes != null ? 'Görsel olarak diyet listesi fotoğrafı/belgesi iliştirildi. Belgedeki tüm öğünleri, porsiyonları ve besinleri dikkatle oku.' : ''}

GÖREVİN:
1. Bu diyetisyen programının günlük TOPLAM KALORİ, PROTEİN (g), KARBONHİDRAT (g) ve YAĞ (g) hedeflerini kesin/tahmini olarak hesapla.
2. Öğünleri (Sabah, Ara Öğün, Öğle, Akşam vb.) listele.
3. Çıktıyı SADECE geçerli bir JSON objesi olarak döndür:
{
  "toplamKalori": 2100,
  "toplamProtein": 150,
  "toplamKarb": 220,
  "toplamYag": 65,
  "notlar": "Diyetisyen yüksek proteinli, dengeli toparlanma planı hazırlamış.",
  "ogunler": [
    {"ad": "Kahvaltı", "detay": "3 yumurta, 50g lor, 2 dilim tam buğday ekmeği, yeşillik", "kalori": 450},
    {"ad": "Öğle Yemeği", "detay": "150g ızgara tavuk göğsü, 150g basmati pirinç, yeşil salata", "kalori": 550},
    {"ad": "Ara Öğün", "detay": "1 porsiyon meyve, 10 adet çiğ badem", "kalori": 200},
    {"ad": "Akşam Yemeği", "detay": "160g fırın somon, haşlanmış brokoli, 1 dilim siyez ekmeği", "kalori": 600}
  ]
}
''';

      final res = await _generateContent(model, apiKey, prompt, base64Image: base64Image);
      if (res == null || res.isEmpty) return null;

      final cleanJson = res.replaceAll(RegExp(r'```json\s*|```'), '').trim();
      final decoded = jsonDecode(cleanJson);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } catch (e) {
      debugPrint("Diyetisyen menü analizi hatası: $e");
      return null;
    }
  }

  /// Avcının mevcut kilosu, hedef kilosu, vücut kompozisyonu, beslenme planı
  /// ve kendi özel fikir/taleplerini harmanlayarak stratejik koçluk direktifi üretir.
  static Future<Map<String, dynamic>?> aiHedefKiloVeDiyetAnalizi({
    required double mevcutKilo,
    required double hedefKilo,
    required double boy,
    required double yagOrani,
    required int gunlukKalori,
    required int protein,
    required int karb,
    required int yag,
    required int haftalikIdmanGunu,
    required bool dovuscuMu,
    String? kullaniciFikri,
  }) async {
    final apiKey = SystemMemory.geminiApiKey.trim();
    if (apiKey.isEmpty) return null;

    final model = SystemMemory.geminiActiveModel;
    final double kiloFarki = hedefKilo - mevcutKilo;

    final prompt = '''
Sen Solo Leveling evrenindeki "SİSTEM"sin (The System). Avcının hedeflenen kilosuna ulaşması için diyet, kalori ve beslenme stratejisini analiz ediyorsun.

AVCI METABOLİK VERİLERİ:
- Mevcut Kilo: ${mevcutKilo.toStringAsFixed(1)} kg | Hedef Kilo: ${hedefKilo.toStringAsFixed(1)} kg (Fark: ${kiloFarki.toStringAsFixed(1)} kg)
- Boy: ${boy.toStringAsFixed(0)} cm | Vücut Yağ Oranı: %${yagOrani.toStringAsFixed(1)}
- Mevcut Kalori Hedefi: $gunlukKalori kcal
- Makrolar: P: ${protein}g | C: ${karb}g | F: ${yag}g
- Haftalık İdman: $haftalikIdmanGunu gün (${dovuscuMu ? "Dövüş Sporcusu / Combat" : "Fitness / Hipertrofi"})
${(kullaniciFikri != null && kullaniciFikri.isNotEmpty) ? '- AVCININ KENDİ GÖRÜŞÜ / ÖZEL BESLENME TALEBİ: "$kullaniciFikri"' : ''}

GÖREVİN:
1. Avcının kendi fikrini/talebini ve biyometrik verilerini harmanla.
2. Hedefe sağlıklı ve disiplinli ulaşması için haftalık tempo (kg/hafta) ve tahmini hedef tamamlama süresini (hafta) hesapla.
3. Gerekirse kalori ve makrolarda kullanıcının hedefine uygun ince ayarlar öner (revizeHedefKalori, revizeProtein, revizeKarb, revizeYag).
4. Avcıya hitaben motive edici, otoriter ve RPG sistem tonunda bir stratejik direktif yaz.
5. Yalnızca geçerli bir JSON objesi döndür:
{
  "stratejikDirektif": "Avcı, hedeflenen forma ulaşman için protokol hazırlandı...",
  "haftalikPaceKg": 0.5,
  "tahminiHafta": 16,
  "revizeHedefKalori": $gunlukKalori,
  "revizeProtein": $protein,
  "revizeKarb": $karb,
  "revizeYag": $yag,
  "taktikOzet": "Yüksek protein ve idman sonrası glikojen toparlanması."
}
''';

    try {
      final res = await _generateContent(model, apiKey, prompt);
      if (res == null || res.isEmpty) return null;

      final cleanJson = res.replaceAll(RegExp(r'```json\s*|```'), '').trim();
      final decoded = jsonDecode(cleanJson);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } catch (e) {
      debugPrint("Hedef kilo AI analizi hatası: $e");
      return null;
    }
  }

  /// Fotoğrafı analiz edip Avatar için çok detaylı bir İngilizce prompt oluşturur.
  static Future<String?> avatarIcinPromptUret(Uint8List fotoBytes) async {
    final apiKey = SystemMemory.geminiApiKey.trim();
    if (apiKey.isEmpty) return null;

    final model = SystemMemory.geminiActiveModel;
    String base64Image = base64Encode(fotoBytes);

    try {
      final prompt = '''
Sen bir karakter tasarımcısısın. Sana verilen bu fotoğraftaki kişinin yüz hatlarını (saç stili, sakal/bıyık durumu, yüz şekli, göz yapısı) piksel piksel analiz et. 
Ardından bu kişinin "Solo Leveling" tarzı bir RPG oyununda 'uyanmış' (awakened) halini betimleyen, 
İNGİLİZCE, son derece detaylı bir "Görsel Üretim Promptu (Image Generation Prompt)" yaz.

Kurallar:
- Prompt İngilizce olmalı.
- Kişinin fiziksel yüz benzerliği kesinlikle korunmalı (örneğin sakallıysa sakal tipi, saçları nasılsa o).
- Kişi kaslı, fit ve üzerinde siyah bir v-yaka tişört ile çizilmeli.
- Arka planda karanlık, kasvetli bir zindan (dungeon) veya loş bir spor salonu olmalı.
- Önünde parlayan, havada süzülen neon mavi bir "Sistem Hologram Paneli" (glowing blue holographic system panel) bulunmalı ve kişi ona bakmalı.
- "A hyper-realistic, highly detailed cinematic photograph..." şeklinde başla ve photorealistic, 8k resolution, cinematic lighting, sweat drops gibi etiketler ekle.
- Sadece İngilizce promptu döndür, başka hiçbir şey yazma.
''';

      return await _generateContent(model, apiKey, prompt, base64Image: base64Image);
    } catch (e) {
      return 'ERROR: $e';
    }
  }

  static Future<dynamic> avatarUret(String ingilizcePrompt) async {
    // Return mock since the service is currently blocked by Cloudflare turnstile.
    return "AVATAR_SYSTEM_LOCKED";
  }

  /// Faz 6: Akıllı Antrenör
  /// Oyuncunun rank'ine ve max ağırlıklarına göre tam oranlı, kg bazlı idman çıkartır.
  static Future<String?> akilliAntrenor(String talep, String vucutSinifi, String hunterRank, double maxBench, double maxSquat, double maxDeadlift, double kilo) async {
    final apiKey = SystemMemory.geminiApiKey.trim();
    if (apiKey.isEmpty) return null;

    final model = SystemMemory.geminiActiveModel;
    final prompt = '''
You are a ruthless and motivating AI trainer named "System" (Solo Leveling themed).
Hunter's Physical Stats:
- Body Class: $vucutSinifi
- Body Weight: ${kilo.toInt()} KG
- Hunter Rank (Allometric Strength): $hunterRank
- Max Strength (1RM): Bench Press: ${maxBench.toInt()} KG, Squat: ${maxSquat.toInt()} KG, Deadlift: ${maxDeadlift.toInt()} KG

User's request for today: "$talep"
If the request is empty, create a harsh workout suitable for their body class and rank.

Using the Hunter Rank and 1RM (One Rep Max) data, CALCULATE THE EXACT WEIGHTS they should lift in their sets. (e.g. 70-75% of 1RM for hypertrophy).
Provide the workout ONLY in the following JSON format in ENGLISH, do not write a single letter outside of the JSON.

{
  "planAdi": "Quest Title (e.g. C-Rank Chest Annihilation)",
  "sistemMesaji": "System warning (e.g. Your current strength is insufficient for the dungeon, tear your muscles apart.)",
  "gorevler": [
    {"isim": "[CHEST] Barbell Bench Press", "set_tekrar": "4 sets x 10 reps (75 KG)"},
    {"isim": "[CHEST] Incline Dumbbell Press", "set_tekrar": "3 sets x 12 reps (Dumbbell)"}
  ]
}
''';

    try {
      String json = await _generateContent(model, apiKey, prompt) ?? "";
      json = json.replaceAll(RegExp(r'```json\s*|```'), '').trim();
      return json;
    } catch (e) {
      return null;
    }
  }

  /// Gemini AI ile avcının tüm parametrelerini kullanarak kişiselleştirilmiş 7 günlük haftalık antrenman programı üretir.
  static Future<Map<int, List<Gorev>>?> haftalikProgramUret({
    required double kilo,
    required double boy,
    required String rank,
    required String hedef,
    required String zorluk,
    required String ekipman,
    required int idmanGunu,
    required bool dovuscuMu,
    required List<String> dovusBranslari,
    required List<String> eklemKisitlari,
    required List<String> odakBolgeleri,
    double? maxBench,
    double? maxSquat,
    double? deadlift,
    String? ozelTalep,
  }) async {
    final apiKey = SystemMemory.geminiApiKey.trim();
    if (apiKey.isEmpty) return null;

    final model = SystemMemory.geminiActiveModel;
    final prompt = '''
Sen Solo Leveling evrenindeki "Sistem"sin (The System). Avcıya kişiselleştirilmiş, disiplinli ve haftalık bir antrenman programı oluşturuyorsun.

AVCI PROFİL VERİLERİ:
- Rütbe (Rank): $rank
- Vücut: Kilo: ${kilo.toStringAsFixed(1)} kg, Boy: ${boy.toStringAsFixed(0)} cm
- Ana Hedef: $hedef, Zorluk Seviyesi: $zorluk
- Haftalık İdman Günü: $idmanGunu gün (Kalan günler dinlenme / aktif toparlanma)
- Ekipman: $ekipman
- Dövüş Sporcusu Mu: ${dovuscuMu ? "EVET, Branşlar: ${dovusBranslari.join(', ')}" : "HAYIR (Fitness / Vücut Geliştirme)"}
- Eklem Sakatlığı / Hassasiyet Koruması: ${eklemKisitlari.isNotEmpty ? eklemKisitlari.join(', ') : "Yok"} (DİKKAT: Bu eklemleri zorlayacak hareketler KESİNLİKLE YER ALMAMALI, eklem dostu alternatifler kullanılmalı!)
- Öncelikli Odak & Yağ Yakım Bölgeleri: ${odakBolgeleri.isNotEmpty ? odakBolgeleri.join(', ') : "Dengeli"} (DİKKAT: İdman günlerinin sonuna bu bölgeler için özel bitirici [FOCUS-...] hareketleri ekle!)
${(maxBench != null && maxBench > 0) ? "- 1RM Bench Press: ${maxBench.toStringAsFixed(0)} kg" : ""}
${(maxSquat != null && maxSquat > 0) ? "- 1RM Squat: ${maxSquat.toStringAsFixed(0)} kg" : ""}
${(deadlift != null && deadlift > 0) ? "- 1RM Deadlift: ${deadlift.toStringAsFixed(0)} kg" : ""}
${(ozelTalep != null && ozelTalep.isNotEmpty) ? "- Avcının Özel Notu / Talebi: $ozelTalep" : ""}

KURALLAR:
1. Türkçe olarak hazırla.
2. 1'den 7'ye kadar günleri tanımla (1: Pazartesi, 2: Salı, 3: Çarşamba, 4: Perşembe, 5: Cuma, 6: Cumartesi, 7: Pazar).
3. Avcının haftalık idman günü $idmanGunu gündür. İdman olmayan günleri boş dizi [] olarak bırak.
4. Her egzersiz hareketini formatla: "[KATEGORİ] Hareket Adı (Set x Tekrar veya Raund/Süre)".
   - Dövüş hareketlerinde branşa özel gölge boksu stilleri ve kombinasyonları yaz: Örn: "[COMBAT-SHADOW] Boks: Peek-a-boo Bob & Weave + 1-2-Roll-3 (5 Raund x 3 Dk)" veya "[COMBAT-SHADOW] Kickboks: Dutch 1-2-Sol Kroşe-Sağ Low Kick (5 Raund x 3 Dk)"
   - Fitness hareketlerinde yüksek hacim kullan: "[PHY] Barbell Bench Press (4-5 Set x 8-12 Tekrar)" veya "[PHY] Incline Dumbbell Press (4 Set x 12 Tekrar)"
   - Odak bitiricilerinde: "[FOCUS-CORE] Asılı Bacak Kaldırma & Plank (4 Set x 15 Tekrar)"
   - Kardiyo protokollerinde: "[CARDIO] 20 Dk Zone 2 Efor Koşusu / Yürüyüşü" veya "[COMBAT-CARDIO] 15 Dk Hızlı İp Atlama & Burpee Sprawl"
5. DOLU, UZATILMIŞ VE YÜKSEK HACİM KURALI: Her idman günü için KESİNLİKLE 6 İLE 8 HAREKET DİZ. Hareketler 4-5 set ve 10-15 tekrar olmalı, dövüş drilleri 5-6 raund x 3 dk olmalıdır. Asla kısa bırakma!
   Her idman gününde şu katmanlar eksiksiz bulunmalı ve HER GÜNÜN SONUNDA KESİNLİKLE EN AZ 1 TANE AYRI VE NET [CARDIO] GÖREVİ YER ALMALIDIR:
   - 1-2 Ana Bileşik Kuvvet Hareketi (Compound: Bench Press, Squat, Barfiks, Overhead Press vb. - 4-5 Set)
   - 2-3 İzolasyon & Destek Hareketi (Incline DB, Row, Dips, Lateral Raise, Biceps/Triceps vb. - 4-5 Set)
   - 1 Core / Karın Protokolü ([CORE / ABS] veya [FOCUS-CORE] - 4 Set)
   - 1 KESİNTİSİZ KARDİYO MİSYONU ([CARDIO] 20 Dk Eğimli Koşu Bandı, [CARDIO] 20 Dk İp Atlama HIIT, [CARDIO] 5 KM Avcı Koşusu, [CARDIO] 20 Dk Bisiklet/Kürek vb.)
6. ÇIKTIYI YALNIZCA AŞAĞIDAKİ JSON FORMATINDA DÖNDÜR, JSON DIŞINDA HİÇBİR AÇIKLAMA YAZMA:

{
  "1": [
    {"ad": "[PHY] Barbell Bench Press (4 Set x 8 Tekrar)", "tip": "Fiziksel"},
    {"ad": "[PHY] Incline Dumbbell Press (3 Set x 10 Tekrar)", "tip": "Fiziksel"},
    {"ad": "[PHY] Dips / Göğüs İtiş (3 Set x 10 Tekrar)", "tip": "Fiziksel"},
    {"ad": "[PHY] Lateral Raise (4 Set x 12 Tekrar)", "tip": "Fiziksel"},
    {"ad": "[CORE / ABS] Asılı Bacak Kaldırma (3 Set x 15 Tekrar)", "tip": "Fiziksel"},
    {"ad": "[CARDIO] 20 Dk Zone 2 Efor Yürüyüşü / Koşusu", "tip": "Fiziksel"}
  ],
  "2": [],
  "3": [
    {"ad": "...", "tip": "Fiziksel"}
  ],
  "4": [],
  "5": [
    {"ad": "...", "tip": "Fiziksel"}
  ],
  "6": [],
  "7": []
}
''';

    try {
      final responseText = await _generateContent(model, apiKey, prompt);
      if (responseText == null || responseText.isEmpty) return null;

      final cleanJson = responseText.replaceAll(RegExp(r'```json\s*|```'), '').trim();
      final decoded = jsonDecode(cleanJson);
      if (decoded is! Map) return null;

      final Map<int, List<Gorev>> plan = {};
      for (int i = 1; i <= 7; i++) {
        plan[i] = [];
        final keyStr = i.toString();
        if (decoded.containsKey(keyStr) && decoded[keyStr] is List) {
          final list = decoded[keyStr] as List;
          for (final item in list) {
            if (item is Map) {
              final ad = item['ad']?.toString() ?? item['isim']?.toString() ?? '';
              final tip = item['tip']?.toString() ?? 'Fiziksel';
              if (ad.isNotEmpty) {
                plan[i]!.add(Gorev(ad, false, tip));
              }
            }
          }
        }
      }
      return plan;
    } catch (e) {
      debugPrint("Haftalık program JSON decode hatası: $e");
      return null;
    }
  }

  /// Avcının rütbe, odak bölgesi ve dövüş durumuna göre 3-4 hareketlik kişiye özel "Ek İdman / Finisher Booster" üretir.
  static Future<List<Gorev>?> aiEkIdmanUret({
    required String rank,
    required bool dovuscuMu,
    required List<String> dovusBranslari,
    required List<String> odakBolgeleri,
    required List<String> eklemKisitlari,
  }) async {
    final apiKey = SystemMemory.geminiApiKey.trim();
    if (apiKey.isEmpty) return null;

    final model = SystemMemory.geminiActiveModel;
    final prompt = '''
Sen Solo Leveling evrenindeki "Sistem"sin. Avcı için seans sonuna veya mevcut idmanına eklenecek 4-5 hareketlik yüksek etkili ve uzatılmış bir "AI ÖZEL EK İDMAN / FINISHER BOOSTER" oluştur.
AVCI:
- Rütbe: $rank
- Dövüş Sporcusu Mu: ${dovuscuMu ? "EVET, ${dovusBranslari.join(', ')}" : "HAYIR"}
- Öncelikli Odak: ${odakBolgeleri.isNotEmpty ? odakBolgeleri.join(', ') : "Karın & Kardiyo"}
- Sakatlık Koruması: ${eklemKisitlari.isNotEmpty ? eklemKisitlari.join(', ') : "Yok"}

KURALLAR:
1. Türkçe olarak 4 veya 5 hareket hazırla.
2. Format: "[KATEGORİ] Hareket Adı (Set x Tekrar veya Süre)"
3. KESİNLİKLE EN AZ 1 TANE AYRI VE NET [CARDIO] GÖREVİ İÇERMELİDİR (Örn: "[CARDIO] 20 Dk Yüksek Yoğunluklu İp Atlama HIIT").
4. ÇIKTIYI YALNIZCA AŞAĞIDAKİ JSON DİZİSİ OLARAK DÖNDÜR, BAŞKA HİÇBİR ŞEY YAZMA:
[
  {"ad": "[FOCUS-CORE] Asılı Bacak Kaldırma & Plank (4 Set x 15)", "tip": "Fiziksel"},
  {"ad": "[CARDIO] 20 Dk Yüksek Yoğunluklu İp Atlama HIIT", "tip": "Fiziksel"},
  {"ad": "[COMBAT] Gölge Boksu Patlayıcı Kombinasyon (4 Raund x 3 Dk)", "tip": "Fiziksel"},
  {"ad": "[PHY] Dips & Göğüs İtiş (4 Set x 12)", "tip": "Fiziksel"}
]
''';

    try {
      final responseText = await _generateContent(model, apiKey, prompt);
      if (responseText == null || responseText.isEmpty) return null;

      final cleanJson = responseText.replaceAll(RegExp(r'```json\s*|```'), '').trim();
      final decoded = jsonDecode(cleanJson);
      if (decoded is! List) return null;

      final List<Gorev> gorevler = [];
      for (final item in decoded) {
        if (item is Map) {
          final ad = item['ad']?.toString() ?? item['isim']?.toString() ?? '';
          final tip = item['tip']?.toString() ?? 'Fiziksel';
          if (ad.isNotEmpty) {
            gorevler.add(Gorev(ad, false, tip));
          }
        }
      }
      return gorevler.isNotEmpty ? gorevler : null;
    } catch (e) {
      debugPrint("AI booster generation error: $e");
      return null;
    }
  }

  /// Uzmanlık alanı, seviye ve günlük süreye göre kişiye özel haftalık zihinsel gelişim ve çalışma protokolü üretir.
  static Future<List<MentalTask>> aiCalismaPlaniUret({
    required String alan,
    required String seviye,
    required int gunlukDakika,
    String? hedef,
  }) async {
    final apiKey = SystemMemory.geminiApiKey.trim();
    final model = SystemMemory.geminiActiveModel.isNotEmpty
        ? SystemMemory.geminiActiveModel
        : 'gemini-3.6-flash';

    if (apiKey.isEmpty) {
      return _varsayilanZihinselProtokol(alan, gunlukDakika);
    }

    final prompt = '''
Sen Solo Leveling Sistemisin. Kullanıcı [AVCI] zihinsel ve mesleki uyanışını gerçekleştirmek istiyor.
Aşağıdaki verilere göre Avcı için 3 veya 4 adet yüksek odaklı ZİHİNSEL GELİŞİM / ÇALIŞMA GÖREVİ hazırla:
- Uzmanlık / İlgi Alanı: $alan
- Mevcut Seviye: $seviye
- Günlük Ayrılacak Süre: $gunlukDakika dakika
- Hedef: ${hedef ?? "Uzmanlıkta Seviye Atlama & Kitap Okuma Disiplini"}

KURALLAR:
1. Türkçe yaz.
2. EN AZ 1 TANE KİTAP OKUMA VEYA KAYNAK ARAŞTIRMA GÖREVİ OLMALIDIR (category: "Book").
3. Diğer görevler pratik, kodlama, vaka inceleme, sınav veya yabancı dil içermelidir (category: "Coding", "Language", "Exam", "Skill").
4. ÇIKTIYI YALNIZCA AŞAĞIDAKİ JSON DİZİSİ OLARAK DÖNDÜR, BAŞKA METİN YAZMA:
[
  {
    "title": "[ALAN] 30 Dk İleri Konu Analizi",
    "category": "Skill",
    "targetMinutes": 30,
    "rewardExp": 90,
    "rewardInt": 2,
    "rewardPer": 1,
    "notes": "Önemli kavramları çıkar."
  },
  {
    "title": "[KİTAP] Alan Kılavuzu Okuması (20 Sayfa)",
    "category": "Book",
    "targetMinutes": 25,
    "targetPages": 20,
    "bookTitle": "Mesleki Başucu Kitabı",
    "rewardExp": 80,
    "rewardInt": 1,
    "rewardPer": 2
  }
]
''';

    try {
      final responseText = await _generateContent(model, apiKey, prompt);
      if (responseText == null || responseText.isEmpty) {
        return _varsayilanZihinselProtokol(alan, gunlukDakika);
      }

      final cleanJson = responseText.replaceAll(RegExp(r'```json\s*|```'), '').trim();
      final decoded = jsonDecode(cleanJson);
      if (decoded is! List) return _varsayilanZihinselProtokol(alan, gunlukDakika);

      final List<MentalTask> gorevler = [];
      for (final item in decoded) {
        if (item is Map<String, dynamic>) {
          gorevler.add(MentalTask.fromJson(item));
        } else if (item is Map) {
          gorevler.add(MentalTask.fromJson(Map<String, dynamic>.from(item)));
        }
      }
      return gorevler.isNotEmpty ? gorevler : _varsayilanZihinselProtokol(alan, gunlukDakika);
    } catch (e) {
      debugPrint("AI study plan generation error: $e");
      return _varsayilanZihinselProtokol(alan, gunlukDakika);
    }
  }

  /// Çevrimdışı veya API'siz durumlarda branşa göre akıllı yerel zihinsel protokol şablonu.
  static List<MentalTask> _varsayilanZihinselProtokol(String alan, int gunlukDakika) {
    final lower = alan.toLowerCase();
    final now = DateTime.now().millisecondsSinceEpoch;

    if (lower.contains('yazılım') || lower.contains('kod') || lower.contains('flutter') || lower.contains('ai') || lower.contains('software')) {
      return [
        MentalTask(
          id: 'mt_${now}_1',
          title: '[KOD] Mimari & Algoritma Pratiği (30 dk)',
          category: 'Coding',
          targetMinutes: 30,
          rewardExp: 100,
          rewardInt: 2,
          rewardPer: 1,
          notes: 'Temiz kod ve tasarım desenlerine dikkat et.',
        ),
        MentalTask(
          id: 'mt_${now}_2',
          title: '[KİTAP] Teknik Kitap Okuma & Analiz (20 sayfa)',
          category: 'Book',
          bookTitle: 'Clean Code / Refactoring',
          targetPages: 20,
          targetMinutes: 25,
          rewardExp: 90,
          rewardInt: 2,
          rewardPer: 2,
        ),
        MentalTask(
          id: 'mt_${now}_3',
          title: '[ODAK] Hata Ayıklama & Derin Çalışma (25 dk)',
          category: 'Skill',
          targetMinutes: 25,
          rewardExp: 80,
          rewardInt: 1,
          rewardPer: 2,
        ),
      ];
    } else if (lower.contains('dil') || lower.contains('english') || lower.contains('ingilizce') || lower.contains('almanca')) {
      return [
        MentalTask(
          id: 'mt_${now}_1',
          title: '[DİL] Hedef Dilde 30 Dk Aktif Pratik & Konuşma',
          category: 'Language',
          targetMinutes: 30,
          rewardExp: 90,
          rewardInt: 1,
          rewardPer: 2,
        ),
        MentalTask(
          id: 'mt_${now}_2',
          title: '[KİTAP] Yabancı Dilde Kitap Okuma (15 sayfa)',
          category: 'Book',
          targetPages: 15,
          targetMinutes: 25,
          rewardExp: 90,
          rewardInt: 2,
          rewardPer: 2,
        ),
        MentalTask(
          id: 'mt_${now}_3',
          title: '[DİNLEME] Yabancı Dilde Podcast & Not Çıkarma',
          category: 'Language',
          targetMinutes: 20,
          rewardExp: 70,
          rewardInt: 1,
          rewardPer: 1,
        ),
      ];
    } else if (lower.contains('sınav') || lower.contains('yks') || lower.contains('kpss') || lower.contains('tıp') || lower.contains('akademi')) {
      return [
        MentalTask(
          id: 'mt_${now}_1',
          title: '[KONU] Yoğunlaştırılmış Konu Özeti Çıkarma (35 dk)',
          category: 'Exam',
          targetMinutes: 35,
          rewardExp: 110,
          rewardInt: 2,
          rewardPer: 1,
        ),
        MentalTask(
          id: 'mt_${now}_2',
          title: '[KİTAP] Ders Kaynağı / Makale İncelemesi (25 sayfa)',
          category: 'Book',
          targetPages: 25,
          targetMinutes: 30,
          rewardExp: 100,
          rewardInt: 2,
          rewardPer: 2,
        ),
        MentalTask(
          id: 'mt_${now}_3',
          title: '[SORU] Kritik Soru Çözümü & Analiz (30 dk)',
          category: 'Exam',
          targetMinutes: 30,
          rewardExp: 90,
          rewardInt: 1,
          rewardPer: 2,
        ),
      ];
    } else {
      return [
        MentalTask(
          id: 'mt_${now}_1',
          title: '[KİTAP] Zihinsel Disiplin & Felsefe Okuması (20 sayfa)',
          category: 'Book',
          bookTitle: 'Günün Eseri',
          targetPages: 20,
          targetMinutes: 25,
          rewardExp: 90,
          rewardInt: 2,
          rewardPer: 2,
        ),
        MentalTask(
          id: 'mt_${now}_2',
          title: '[BECERİ] Uzmanlık Alanında Derin İnceleme (30 dk)',
          category: 'Skill',
          targetMinutes: 30,
          rewardExp: 80,
          rewardInt: 2,
          rewardPer: 1,
        ),
        MentalTask(
          id: 'mt_${now}_3',
          title: '[ODAK] Günlük Planlama & Zihinsel Netlik (15 dk)',
          category: 'Skill',
          targetMinutes: 15,
          rewardExp: 60,
          rewardInt: 1,
          rewardPer: 2,
        ),
      ];
    }
  }

  /// Okunan kitaptan veya konudan kilit avcı dersleri ve stratejik çıkarımlar üretir.
  static Future<String> aiKitapCikarimiUret({
    required String kitapAdi,
    required String notlar,
  }) async {
    final apiKey = SystemMemory.geminiApiKey.trim();
    final model = SystemMemory.geminiActiveModel.isNotEmpty
        ? SystemMemory.geminiActiveModel
        : 'gemini-3.6-flash';

    if (apiKey.isEmpty) {
      return "[ SİSTEM BİLGELİĞİ: $kitapAdi ]\n"
          "1. KAVRAMA: Bilgiyi ezberleme, zihinsel modellerine entegre et.\n"
          "2. DİSİPLİN: Her gün okunan 20 sayfa, yılda 25 kitaba ve devasa bir INT artışına dönüşür.\n"
          "3. EYLEM: Teori tek başına güç değildir; uygulanan bilgi kudrettir.";
    }

    final prompt = '''
Kullanıcı [AVCI] şu kitaptan/konudan notlar okudu ve sisteme kaydetti:
- Eser / Konu: $kitapAdi
- Avcının Notları / Odak Noktaları: $notlar

Solo Leveling Sistemi olarak bu bilgileri analiz et.
Avcıya karakterini, zekasını (INT) ve algısını (PER) geliştirecek 3 TANE KESKİN SİSTEM ÇIKARIMI (Ders / Strateji) yaz.
Başında "[ SİSTEM BİLGELİĞİ: $kitapAdi ]" başlığı olsun.
Maddeli, otoriter ve ilham verici bir dille yaz.
''';

    try {
      final responseText = await _generateContent(model, apiKey, prompt);
      if (responseText != null && responseText.trim().isNotEmpty) {
        return responseText.trim();
      }
    } catch (e) {
      debugPrint("AI insight error: $e");
    }

    return "[ SİSTEM BİLGELİĞİ: $kitapAdi ]\n"
        "1. KAVRAMA: Bilgiyi ezberleme, zihinsel modellerine entegre et.\n"
        "2. DİSİPLİN: Düzenli okuma disiplini zihnin dayanıklılığını maksimuma ulaştırır.\n"
        "3. EYLEM: Okunan her sayfa, zindanda stratejik bir avantaja dönüşür.";
  }
}

