// lib/core/youtube_helper.dart
// ============================================================
// YOUTUBE VIDEO & EGZERSİZ REHBERİ YARDIMCISI
// Egzersiz isimlerini temizleyip YouTube arama sorgusu oluşturur,
// video rehberine tek dokunuşla yönlendirir.
// ============================================================

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class YoutubeHelper {
  /// Görev adını temizleyip en doğru YouTube form arama terimini üretir.
  /// Örnekler:
  /// "[COMBAT] Boks: Patlayıcı İtiş & Plyo Şınav (4 Set x 8 Tekrar)" -> "Boks Patlayıcı İtiş & Plyo Şınav egzersizi nasıl yapılır form"
  /// "[PHY] Push (Chest/Shoulders/Triceps)" -> "Push Chest Shoulders Triceps egzersizi nasıl yapılır form"
  /// "[CHEST] 100 Push-ups" -> "Push-ups egzersizi nasıl yapılır form"
  static String gorevAdiniTemizle(String hamGorevAdi) {
    String metin = hamGorevAdi;

    // 1. Köşeli parantezleri ve içindeki kategori etiketlerini temizle: [COMBAT], [PHY], [CHEST], [CORE / ABS] vb.
    metin = metin.replaceAll(RegExp(r'\[.*?\]'), ' ');

    // 2. Set, tekrar, raund veya süre belirten parantezleri temizle: (4 Set x 8 Tekrar), (3 Min), (3x10), (5 Raund x 3 Dk)
    metin = metin.replaceAll(
      RegExp(r'\((?:[^)]*?(?:set|tekrar|raund|round|dk|min|sec|sn|rep|\d\s*x|\d+\s*km|\d+\s*m)[^)]*?)\)', caseSensitive: false),
      ' ',
    );

    // 3. Kalan parantezleri kaldır
    metin = metin.replaceAll(RegExp(r'[\(\)]'), ' ');

    // 4. "100 Push-ups", "50 Squats" gibi hedeflerdeki saf sayıları baştan temizle ki hareket adı öne çıksın
    metin = metin.replaceAll(RegExp(r'^\s*\d+\s+'), '');

    // 5. Başındaki veya içindeki gereksiz iki nokta / tireleri temizle
    metin = metin.replaceAll(RegExp(r'[:/\\|~]'), ' ');

    // 6. Birden fazla boşlukları teke indir ve kenarları kırp
    metin = metin.replaceAll(RegExp(r'\s+'), ' ').trim();

    if (metin.isEmpty) {
      metin = hamGorevAdi.trim();
    }

    // Arama motorunda doğrudan doğru formu bulması için rehber terimini ekle
    return '$metin egzersizi nasıl yapılır form';
  }

  /// Verilen hareket veya ham görev adı için YouTube'u başlatır
  static Future<void> videoAc(String gorevAdi, {BuildContext? context}) async {
    final aramaSorgusu = gorevAdiniTemizle(gorevAdi);
    final Uri url = Uri.parse('https://www.youtube.com/results?search_query=${Uri.encodeComponent(aramaSorgusu)}');

    try {
      final basarili = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
      if (!basarili) {
        await launchUrl(url, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      debugPrint('YouTube yönlendirme hatası: $e');
      try {
        await launchUrl(url, mode: LaunchMode.platformDefault);
      } catch (_) {}
    }
  }

  /// Herhangi bir görev kartı veya satırına eklenebilen YouTube Form Butonu
  static Widget buildYouTubeButton({
    required String gorevAdi,
    double size = 20,
    Color color = const Color(0xFFEF4444),
    EdgeInsetsGeometry padding = const EdgeInsets.all(4),
  }) {
    return Builder(
      builder: (context) {
        return IconButton(
          icon: Icon(Icons.play_circle_fill, color: color, size: size),
          tooltip: 'YouTube Form Rehberi',
          padding: padding,
          constraints: const BoxConstraints(),
          splashRadius: size + 6,
          onPressed: () => videoAc(gorevAdi, context: context),
        );
      },
    );
  }
}
