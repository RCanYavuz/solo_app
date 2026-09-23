// test/dietitian_scanner_widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solo_leveling_app/controllers/system_memory.dart';
import 'package:solo_leveling_app/widgets/dietitian_scanner_modal.dart';
import 'package:solo_leveling_app/screens/macro_dashboard_screen.dart';

import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:solo_leveling_app/core/document_parser.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    SystemMemory.appLanguage.value = 'tr';
    SystemMemory.boy = 180;
    SystemMemory.kilo = 80;
    SystemMemory.belCm = 84;
    SystemMemory.cinsiyet = 'erkek';
    SystemMemory.diyetisyenListesiAktif = false;
  });

  testWidgets('DietitianScannerModal render olur ve girdi alanları mevcuttur', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DietitianScannerModal(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('DİYETİSYEN MENÜ ENTEGRASYONU'), findsOneWidget);
    expect(find.text('DİYETİSYEN PLANI: [DEVRE DIŞI]'), findsOneWidget);
    expect(find.text('📄 PDF / WORD BELGESİ SEÇ (.pdf, .docx, .doc)'), findsOneWidget);
    expect(find.text('KAMERA'), findsOneWidget);
    expect(find.text('GALERİ / FOTO'), findsOneWidget);
    expect(find.text('DİYETİSYEN HEDEFLERİNİ ONAYLA'), findsOneWidget);
  });

  testWidgets('MacroDashboardScreen biyometrik US Navy kartı ve sliderları gösterir', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MacroDashboardScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('🧬 AVCI METABOLİK RAPORU (US NAVY)'), findsOneWidget);
    expect(find.text('YAĞ ORANI'), findsOneWidget);
    expect(find.text('YAĞSIZ KÜTLE (LBM)'), findsOneWidget);
    expect(find.text('BOY'), findsOneWidget);
    expect(find.text('BEL ÇEVRESİ'), findsOneWidget);
  });

  test('DocumentParser DOCX içeriğini ve XML etiketlerini temizleyip metin üretir', () {
    const mockXml = '''
<?xml version="1.0" encoding="UTF-8"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:body>
    <w:p><w:r><w:t>DİYETİSYEN GÜNLÜK BESLENME LİSTESİ</w:t></w:r></w:p>
    <w:p><w:r><w:t>Kahvaltı: 2 Haşlanmış Yumurta, 50g Lor Peyniri &amp; Yeşillik</w:t></w:r></w:p>
    <w:p><w:r><w:t>Öğle: 150g Tavuk Göğsü, 1 Kase Yoğurt</w:t></w:r></w:p>
  </w:body>
</w:document>
''';

    final archive = Archive();
    final xmlBytes = utf8.encode(mockXml);
    archive.addFile(ArchiveFile('word/document.xml', xmlBytes.length, xmlBytes));
    final docxBytes = Uint8List.fromList(ZipEncoder().encode(archive));

    final extracted = DocumentParser.extractTextFromDocx(docxBytes);

    expect(extracted, contains('DİYETİSYEN GÜNLÜK BESLENME LİSTESİ'));
    expect(extracted, contains('Kahvaltı: 2 Haşlanmış Yumurta, 50g Lor Peyniri & Yeşillik'));
    expect(extracted, contains('Öğle: 150g Tavuk Göğsü, 1 Kase Yoğurt'));
  });
}
