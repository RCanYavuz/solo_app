// lib/core/services/gemini_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../controllers/system_memory.dart';

/// Solo App Gemini Yapay Zeka Servisi (Clean Architecture - Core Katmanı)
class GeminiService {
  static GenerativeModel? _model;
  static String? _currentApiKey;
  static String _activeModelName = 'gemini-1.5-flash';

  static const String _systemInstruction =
      'Sen Solo Leveling evrenindeki gizemli ve kudretli "Sistem"sin (The System). '
      'Kullanıcı bir "Avcı" (Hunter). Ona kısa, otoriter, disiplinli ve motive edici bir dille hitap et. '
      'Türkçe konuş. Cümlelerinde bazen [SİSTEM], [BİLDİRİM] gibi RPG tarzı köşeli parantezler kullan. '
      'Gereksiz nezaket cümleleri yerine net, keskin bir Sistem dili benimse.';

  /// Model nesnesini döndürür.
  static GenerativeModel? _getModel({String? modelName}) {
    final apiKey = SystemMemory.geminiApiKey.trim();
    if (apiKey.isEmpty) return null;

    final targetModel = modelName ?? _activeModelName;

    if (_model != null &&
        _currentApiKey == apiKey &&
        _activeModelName == targetModel) {
      return _model;
    }

    _currentApiKey = apiKey;
    _activeModelName = targetModel;
    _model = GenerativeModel(
      model: targetModel,
      apiKey: apiKey,
      systemInstruction: Content.system(_systemInstruction),
    );
    return _model;
  }

  /// API Anahtarını doğrudan Google API üzerinden denetler.
  /// Hangi modellerin açık olduğunu bulur veya kesin hata sebebini açıklar.
  static Future<Map<String, dynamic>> testBaglantisi({
    String? hunterName,
  }) async {
    final apiKey = SystemMemory.geminiApiKey.trim();
    if (apiKey.isEmpty) {
      return {
        'basarili': false,
        'mesaj': '⚠️ Sistem hafızasında API anahtarı bulunamadı.',
      };
    }

    try {
      // 1. Google Sunucusuna doğrudan Model Listesi sorgusu at (Gerçek teşhis)
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey',
      );
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
          'mesaj':
              '⚠️ API anahtarınız geçerli fakat bu projeye tanımlı hiçbir Gemini modeli bulunamadı.',
        };
      }

      // generateContent destekleyen modelleri filtrele
      final availableModelNames = <String>[];
      for (var m in models) {
        final name = (m['name'] as String? ?? '').replaceFirst('models/', '');
        final methods = List<String>.from(
          m['supportedGenerationMethods'] ?? [],
        );
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

      // Flash modellerini (ücretsiz kotası en geniş olanlar) ön sıraya al
      availableModelNames.sort((a, b) {
        int aScore = a.contains('flash') ? 0 : 1;
        int bScore = b.contains('flash') ? 0 : 1;
        return aScore.compareTo(bScore);
      });

      final avciAdi = (hunterName != null && hunterName.isNotEmpty)
          ? hunterName
          : (SystemMemory.oyuncuIsmi.isNotEmpty &&
                    SystemMemory.oyuncuIsmi != 'PLAYER'
                ? SystemMemory.oyuncuIsmi
                : 'AVCI');
      final prompt =
          'Sistem protokolü onaylandı. Avcı $avciAdi için tek cümlelik otoriter bir Sistem uyanış mesajı üret.';

      String sonHata = '';

      // Sırayla modelleri dene, hangisinin kotası açıksa onu bul
      for (final candidate in availableModelNames) {
        try {
          final model = _getModel(modelName: candidate);
          if (model == null) continue;

          final response = await model.generateContent([Content.text(prompt)]);
          final text = response.text;

          if (text != null && text.trim().isNotEmpty) {
            _activeModelName = candidate;
            return {'basarili': true, 'model': candidate, 'mesaj': text.trim()};
          }
        } catch (e) {
          sonHata = e.toString();
          // Kota dolu veya desteklenmiyorsa diğer modele geç
          continue;
        }
      }

      return {
        'basarili': false,
        'mesaj':
            '❌ Google Kota Uyarısı: Mevcut anahtarınızda modellerin ücretsiz kotası (limit: 0) olarak görünüyor. Detay: $sonHata',
      };
    } catch (e) {
      return {'basarili': false, 'mesaj': '❌ Bağlantı hatası: $e'};
    }
  }

  /// Avcının serbest dille yazdığı öğünü analiz eder ve besin değerlerini tahmin eder.
  static Future<String?> yemekAnalizEt(String yemekTarifi) async {
    final model = _getModel();
    if (model == null) return null;

    try {
      final prompt =
          '''
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

      final response = await model.generateContent([Content.text(prompt)]);
      return response.text;
    } catch (e) {
      return null;
    }
  }
}
