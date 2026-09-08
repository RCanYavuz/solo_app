// lib/core/services/gemini_service.dart
import 'dart:async';
import 'dart:convert';
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

  /// REST API üzerinden Gemini'ye mesaj gönderir.
  static Future<String?> _generateContent(String modelName, String apiKey, String prompt) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=$apiKey',
    );

    final body = jsonEncode({
      'system_instruction': {
        'parts': [{'text': _systemInstruction}]
      },
      'contents': [
        {
          'parts': [{'text': prompt}]
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
        final parts = candidates[0]['content']?['parts'] as List?;
        if (parts != null && parts.isNotEmpty) {
          for (final part in parts) {
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
  /// Çalışan bir model bulur ve Sistem uyanış mesajı üretir.
  static Future<Map<String, dynamic>> testBaglantisi({
    String? hunterName,
    String? apiKeyOverride,
  }) async {
    final apiKey = (apiKeyOverride != null && apiKeyOverride.trim().isNotEmpty)
        ? apiKeyOverride.trim()
        : SystemMemory.geminiApiKey.trim();
    if (apiKey.isEmpty) {
      return {
        'basarili': false,
        'mesaj': '⚠️ Sistem hafızasında API anahtarı bulunamadı.',
      };
    }

    final avciAdi = (hunterName != null && hunterName.isNotEmpty)
        ? hunterName
        : (SystemMemory.oyuncuIsmi.isNotEmpty &&
                  SystemMemory.oyuncuIsmi != 'PLAYER'
              ? SystemMemory.oyuncuIsmi
              : 'AVCI');
    final prompt =
        'Sistem protokolü onaylandı. Avcı $avciAdi için tek cümlelik otoriter bir Sistem uyanış mesajı üret.';

    // Güncel modeller (Eylül 2026)
    final modelsToTry = <String>[
      'gemini-3.6-flash',
      'gemini-3.5-flash',
      'gemini-3.1-pro',
      'gemini-3-flash-preview',
    ];

    final hatalar = <String>[];

    for (final candidate in modelsToTry) {
      try {
        final text = await _generateContent(candidate, apiKey, prompt);

        if (text != null && text.trim().isNotEmpty) {
          activeModelName = candidate;
          SystemMemory.geminiApiKey = apiKey;
          await SystemMemory.kaydet();
          return {'basarili': true, 'model': candidate, 'mesaj': text.trim()};
        }
      } on TimeoutException {
        hatalar.add('$candidate: Zaman aşımı (30s)');
        continue;
      } catch (e) {
        String hataOzet = e.toString();
        if (hataOzet.length > 150) hataOzet = '${hataOzet.substring(0, 150)}...';
        hatalar.add('$candidate: $hataOzet');
        continue;
      }
    }

    return {
      'basarili': false,
      'mesaj':
          '❌ Hiçbir model yanıt veremedi.\n\n'
          'Denenen modeller:\n${hatalar.join('\n')}\n\n'
          'Olası sebepler:\n'
          '• API anahtarı geçersiz\n'
          '• Generative AI API projenizde aktif değil\n'
          '• Ücretsiz kota dolmuş',
    };
  }

  /// Avcının serbest dille yazdığı öğünü analiz eder ve besin değerlerini tahmin eder.
  static Future<String?> yemekAnalizEt(String yemekTarifi) async {
    final apiKey = SystemMemory.geminiApiKey.trim();
    if (apiKey.isEmpty) return null;

    final model = activeModelName.isNotEmpty &&
            !activeModelName.contains('1.5') &&
            !activeModelName.contains('2.5')
        ? activeModelName
        : 'gemini-3.6-flash';

    try {
      final prompt = '''
Avcı şu öğünü tüketti: "$yemekTarifi".
Lütfen bu öğünün yaklaşık besin değerlerini çıkar.
Yalnızca geçerli bir JSON objesi döndür:
{
  "yemekAdi": "Kısa yemek adı",
  "kalori": 450,
  "protein": 30,
  "karbonhidrat": 45,
  "yag": 12,
  "sistemMesaji": "Disiplinli beslenme tespit edildi."
}
''';

      return await _generateContent(model, apiKey, prompt);
    } catch (e) {
      return null;
    }
  }
}
