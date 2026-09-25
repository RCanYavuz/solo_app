// lib/core/document_parser.dart
import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';

/// Diyetisyen Doküman & Liste Ayrıştırıcı (Dietitian Document Parser)
/// [DietitianScannerModal] tarafından kullanılarak PDF, Word (.docx, .doc),
/// görsel ve metin formatındaki profesyonel diyetisyen listelerinin
/// Gemini AI metabolik taramasına aktarılmasını sağlar.

class ParsedDocument {
  final String fileName;
  final String extension;
  final Uint8List bytes;
  final String? extractedText;
  final String mimeType;

  ParsedDocument({
    required this.fileName,
    required this.extension,
    required this.bytes,
    this.extractedText,
    required this.mimeType,
  });

  bool get isPdf => extension.toLowerCase() == 'pdf';
  bool get isWord => extension.toLowerCase() == 'docx' || extension.toLowerCase() == 'doc';
  bool get isImage => ['jpg', 'jpeg', 'png', 'webp'].contains(extension.toLowerCase());
}

class DocumentParser {
  /// Sistem dosya seçicisini açarak PDF, Word (.docx, .doc) veya metin dosyası seçtirir.
  static Future<ParsedDocument?> pickDocument() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'doc', 'txt', 'png', 'jpg', 'jpeg'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return null;

      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null) return null;

      final ext = (file.extension ?? '').toLowerCase();
      String? extractedText;
      String mimeType = 'application/octet-stream';

      if (ext == 'docx') {
        extractedText = extractTextFromDocx(bytes);
        mimeType = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      } else if (ext == 'pdf') {
        mimeType = 'application/pdf';
      } else if (ext == 'txt') {
        extractedText = utf8.decode(bytes, allowMalformed: true);
        mimeType = 'text/plain';
      } else if (ext == 'doc') {
        // Eski binary doc dosyaları için en azından UTF-8/ASCII metin bloklarını süzmeyi dene
        extractedText = _extractTextFromLegacyDoc(bytes);
        mimeType = 'application/msword';
      } else if (ext == 'jpg' || ext == 'jpeg') {
        mimeType = 'image/jpeg';
      } else if (ext == 'png') {
        mimeType = 'image/png';
      }

      return ParsedDocument(
        fileName: file.name,
        extension: ext,
        bytes: bytes,
        extractedText: extractedText,
        mimeType: mimeType,
      );
    } catch (e) {
      debugPrint('Doküman seçme ve ayrıştırma hatası: $e');
      return null;
    }
  }

  /// Word (.docx) dosyasından saf metni ayrıştırır.
  /// DOCX, zip formatında bir pakettir ve ana içerik word/document.xml dosyasında bulunur.
  static String extractTextFromDocx(Uint8List bytes) {
    try {
      final archive = ZipDecoder().decodeBytes(bytes);
      for (final file in archive) {
        if (file.name == 'word/document.xml') {
          final content = utf8.decode(file.content as List<int>, allowMalformed: true);
          return _cleanWordXml(content);
        }
      }
    } catch (e) {
      debugPrint('DOCX ayrıştırma hatası: $e');
    }
    return '';
  }

  static String _cleanWordXml(String xmlContent) {
    // Paragraf sonlarını yeni satıra çevir
    String text = xmlContent
        .replaceAll(RegExp(r'</w:p>'), '\n')
        .replaceAll(RegExp(r'<w:br[^>]*>'), '\n')
        .replaceAll(RegExp(r'<w:tab[^>]*>'), '\t');

    // XML taglerini temizle
    text = text.replaceAll(RegExp(r'<[^>]+>'), '');

    // Standart XML/HTML entity kaçışlarını dönüştür
    text = text
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'");

    // Fazla boş satırları toparla
    final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty);
    return lines.join('\n');
  }

  /// Eski .doc dosyalarında bulunan okunabilir metin parçalarını kurtarır
  static String _extractTextFromLegacyDoc(Uint8List bytes) {
    final buffer = StringBuffer();
    int consecutiveChars = 0;
    final currentWord = StringBuffer();

    for (int b in bytes) {
      // Yazdırılabilir ASCII ve Türkçe karakter aralıkları
      if ((b >= 32 && b <= 126) || b == 10 || b == 13) {
        currentWord.writeCharCode(b);
        consecutiveChars++;
      } else {
        if (consecutiveChars >= 3) {
          buffer.write(currentWord.toString());
          buffer.write(' ');
        }
        currentWord.clear();
        consecutiveChars = 0;
      }
    }
    if (consecutiveChars >= 3) {
      buffer.write(currentWord.toString());
    }

    final raw = buffer.toString();
    final cleanLines = raw.split('\n').map((l) => l.trim()).where((l) => l.length > 3);
    return cleanLines.join('\n');
  }
}
