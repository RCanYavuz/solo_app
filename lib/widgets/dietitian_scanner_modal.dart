// lib/widgets/dietitian_scanner_modal.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/system_memory.dart';
import '../core/services/gemini_service.dart';

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
      setState(() => _hata = "Görsel seçilemedi: $e");
    }
  }

  Future<void> _taramayiBaslat() async {
    final metin = _metinCtrl.text.trim();
    if (metin.isEmpty && _secilenFoto == null) {
      setState(() => _hata = "Lütfen diyet listenizin metnini yazın veya belgesini fotoğraflayın.");
      return;
    }

    setState(() {
      _tariyor = true;
      _hata = null;
    });

    final res = await GeminiService.diyetisyenMenusuAnalizEt(metin, imageBytes: _secilenFoto);

    if (!mounted) return;

    if (res == null) {
      setState(() {
        _tariyor = false;
        _hata = "Diyet listesi çözümlenemedi. İnternet bağlantınızı veya Gemini API anahtarınızı kontrol edin.";
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
      setState(() => _hata = "Lütfen geçerli bir toplam kalori değeri girin.");
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
          "📋 DİYETİSYEN PROGRAMI AKTİF EDİLDİ: $kalori kcal (P: ${protein}g, C: ${karb}g, F: ${yag}g)",
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
          "⚡ SİSTEM YAPAY ZEKA METABOLİK REÇETESİNE DÖNÜLDÜ",
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
                        'DİYETİSYEN MENÜ ENTEGRASYONU',
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
                'Kendi diyetisyeninizin verdiği beslenme listesini fotoğraf veya metin olarak tarayın. Sistem diyetisyen hedeflerinizi temel alır, ağır idman günlerinde kas kaybını önlemek için dinamik telafi ekler.',
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
                              ? 'DİYETİSYEN PLANI: [AKTİF]'
                              : 'DİYETİSYEN PLANI: [DEVRE DIŞI]',
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
                              : 'Şu an Sistem Yapay Zeka reçetesi devrede.',
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                    if (SystemMemory.diyetisyenListesiAktif)
                      TextButton.icon(
                        onPressed: _diyetisyeniDevreDisiBirak,
                        icon: const Icon(Icons.refresh, color: sysRed, size: 16),
                        label: const Text('İPTAL ET', style: TextStyle(color: sysRed, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Tarama & Yükleme Bölümü
              Text(
                'LİSTE YÜKLEME VE SİSTEM ÇÖZÜMLEME',
                style: GoogleFonts.orbitron(color: sysBlue, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
              const SizedBox(height: 8),

              // Görsel Seçim Butonları
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _tariyor ? null : () => _fotoSec(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt, color: sysBlue, size: 16),
                      label: const Text('KAMERAYLA ÇEK', style: TextStyle(color: sysBlue, fontSize: 11, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: sysBlue.withValues(alpha: 0.5)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _tariyor ? null : () => _fotoSec(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library, color: sysBlue, size: 16),
                      label: const Text('GALERİDEN SEÇ', style: TextStyle(color: sysBlue, fontSize: 11, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: sysBlue.withValues(alpha: 0.5)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
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
                      const Expanded(
                        child: Text(
                          'Diyetisyen belgesi / fotoğrafı eklendi.',
                          style: TextStyle(color: sysGreen, fontSize: 11, fontWeight: FontWeight.bold),
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
                  hintText: 'Diyetisyenin verdiği öğünleri yapıştırın veya not ekleyin (Örn: 2000 kcal, 140g protein, sabah yulaf+yumurta...)',
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
                    _tariyor ? 'SİSTEM ÇÖZÜMLÜYOR...' : 'SİSTEM METABOLİK TARAYICIYI BAŞLAT',
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
                'DİYETİSYEN HEDEFLERİNİ ONAYLA',
                style: GoogleFonts.orbitron(color: sysGold, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _makroGirdi('KALORİ (kcal)', _kaloriCtrl, sysGold),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _makroGirdi('PROTEİN (g)', _proteinCtrl, sysBlue),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _makroGirdi('KARB (g)', _karbCtrl, Colors.orangeAccent),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _makroGirdi('YAĞ (g)', _yagCtrl, Colors.purpleAccent),
                  ),
                ],
              ),

              // Öğün Dökümü Varsa Göster
              if (_tarananOgunler.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'TARANAN ÖĞÜN DÖKÜMÜ (${_tarananOgunler.length} ÖĞÜN)',
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
                              Text(og['ad'] ?? 'Öğün', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
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
                    'DİYETİSYEN LİSTESİNİ SİSTEME REÇETE ET',
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
