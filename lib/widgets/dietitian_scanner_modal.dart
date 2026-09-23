// lib/widgets/dietitian_scanner_modal.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/system_memory.dart';
import '../core/services/gemini_service.dart';
import '../core/document_parser.dart';
import '../core/translation_manager.dart';

class DietitianScannerModal extends StatefulWidget {
  const DietitianScannerModal({super.key});

  @override
  State<DietitianScannerModal> createState() => _DietitianScannerModalState();
}

class _DietitianScannerModalState extends State<DietitianScannerModal> {
  static const Color sysBlue = Color(0xFF38BDF8);
  static const Color sysDarkBg = Color(0xFF030712);
  static const Color sysGold = Color(0xFFB08D57);
  static const Color sysRed = Color(0xFFEF4444);
  static const Color sysGreen = Color(0xFF10B981);
  static const Color sysTextMuted = Color(0xFF94A3B8);

  final TextEditingController _metinCtrl = TextEditingController();
  final TextEditingController _kaloriCtrl = TextEditingController();
  final TextEditingController _proteinCtrl = TextEditingController();
  final TextEditingController _karbCtrl = TextEditingController();
  final TextEditingController _yagCtrl = TextEditingController();

  Uint8List? _secilenFoto;
  ParsedDocument? _secilenDokuman;
  bool _tariyor = false;
  String? _hata;
  String? _aiNot;
  List<Map<String, dynamic>> _tarananOgunler = [];

  @override
  void initState() {
    super.initState();
    if (SystemMemory.diyetisyenListesiAktif) {
      _kaloriCtrl.text = SystemMemory.diyetisyenBazKalori.toString();
      _proteinCtrl.text = SystemMemory.diyetisyenBazProtein.toString();
      _karbCtrl.text = SystemMemory.diyetisyenBazKarb.toString();
      _yagCtrl.text = SystemMemory.diyetisyenBazYag.toString();
      _tarananOgunler = List<Map<String, dynamic>>.from(SystemMemory.diyetisyenOgunleri);
    }
  }

  @override
  void dispose() {
    _metinCtrl.dispose();
    _kaloriCtrl.dispose();
    _proteinCtrl.dispose();
    _karbCtrl.dispose();
    _yagCtrl.dispose();
    super.dispose();
  }

  Future<void> _fotoSec(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: source, maxWidth: 1024, maxHeight: 1024);
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _secilenFoto = bytes;
          _hata = null;
        });
      }
    } catch (e) {
      setState(() => _hata = TranslationManager.isTurkish ? "Görsel seçilemedi: $e" : "Could not select image: $e");
    }
  }

  Future<void> _dokumanSec() async {
    try {
      final doc = await DocumentParser.pickDocument();
      if (doc != null) {
        setState(() {
          _secilenDokuman = doc;
          _secilenFoto = null;
          _hata = null;
          if (doc.extractedText != null && doc.extractedText!.isNotEmpty) {
            if (_metinCtrl.text.trim().isEmpty) {
              _metinCtrl.text = doc.extractedText!;
            } else {
              _metinCtrl.text = '${_metinCtrl.text}\n\n${TranslationManager.isTurkish ? '[BELGEDEN OKUNAN METİN]:' : '[EXTRACTED TEXT]:'}\n${doc.extractedText!}';
            }
          }
        });
      }
    } catch (e) {
      setState(() => _hata = TranslationManager.isTurkish ? "Belge seçilemedi: $e" : "Could not select document: $e");
    }
  }

  Future<void> _taramayiBaslat() async {
    final metin = _metinCtrl.text.trim();
    if (metin.isEmpty && _secilenFoto == null && _secilenDokuman == null) {
      setState(() => _hata = TranslationManager.isTurkish
          ? "Lütfen diyet listenizin metnini yazın veya PDF / Word / Fotoğraf belgesi yükleyin."
          : "Please enter your diet list text or upload a PDF / Word / Image file.");
      return;
    }

    setState(() {
      _tariyor = true;
      _hata = null;
    });

    Uint8List? bytesToSend = _secilenDokuman?.bytes ?? _secilenFoto;
    String? mimeType = _secilenDokuman?.mimeType ?? (_secilenFoto != null ? 'image/jpeg' : null);

    final res = await GeminiService.diyetisyenMenusuAnalizEt(
      metin,
      documentBytes: bytesToSend,
      mimeType: mimeType,
    );

    if (!mounted) return;

    if (res == null) {
      setState(() {
        _tariyor = false;
        _hata = TranslationManager.isTurkish
            ? "Diyet listesi çözümlenemedi. İnternet bağlantınızı veya Gemini API anahtarınızı kontrol edin."
            : "Could not decode diet list. Check your internet connection or Gemini API key.";
      });
      return;
    }

    setState(() {
      _tariyor = false;
      _kaloriCtrl.text = (res['toplamKalori'] ?? 2000).toString();
      _proteinCtrl.text = (res['toplamProtein'] ?? 140).toString();
      _karbCtrl.text = (res['toplamKarb'] ?? 220).toString();
      _yagCtrl.text = (res['toplamYag'] ?? 60).toString();
      _aiNot = res['notlar']?.toString();

      final ogunlerRaw = res['ogunler'] as List?;
      if (ogunlerRaw != null) {
        _tarananOgunler = ogunlerRaw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    });
  }

  void _kaydetVeUygula() {
    final kalori = int.tryParse(_kaloriCtrl.text.trim()) ?? 0;
    final protein = int.tryParse(_proteinCtrl.text.trim()) ?? 0;
    final karb = int.tryParse(_karbCtrl.text.trim()) ?? 0;
    final yag = int.tryParse(_yagCtrl.text.trim()) ?? 0;

    if (kalori <= 0) {
      setState(() => _hata = TranslationManager.isTurkish ? "Lütfen geçerli bir toplam kalori değeri girin." : "Please enter a valid total calorie value.");
      return;
    }

    SystemMemory.diyetisyenListesiniKaydet(
      kalori: kalori,
      protein: protein,
      karb: karb,
      yag: yag,
      ogunler: _tarananOgunler,
    );

    Navigator.pop(context, true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          TranslationManager.isTurkish
              ? "📋 DİYETİSYEN PROGRAMI AKTİF EDİLDİ: $kalori kcal (P: ${protein}g, C: ${karb}g, F: ${yag}g)"
              : "📋 DIETITIAN PROGRAM ACTIVATED: $kalori kcal (P: ${protein}g, C: ${karb}g, F: ${yag}g)",
          style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        backgroundColor: sysGreen,
      ),
    );
  }

  void _diyetisyeniDevreDisiBirak() {
    SystemMemory.diyetisyenListesiniSifirla();
    Navigator.pop(context, true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          TranslationManager.isTurkish
              ? "⚡ SİSTEM YAPAY ZEKA METABOLİK REÇETESİNE DÖNÜLDÜ"
              : "⚡ REVERTED TO SYSTEM AI METABOLIC PROTOCOL",
          style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        backgroundColor: sysBlue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: sysDarkBg,
        border: Border(top: BorderSide(color: sysGold.withValues(alpha: 0.6), width: 2)),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Başlık ve Kapatma Butonu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.assignment_turned_in, color: sysGold, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        TranslationManager.get('diet_scan_title'),
                        style: GoogleFonts.orbitron(
                          color: sysGold,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: sysTextMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                TranslationManager.get('diet_scan_desc'),
                style: const TextStyle(color: sysTextMuted, fontSize: 12, height: 1.4),
              ),
              const SizedBox(height: 16),

              // Aktiflik Durum Kartı
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: SystemMemory.diyetisyenListesiAktif
                      ? sysGold.withValues(alpha: 0.12)
                      : Colors.white.withValues(alpha: 0.04),
                  border: Border.all(
                    color: SystemMemory.diyetisyenListesiAktif ? sysGold : Colors.white12,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          SystemMemory.diyetisyenListesiAktif
                              ? TranslationManager.get('diet_scan_plan_active')
                              : TranslationManager.get('diet_scan_plan_disabled'),
                          style: GoogleFonts.orbitron(
                            color: SystemMemory.diyetisyenListesiAktif ? sysGold : sysTextMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          SystemMemory.diyetisyenListesiAktif
                              ? '${SystemMemory.diyetisyenBazKalori} kcal | P: ${SystemMemory.diyetisyenBazProtein}g | C: ${SystemMemory.diyetisyenBazKarb}g'
                              : TranslationManager.get('diet_scan_system_active'),
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                    if (SystemMemory.diyetisyenListesiAktif)
                      TextButton.icon(
                        onPressed: _diyetisyeniDevreDisiBirak,
                        icon: const Icon(Icons.refresh, color: sysRed, size: 16),
                        label: Text(TranslationManager.get('diet_scan_cancel_btn'), style: const TextStyle(color: sysRed, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Tarama & Yükleme Bölümü
              Text(
                TranslationManager.get('diet_scan_upload_sec'),
                style: GoogleFonts.orbitron(color: sysBlue, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
              const SizedBox(height: 8),

              // Belge ve Görsel Seçim Butonları
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _tariyor ? null : _dokumanSec,
                  icon: const Icon(Icons.description, color: sysDarkBg, size: 18),
                  label: Text(
                    TranslationManager.get('diet_scan_select_doc'),
                    style: const TextStyle(color: sysDarkBg, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: sysBlue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _tariyor ? null : () => _fotoSec(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt, color: sysTextMuted, size: 15),
                      label: Text(TranslationManager.get('diet_scan_camera'), style: const TextStyle(color: sysTextMuted, fontSize: 11, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _tariyor ? null : () => _fotoSec(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library, color: sysTextMuted, size: 15),
                      label: Text(TranslationManager.get('diet_scan_gallery_photo'), style: const TextStyle(color: sysTextMuted, fontSize: 11, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),

              if (_secilenDokuman != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: sysBlue.withValues(alpha: 0.12),
                    border: Border.all(color: sysBlue.withValues(alpha: 0.5)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _secilenDokuman!.isPdf
                            ? Icons.picture_as_pdf
                            : (_secilenDokuman!.isWord ? Icons.article : Icons.description),
                        color: _secilenDokuman!.isPdf ? sysRed : sysBlue,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _secilenDokuman!.fileName,
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${(_secilenDokuman!.bytes.length / 1024).toStringAsFixed(1)} KB • ${_secilenDokuman!.extension.toUpperCase()} ${TranslationManager.get('diet_scan_doc_label')}',
                              style: TextStyle(color: sysBlue.withValues(alpha: 0.8), fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: sysRed, size: 16),
                        onPressed: () => setState(() => _secilenDokuman = null),
                      ),
                    ],
                  ),
                ),
              ],

              if (_secilenFoto != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: sysGreen.withValues(alpha: 0.1),
                    border: Border.all(color: sysGreen.withValues(alpha: 0.4)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: sysGreen, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          TranslationManager.get('diet_scan_doc_added'),
                          style: const TextStyle(color: sysGreen, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: sysRed, size: 16),
                        onPressed: () => setState(() => _secilenFoto = null),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 10),

              // Metin Alanı
              TextField(
                controller: _metinCtrl,
                maxLines: 3,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: TranslationManager.get('diet_scan_hint'),
                  hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
                  contentPadding: const EdgeInsets.all(12),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2))),
                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: sysBlue)),
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 10),

              // Çözümle Butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _tariyor ? null : _taramayiBaslat,
                  icon: _tariyor
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: sysDarkBg))
                      : const Icon(Icons.auto_awesome, color: sysDarkBg, size: 18),
                  label: Text(
                    _tariyor ? TranslationManager.get('diet_scan_decoding_btn') : TranslationManager.get('diet_scan_start_btn'),
                    style: GoogleFonts.orbitron(color: sysDarkBg, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: sysGold,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                ),
              ),

              if (_hata != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: sysRed.withValues(alpha: 0.1),
                    border: Border.all(color: sysRed),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(_hata!, style: const TextStyle(color: sysRed, fontSize: 12)),
                ),
              ],

              if (_aiNot != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: sysGold.withValues(alpha: 0.08),
                    border: Border.all(color: sysGold.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: sysGold, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_aiNot!, style: const TextStyle(color: sysGold, fontSize: 11)),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),
              const Divider(color: Colors.white12),
              const SizedBox(height: 10),

              // Reçete Değerlerini Düzenleme & Onaylama
              Text(
                TranslationManager.get('diet_scan_confirm_title'),
                style: GoogleFonts.orbitron(color: sysGold, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _makroGirdi(TranslationManager.get('diet_scan_cal'), _kaloriCtrl, sysGold),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _makroGirdi(TranslationManager.get('diet_scan_pro'), _proteinCtrl, sysBlue),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _makroGirdi(TranslationManager.get('diet_scan_carb'), _karbCtrl, Colors.orangeAccent),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _makroGirdi(TranslationManager.get('diet_scan_fat'), _yagCtrl, Colors.purpleAccent),
                  ),
                ],
              ),

              // Öğün Dökümü Varsa Göster
              if (_tarananOgunler.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  TranslationManager.get('diet_scan_breakdown').replaceAll('{0}', _tarananOgunler.length.toString()),
                  style: GoogleFonts.orbitron(color: sysTextMuted, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                ..._tarananOgunler.map((og) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      border: Border.all(color: Colors.white10),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(og['ad'] ?? TranslationManager.get('diet_scan_meal_default'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                              if (og['detay'] != null)
                                Text(og['detay'], style: const TextStyle(color: sysTextMuted, fontSize: 11)),
                            ],
                          ),
                        ),
                        if (og['kalori'] != null)
                          Text('${og['kalori']} kcal', style: const TextStyle(color: sysGold, fontWeight: FontWeight.bold, fontSize: 11)),
                      ],
                    ),
                  );
                }),
              ],

              const SizedBox(height: 20),

              // Uygula ve Kaydet Butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _kaydetVeUygula,
                  icon: const Icon(Icons.check, color: sysDarkBg, size: 20),
                  label: Text(
                    TranslationManager.get('diet_scan_apply_btn'),
                    style: GoogleFonts.orbitron(color: sysDarkBg, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: sysGreen,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );

  }

  Widget _makroGirdi(String baslik, TextEditingController ctrl, Color renk) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(baslik, style: GoogleFonts.orbitron(color: renk, fontSize: 9, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: renk.withValues(alpha: 0.4))),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: renk)),
            filled: true,
            fillColor: const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
