// lib/core/services/gemini_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../../controllers/system_memory.dart';

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
        'mesaj': '⚠️ Sistem hafızasında API anahtarı bulunamadı.',
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
          'mesaj': '❌ Google API Hatası (${res.statusCode}): $errMsg',
        };
      }

      final data = jsonDecode(res.body);
      final List models = data['models'] ?? [];

      if (models.isEmpty) {
        return {
          'basarili': false,
          'mesaj': '⚠️ API anahtarınız geçerli fakat bu projeye tanımlı hiçbir Gemini modeli bulunamadı.',
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
          'mesaj': '⚠️ Kullanılabilir metin üretim modeli bulunamadı.',
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
          : (SystemMemory.oyuncuIsmi.isNotEmpty && SystemMemory.oyuncuIsmi != 'PLAYER' ? SystemMemory.oyuncuIsmi : 'AVCI');
      final prompt = 'Sistem protokolü onaylandı. Avcı $avciAdi için tek cümlelik otoriter bir Sistem uyanış mesajı üret.';

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
Sen "Sistem" adında acımasız ve motive edici bir yapay zeka antrenörüsün (Solo Leveling temalı).
Karşındaki Avcı'nın Fiziksel İstatistikleri:
- Vücut Sınıfı: $vucutSinifi
- Vücut Ağırlığı: ${kilo.toInt()} KG
- Hunter Rank (Allometric Güç): $hunterRank
- Maksimum Güç (1RM): Bench Press: ${maxBench.toInt()} KG, Squat: ${maxSquat.toInt()} KG, Deadlift: ${maxDeadlift.toInt()} KG

Kullanıcının bugünkü talebi: "$talep"
Eğer talep boşsa, vücut sınıfına ve rütbesine uygun sert bir idman uydur.

Hunter Rank ve 1RM (Maksimum Tekrar) verilerini kullanarak, setlerde kaldırması gereken KİLOLARI BİZZAT HESAPLA. (Örn: Hacim için 1RM'nin %70-75'i).
Döndüreceğin idmanı SADECE aşağıdaki JSON formatında ver, JSON dışında tek bir harf yazma.

{
  "planAdi": "Görev Başlığı (Örn: C-Rank Göğüs Yıkımı)",
  "sistemMesaji": "Sistem uyarısı (Örn: Mevcut gücün zindan için yetersiz, kaslarını parçala.)",
  "gorevler": [
    {"isim": "[CHEST] Barbell Bench Press", "set_tekrar": "4 set x 10 tekrar (75 KG)"},
    {"isim": "[CHEST] Incline Dumbbell Press", "set_tekrar": "3 set x 12 tekrar (Dambıl ile)"}
  ]
}
''';

    try {
      String json = await _generateContent(model, apiKey, prompt);
      if (json.startsWith("```json")) {
        json = json.replaceAll("```json", "").replaceAll("```", "").trim();
      }
      return json;
    } catch (e) {
      return null;
    }
  }
}
